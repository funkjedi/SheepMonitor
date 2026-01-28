local addonName, SheepMonitor = ...

SheepMonitor = LibStub('AceAddon-3.0'):NewAddon(SheepMonitor, addonName, 'AceEvent-3.0', 'AceTimer-3.0')

_G['SheepMonitor'] = SheepMonitor

local L = LibStub('AceLocale-3.0'):GetLocale('SheepMonitor')

local LibAuraInfo = LibStub('LibAuraInfo-1.0')

-- LuaFormatter off
LibAuraInfo.auraInfo[118]     = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[28271]   = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[28272]   = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[61305]   = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[61721]   = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[61780]   = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[126819]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[161353]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[161354]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[161355]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[161372]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[383121]  = '60;1' -- adding mass polymorph
LibAuraInfo.auraInfo[3355]    = '60;1' -- fixing incorrect value
LibAuraInfo.auraInfo[115078]  = '40;1' -- adding ability_monk_paralysis
LibAuraInfo.auraInfo[460392]  = '60;1' -- updating polymorph value for TWW
-- LuaFormatter on

-- damage event types for CLEU break detection
local damageEventTypes = {
    ['SWING_DAMAGE'] = true,
    ['RANGE_DAMAGE'] = true,
    ['SPELL_DAMAGE'] = true,
    ['SPELL_PERIODIC_DAMAGE'] = true,
    ['SPELL_BUILDING_DAMAGE'] = true,
    ['ENVIRONMENTAL_DAMAGE'] = true,
    ['DAMAGE_SPLIT'] = true,
    ['DAMAGE_SHIELD'] = true,
}

local issecretvalue = issecretvalue or function()
    return false
end

function SheepMonitor:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New('SheepMonitorDatabase', {
        char = {
            monitorRaid = false,
            enableNotifier = true,
            enableRaid = true,
            enableChat = false,
            enableParty = false,
            enablePolymorphMessages = false,
            enableBreakMessages = true,
            enableBreakWarningMessages = false,
            enableAudibleBreak = true,
            audibleBreakSound = 'Sound\\Interface\\AlarmClockWarning3.wav',
            enableAudibleBreakWarning = false,
            audibleBreakWarningSound = 'Sound\\Interface\\RaidWarning.wav',
            enableOmniCC = false,
            enableQuartz = false,
            growUpwards = false,
        },
    })

    self:CreateInterfaceOptions()
    -- InterfaceOptionsFrame_OpenToCategory('SheepMonitor')

    if (self:IsClassic()) then
        LibAuraInfo.auraInfo[118] = '20;1'
        LibAuraInfo.auraInfo[12824] = '30;1'
        LibAuraInfo.auraInfo[12825] = '40;1'
        LibAuraInfo.auraInfo[12826] = '50;1'
        LibAuraInfo.auraInfo[28272] = '50;1'
    end

    if (self:IsCata()) then
        LibAuraInfo.auraInfo[118] = '50;1'
        LibAuraInfo.auraInfo[28272] = '50;1'
    end
end

function SheepMonitor:IsClassic()
    return WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
end

function SheepMonitor:IsCata()
    return WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
end

function SheepMonitor:OnEnable()
    self:RegisterEvent('UNIT_AURA')

    if self:IsClassic() then
        self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    end
end

function SheepMonitor:UNIT_AURA(event, unitTarget, updateInfo)
    local destGUID = UnitGUID(unitTarget)

    if updateInfo then
        self:HandleUnitAuraRetail(unitTarget, destGUID, updateInfo)
    else
        self:HandleUnitAuraClassic(unitTarget, destGUID)
    end
end

function SheepMonitor:HandleUnitAuraRetail(unitTarget, destGUID, updateInfo)
    if updateInfo.addedAuras then
        for _, aura in ipairs(updateInfo.addedAuras) do
            local spellId = aura.spellId

            -- guard against secret spellIds that can't be used as table keys
            if not issecretvalue(spellId) and self.trackableAuras[spellId] then
                if aura.sourceUnit == 'player' or (self.db.char.monitorRaid and UnitInRaid(aura.sourceUnit)) then
                    local sheepData = {
                        auraGUID = spellId .. destGUID,
                        auraInstanceID = aura.auraInstanceID,
                        sourceName = UnitName(aura.sourceUnit),
                        destGUID = destGUID,
                        destName = UnitName(unitTarget),
                        spellId = spellId,
                        spellName = aura.name,
                        texture = aura.icon,
                        timestamp = GetTime(),
                        duration = aura.duration,
                        expirationTime = aura.expirationTime,
                    }

                    self:AuraApplied(sheepData)
                end
            end
        end
    end

    if updateInfo.updatedAuraInstanceIDs then
        for _, instanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local updatedAuraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unitTarget, instanceID)

            if updatedAuraData then
                self:AuraUpdated(instanceID, updatedAuraData)
            end
        end
    end

    if updateInfo.removedAuraInstanceIDs then
        for _, instanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            local index, aura = SheepMonitor:GetAuraByInstanceID(instanceID)
            if index and aura then
                self:AuraRemoved(aura.destGUID, aura.spellId)
            end
        end
    end
end

