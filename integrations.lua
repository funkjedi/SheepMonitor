local addonName, SheepMonitor = ...

function SheepMonitor:ShowQuartz(aura)
    if aura and IsAddOnLoaded('Quartz') then
        local Mirror = LibStub('AceAddon-3.0'):GetAddon('Quartz3'):GetModule('Mirror')

        Mirror.ExternalTimers[aura.destName .. ' (' .. aura.spellName .. ')'] = {
            startTime = aura.timestamp,
            endTime = aura.timestamp + aura.duration,
            icon = aura.texture,
            color = { 1, 0, 0 },
            spellid = aura.spellId,
            spellname = aura.spellName,
            expires = aura.timestamp + aura.duration,
            cooldown = false,
            spelltype = 'combatlog',
        }

        Mirror:SendMessage('Quartz3Mirror_UpdateCustom')
    end
end

function SheepMonitor:HideQuartz(aura)
    if aura and IsAddOnLoaded('Quartz') then
        local Mirror = LibStub('AceAddon-3.0'):GetAddon('Quartz3'):GetModule('Mirror')

        for k, v in pairs(Mirror.ExternalTimers) do
            if (tostring(v.spellid) == tostring(aura.spellId)) and (v.spelltype == 'combatlog') then
                Mirror.ExternalTimers[k] = nil
                Mirror:SendMessage('Quartz3Mirror_UpdateCustom')
            end
        end
    end
end

-- logic copied from Dominos
local function GetActionBarButtonFrame(id)
    if id <= 12 then
        return _G['ActionButton' .. id]
    elseif id <= 24 then
        return nil
    elseif id <= 36 then
        return _G['MultiBarRightButton' .. (id - 24)]
    elseif id <= 48 then
        return _G['MultiBarLeftButton' .. (id - 36)]
    elseif id <= 60 then
        return _G['MultiBarBottomRightButton' .. (id - 48)]
    elseif id <= 72 then
        return _G['MultiBarBottomLeftButton' .. (id - 60)]
    end
    return nil
end

function SheepMonitor:ShowOmniCC(aura)
    if aura and IsAddOnLoaded('OmniCC') then
        for i = 1, 120 do
            local spellId = select(2, GetActionInfo(i))

            if spellId == aura.spellId then
                local button = GetActionBarButtonFrame(i)

                if button then
                    local timer = OmniCC.Timer:Get(button) or OmniCC.Timer:New(button)
                    timer:Start(aura.timestamp, aura.duration)
                end
            end
        end
    end
end

function SheepMonitor:HideOmniCC(aura)
    if aura and IsAddOnLoaded('OmniCC') then
        for i = 1, 120 do
            local spellId = select(2, GetActionInfo(i))

            if spellId == aura.spellId then
                local button = GetActionBarButtonFrame(i)

                if button then
                    local timer = OmniCC.Timer:Get(button)
                    if timer and timer.enabled then
                        timer:Stop()
                    end
                end
            end
        end
    end
end
