--Main frame to display coordinates and map/instance IDs
local cordsFrame = CreateFrame("Frame", "MyConcordanceFrame", UIParent, "BackdropTemplate")
cordsFrame:SetSize(100, 50)  -- Frame size (width, height)
cordsFrame:SetPoint("CENTER") -- Default position
cordsFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
cordsFrame:SetBackdropColor(0, 0, 0, 0.8)  -- Background color (black with transparency)
cordsFrame:SetBackdropBorderColor(0, 0, 0)  -- Border color (black)

-- Text to display coordinates, map ID, and instance ID
local coordinateText = cordsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
coordinateText:SetPoint("TOPLEFT", cordsFrame, "TOPLEFT", 5, -5)  -- Align to the top left with some padding
coordinateText:SetJustifyH("LEFT")  -- Set horizontal justification to left

-- Function to update the displayed coordinates and IDs
local function UpdateCoordinateDisplay()
    local mapID = C_Map.GetBestMapForUnit("player") or 0  -- Default to 0 if invalid
    local position = C_Map.GetPlayerMapPosition(mapID, "player")

    local x = position and position.x or 0
    local y = position and position.y or 0
    local instanceID = select(8, GetInstanceInfo()) or 0

    -- Set text with whole numbers for X and Y, color white for numbers
    coordinateText:SetText(string.format(
        "|cffffff00X:|r |cffffffff%d|r  |cffffff00Y:|r |cffffffff%d|r\n|cffffff00MapID:|r |cffffffff%d|r\n|cffffff00InstanceID:|r |cffffffff%d|r",
        math.floor(x * 100), math.floor(y * 100), mapID, instanceID
    ))
end

-- Left-click to print coordinates in chat
cordsFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        local mapID = C_Map.GetBestMapForUnit("player") or 0  -- Default to 0 if invalid
        local position = C_Map.GetPlayerMapPosition(mapID, "player")

        local x = position and position.x or 0
        local y = position and position.y or 0
        local instanceID = select(8, GetInstanceInfo()) or 0

        print(string.format(
            "|cffffff00X:|r |cffffffff%d|r |cffffff00Y:|r |cffffffff%d|r |cffffff00Map ID:|r |cffffffff%d|r |cffffff00Instance ID:|r |cffffffff%d|r",
            math.floor(x * 100), math.floor(y * 100), mapID, instanceID
        ))
    end
end)

-- Makes the frame movable
cordsFrame:SetMovable(true)
cordsFrame:EnableMouse(true)
cordsFrame:RegisterForDrag("LeftButton")
cordsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
cordsFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

-- Update coordinates on frame update
cordsFrame:SetScript("OnUpdate", UpdateCoordinateDisplay)

-- Initialize the display
UpdateCoordinateDisplay()
