local _, core = ...

local quintessenceItemId = 17333
local eternalQuintessenceItemId = 22754
local hourglassItemId = 19183
local onyCloakItemId = 15138
local onyNeckItemId = 16309

local itemMap = {
    ["water"] = quintessenceItemId,
    ["sand"] = hourglassItemId,
    ["onyneck"] = onyNeckItemId,
    ["onycloak"] = onyCloakItemId
}

core.addSimilarItemId(quintessenceItemId, eternalQuintessenceItemId)

local function checkHelper(itemString, location)
    itemString = string.gsub(itemString, "^%s*(.-)%s*$", "%1")
    local items = {}
    local len = 0
    for item in string.gmatch(itemString, "%S+") do
        if itemMap[item] then
            table.insert(items, itemMap[item])
        else
            local itemId = tonumber(item)
            if itemId then
                table.insert(items, itemId)
            else
                print("Invalid itemId " .. item)
            end
        end
        len = len + 1
    end

    if len == 1 then
        core.showItemList(items[1], location)
    else
        core.showItemsList(items, location)
    end
end

local function printHelp()
    local commonCommands = {
        "Commands for the Socially Undead addon:",
        "/su check water -> Displays which players which have an (Eternal) Aqual Quintessence",
        "/su check sand -> Displays Hourglass Sand count for each player",
        "/su check onycloak -> Display whether each player has Onyxia Scale Cloak equipped",
        "/su check onyneck -> Display whether each player has Drakefire Amulet in their inventory",
        "/su check <itemId> -> Displays how many items with the given id each player has in their inventory"
    }

    local officerCommands = {
        "/su addons -> Displays which players in raid have required addons installed",
        "/su durability -> Displays durability for players in raid",
        "/su ready -> Displays pre-raid attendance check including location and durability",
        "/su buffs -> WIP - Will display all relevant buffs before pull",
        "/su worldbuffs -> Displays all worldbuffs and total additional dkp",
        "/su whisper -> Automatically whisper raid members that its their turn to loot for your current zone"
    }

    if core.isOfficer() then
        for i = 1, #officerCommands do
            print(officerCommands[i])
        end
    end

    for i = 1, #commonCommands do
        print(commonCommands[i])
    end
end

local function sociallyundead(command)
    local isOfficer = core.isOfficer()
    if command == "" or command == "help" then
        printHelp()
    elseif core.startsWith(command, "ready") and isOfficer then
        core.showReady()
    elseif core.startsWith(command, "export") and isOfficer then
        core.showExport()
    elseif core.startsWith(command, "durability") and isOfficer then
        core.showDurability()
    elseif core.startsWith(command, "addons") and isOfficer then
        core.showAddonInstalls()
    elseif core.startsWith(command, "buffs") and isOfficer then
        core.showBuffs()
    elseif core.startsWith(command, "worldbuffs") and isOfficer then
        core.showWorldBuffs()
    elseif core.startsWith(command, "whisper") and isOfficer then
        core.toggleLootWhisper()
    elseif core.startsWith(command, "check equipped") then
        local itemString = string.gsub(command, "check equipped", "")
        checkHelper(itemString, "equipped")
    elseif core.startsWith(command, "check") then
        local itemString = string.gsub(command, "check", "")
        checkHelper(itemString)
    else
        print("The command " .. command .. " was not recognized.")
        printHelp()
    end
end

SLASH_SOCIALLYUNDEAD1 = "/sociallyundead"
SlashCmdList["SOCIALLYUNDEAD"] = sociallyundead

SLASH_SU1 = "/su"
SlashCmdList["SU"] = sociallyundead
