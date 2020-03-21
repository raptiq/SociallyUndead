local addonName, addonData = ...

local playerFrame = nil
local itemFrame = nil

local function createFrameWithTable(name, cols, rows)
    local frame = CreateFrame("FRAME")
    frame.name = "SU_" .. name

    frame:SetSize(250, 420)
    frame:SetPoint("CENTER")
    frame:SetBackdrop(
        {
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
            tile = true,
            tileSize = 5,
            edgeSize = 2
        }
    )
    frame:SetBackdropColor(0, 0, 0, 1)
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    frame.text = frame:CreateFontString(nil, "ARTWORK")
    frame.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
    frame.text:SetPoint("TOP", 0, -5)
    frame.text:SetText(name)

    local b = CreateFrame("Button", "MyButton", frame, "UIPanelButtonTemplate")
    b:SetSize(120, 30)
    b:SetText("Close")
    b:SetPoint("BOTTOM", 0, 5)
    b:SetScript(
        "OnClick",
        function()
            frame:Hide()
        end
    )

    local ScrollingTable = LibStub("ScrollingTable")
    local scrollTable = ScrollingTable:CreateST(cols, 16, 20, nil, frame)

    scrollTable:SetData(rows)

    return {frame = frame, table = scrollTable}
end

local function createPlayerFrame(cols, rows)
    if itemFrame then
        itemFrame.frame:Hide()
    end

    if not playerFrame then
        playerFrame = createFrameWithTable("PlayerFrame", cols, rows)
    else
        playerFrame.table:SetData(rows)
        playerFrame.frame:Show()
    end
end

addonData.createPlayerFrame = createPlayerFrame

local function createItemFrame(name, cols, rows)
    if playerFrame then
        playerFrame.frame:Hide()
    end

    if not itemFrame then
        itemFrame = createFrameWithTable(name, cols, rows)
    else
        itemFrame.frame.text:SetText(name)
        itemFrame.table:SetData(rows)
        itemFrame.frame:Show()
    end
end

addonData.createItemFrame = createItemFrame
