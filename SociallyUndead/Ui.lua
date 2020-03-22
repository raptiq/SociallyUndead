local _, core = ...

local playerFrame = nil
local itemFrame = nil

local function createFrameWithTable(name, cols, rows)
    local frame = CreateFrame("FRAME")
    frame.name = "SU_" .. name

    width = 32 -- size of scrollbar
    for _, val in ipairs(cols) do
        width = width + val.width
    end

    frame:SetSize(width, 380)
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

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", 5, 5)

    local ScrollingTable = LibStub("ScrollingTable")
    local scrollTable = ScrollingTable:CreateST(cols, 16, 20, nil, frame)

    scrollTable.frame:SetPoint("Bottom", frame, "BOTTOM")
    scrollTable:SetData(rows)

    return {frame = frame, table = scrollTable}
end

local function createPlayerFrame(name, cols, rows)
    if itemFrame then
        itemFrame.frame:Hide()
    end

    if not playerFrame then
        playerFrame = createFrameWithTable(name, cols, rows)
    else
        playerFrame.table:SetData(rows)
        playerFrame.frame:Show()
    end
end

core.createPlayerFrame = createPlayerFrame

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

core.createItemFrame = createItemFrame
