local addonName = "CircadianRhythm"
local settings = {}

-- Load settings from saved variables
if CircadianRhythmSettings then
    settings = CircadianRhythmSettings
else
    settings = {
        showGameTimeOnHover = true,
        use12HourFormat = true,
        showButton = true,
    }
end

-- Function to save settings
local function SaveSettings()
    CircadianRhythmSettings = settings
end

-- Create the button
local button = CreateFrame("Button", "MyGameTimeButton", UIParent)
button:SetSize(40, 40)
button:SetPoint("CENTER", 0, 0)
button:SetMovable(true)

local texture = button:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(button)

local function ConvertTo12HourFormat(hour)
    local ampm = "AM"
    if hour >= 12 and hour < 24 then
        ampm = "PM"
    end
    if hour == 0 or hour == 24 then
        hour = 12
    else
        hour = hour % 12
        if hour == 0 then
            hour = 12
        end
    end
    return hour, ampm
end

local function UpdateGameTimeTexture()
    local fake_hour = _G['EPOCH_GAME_TIME_HUMAN']
    if fake_hour then
        local texturePath
        if fake_hour == "Morning" or fake_hour == "Noon" or fake_hour == "Afternoon" or fake_hour == "Evening" then
            texturePath = "Interface\\AddOns\\" .. addonName .. "\\images\\day"
        elseif fake_hour == "Night" or fake_hour == "Midnight" or fake_hour == "Late Night" then
            texturePath = "Interface\\AddOns\\" .. addonName .. "\\images\\night"
        else
            texturePath = "Interface\\Icons\\inv_misc_gem_amethyst_02" -- Default texture (sun)
        end

        texture:SetTexture(texturePath)
    end
end

