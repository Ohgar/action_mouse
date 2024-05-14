-- Create a menu frame
local menuFrame = CreateFrame("Frame", "ActionMouseMenu", InterfaceOptionsFramePanelContainer)
menuFrame.name = "Action Mouse"
InterfaceOptions_AddCategory(menuFrame)

-- Create a menu title
local menuTitle = menuFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
menuTitle:SetPoint("TOPLEFT", 16, -16)
menuTitle:SetText("/actionmouse")

-- Create a table to store the checkboxes
local checkBoxes = {}

-- unCheckAll()
local function uncheckAll()
    for _, checkBox in pairs(checkBoxes) do
        checkBox:SetChecked(false)
    end
end

-- createDescription()
local function createDescription(text, xPos, yPos)
    local descriptionFrame = CreateFrame("Frame", "ActionMouseDescription", menuFrame)
    descriptionFrame:SetSize(200, 50) -- Set the size of the frame
    descriptionFrame:SetPoint("TOPLEFT", menuTitle, "BOTTOMLEFT", xPos, yPos) -- Set the position of the frame
    descriptionFrame.text = descriptionFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    descriptionFrame.text:SetPoint("TOPLEFT", descriptionFrame, "TOPLEFT")
    descriptionFrame.text:SetJustifyH("LEFT") -- Align the text to the left
    descriptionFrame.text:SetText(text)
end

-- createCheckbox()
local function createCheckbox(text, xPos, yPos, index)
    local checkBoxFrame = CreateFrame("CheckButton", "ActionMouseCheckBox" .. index, menuFrame, "ChatConfigCheckButtonTemplate")
    checkBoxFrame:SetPoint("TOPLEFT", menuTitle, "BOTTOMLEFT", xPos, yPos)
    checkBoxFrame.Text:SetText(text)

    checkBoxFrame:SetScript("OnClick", function(self)
        uncheckAll()
        self:SetChecked(true)
        -- Save the selected checkbox index
        actionMouseSettings = actionMouseSettings or {}
        actionMouseSettings.selectedCheckbox = index

        -- Update actionMouseSettings
        actionMouseSettings.isClickCon = (index == 1)
        actionMouseSettings.isFullCon = (index == 2)
        actionMouseSettings.isSomeCon = (index == 3)
        actionMouseSettings.isAutoCon = (index == 4)
    end)

    -- Add the checkbox to the checkboxes table
    table.insert(checkBoxes, checkBoxFrame)
end

-- Initialize actionMouseSettings if it doesn't exist
actionMouseSettings = actionMouseSettings or {selectedCheckbox = 1}
actionMouseSettings.sliders = actionMouseSettings.sliders or {x = 0, y = 130}

-- createSlider()
local function createSlider(name, xPos, yPos, minVal, maxVal, step)
    local slider = CreateFrame("Slider", name, menuFrame, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", menuTitle, "BOTTOMLEFT", xPos, yPos)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    -- Set the default value
    local defaultValue = name == "Reticle X" and actionMouseSettings.sliders.x or actionMouseSettings.sliders.y
    slider:SetValue(defaultValue)

    -- Add text for the slider
    slider.Text:SetText(name)
    slider.Text:SetPoint("BOTTOM", slider, "TOP")

    -- Add text for the current value
    slider.Value = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slider.Value:SetPoint("TOP", slider, "BOTTOM")
    slider.Value:SetText(string.format("%.2f", defaultValue))

    slider:SetScript("OnValueChanged", function(self, value)
        self.Value:SetText(string.format("%.2f", value))
        -- Save the slider value
        if name == "Reticle X" then
            actionMouseSettings.sliders.x = value
        else
            actionMouseSettings.sliders.y = value
        end
    end)

    return slider
end

-- createReloadButton()
local function createReloadButton(xPos, yPos)
    local reloadButton = CreateFrame("Button", "ReloadUIButton", menuFrame, "UIPanelButtonTemplate")
    reloadButton:SetPoint("TOPLEFT", menuTitle, "BOTTOMLEFT", xPos, yPos)
    reloadButton:SetSize(100, 30) -- Set the size of the button
    reloadButton:SetText("Reload UI") -- Set the text of the button
    reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
end

-- MENU ITEMS
createCheckbox("Use Click Reticle (default)", -30, -30, 1)
local clickSliderX = createSlider("Reticle X", 250, -60, -200, 200, 1)
local clickSliderY = createSlider("Reticle Y", 450, -60, -200, 200, 1)
createDescription("The recommended way to use Action Mouse.\nSet reticle position with sliders.\nClick reticle to start mouselook.\nRight click to stop mouselook.\nCursor will alwayse be at reticle position.", 0, -50)

createCheckbox("Full Control (Keybind)", -30, -120, 2)
createDescription("Good if you care about cursor position and don't mind manually exiting mouselook.\nSet reticle to the cursor's position.\nSet keybind in Options>Keybindings>Action Mouse.\nToggle mouselook with keybind only.", 0, -140)

createCheckbox("Some Control (Keybind)", -30, -210, 3)
createDescription("Good if you care about cursor position but want easier access to UI.\nSet reticle to the cursor's position.\nMouselook ends when key UI is shown.\nDoes not work for all UI.\nSet keybind in Options>Keybindings>Action Mouse.", 0, -230)

createCheckbox("Auto", -30, -300, 4)
createDescription("Mouselook will always be on except when key UI is shown.\nNo reticle is used.\nGreat if you don't need the cursor in a specific position.", 0, -320)

createReloadButton(200, -400)
createDescription("Reload the UI to apply any changes.", 165, -440)

-- Load the player's preference
local loadSettingsFrame = CreateFrame("Frame")
loadSettingsFrame:RegisterEvent("ADDON_LOADED")
loadSettingsFrame:SetScript("OnEvent", function(self, event, addonName)
    -- Make sure the event is for this addon
    if addonName == "ActionMouse" then        
        -- If the user has made a selection, use that
        if actionMouseSettings.selectedCheckbox then
            uncheckAll()
            checkBoxes[actionMouseSettings.selectedCheckbox]:SetChecked(true)
        end
        -- Load the slider values
        clickSliderX:SetValue(actionMouseSettings.sliders.x)
        clickSliderY:SetValue(actionMouseSettings.sliders.y)
    end
end)

-- Function to get slider values
function getClickSliderValues()
    return clickSliderX:GetValue(), clickSliderY:GetValue()
end

-- Allow for a /command
SLASH_MYADDON1 = "/actionmouse"
SlashCmdList["MYADDON"] = function(msg)
    InterfaceOptionsFrame_OpenToCategory(menuFrame)
    InterfaceOptionsFrame_OpenToCategory(menuFrame) -- Run this twice to actually open the menu
end
