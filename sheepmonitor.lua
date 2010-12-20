
local LibAuraInfo = LibStub('LibAuraInfo-1.0')
LibAuraInfo.auraInfo[28271] = '50;1'
LibAuraInfo.auraInfo[28272] = '50;1'
LibAuraInfo.auraInfo[61305] = '50;1'
LibAuraInfo.auraInfoPvP[28271] = 10
LibAuraInfo.auraInfoPvP[28272] = 10
LibAuraInfo.auraInfoPvP[61305] = 10

local L = LibStub('AceLocale-3.0'):GetLocale('SheepMonitor')


SheepMonitor = DongleStub('Dongle-1.2'):New('SheepMonitor')
function SheepMonitor:Initialize()
	self.db = self:InitializeDB('SheepMonitorDatabase', {
		char = {
			enableNotifier = true,
			enableRaid = true,
			enableChat = false,
			enableParty = false,
			enableBreakMessages = true,
			enableBreakWarningMessages = true,
			enableAudibleBreak = true,
			audibleBreakSound = 'Sound\\Interface\\AlarmClockWarning3.wav',
			enableAudibleBreakWarning = false,
			audibleBreakWarningSound = 'Sound\\Interface\\RaidWarning.wav',
			enableOmniCC = false,
		}
	})
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	self:CreateInterfaceOptions()
	--InterfaceOptionsFrame_OpenToCategory('SheepMonitor')
end


local polymorphAuras = {
	[118] = 'Interface\\Icons\\Spell_Nature_Polymorph',         -- sheep
	[28271] = 'Interface\\Icons\\Ability_Hunter_Pet_Turtle',    -- turtle
	[28272] = 'Interface\\Icons\\Spell_Magic_PolymorphPig',     -- pig
	[61305] = 'Interface\\Icons\\Achievement_Halloween_Cat_01', -- cat
	[61721] = 'Interface\\Icons\\Spell_Magic_PolymorphRabbit',  -- rabbit
	[51514] = 'Interface\\Icons\\Spell_Shaman_Hex',             -- hex
	[76780] = 'Interface\\Icons\\Spell_Shaman_BindElemental',   -- bind elemental
	[9484] = 'Interface\\Icons\\Spell_Nature_Slow',             -- shackle undead
	[2637] = 'Interface\\Icons\\Spell_Nature_Sleep',            -- hibernate
}
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

function SheepMonitor:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool = select(1, ...)
	if (eventType == 'SPELL_AURA_APPLIED' or eventType == 'SPELL_AURA_REFRESH') and sourceName == UnitName('player') then
		if polymorphAuras[spellId] then
			self.polymorph = {
				destGUID = destGUID,
				destName = destName,
				spellId = spellId,
				spellName = spellName,
				texture = polymorphAuras[spellId],
				timestamp = GetTime(),
				duration = 50,
			}
			if destGUID == UnitGUID('target') then
				self.polymorph.duration = select(6, UnitAura('target', spellName, nil, 'PLAYER|HARMFUL'))
			else
				-- if target was switch before the cast was completed use LibAuraInfo to get a best guess for duration
				-- NOTE: LibAuraInfo doesn't account for the duration variance of the different spell levels
				self.polymorph.duration = LibAuraInfo:GetDuration(spellId, sourceGUID, destGUID)
			end
			self:POLYMORPH_APPLIED()
			self:ScheduleRepeatingTimer('SHEEPMONITOR_TIMER', function()
				SheepMonitor.polymorph.remaining = SheepMonitor.polymorph.duration - floor(GetTime() - SheepMonitor.polymorph.timestamp)
				if SheepMonitor.polymorph.remaining > 0 then
					SheepMonitor:POLYMORPH_UPDATE()
				end
			end, 1)
			self:ScheduleRepeatingTimer('SHEEPMONITOR_PRECISE_TIMER', function()
				SheepMonitor.polymorph.remainingRaw = SheepMonitor.polymorph.duration - (GetTime() - SheepMonitor.polymorph.timestamp)
				if SheepMonitor.polymorph.remainingRaw > 0 then
					SheepMonitor:POLYMORPH_UPDATE_PRECISE()
				end
			end, 0.1)
		end
	end
	-- watch for damage on our polymorph and record whoever breaks
	if damageEventTypes[eventType] and self.polymorph and self.polymorph.destGUID == destGUID then
		if self.polymorph.auraRemoved and not self.polymorph.breakerName then
			self.polymorph.breakerName = sourceName
			self.polymorph.breakerReason = eventType == 'SWING_DAMAGE' and 'Melee' or spellName
		end
	end
	-- watch for our polymorph to dissipate
	if eventType == 'SPELL_AURA_REMOVED' then
		if polymorphAuras[spellId] and self.polymorph and self.polymorph.destGUID == destGUID then
			-- delay clearing up the polymorph so we can check who broken our sheep
			self:ScheduleTimer('SHEEPMONITOR_BREAKER_WATCH', function()
				SheepMonitor:POLYMORPH_REMOVED()
				SheepMonitor.polymorph = nil
			end, 0.1)
			self:CancelTimer('SHEEPMONITOR_TIMER')
			self:CancelTimer('SHEEPMONITOR_PRECISE_TIMER')
			self.polymorph.auraRemoved = true
		end
	end
