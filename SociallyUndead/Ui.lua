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

    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:SetScript(
        "OnMouseDown",
        function(self, button)
            if button == "LeftButton" then
                self:StartMoving()
            end
        end
    )
    frame:SetScript("OnMouseUp", frame.StopMovingOrSizing)

    frame.text = frame:CreateFontString(nil, "ARTWORK")
    frame.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
    frame.text:SetPoint("TOP", 0, -5)
    frame.text:SetText(name)

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", 5, 5)

    local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    b:SetSize(48, 16)
    b:SetText("Export")
    b:SetPoint("TOPLEFT", 5, -5)
    b:SetScript(
        "OnClick",
        function()
            frame:Hide()
            core.createExportFrame(core.getExportString(cols, rows))
        end
    )

    local ScrollingTable = LibStub("ScrollingTable")
    local scrollTable = ScrollingTable:CreateST(cols, 16, 20, nil, frame)

    scrollTable.frame:SetPoint("Bottom", frame, "BOTTOM")
    scrollTable.frame:SetPoint("Left", frame, "LEFT")

    scrollTable:SetData(rows)

    return {frame = frame, table = scrollTable}
end

local function createPlayerFrame(name, cols, rows)
    if itemFrame then
        itemFrame.frame:Hide()
    end

    playerFrame = createFrameWithTable(name, cols, rows)
end

core.createPlayerFrame = createPlayerFrame

local function createItemFrame(name, cols, rows)
    if playerFrame then
        playerFrame.frame:Hide()
    end

    itemFrame = createFrameWithTable(name, cols, rows)
end

core.createItemFrame = createItemFrame

local function getExportString(cols, rows)
    exportString = ""
    for _, col in ipairs(cols) do
        exportString = exportString .. col.name .. ","
    end
    exportString = exportString .. "\n"

    for _, row in ipairs(rows) do
        for _, rowCol in ipairs(row.cols) do
            exportString = exportString .. tostring(rowCol.value) .. ","
        end
        exportString = exportString .. "\n"
    end
    return exportString
end

core.getExportString = getExportString

local function createExportFrame(text)
    if not ExportFrame then
        local f = CreateFrame("Frame", "ExportFrame", UIParent)
        f:SetPoint("CENTER")
        f:SetSize(700, 590)

        f:SetBackdrop(
            {
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
                edgeSize = 17,
                insets = {left = 8, right = 6, top = 8, bottom = 8}
            }
        )
        f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue

        -- Movable
        f:SetMovable(true)
        f:SetClampedToScreen(true)
        f:SetScript(
            "OnMouseDown",
            function(self, button)
                if button == "LeftButton" then
                    self:StartMoving()
                end
            end
        )
        f:SetScript("OnMouseUp", f.StopMovingOrSizing)

        -- Close Button
        local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", 5, 5)

        f.closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        f.closeBtn:SetPoint("CENTER", f.closeContainer, "TOPRIGHT", -14, -14)
        tinsert(UISpecialFrames, f:GetName()) -- Sets frame to close on "Escape"

        -- ScrollFrame
        local sf = CreateFrame("ScrollFrame", "ExportScrollFrame", ExportFrame, "UIPanelScrollFrameTemplate")
        sf:SetPoint("LEFT", 20, 0)
        sf:SetPoint("RIGHT", -32, 0)
        sf:SetPoint("TOP", 0, -20)
        sf:SetPoint("BOTTOM", 0, 160)

        -- -- Description
        -- f.desc = f:CreateFontString(nil, "OVERLAY")
        -- f.desc:SetPoint("TOPLEFT", sf, "BOTTOMLEFT", 10, -10);
        -- f.desc:SetText("|CFFAEAEDDExport below one at a time in order. Copy all html and paste into local .html file one after the other. DKP and Loot History often take a few seconds to generate and will lock your screen briefly. As a result they are limited to the most recent 200 entries for each. All tables will be tabbed for convenience.|r");
        -- f.desc:SetWidth(sf:GetWidth()-30)

        -- EditBox
        local eb = CreateFrame("EditBox", "ExportEditFrame", ExportScrollFrame)
        eb:SetSize(sf:GetSize())
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false) -- dont automatically focus
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript(
            "OnEscapePressed",
            function()
                f:Hide()
            end
        )
        sf:SetScrollChild(eb)

        -- Resizable
        f:SetResizable(true)
        f:SetMinResize(650, 500)

        local rb = CreateFrame("Button", "ExportBoxResizeButton", ExportFrame)
        rb:SetPoint("BOTTOMRIGHT", -6, 7)
        rb:SetSize(16, 16)

        rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

        rb:SetScript(
            "OnMouseDown",
            function(self, button)
                if button == "LeftButton" then
                    f:StartSizing("BOTTOMRIGHT")
                end
            end
        )
        rb:SetScript(
            "OnMouseUp",
            function(self, button)
                f:StopMovingOrSizing()
                self:GetHighlightTexture():Show()
                eb:SetWidth(sf:GetWidth())
            end
        )
        f:Show()
    end
    if text then
        ExportEditFrame:SetText(text)
    end
    ExportFrame:Show()
end

core.createExportFrame = createExportFrame
