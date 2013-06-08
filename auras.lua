

SheepMonitor.AuraWatcher = {}
SheepMonitor.AuraWatcher.auras = {}

function SheepMonitor.AuraWatcher:Add(...)
	local aura = SheepMonitor.Aura:New(...)
	local index = self:UnitHasAura(aura.unitGUID, aura.spellId)
	if index then
		self:Remove(index)
	end
	table.insert(self.auras, aura)
	return aura;
end

function SheepMonitor.AuraWatcher:Remove(index)
	local aura = SheepMonitor.AuraWatcher.auras[index]
	if aura then
		aura.notifier:Stop()
		table.remove(SheepMonitor.AuraWatcher.auras, index)
	end
end

function SheepMonitor.AuraWatcher:UnitHasAura(unitGUID, spellId)
	for index,aura in ipairs(self.auras) do
		if destGUID == aura.unitGUID and spellId == aura.spellId then
			return index,aura
		end
	end
end

function SheepMonitor.AuraWatcher:Broken(...)
	local _, _, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName = select(1, ...)
	local index, aura = self:UnitHasAura(destGUID, spellId)
	if index then
		-- we only need to watch damage in the combat logs during the brief moment the timer is up
		-- the flag must be a counter as it's possible that multiple timers are up at once
		self.watchForBreakers = self.watchForBreakers and self.watchForBreakers + 1 or 1
		-- delay removal of the aura so we can check who the breaker was
		SheepMonitor:ScheduleTimer(function()
			SheepMonitor.AuraWatcher.watchForBreakers = SheepMonitor.AuraWatcher.watchForBreakers - 1
			SheepMonitor.AuraWatcher:Remove(index)
			SheepMonitor:POLYMORPH_REMOVED(aura)
		end, 0.1)
	end
end

function SheepMonitor.AuraWatcher:Breaker(...)
	local _, _, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName = select(1, ...)
	local index, aura = self:UnitHasAura(destGUID, spellId)
	if index then
		aura:Break(sourceName, eventType == 'SWING_DAMAGE' and 'Melee' or spellName)
	end
end


SheepMonitor.Aura = {}
SheepMonitor.Aura.__index = SheepMonitor.Aura;

SheepMonitor.Aura.trackable = {
	[118]   = 'Interface\\Icons\\Spell_Nature_Polymorph',           -- Polymorph
	[339]   = 'Interface\\Icons\\Spell_Nature_StrangleVines',       -- Entangling Roots
	[605]   = 'Interface\\Icons\\Spell_Shadow_ShadowWordDominate',  -- Mind Control
	[710]   = 'Interface\\Icons\\Spell_Shadow_Cripple',             -- Banish
	[1098]  = 'Interface\\Icons\\Spell_Shadow_EnslaveDemon',        -- Enslave Demon
	[1513]  = 'Interface\\Icons\\Ability_Druid_Cower',              -- Scare Beast
	[2637]  = 'Interface\\Icons\\Spell_Nature_Sleep',               -- Hibernate
	[3355]  = 'Interface\\Icons\\Spell_Frost_ChainsOfIce',          -- Freezing Trap
	[5782]  = 'Interface\\Icons\\Spell_Shadow_Possession',          -- Fear
	[6358]  = 'Interface\\Icons\\Spell_Shadow_MindSteal',           -- Seduction
	[6770]  = 'Interface\\Icons\\Ability_Sap',                      -- Sap
	[8122]  = 'Interface\\Icons\\Spell_Shadow_PsychicScream',       -- Psychic Scream
	[9484]  = 'Interface\\Icons\\Spell_Nature_Slow',                -- Shackle Undead
	[10326] = 'Interface\\Icons\\Spell_Holy_TurnUndead',            -- Turn Evil
	[19386] = 'Interface\\Icons\\Inv_Spear_02',                     -- Wyvern Sting
	[20066] = 'Interface\\Icons\\Spell_Holy_PrayerOfHealing',       -- Repentance
	[28271] = 'Interface\\Icons\\Ability_Hunter_Pet_Turtle',        -- Polymorph (Turtle)
	[28272] = 'Interface\\Icons\\Spell_Magic_PolymorphPig',         -- Polymorph (Pig)
	[51514] = 'Interface\\Icons\\Spell_Shaman_Hex',                 -- Hex
	[61305] = 'Interface\\Icons\\Achievement_Halloween_Cat_01',     -- Polymorph (Cat)
	[61721] = 'Interface\\Icons\\Spell_Magic_PolymorphRabbit',      -- Polymorph (Rabbit)
	[76780] = 'Interface\\Icons\\Spell_Shaman_BindElemental',       -- Bind Elemental
--	[82691] = 'Interface\\Icons\\Spell_Frost_Ring Of Frost',        -- Ring of Frost
}


do
	local LibAuraInfo = LibStub('LibAuraInfo-1.0')
	LibAuraInfo.auraInfo[3355] = '60;1' -- fixing incorrect value

	function SheepMonitor.Aura:New(...)
		local _, _, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName = select(1, ...)
		local self = {
			sourceGUID = sourceGUID,
			sourceName = sourceName,
			destGUID = destGUID,
			destName = destName,
			spellId = spellId,
			spellName = spellName,
			texture = SheepMonitor.Aura.trackable[spellId],
			timestamp = GetTime(),
			duration = LibAuraInfo:GetDuration(spellId, sourceGUID, destGUID),
		}

		if destGUID == UnitGUID('target') then
			self.duration = select(6, UnitAura('target', spellName, nil, 'PLAYER|HARMFUL')) or 0
		end

		setmetatable(self, SheepMonitor.Aura);

		self.notifier = SheepMonitor:CountdownBar(self):Start()
		return self
	end
end

function SheepMonitor.Aura:Break(breakerName, breakerReason)
	self.breakerName = breakerName
	self.breakerReason = breakerReason
end
