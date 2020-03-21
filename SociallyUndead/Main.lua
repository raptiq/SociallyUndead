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
    print(
        [[Commands for the Socially Undead addon:
    /su -> Opens the addon settings
    /su check water -> Shows the players wich have an (Eternal) Aqual Quintessence
    /su check sand -> Shows how much Hourglass Sand players have
    /su check ony -> Shows the players which have the Onyxiascale Cloak equipped
    /su check <itemId> -> Shows how many items of this id players have in their inventory
    ]]
    )
end

local function sociallyundead(command)
    if command == "" then
        printHelp()
    elseif addonData.startsWith(command, "check") then
        checkItem(string.sub(command, 7))
    elseif command == "help" then
        printHelp()
    else
        print("The command " .. command .. " was not recognized.")
        printHelp()
    end
end

SLASH_SOCIALLYUNDEAD1 = "/sociallyundead"
SlashCmdList["SOCIALLYUNDEAD"] = sociallyundead

SLASH_SU1 = "/su"
SlashCmdList["SU"] = sociallyundead
