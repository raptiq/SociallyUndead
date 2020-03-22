local _, core = ...

local commandDelimiter = "\1"

local lootlist = {} -- String encoded NAME:GUID
local lootlistMap = {}
local playerAddonData = {}
local itemTrackingTable = {}
local similarItemIds = {}
local addonMessagePrefix = "SU"

local events = {}
local addonMessageHandlers = {}

local checkableAddons = {"SociallyUndead", "MonolithDKP", "Details_TinyThreat", "DBM-Core"}

-----------------
-- Protocol
-----------------

local function buildMessage(command, message)
    local msg = command
    if message then
        msg = msg .. commandDelimiter .. message
    end
    return msg
end

local function sendAddonMessage(command, message)
    C_ChatInfo.SendAddonMessage(addonMessagePrefix, buildMessage(command, message), "RAID")
end

local function sendAddonWhisper(command, message, targetPlayer)
    C_ChatInfo.SendAddonMessage(addonMessagePrefix, buildMessage(command, message), "WHISPER", targetPlayer)
end

local function splitByDelimiter(message, delimiter)
    local split = core.splitString(message, delimiter)
    return split[1], split[2]
end

local function parseMessage(message)
    return splitByDelimiter(message, commandDelimiter)
end

-----------------------------
-- addonMessageHandlers table
-----------------------------

-- str format: addon:version,addon:version
function addonMessageHandlers:DISCOVER_ADDONS(sender)
    local message = ""

    for _, addonName in ipairs(checkableAddons) do
        loaded, _ = IsAddOnLoaded(addonName)
        message = message .. addonName .. ":" .. tostring(loaded) .. "," -- todo: figure out if we can get addon version #
    end

    sendAddonWhisper("REPORT_ADDONS", message, sender)
end

function addonMessageHandlers:REPORT_ADDONS(sender, message)
    local addons = core.splitString(message, ",")

    local data = {}

    for _, addonRow in ipairs(addons) do
        local addonName, addonVersion = splitByDelimiter(addonRow, ":")
        table.insert(data, {["addon"] = addonName, version = addonVersion})
    end
    playerAddonData[sender] = data
end

function addonMessageHandlers:LOOT_DETECTED(sender, message)
    local guid, itemLink = splitByDelimiter(message, ":")
    if lootlistMap[guid] then
        local _, itemId = splitByDelimiter(itemLink, ":")

        local hasItemValue = false
        for index, value in ipairs(lootlistMap[guid].loot) do
            local _, itemLinkId = splitByDelimiter(itemLink, ":")

            if itemLinkId == itemId then
                hasItemValue = true
            end
        end

        if not hasItemValue then
            table.insert(lootlistMap[guid].loot, itemLink)
        end
    else
        lootlistMap[guid] = {player = "?", loot = {itemLink}}
    end
end

function addonMessageHandlers:DISCOVER_ITEM(sender)
    local location, itemId = splitByDelimiter(message, ":")
    itemId = tonumber(itemId)
    local itemCount = 0
    if location == "equipped" then
        if IsEquippedItem(itemId) then
            itemCount = 1
        end
    else
        itemCount = GetItemCount(itemId, false)
        if similarItemIds[itemId] then
            for i, v in ipairs(similarItemIds[itemId]) do
                itemCount = itemCount + GetItemCount(v, false)
            end
        end
    end

    local item = Item:CreateFromItemID(itemId)
    item:ContinueOnItemLoad(
        function()
            local itemName, itemLink = GetItemInfo(itemId)

            local raidIndex = UnitInRaid(sender)
            local _, rank = GetRaidRosterInfo(raidIndex) -- 1 = promoted, 2 = raid leader

            if rank ~= 0 then
                core.printColor(sender .. " inspected you for " .. itemLink)
            end
            sendAddonWhisper("REPORT_INSPECTION", itemCount, sender)
        end
    )
end

function addonMessageHandlers:REPORT_INSPECTION(sender, itemCount)
    table.insert(itemTrackingTable, {player = sender, quantity = itemCount})
end

