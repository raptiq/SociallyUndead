local _, core = ...

local quintessenceItemId = 17333
local eternalQuintessenceItemId = 22754
local hourglassItemId = 19183
local onycloakItemId = 15138

core.addSimilarItemId(quintessenceItemId, eternalQuintessenceItemId)

local function checkItem(command)
    if command == "water" then
        core.showItemList(quintessenceItemId)
    elseif command == "sand" then
        core.showItemList(hourglassItemId)
    elseif command == "ony" then
        core.showItemList(onycloakItemId, "equipped")
    else
        local itemId = tonumber(command)
        if itemId then
            core.showItemList(itemId)
        else
            print("Invalid itemId " .. command)
        end
    end
end

local function printHelp()
    local commonCommands =
        [[Commands for the Socially Undead addon:
        /su check water -> Displays which players which have an (Eternal) Aqual Quintessence
        /su check sand -> Displays Hourglass Sand count for each player
        /su check ony -> Display whether each player has Onyxia Scale Cloak equipped
        /su check <itemId> -> Displays how many items with the given id each player has in their inventory
        ]]

    local officerCommands =
        [[/su addons -> Displays which players in raid have required addons installed
        /su durability -> Displays durability for players in raid
        /su ready -> Displays pre-raid attendance check including location and durability
        /su buffs -> WIP - Will display all relevant buffs before pull
        ]]

    if core.isOfficer() then
        print(commonCommands .. officerCommands)
    else
        print(commonCommands)
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
        core.showAddonInstalls()
    elseif core.startsWith(command, "check") then
        checkItem(string.sub(command, 7)) -- TODO: decouple this jank from command word length
    else
        print("The command " .. command .. " was not recognized.")
        printHelp()
    end
end

SLASH_SOCIALLYUNDEAD1 = "/sociallyundead"
SlashCmdList["SOCIALLYUNDEAD"] = sociallyundead

SLASH_SU1 = "/su"
SlashCmdList["SU"] = sociallyundead
