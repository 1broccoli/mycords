-- Initialize saved variables if they don't exist
if not MyCordsData then
    MyCordsData = {
        showMapID = true,  -- Default to true
        showInstanceID = true  -- Default to true
    }
end

-- Main frame to display coordinates and map/instance IDs
local cordsFrame = CreateFrame("Frame", "MyCordsFrame", UIParent, "BackdropTemplate")
cordsFrame:SetSize(100, 50)  -- Initial frame size (width, height)
cordsFrame:SetPoint("CENTER") -- Default position
cordsFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
cordsFrame:SetBackdropColor(0, 0, 0, 0.8)  -- Background color (black with transparency)
cordsFrame:SetBackdropBorderColor(0, 0, 0)  -- Border color

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
    local text = string.format("|cffffff00X:|r |cffffffff%d|r  |cffffff00Y:|r |cffffffff%d|r", 
        math.floor(x * 100), math.floor(y * 100))

    if MyCordsData.showMapID then
        text = text .. string.format("\n|cffffff00Map ID:|r |cffffffff%d|r", mapID)  -- Set Map ID text color to yellow
    end
    
    if MyCordsData.showInstanceID then
        text = text .. string.format("\n|cffffff00Instance ID:|r |cffffffff%d|r", instanceID)  -- Set Instance ID text color to yellow
    end

    coordinateText:SetText(text)

    -- Dynamically adjust frame width and height based on the text width and height
    local textWidth = coordinateText:GetStringWidth() + 10  -- Add some padding
    local textHeight = coordinateText:GetStringHeight() + 10  -- Add some padding
    cordsFrame:SetSize(textWidth, textHeight)
end

-- Left-click to print coordinates in chat, right-click to show settings
cordsFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        local mapID = C_Map.GetBestMapForUnit("player") or 0
        local position = C_Map.GetPlayerMapPosition(mapID, "player")

        local x = position and position.x or 0
        local y = position and position.y or 0
        local instanceID = select(8, GetInstanceInfo()) or 0

        -- Build the text to print based on checkbox states
        local text = string.format(
            "|cffffff00X:|r |cffffffff%d|r |cffffff00Y:|r |cffffffff%d|r",
            math.floor(x * 100), math.floor(y * 100)
        )

        if MyCordsData.showMapID then
            text = text .. string.format(" |cffffff00Map ID:|r |cffffffff%d|r", mapID)
        end

        if MyCordsData.showInstanceID then
            text = text .. string.format(" |cffffff00Instance ID:|r |cffffffff%d|r", instanceID)
        end

        -- Print the assembled text in chat
        print(text)
    elseif button == "RightButton" then
        if MyCordsSettingsFrame:IsShown() then
            MyCordsSettingsFrame:Hide()
        else
            MyCordsSettingsFrame:Show()
        end
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

-- Create a settings frame for checkbox options
local MyCordsSettingsFrame = CreateFrame("Frame", "MyCordsSettingsFrame", UIParent, "BackdropTemplate")
MyCordsSettingsFrame:SetSize(160, 70)  -- Frame size
MyCordsSettingsFrame:SetPoint("BOTTOM", cordsFrame, "TOP", 0, 5) -- Anchor it to the bottom of the main frame
MyCordsSettingsFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 4, edgeSize = 8,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
MyCordsSettingsFrame:SetBackdropColor(0, 0, 0, 0.8)  -- Background color
MyCordsSettingsFrame:SetBackdropBorderColor(0, 0, 0)  -- Border color
MyCordsSettingsFrame:Hide()  -- Hide settings frame on startup

-- Checkbox for showing/hiding MapID
local mapIDCheckbox = CreateFrame("CheckButton", "ShowMapIDCheckbox", MyCordsSettingsFrame, "ChatConfigCheckButtonTemplate")
mapIDCheckbox:SetPoint("TOPLEFT", 10, -10)
mapIDCheckbox.text = mapIDCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mapIDCheckbox.text:SetPoint("LEFT", mapIDCheckbox, "RIGHT", 5, 0)
mapIDCheckbox.text:SetText("|cffffff00Show|r |cffffffffMap ID|r")
mapIDCheckbox:SetChecked(MyCordsData.showMapID)
mapIDCheckbox:SetScript("OnClick", function(self)
    MyCordsData.showMapID = self:GetChecked()
    UpdateCoordinateDisplay()
end)

-- Checkbox for showing/hiding InstanceID
local instanceIDCheckbox = CreateFrame("CheckButton", "ShowInstanceIDCheckbox", MyCordsSettingsFrame, "ChatConfigCheckButtonTemplate")
instanceIDCheckbox:SetPoint("TOPLEFT", mapIDCheckbox, "BOTTOMLEFT", 0, -5)
instanceIDCheckbox.text = instanceIDCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
instanceIDCheckbox.text:SetPoint("LEFT", instanceIDCheckbox, "RIGHT", 5, 0)
instanceIDCheckbox.text:SetText("|cffffff00Show|r |cffffffffInstance ID|r")
instanceIDCheckbox:SetChecked(MyCordsData.showInstanceID)
instanceIDCheckbox:SetScript("OnClick", function(self)
    MyCordsData.showInstanceID = self:GetChecked()
    UpdateCoordinateDisplay()
end)

-- Function to update checkbox states from saved variables
local function UpdateCheckboxStates()
    if mapIDCheckbox and instanceIDCheckbox then
        mapIDCheckbox:SetChecked(MyCordsData.showMapID)
        instanceIDCheckbox:SetChecked(MyCordsData.showInstanceID)
    end
end

-- Load saved checkbox states when settings frame is shown
MyCordsSettingsFrame:SetScript("OnShow", UpdateCheckboxStates)

-- Save the checkbox states when the player logs out
local function MyCords_SaveVariables()
    MyCordsData.showMapID = mapIDCheckbox:GetChecked()
    MyCordsData.showInstanceID = instanceIDCheckbox:GetChecked()
end

-- Event handler for loading and saving variables
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "MyCords" then
        UpdateCheckboxStates()  -- Load checkbox states on addon load
    elseif event == "PLAYER_LOGOUT" then
        MyCords_SaveVariables()  -- Save checkbox states on logout
    end
end)
