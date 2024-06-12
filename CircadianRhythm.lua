local addonName = "CircadianRhythm"

local button = CreateFrame("Button", "MyGameTimeButton", UIParent)
button:SetSize(40, 40)
button:SetPoint("CENTER", 0, 0)
button:SetMovable(true)

local texture = button:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(button)

local function UpdateGameTimeTexture()
    local fake_hour = _G['EPOCH_GAME_TIME_HUMAN']
    if fake_hour then
        --print("Current Time of Day:", fake_hour) --Debug

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
    GameTooltip:SetOwner(button, "ANCHOR_TOP")
    GameTooltip:AddLine((_G['EPOCH_GAME_TIME_HUMAN'] or "Unknown"), 1, 1, 1)
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

button:RegisterEvent("ADDON_LOADED")

button:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == addonName then
        self:SetScript("OnUpdate", OnUpdate)
        self:SetScript("OnEnter", OnEnter)
        self:SetScript("OnLeave", OnLeave)
        self:SetScript("OnMouseDown", OnMouseDown)
        self:SetScript("OnMouseUp", OnMouseUp)
    end
end)
