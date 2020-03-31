local _, core = ...

----------------------------------------
-- options, targetlist and memberlist (order is prio)
----------------------------------------

core.isDebug = false

core.enableChat = true

core.targets = {"{rt8}", "{rt7}", "{rt3}", "{rt1}", "{rt5}", "{rt4}", "{rt2}", "{rt6}", "Hunters Mark"}

--------------------------
-- Memberlist processing
--------------------------

local function mergeArray(t1, t2)
    for _, v in ipairs(t2) do
        table.insert(t1, v)
    end
end

local function toSet(tab)
    local result = {}

    for index, value in ipairs(tab) do
        result[value] = true
    end
    return result
end

----------------------
-- Chat and Exorsus helpers
----------------------

local chatBuffer = {}

local function sendWhisperMessage(receiver, text)
    SendChatMessage(text, "WHISPER", nil, receiver)
end

core.sendWhisperMessage = sendWhisperMessage

local function sendChatMessage(text)
    text = "[Socially Undead]: " .. text
    if core.enableChat then
        if core.isDebug then
            print(text)
        else
            SendChatMessage(text, "RAID")
        end
    end

    chatBuffer[#chatBuffer + 1] = core.colorizeTextByRole(text)
end

core.sendChatMessage = sendChatMessage

local function setExRTNote(name, text)
    local index = 0
    for i = 1, #VExRT.Note.Black do
        if VExRT.Note.BlackNames[i] == name then
            index = i
            break
        end
    end

    if index == 0 then
        index = #VExRT.Note.Black + 1
    end

    VExRT.Note.Black[index] = text
    VExRT.Note.BlackNames[index] = name
    VExRT.Note.BlackLastUpdateTime[index] = time()
end

core.setExRTNote = setExRTNote

local function getExRTNote(name)
    for i = 1, #VExRT.Note.Black do
        if VExRT.Note.BlackNames[i] == name then
            return VExRT.Note.Black[i]
        end
    end

    return ""
end

core.getExRTNote = getExRTNote

local function flushChatBuffer()
    local str = table.concat(chatBuffer, "\n")
    chatBuffer = {}
    return str
end

core.flushChatBuffer = flushChatBuffer

------------------------------
-- Collection helpers
------------------------------

local function shallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

core.shallowCopy = shallowCopy

local function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

core.hasValue = hasValue

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0 -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

core.pairsByKeys = pairsByKeys

local function copyAndRemoveNotInRaid(raidMembers, memberlist)
    local copy = {}

    if core.isDebug then
        copy = core.shallowCopy(memberlist)
        return copy
    end

    for i, member in ipairs(memberlist) do
        for i, raidMember in ipairs(raidMembers) do
            if raidMember.name == member then
                copy[#copy + 1] = member
                break
            end
        end
    end

    return copy
end

core.copyAndRemoveNotInRaid = copyAndRemoveNotInRaid

local function tableCount(tab)
    local count = 0
    for _ in pairs(tab) do
        count = count + 1
    end
    return count
end

core.tableCount = tableCount

local function tableMerge(t1, t2)
    for _, v in ipairs(t2) do
        table.insert(t1, v)
    end

    return t1
end

core.tableMerge = tableMerge

local function tableMergeWithKeys(t1, t2)
    for k, v in ipairs(t2) do
        t1[k] = v
    end

    return t1
end

core.tableMergeWithKeys = tableMergeWithKeys

-----------------------
-- Game info helpers
-----------------------

local function getRaidMembers()
    local raidMembers = {}

    if not IsInRaid() then
        return raidMembers
    end

    for i = 1, 40 do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole =
            GetRaidRosterInfo(i)
        if name then
            raidMembers[#raidMembers + 1] = {name = name, class = class, zone = zone}
        end
    end

    return raidMembers
end

core.getRaidMembers = getRaidMembers

local function isMC()
    if core.isDebug == "MC" then
        return true
    end

    local instanceName = GetInstanceInfo()
    return instanceName == "Molten Core"
end

core.isMC = isMC

local function isBWL()
    if core.isDebug == "BWL" then
        return true
    end

    local instanceName = GetInstanceInfo()
    return instanceName == "Blackwing Lair"
end

core.isBWL = isBWL

---------------------------
-- Class / role coloring
---------------------------

local classColors = {
    ["Druid"] = "FF7D0A",
    ["Hunter"] = "A9D271",
    ["Mage"] = "40C7EB",
    ["Shaman"] = "F58CBA",
    ["Priest"] = "FFFFFF",
    ["Rogue"] = "FFF569",
    ["Warlock"] = "8787ED",
    ["Warrior"] = "C79C6E"
}

local roleToColor = {
    ["Druid"] = classColors.Druid,
    ["Druids"] = classColors.Druid,
    ["Feral"] = classColors.Druid,
    ["Feral-Druid"] = classColors.Druid,
    ["Ferals"] = classColors.Druid,
    ["Cat"] = classColors.Druid,
    ["Cats"] = classColors.Druid,
    ["Bear"] = classColors.Druid,
    ["Bears"] = classColors.Druid,
    ["Heal-Druid"] = classColors.Druid,
    ["Hunter"] = classColors.Hunter,
    ["Hunters"] = classColors.Hunter,
    ["Mage"] = classColors.Mage,
    ["Mages"] = classColors.Mage,
    ["Shaman"] = classColors.Shaman,
    ["Shamans"] = classColors.Shaman,
    ["Resto-Shaman"] = classColors.Shaman,
    ["Resto-Shamans"] = classColors.Shaman,
    ["Enhance"] = classColors.Shaman,
    ["Enhance-Shaman"] = classColors.Shaman,
    ["Enhance-Shamans"] = classColors.Shaman,
    ["Enhances"] = classColors.Shaman,
    ["Enhancement"] = classColors.Shaman,
    ["Enhancements"] = classColors.Shaman,
    ["Ele"] = classColors.Shaman,
    ["Ele-Shaman"] = classColors.Shaman,
    ["Eles"] = classColors.Shaman,
    ["Elemental"] = classColors.Shaman,
    ["Elementals"] = classColors.Shaman,
    ["Priest"] = classColors.Priest,
    ["Priests"] = classColors.Priest,
    ["Heal-Priest"] = classColors.Priest,
    ["Heal-Priests"] = classColors.Priest,
    ["Shadow-Priest"] = classColors.Priest,
    ["Shadow-Priests"] = classColors.Priest,
    ["Rogue"] = classColors.Rogue,
    ["Rogues"] = classColors.Rogue,
    ["Sword-Rogue"] = classColors.Rogue,
    ["Sword-Rogues"] = classColors.Rogue,
    ["Dagger-Rogue"] = classColors.Rogue,
    ["Dagger-Rogues"] = classColors.Rogue,
    ["Warlock"] = classColors.Warlock,
    ["Warlocks"] = classColors.Warlock,
    ["Warrior"] = classColors.Warrior,
    ["Warriors"] = classColors.Warrior,
    ["Tank"] = classColors.Warrior,
    ["Tank-Warrior"] = classColors.Warrior,
    ["Tanks"] = classColors.Warrior,
    ["Fury"] = classColors.Warrior,
    ["Fury-Warrior"] = classColors.Warrior,
    ["Orc-Fury-Warrior"] = classColors.Warrior,
    ["Non-Orc-Fury-Warrior"] = classColors.Warrior,
    ["Furys"] = classColors.Warrior,
    ["Furies"] = classColors.Warrior
}

local function colorize(text, color)
    return "|cFF" .. color .. text .. "|r"
end

local function colorizeWordByRole(word)
    if roleToColor[word] then
        return colorize(word, roleToColor[word])
    end

    return word
end

local function colorizeTextByRole(text)
    return string.gsub(text, "%S+", colorizeWordByRole)
end

core.colorizeTextByRole = colorizeTextByRole

local function colorizePlayer(player)
    local _, playerClass = UnitClass(player)
    local r, g, b, _ = GetClassColor(playerClass)

    return {
        r = r,
        g = g,
        b = b,
        a = 1
    }
end

core.colorizePlayer = colorizePlayer

local function printColor(text, color)
    if not color then
        color = "96a9eb"
    end

    print("\124cff" .. color .. "[SociallyUndead]: " .. text .. "\124r")
end

core.printColor = printColor

-- strip server name eg Raptiq-Blauemeux
local function getPlayerName(name)
    local splits = core.splitString(name, "-")
    return splits[1]
end

core.getPlayerName = getPlayerName

-- get rank index of given player
local function getGuildRankIndex(player)
    local name, rank

    if IsInGuild() then
        local guildSize, _, _ = GetNumGuildMembers()

        for i = 1, tonumber(guildSize) do
            name, _, rank = GetGuildRosterInfo(i)
            name = getPlayerName(name)
            if name == player then
                return rank + 1 -- https://wow.gamepedia.com/API_GetGuildRosterInfo
            end
        end
    end
    return false
end

-- check player's officer status by seeing if they can speak in officer chat
local function isOfficer()
    if IsInGuild() then
        local curPlayerRank = getGuildRankIndex(UnitName("player"))
        if curPlayerRank then
            return C_GuildInfo.GuildControlGetRankFlags(curPlayerRank)[4]
        end
    end
    return false
end

core.isOfficer = isOfficer

------------------
-- Misc stuff
------------------

-- useful for debugging
function dumpTable(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dumpTable(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

core.dumpTable = dumpTable

function round(number, decimals)
    return (("%%.%df"):format(decimals)):format(number)
end

core.round = round

local function callback(duration, callback)
    local newFrame = CreateFrame("Frame")
    newFrame:SetScript(
        "OnUpdate",
        function(self, elapsed)
            duration = duration - elapsed
            if duration <= 0 then
                callback()
                newFrame:SetScript("OnUpdate", nil)
            end
        end
    )
end

core.callback = callback

local function splitString(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end

    local t = {}

    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end

    return t
end

core.splitString = splitString

local function startsWith(str, start)
    return str:sub(1, #start) == start
end

core.startsWith = startsWith

local function getNpcId(guid)
    local _, _, _, _, _, npcId = strsplit("-", guid)
    return tonumber(npcId)
end

core.getNpcId = getNpcId

local function isEmpty(maybeEmpty)
    return maybeEmpty == nil or maybeEmpty == ""
end

core.isEmpty = isEmpty

local bossIds = {
    10184, -- Onyxia
    12118, -- Lucifron
    12056, -- Geddon
    12057, -- Garr
    12259, -- Gehennas
    11988, -- Golemagg
    11982, -- Magmadar
    12018, -- Domo
    11502, -- Ragnaros
    12264, -- Shazzrah
    12098, -- Sulfuron
    12017, -- Broodlord
    14020, -- Chromaggus
    14601, -- Ebonroc
    11983, -- Firemaw
    11981, -- Flamegor
    11583, -- Nefarian
    12435, -- Razorgore
    13020, -- Vael
    15516, -- Sartura
    15727, -- Cthun
    15276, -- Veklor
    15275, -- Veknilash
    15510, -- Fankriss
    15511, -- Lord Kri
    15517, -- Ouro
    15509, -- Huhuran
    15543, -- Yauj
    15263, -- Skeram
    15544, -- Vem
    15299, -- Viscidus
    15956, -- Anub'Rekhan
    15932, -- Gluth
    16060, -- Gothik
    15953, -- Faerlina
    15931, -- Grobbulus
    15936, -- Heigan
    16062, -- Mograine
    16061, -- Razuvious
    15990, -- KelThuzad
    16065, -- Blaumeux
    16011, -- Loatheb
    15952, -- Maexxna
    15954, -- Noth
    16028, -- Patchwerk
    15989, -- Sapphiron
    16063, -- Zeliek
    15928, -- Thaddius
    16064 -- Korthazz
}

local function isBoss(npcId)
    return core.hasValue(bossIds, npcId)
end

core.isBoss = isBoss
