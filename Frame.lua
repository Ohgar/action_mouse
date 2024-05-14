-- Define a table for your addon
ActionMouse = ActionMouse or {}

-- User preferences
ActionMouse.isClickCon = false
ActionMouse.isFullCon = false
ActionMouse.isSomeCon = false
ActionMouse.isAutoCon = false

function ActionMouse.updateControlVariables()
    ActionMouse.isClickCon = actionMouseSettings.isClickCon
    ActionMouse.isFullCon = actionMouseSettings.isFullCon
    ActionMouse.isSomeCon = actionMouseSettings.isSomeCon
    ActionMouse.isAutoCon = actionMouseSettings.isAutoCon
end

-- Load the player's preference
local loadSettingsFrame = CreateFrame("Frame")
loadSettingsFrame:RegisterEvent("PLAYER_LOGIN")
loadSettingsFrame:SetScript("OnEvent", function(self, event)
    -- Initialize actionMouseSettings if it doesn't exist
    actionMouseSettings = actionMouseSettings or {selectedCheckbox = 1}
    actionMouseSettings.sliders = actionMouseSettings.sliders or {x = 0, y = 150}

    -- Update control variables
    ActionMouse.updateControlVariables()
end)

ActionMouse.isActionMode = false -- Used to prevent right click stopping mouselook

local reticleButton = CreateFrame("Button", "ClickButton", UIParent, "SecureActionButtonTemplate")

-- When the player enters the game after character select
local enterWorldFrame = CreateFrame("Frame")
enterWorldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
enterWorldFrame:SetScript("OnEvent", function(self, event, ...)
    local clickX, clickY = getClickSliderValues() -- Update the slider values
    if ActionMouse.isClickCon then
        createClickReticle(clickX, clickY)
    end
end)

-- Action mode functions
function ActionMouse.toggleActionMode()
    if ActionMouse.isFullCon or ActionMouse.isSomeCon then
        if IsMouselooking() then
            actionModeStop()
        else
            actionModeStart()
        end
    end    
end

-- Define a global function that calls ActionMouse.toggleActionMode
function ToggleActionMode()
    ActionMouse.toggleActionMode()
end

function actionModeStart()
    MouselookStart()
    ActionMouse.isActionMode = true

    if ActionMouse.isFullCon or ActionMouse.isSomeCon then
        local cursorX, cursorY = GetCursorPosition() -- Update the cursor position
        createCursorReticle(cursorX, cursorY)
    end
end

function actionModeStop()
    MouselookStop()
    ActionMouse.isActionMode = false

    if ActionMouse.isFullCon or ActionMouse.isSomeCon then
        clearReticle()
    end
end

-- Update
local updateFrame = CreateFrame("Frame") 
updateFrame:SetScript("OnUpdate", function(self,elapsed)
    onUpdate()
end)

function onUpdate() -- Called every frame
    if not ActionMouse.isClickCon then
        rightClickWorkaround()
        uiPanelCheck()
    end
end

-- Workaround for right click causing MouselookStop()
function rightClickWorkaround()
    if ActionMouse.isActionMode and not IsMouselooking() then
        MouselookStart()
    end
end

-- Stops action mode when key UI is opened
function uiPanelCheck()
    if ActionMouse.isAutoCon then
        if getAllUIPanels() and ActionMouse.isActionMode then
            actionModeStop()
        elseif not getAllUIPanels() and not ActionMouse.isActionMode then
            actionModeStart()
        end
    end
    
    if ActionMouse.isSomeCon then
        if getAllUIPanels() and ActionMouse.isActionMode then
            actionModeStop()
            clearReticle()
		end
    end
end

-- Returns if any key UI is on screen
function getAllUIPanels()
    if (GetUIPanel("left") or GetUIPanel("right") or GetUIPanel("center")) then
        return true
    else
        return false
    end
end

function createClickReticle(xPos, yPos)
    -- If the reticleButton already exists, remove its current position
    if reticleButton then
        reticleButton:ClearAllPoints()
    end

    reticleButton:SetSize(15,15)
    reticleButton:SetPoint("CENTER", UIParent, "CENTER", xPos, yPos)
    reticleButton:SetNormalTexture("Interface\\AddOns\\ActionMouse\\action_mouse_reticle.png")
    reticleButton:SetScript("OnClick", MouselookStart)
end

function createCursorReticle(xPos, yPos)
    -- If the reticleButton already exists, remove its current position
    if reticleButton then
        reticleButton:ClearAllPoints()
    end

    -- Get the size and position of the UIParent frame
    local uiScale = UIParent:GetEffectiveScale()
    local uiCenterX, uiCenterY = UIParent:GetCenter()

    -- Calculate the cursor position relative to the center of the UIParent frame
    local cursorX = (xPos / uiScale) - uiCenterX
    local cursorY = (yPos / uiScale) - uiCenterY

    reticleButton:SetSize(25,25)
    reticleButton:SetPoint("CENTER", UIParent, "CENTER", cursorX, cursorY)
    reticleButton:SetNormalTexture("Interface\\AddOns\\ActionMouse\\action_mouse_reticle.png")
    reticleButton:Show()
end

function clearReticle()
    if reticleButton then
        reticleButton:ClearAllPoints()
        reticleButton:Hide() -- Hide the button
    end
end