function addonMessageHandlers:CAN_LOOT(sender, text)
    if lootlist[text] then
        lootlist[text] = lootlist[text] + 1
    else
        lootlist[text] = 1

        core.callback(
            1,
            function()
                local creatureName, createGuid = splitByDelimiter(text, ":")
                local _, mlPlayerId = GetLootMethod()
                local playerIsMasterLooter = mlPlayerId == 0
                local npcId = core.getNpcId(creatureGuid)

                if lootlist[text] > 1 then
                    lootlistMap[creatureGuid] = {player = "Multiple players", loot = {}}
                elseif lootlist[text] == 1 then
                    lootlistMap[creatureGuid] = {player = sender, loot = {}}

                    local skinningTargetIds = {
                        11671, -- Core hound
                        11673, -- Ancient Core Hound
                        12461, --Death Talon Overseer
                        12460, --Death Talon Wyrmguard
                        12467, --Death Talon Captain
                        12465, --Death Talon Wyrmkin
                        12463, --Death Talon Flamescale
                        12464, --Death Talon Seether
                        12468 --Death Talon Hatcher
                    }

                    if core.hasValue(skinningTargetIds, npcId) then
                        core.printColor(sender .. " can loot" .. creatureName)

                        if playerIsMasterLooter then
                            core.sendWhisperMessage(sender, "Please loot " .. creatureName)
                        end
                    end
                end
            end
        )
    end
end

----------------
-- events table
----------------

function events:CHAT_MSG_ADDON(prefix, text, channel, sender, target)
    if prefix ~= addonMessagePrefix or channel == "SAY" or channel == "YELL" or channel == "GUILD" or not IsInRaid() then
        return
    end

    local command, message = parseMessage(text)
    message = message or "nil"

    local handler = addonMessageHandlers[command]
    if not handler then
        return
    end

    sender = core.getPlayerName(sender)
    handler(self, sender, message)
end

function events:PLAYER_LOGIN()
    C_ChatInfo.RegisterAddonMessagePrefix(addonMessagePrefix)
end

function events:LOOT_OPENED()
    if not IsInRaid() then
        return
    end
    local guid = UnitGUID("target")

    if not guid or not UnitIsDead("target") then
        return
    end

    if not lootlistMap[guid] then
        lootlistMap[guid] = {player = "?", loot = {}}
    end

    for i = 1, GetNumLootItems() do
        if LootSlotHasItem(i) then
            local itemLink = GetLootSlotLink(i)
            if itemLink then
                local _, _, _, _, rarity = GetLootSlotInfo(i)

                if rarity >= GetLootThreshold() then
                    sendAddonMessage("LOOT_DETECTED", guid .. ":" .. itemLink)
                end
            end
        end
    end
end

function events:UPDATE_MOUSEOVER_UNIT()
    if not IsInRaid() then
        return
    end
    local unitGuid = UnitGUID("mouseover")

    if not UnitIsDead("mouseover") or not lootlistMap[unitGuid] then
        return
    end

    GameTooltip:AddLine("Lootable by " .. lootlistMap[unitGuid].player)

    if next(lootlistMap[unitGuid].loot) then
        local hasLoot, _ = CanLootUnit(unitGuid)

        if hasLoot then
            table.foreach(
                lootlistMap[unitGuid].loot,
                function(k, v)
                    GameTooltip:AddLine(v)
                end
            )
        else
            lootlistMap[unitGuid].loot = {}
        end
    end
    GameTooltip:Show()
end

local blackList = {
    -- 17877, 18871, 18870, 18868, 18867, 18869, --shadowburn
    -- 172, 25311, 11672,	6223, 11671, 6222, 7648, --corruption
    -- 14323, 14324, 14325, 1130, --huntersmark
    1978,
    13549,
    13551,
    13552,
    13553,
    13554,
    13555,
    25295, --serpentsting
    5570,
    24974,
    24975,
    24976,
    24977, --insect swarm
    16511,
    17347,
    17348, --hemorrhage
    8921,
    8924,
    9835,
    9834,
    8926,
    8925,
    8928,
    8927,
    9833,
    8929, --moonfire
    12294,
    21551,
    21552,
    21553, --mortal strike
    -- 15286, --vampiric embrace
    3034,
    14279,
    14280, --viper sting
    3043,
    14277,
    14276,
    14275, --scorpid sting
    2835,
    2837,
    11357,
    11358,
    25347 --deadly poison - only works when boss is targeted while poison is applied
    -- 702, 1108, 6205, 7646, 11707, 11708, --curse of weakness
}