end

function SheepMonitor:POLYMORPH_APPLIED()
	if self.db.char.enableNotifier then
		self:ShowNotifier()
	end
	if self.db.char.enableOmniCC then
		self:ShowOmniCC()
	end
end

function SheepMonitor:POLYMORPH_UPDATE()
	if self.db.char.enableNotifier then
		self:UpdateNotifierCountdown()
	end
	if self.db.char.enableBreakWarningMessages and self.polymorph.remaining < 6 then
		local message = L['WARNING_BREAK_INCOMING']:format(self.polymorph.spellName, self.polymorph.remaining)
		if self.db.char.enableRaid then
			RaidBossEmoteFrame.slot1:Hide()
			RaidNotice_AddMessage(RaidBossEmoteFrame, message, ChatTypeInfo["BATTLEGROUND_LEADER"])
		end
		if self.db.char.enableChat then
			print(message)
		end
	end
	if self.db.char.enableAudibleBreakWarning and self.polymorph.remaining == 5 then
		PlaySoundFile(self.db.char.audibleBreakWarningSound)
	end
end

function SheepMonitor:POLYMORPH_UPDATE_PRECISE()
	if self.db.char.enableNotifier then
		self:UpdateNotifierStatusBar()
	end
end

function SheepMonitor:POLYMORPH_REMOVED()
	if self.db.char.enableNotifier then
		self:HideNotifier()
	end
	if self.db.char.enableOmniCC then
		self:HideOmniCC()
	end
	if self.db.char.enableAudibleBreak then
		PlaySoundFile(self.db.char.audibleBreakSound)
	end

	local message = L['WARNING_BROKEN']:format(self.polymorph.spellName)
	if self.polymorph.breakerName then
		message = L['WARNING_BROKEN_BY']:format(self.polymorph.spellName, self.polymorph.breakerName, self.polymorph.breakerReason)
	end
	if self.db.char.enableRaid then
		RaidBossEmoteFrame.slot1:Hide()
		RaidNotice_AddMessage(RaidBossEmoteFrame, message, ChatTypeInfo["RAID_BOSS_EMOTE"])
	end
	if self.db.char.enableChat then
		print(message)
	end
	if self.db.char.enableParty then
		local chatType = false
		if GetRealNumRaidMembers() > 0 then
			chatType = "RAID"
		elseif GetNumRaidMembers() > 0 then
			chatType = "BATTLEGROUND"
		elseif GetNumPartyMembers() > 0 then
			chatType = "PARTY"
		end
		if chatType then
			SendChatMessage(message, chatType)
		end
	end
end

function SheepMonitor:PLAYER_ENTERING_WORLD()
	if self.db.char.enableNotifier then
		self:HideNotifier()
	end
	if self.db.char.enableOmniCC then
		self:HideOmniCC()
	end
	self:CancelTimer('SHEEPMONITOR_TIMER')
	self:CancelTimer('SHEEPMONITOR_PRECISE_TIMER')
	self.polymorph = nil
end

