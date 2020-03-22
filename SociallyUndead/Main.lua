local addonName, addonData = ...

local quintessenceItemId = 17333
local eternalQuintessenceItemId = 22754
local hourglassItemId = 19183
local onycloakItemId = 15138

addonData.addSimilarItemId(quintessenceItemId, eternalQuintessenceItemId)

local function checkItem(command)
    if command == "water" then
        addonData.showItemList(quintessenceItemId)
    elseif command == "sand" then
        addonData.showItemList(hourglassItemId)
    elseif command == "ony" then
        addonData.showItemList(onycloakItemId, "equipped")
    else
        local itemId = tonumber(command)
        if itemId then
            addonData.showItemList(itemId)
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
        [[/su attendance -> Displays which players are in raid and in kargath
        /su addons -> Displays which players in raid have required addons installed
        ]]

    if addonData.isOfficer() then
        print(commonCommands .. officerCommands)
    else
        print(commonCommands)
    end
end

local function sociallyundead(command)
    if command == "" or command == "help" then
        printHelp()
    elseif addonData.startsWith(command, "attendance") then
        print("This command is still being worked on")
    elseif addonData.startsWith(command, "addons") then
        addonData.showAddonInstalls()
    elseif addonData.startsWith(command, "buffs") then
        addonData.showAddonInstalls()
    elseif addonData.startsWith(command, "check") then
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