function events:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGuid, spellId)
    local targetGuid = UnitGUID("target")

    if targetGuid and core.hasValue(blackList, spellId) then
        local healthPercent = UnitHealth("target") / UnitHealthMax("target")
        local npcId = core.getNpcId(targetGuid)
        local onyxia = 10184
        if healthPercent > 0.05 and npcId ~= onyxia and core.isBoss(npcId) then
            if not core.isAllowed(UnitName("player"), spellId) then
                local spellName = GetSpellInfo(spellId)
                core.sendChatMessage("Used " .. spellName .. " on a boss")
            end
        end
    end

    if not IsInRaid() then
        return
    end
    local dowseRuneSpellId = 21358

    if unitTarget == "player" and spellId == dowseRuneSpellId then
        core.sendChatMessage("I have doused a rune!")
    end
end

function events:COMBAT_LOG_EVENT_UNFILTERED()
    if not IsInRaid() then
        return
    end
    local _, eventName, _, _, _, _, _, destGuid, destName = CombatLogGetCurrentEventInfo()
    local isCreature = core.startsWith(destGuid, "Creature")
    if eventName ~= "UNIT_DIED" or not isCreature then
        return
    end

    core.callback(
        1,
        function()
            local hasLoot, _ = CanLootUnit(destGuid)

            if hasLoot and IsInRaid() then
                sendAddonMessage("CAN_LOOT", destName .. ":" .. destGuid)
                return
            end
        end
    )
end

-------------
-- API
-------------

local function addSimilarItemId(itemId, similarItemId)
    local similarIds = similarItemIds[itemId]
    if not similarIds then
        similarItemIds[itemId] = {}
        similarIds = similarItemIds[itemId]
    end

    similarIds[#similarIds + 1] = similarItemId
end

core.addSimilarItemId = addSimilarItemId

local function tableFindPlayer(tab, name)
    for index, value in ipairs(tab) do
        if value.player == name then
            return value
        end
    end

    return nil
end

function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

local function showAddonInstalls()
    if not IsInRaid() then
        return
    end

    local playerName, _ = UnitName("player")

    sendAddonMessage("DISCOVER_ADDONS")

    core.callback(
        1,
        function()
            local cols = {
                {["name"] = "Name", ["width"] = 75}
            }
            local emptyAddonCols = {}

            for _, name in ipairs(checkableAddons) do
                table.insert(cols, {["name"] = name, ["width"] = 75})
                table.insert(emptyAddonCols, {["name"] = name, value = "MISSING"})
            end

            local players = core.getRaidMembers()
            local data = {}

            for i, val in pairs(players) do
                local color = core.colorizePlayer(val.name)
                local playerCols = {
                    {value = val.name, color = color}
                }

                local playerData = playerAddonData[val.name]
                if playerData then
                    for _, addonName in ipairs(checkableAddons) do
                        for _, aData in ipairs(playerData) do
                            if aData.addon == addonName then
                                table.insert(playerCols, {value = tostring(aData.version)})
                            end
                        end
                    end
                else
                    playerCols = core.tableMerge(playerCols, emptyAddonCols)
                end

                table.insert(data, {cols = playerCols})
            end

            core.createPlayerFrame("Player Addons", cols, data)
            playerAddonData = {}
        end
    )
end

core.showAddonInstalls = showAddonInstalls

local function showItemList(itemId, location)
    if not IsInRaid() then
        return
    end

    sendAddonMessage("DISCOVER_ITEM", location or "inventory" .. ":" .. itemId)

    core.callback(
        1,
        function()
            local cols = {
                {["name"] = "Player", ["width"] = 120, ["align"] = "CENTER"},
                {["name"] = "Quantity", ["width"] = 80, ["align"] = "CENTER"}
            }

            local players = core.getRaidMembers()
            local data = {}

            for i, val in pairs(players) do
                local playerData = tableFindPlayer(itemTrackingTable, val.name)
                local color = core.colorizePlayer(val.name)

                if not playerData then
                    playerData = {player = val.name, quantity = "?"}
                end

                table.insert(
                    data,
                    {
                        cols = {
                            {value = val.name, color = color},
                            {value = playerData.quantity}
                        }
                    }
                )
            end

            local item = Item:CreateFromItemID(itemId)
            item:ContinueOnItemLoad(
                function()
                    local itemName, itemLink = GetItemInfo(itemId)
                    core.createItemFrame(itemName, cols, data)
                    itemTrackingTable = {}
                end
            )
        end
    )
end

core.showItemList = showItemList

------------------------
-- Register to events
------------------------

local frame = CreateFrame("FRAME", "SU_EventFrame")

frame:SetScript(
    "OnEvent",
    function(self, event, ...)
        events[event](self, ...)
    end
)

for k, v in pairs(events) do
    frame:RegisterEvent(k)
end
