local addonName, addonData = ...

local function GameTooltip_OnTooltipSetItem(tooltip)
	local itemName, itemLink = tooltip:GetItem()
	if not itemName or not itemLink then return; end
	
	local _, _, _, _, _, itemType = GetItemInfo(itemLink)

	local _, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId,
		  linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", itemLink)
          
	if itemType ~= "Armor" and itemType ~= "Weapon" and itemType ~= "Quest" and itemType ~= "Miscellaneous" and itemType ~= "Trade Goods" then
		return
	end

	itemId = tonumber(itemId)

    if addonData.lootDb[itemId] then
        local itemInfo = addonData.lootDb[itemId]
        
        tooltip:AddLine(" ")
        tooltip:AddLine("|cFF00FF00SU Loot Info|r")
        tooltip:AddLine("Prio: " .. addonData.colorizeTextByRole(itemInfo.role))
        tooltip:AddLine("Min Bid: |cFFA330C9" ..  itemInfo.dkp .. " DKP|r")
            
        if (itemInfo.note ~= nil and itemInfo.note ~= "") then
            tooltip:AddLine("Notes: " .. itemInfo.note)
        end
    end
end

GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)

ItemRefTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)