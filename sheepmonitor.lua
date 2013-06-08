
local L = LibStub('AceLocale-3.0'):GetLocale('SheepMonitor')


SheepMonitor = LibStub('AceAddon-3.0'):NewAddon('SheepMonitor', 'AceEvent-3.0', 'AceTimer-3.0')
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
		}
	})

	-- restore the notifiers save position
	if self.db.char.notifierFramePosition and SheepMonitorNotifierFrame then
		SheepMonitorNotifierFrame:ClearAllPoints()
		SheepMonitorNotifierFrame:SetPoint(unpack(self.db.char.notifierFramePosition))
	end

	self:CreateInterfaceOptions()
	--InterfaceOptionsFrame_OpenToCategory('SheepMonitor')
end

function SheepMonitor:OnEnable()
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
end



do
	local auraEventTypes = {
		['SPELL_AURA_APPLIED'] = true,
		['SPELL_AURA_REFRESH'] = true,
	}
	local auraBrokenEventTypes = {
		['SPELL_AURA_REMOVED'] = true,
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
		local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool = select(1, ...)

		-- watch for polymorphed mobs
		if auraEventTypes[eventType] and SheepMonitor.Aura.trackable[spellId] then
			if sourceName == UnitName('player') or (self.db.char.monitorRaid and UnitInRaid(sourceName)) then
				local aura = SheepMonitor.AuraWatcher:Add(...)
				self:POLYMORPH_APPLIED(aura);
			end
		end
		-- watch for our polymorph to dissipate
		if auraBrokenEventTypes[eventType] and SheepMonitor.Aura.trackable[spellId] then
			SheepMonitor.AuraWatcher:Broken(...)
		end
		-- watch for damage on our polymorph and record whoever breaks
		if damageEventTypes[eventType] and self.watchForBreakers and self.watchForBreakers > 0 then
			SheepMonitor.AuraWatcher:Breaker(...)
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
			self:ShowRaidWarning(message, ChatTypeInfo["BATTLEGROUND_LEADER"])
		end
		if self.db.char.enableChat then
			print(message)
		end
		if self.db.char.enableParty then
			self:SendAnnouncement(message)
		end
	end
	if self.db.char.enableAudibleBreakWarning and remaining == 5 then
		PlaySoundFile(self.db.char.audibleBreakWarningSound)
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
		PlaySoundFile(self.db.char.audibleBreakSound)
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
	RaidNotice_AddMessage(RaidBossEmoteFrame, message, color or ChatTypeInfo["RAID_BOSS_EMOTE"])
end

function SheepMonitor:SendAnnouncement(message)
	local chatType = false
	if IsInRaid() then
		chatType = "RAID"
	elseif GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE) > 0 then
		chatType = "BATTLEGROUND"
	elseif IsInGroup() then
		chatType = "PARTY"
	end
	if chatType then
		SendChatMessage(message, chatType)
	end
end