function SheepMonitor:HandleUnitAuraClassic(unitTarget, destGUID)
    for spellId, texture in pairs(self.trackableAuras) do
        local auraData = SheepMonitor.GetUnitAuraBySpellID(unitTarget, spellId)

        if auraData then
            local sourceUnit = auraData.sourceUnit

            if sourceUnit == 'player' or (self.db.char.monitorRaid and UnitInRaid(sourceUnit)) then
                local existingIndex = self:UnitHasAura(destGUID, spellId)

                if not existingIndex then
                    local spellName, _, spellTexture = SheepMonitor.GetSpellInfo(spellId)
                    local sheepData = {
                        auraGUID = spellId .. destGUID,
                        sourceName = sourceUnit and UnitName(sourceUnit) or UnitName('player'),
                        destGUID = destGUID,
                        destName = UnitName(unitTarget),
                        spellId = spellId,
                        spellName = auraData.name or spellName,
                        texture = auraData.icon or spellTexture or texture,
                        timestamp = GetTime(),
                        duration = auraData.duration or LibAuraInfo:GetDuration(spellId),
                        expirationTime = auraData.expirationTime,
                    }

                    self:AuraApplied(sheepData)
                end
            end
        else
            local existingIndex, existingAura = self:UnitHasAura(destGUID, spellId)

            if existingIndex and existingAura then
                self:AuraRemoved(destGUID, spellId)
            end
        end
    end
end

function SheepMonitor:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2,
        spellId, spellName = CombatLogGetCurrentEventInfo()

    local isDamageEvent = damageEventTypes[eventType]
    local isAuraRemoved = eventType == 'SPELL_AURA_REMOVED'

    if not isDamageEvent and not isAuraRemoved then
        return
    end

    if isDamageEvent and self.watchForBreakers and self.watchForBreakers > 0 then
        if eventType == 'SWING_DAMAGE' then
            self:AuraBroken(destGUID, sourceName, 'Melee')
        else
            self:AuraBroken(destGUID, sourceName, spellName or 'Unknown')
        end
    end

    if isAuraRemoved then
        local _

        if spellId < 1 and spellName then
            _, _, _, _, _, _, spellId = SheepMonitor.GetSpellInfo(spellName)
        end

        spellId = spellId or 0

        if self.trackableAuras[spellId] then
            self:AuraRemoved(destGUID, spellId)
        end
    end
end

function SheepMonitor:POLYMORPH_APPLIED(aura)
    if self.db.char.enableOmniCC then
        self:ShowOmniCC(aura)
    end

    if self.db.char.enableQuartz then
        self:ShowQuartz(aura)
    end

    if self.db.char.enablePolymorphMessages then
        local message = L['WARNING_APPLIED']:format(aura.spellName, aura.destName)

        if self.db.char.enableRaid then
            self:ShowRaidWarning(message)
        end

        if self.db.char.enableChat then
            print(message)
        end

        if self.db.char.enableParty then
            self:SendAnnouncement(message)
        end
    end
end

function SheepMonitor:POLYMORPH_UPDATE(aura, remaining)
    if self.db.char.enableBreakWarningMessages and remaining < 6 then
        local message = L['WARNING_BREAK_INCOMING']:format(aura.spellName, remaining)

        if self.db.char.enableRaid then
            self:ShowRaidWarning(message, ChatTypeInfo['BATTLEGROUND_LEADER'])
        end

        if self.db.char.enableChat then
            print(message)
        end

        if self.db.char.enableParty then
            self:SendAnnouncement(message)
        end
    end

    if self.db.char.enableAudibleBreakWarning and remaining == 5 then
        self:PlaySoundFile(self.db.char.audibleBreakWarningSound)
    end
end

function SheepMonitor:POLYMORPH_REMOVED(aura)
    if self.db.char.enableOmniCC then
        self:HideOmniCC(aura)
    end

    if self.db.char.enableQuartz then
        self:HideQuartz(aura)
    end

    -- only play sound and show messages if the aura was broken early
    -- breakerName is set via CLEU (Classic), wasBroken is set via timer (Retail)
    if not aura.breakerName and not aura.wasBroken then
        return
    end

    if self.db.char.enableAudibleBreak then
        self:PlaySoundFile(self.db.char.audibleBreakSound)
    end

    if self.db.char.enableBreakMessages then
        local message = L['WARNING_BROKEN']:format(aura.spellName)

        if aura.breakerName then
            message = L['WARNING_BROKEN_BY']:format(aura.spellName, aura.breakerName, aura.breakerReason)
        end

        if self.db.char.enableRaid then
            self:ShowRaidWarning(message)
        end

        if self.db.char.enableChat then
            print(message)
        end

        if self.db.char.enableParty then
            self:SendAnnouncement(message)
        end
    end
end

function SheepMonitor:ShowRaidWarning(message, color)
    RaidBossEmoteFrame.slot1:Hide()
    RaidNotice_AddMessage(RaidBossEmoteFrame, message, color or ChatTypeInfo['RAID_BOSS_EMOTE'])
end

function SheepMonitor:SendAnnouncement(message)
    local chatType = false

    if GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE) > 0 then
        chatType = 'INSTANCE_CHAT'
    elseif IsInRaid() then
        chatType = 'RAID'
    elseif IsInGroup() then
        chatType = 'PARTY'
    end

    if chatType then
        SendChatMessage(message, chatType)
    end
end

function SheepMonitor:PlaySoundFile(file)
    local sounds

    if self:IsClassic() then
        sounds = {
            ['Sound\\Interface\\AlarmClockWarning3.wav'] = 'Sound\\Interface\\AlarmClockWarning3.ogg',
            ['Sound\\Interface\\RaidWarning.wav'] = 'Sound\\Interface\\RaidWarning.ogg',
        }
    else
        sounds = { ['Sound\\Interface\\AlarmClockWarning3.wav'] = 567458, ['Sound\\Interface\\RaidWarning.wav'] = 567397 }
    end

    if sounds[file] then
        file = sounds[file]
    end

    PlaySoundFile(file)
end