local function OnUpdate(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 1 then -- Check every second
        UpdateGameTimeTexture()
        self.elapsed = 0
    end
end

local function OnEnter()
    if not settings.showGameTimeOnHover then return end  -- Early exit if hovering is disabled

    local tooltipTitle = _G['EPOCH_GAME_TIME_HUMAN'] or "Game Time"
    local hour = _G['EPOCH_GAME_TIME'] or 0
    local displayTime

    if settings.use12HourFormat then
        local hour12, ampm = ConvertTo12HourFormat(hour)
        displayTime = hour12 .. " " .. ampm
    else
        displayTime = hour .. " hours" -- Display in military format
    end

    GameTooltip:SetOwner(button, "ANCHOR_TOP")
    GameTooltip:AddLine("|TInterface\\Icons\\inv_misc_pocketwatch_01:16|t |cffFFD700" .. tooltipTitle .. "|r", 1, 1, 1)
    GameTooltip:AddLine("|cFF87CEFACurrent Time: |r" .. displayTime, 0.7, 0.7, 0.9)
    GameTooltip:Show()
end

local function OnLeave()
    GameTooltip:Hide()
end

local function OnMouseDown(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end

local function OnMouseUp(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
    end
end

function GameTime_UpdateTooltip()
    -- title
    GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)

    GameTooltip:AddDoubleLine(
        "Game Time:",
        _G['EPOCH_GAME_TIME_HUMAN'],
        NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b
    )

    -- Use displayTime instead of EPOCH_GAME_TIME
    local hour = _G['EPOCH_GAME_TIME'] or 0
    local displayTime

    if settings.use12HourFormat then
        local hour12, ampm = ConvertTo12HourFormat(hour)
        displayTime = hour12 .. " " .. ampm
    else
        displayTime = hour .. ":00" -- Military format
    end

    GameTooltip:AddDoubleLine(
        "Epoch Time:",
        displayTime,
        NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b
    )

    -- realm time
    GameTooltip:AddDoubleLine(
        TIMEMANAGER_TOOLTIP_REALMTIME,
        GameTime_GetGameTime(true),
        NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b
    )

    -- local time
    GameTooltip:AddDoubleLine(
        TIMEMANAGER_TOOLTIP_LOCALTIME,
        GameTime_GetLocalTime(true),
        NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
        HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b
    )
end

-- Create Options Panel in Interface AddOns
local optionsPanel = CreateFrame("Frame", addonName .. "OptionsPanel", UIParent)
optionsPanel.name = addonName
InterfaceOptions_AddCategory(optionsPanel)

-- Checkbox for showing Game Time on hover
local hoverCheckbox = CreateFrame("CheckButton", addonName .. "ShowHoverCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
hoverCheckbox:SetPoint("TOPLEFT", 16, -16)

-- Set the label for the hover checkbox
local hoverLabel = hoverCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hoverLabel:SetPoint("LEFT", hoverCheckbox, "RIGHT", 4, 0)
hoverLabel:SetText("Show Game Time on Hover")

hoverCheckbox:SetChecked(settings.showGameTimeOnHover)
hoverCheckbox:SetScript("OnClick", function(self)
    settings.showGameTimeOnHover = self:GetChecked()
    SaveSettings() -- Save settings
end)

-- Checkbox for AM/PM or Military time format
local formatCheckbox = CreateFrame("CheckButton", addonName .. "Use12HourFormatCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
formatCheckbox:SetPoint("TOPLEFT", hoverCheckbox, "BOTTOMLEFT", 0, -8)

-- Set the label for the format checkbox
local formatLabel = formatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
formatLabel:SetPoint("LEFT", formatCheckbox, "RIGHT", 4, 0)
formatLabel:SetText("Use AM/PM Format")

formatCheckbox:SetChecked(settings.use12HourFormat)
formatCheckbox:SetScript("OnClick", function(self)
    settings.use12HourFormat = self:GetChecked()
    SaveSettings() -- Save settings
end)

-- Checkbox for showing/hiding the button
local buttonCheckbox = CreateFrame("CheckButton", addonName .. "ShowButtonCheckbox", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
buttonCheckbox:SetPoint("TOPLEFT", formatCheckbox, "BOTTOMLEFT", 0, -8)

-- Set the label for the button checkbox
local buttonLabel = buttonCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
buttonLabel:SetPoint("LEFT", buttonCheckbox, "RIGHT", 4, 0)
buttonLabel:SetText("Show Game Time Graphic")

buttonCheckbox:SetChecked(settings.showButton)
buttonCheckbox:SetScript("OnClick", function(self)
    settings.showButton = self:GetChecked()
    SaveSettings() -- Save settings
    if settings.showButton then
        button:Show() -- Show the button
    else
        button:Hide() -- Hide the button
    end
end)

button:RegisterEvent("ADDON_LOADED")

button:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == addonName then
        -- Load settings
        if CircadianRhythmSettings then
            settings = CircadianRhythmSettings
        else
            settings = {
                showGameTimeOnHover = true,
                use12HourFormat = true,
                showButton = true,
            }
        end

        -- Apply loaded settings
        hoverCheckbox:SetChecked(settings.showGameTimeOnHover)
        formatCheckbox:SetChecked(settings.use12HourFormat)
        buttonCheckbox:SetChecked(settings.showButton)

        -- Set scripts for button actions
        self:SetScript("OnUpdate", OnUpdate)
        self:SetScript("OnEnter", OnEnter)
        self:SetScript("OnLeave", OnLeave)
        self:SetScript("OnMouseDown", OnMouseDown)
        self:SetScript("OnMouseUp", OnMouseUp)

        -- Show or hide the button based on the setting
        if settings.showButton then
            button:Show()
        else
            button:Hide()
        end

        -- Initialize the game time texture
        UpdateGameTimeTexture()
    end
end)

-- Hook into ElvUI's Time tooltip
local function HookElvUITimeTooltip()
    if ElvUI and ElvUI:GetModule("DataTexts") then
        local dataText = ElvUI:GetModule("DataTexts"):GetDataText("Time")

        if dataText and dataText.OnEnter then
            local originalOnEnter = dataText.OnEnter
            dataText.OnEnter = function(self)
                originalOnEnter(self) -- Call the original function
                GameTime_UpdateTooltip() -- Call your custom tooltip function
                GameTooltip:Show() -- Ensure the tooltip is shown
            end
        end
    end
end

-- Call the function to hook into ElvUI's tooltip
HookElvUITimeTooltip()