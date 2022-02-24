local addonName, SheepMonitor = ...

SheepMonitor = LibStub('AceAddon-3.0'):NewAddon(SheepMonitor, addonName, 'AceEvent-3.0', 'AceTimer-3.0')

local L = LibStub('AceLocale-3.0'):GetLocale('SheepMonitor')

local LibAuraInfo = LibStub('LibAuraInfo-1.0')

-- LuaFormatter off
LibAuraInfo.auraInfo[118]    = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[28271]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[28272]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[61305]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[61721]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[61780]  = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[126819] = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[161353] = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[161354] = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[161355] = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[161372] = '60;1' -- updating polymorph value for BFA
LibAuraInfo.auraInfo[3355]   = '60;1' -- fixing incorrect value
LibAuraInfo.auraInfo[115078] = '40;1' -- adding ability_monk_paralysis
-- LuaFormatter on

local LibAuras = LibStub:GetLibrary('LibAuras')

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
end

function SheepMonitor:IsClassic()
    return select(1, GetBuildInfo()) < '8.0.0'
end

function SheepMonitor:OnEnable()
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end

function SheepMonitor:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2,
        spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()

    -- the classic always returns a spell id of zero so we
    -- resolve the spell id using the spell name instead
    if self:IsClassic() then
        spellId = select(7, GetSpellInfo(spellName))
    end

    --	if (eventType == 'SPELL_AURA_APPLIED' or eventType == 'SPELL_AURA_REFRESH') and sourceName == UnitName('player') then
    --		ATOM:Dump({ spellId = spellId, spellName = spellName })
    --	end

    -- watch for polymorphed mobs
    if (eventType == 'SPELL_AURA_APPLIED' or eventType == 'SPELL_AURA_REFRESH') and self.trackableAuras[spellId] then
        if (self.db.char.monitorRaid and UnitInRaid(sourceName)) or sourceName == UnitName('player') then
            local aura = {
                auraGUID = spellId .. destGUID, -- a unique identifier for this aura occurance
                sourceGUID = sourceGUID,
                sourceName = sourceName,
                destGUID = destGUID,
                destName = destName,
                spellId = spellId,
                spellName = spellName,
                texture = self.trackableAuras[spellId],
                timestamp = GetTime(),
                duration = LibAuraInfo:GetDuration(spellId, sourceGUID, destGUID),
            }

            if not self:IsClassic() and destGUID == UnitGUID('target') then
                aura.duration = select(5, LibAuras:UnitAura('target', spellId, 'PLAYER|HARMFUL')) or 0
            end

            self:AuraApplied(aura)
        end
    end

    -- watch for damage on our polymorph and record whoever breaks
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

    if self.watchForBreakers and self.watchForBreakers > 0 and damageEventTypes[eventType] then
        self:AuraBroken(destGUID, sourceName, eventType == 'SWING_DAMAGE' and 'Melee' or spellName)
    end

    -- watch for our polymorph to dissipate
    if eventType == 'SPELL_AURA_REMOVED' then
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
