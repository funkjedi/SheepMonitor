

SheepMonitor.auras = {}


-- theses are the cc auras that we track
SheepMonitor.trackableAuras = {
	[118]   = 'Interface\\Icons\\Spell_Nature_Polymorph',           -- Polymorph
	[28271] = 'Interface\\Icons\\Ability_Hunter_Pet_Turtle',        -- Polymorph (Turtle)
	[28272] = 'Interface\\Icons\\Spell_Magic_PolymorphPig',         -- Polymorph (Pig)
	[61305] = 'Interface\\Icons\\Achievement_Halloween_Cat_01',     -- Polymorph (Cat)
	[61721] = 'Interface\\Icons\\Spell_Magic_PolymorphRabbit',      -- Polymorph (Rabbit)
--	[82691] = 'Interface\\Icons\\Spell_Frost_Ring Of Frost',        -- Ring of Frost
	[51514] = 'Interface\\Icons\\Spell_Shaman_Hex',                 -- Hex
	[76780] = 'Interface\\Icons\\Spell_Shaman_BindElemental',       -- Bind Elemental
	[9484]  = 'Interface\\Icons\\Spell_Nature_Slow',                -- Shackle Undead
	[8122]  = 'Interface\\Icons\\Spell_Shadow_PsychicScream',       -- Psychic Scream
	[605]   = 'Interface\\Icons\\Spell_Shadow_ShadowWordDominate',  -- Mind Control
	[2637]  = 'Interface\\Icons\\Spell_Nature_Sleep',               -- Hibernate
	[6770]  = 'Interface\\Icons\\Ability_Sap',                      -- Sap
	[3355]  = 'Interface\\Icons\\Spell_Frost_ChainsOfIce',          -- Freezing Trap
	[19386] = 'Interface\\Icons\\Inv_Spear_02',                     -- Wyvern Sting
	[1513]  = 'Interface\\Icons\\Ability_Druid_Cower',              -- Scare Beast
	[710]   = 'Interface\\Icons\\Spell_Shadow_Cripple',             -- Banish
	[5782]  = 'Interface\\Icons\\Spell_Shadow_Possession',          -- Fear
	[6358]  = 'Interface\\Icons\\Spell_Shadow_MindSteal',           -- Seduction
	[20066] = 'Interface\\Icons\\Spell_Holy_PrayerOfHealing',       -- Repentance
	[10326] = 'Interface\\Icons\\Spell_Holy_TurnUndead',            -- Turn Evil
	[1098]  = 'Interface\\Icons\\Spell_Shadow_EnslaveDemon',        -- Enslave Demon
	[339]   = 'Interface\\Icons\\Spell_Nature_StrangleVines',       -- Entangling Roots
}


function SheepMonitor:AuraApplied(aura)
	--print('SheepMonitor:AuraApplied', aura.destGUID, aura.spellId)
	local index = self:UnitHasAura(aura.destGUID, aura.spellId)
	if index then
		table.remove(self.auras, index)
	end
	table.insert(self.auras, aura)
	self:POLYMORPH_APPLIED(aura)
	aura.timer = SheepMonitor.Timer:Get(aura) or SheepMonitor.Timer:New()
	aura.timer:Start(aura)
end

function SheepMonitor:AuraBroken(destGUID, breakerName, breakerReason)
	--print('SheepMonitor:AuraBroken', destGUID, breakerName, breakerReason)
	for index, aura in ipairs(self.auras) do
		if aura.destGUID == destGUID then
			self.auras[index].breakerName = breakerName
			self.auras[index].breakerReason = breakerReason
		end
	end
end

function SheepMonitor:AuraRemoved(destGUID, spellId)
	--print('SheepMonitor:AuraRemoved', destGUID, spellId)
	local index, aura = self:UnitHasAura(destGUID, spellId)
	if index then
		-- we only need to watch damage in the combat logs during the brief moment the timer is up
		-- the flag must be a counter as it's possible that multiple timers are up at once
		self.watchForBreakers = self.watchForBreakers and self.watchForBreakers + 1 or 1
		-- delay removal of the aura so we can check who the breaker was
		self:ScheduleTimer(function()
			SheepMonitor.watchForBreakers = SheepMonitor.watchForBreakers - 1
			table.remove(SheepMonitor.auras, index)
			SheepMonitor:POLYMORPH_REMOVED(aura)
			if aura.timer then
				aura.timer:Stop()
			end
			SheepMonitor.Timer:UpdateTimers()
		end, 0.1)
	end
end


function SheepMonitor:UnitHasAura(destGUID, spellId)
	for index, aura in ipairs(self.auras) do
		if aura.destGUID == destGUID and aura.spellId == spellId then
			return index, aura
		end
	end
end



--UNUSED
--created for testing purposes

function SheepMonitor:GetSpellInfo(spellId, FROM_SPELLBOOK)
	local name, rank, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange = FROM_SPELLBOOK and GetSpellInfo(spellId, BOOKTYPE_SPELL) or GetSpellInfo(spellId)
	if name then
		local spell = {
			id = FROM_SPELLBOOK and select(2, GetSpellBookItemInfo(name)) or spellId,
			name = name,
			rank = rank,
			icon = icon,
			powerCost = powerCost,
			isFunnel = isFunnel,
			powerType = powerType,
			castingTime = castingTime,
			minRange = minRange,
			maxRange = maxRange,
			texture = FROM_SPELLBOOK and GetSpellTexture(spellId, BOOKTYPE_SPELL) or GetSpellTexture(name),
			actionslots = {},
			tooltips = {},
			index = index,
		}
		-- retrieve the slot id for any actionbars the spell is in
		for i = 1, 120 do
			local spellId = select(2, GetActionInfo(i))
			if spellId == spell.id then
				table.insert(spell.actionslots, i)
			end
		end
		-- retrieve the tooltip information
		if not SheepMonitorGameTooltip then
			CreateFrame('GameTooltip', 'SheepMonitorGameTooltip', nil, 'GameTooltipTemplate'):SetOwner(WorldFrame, 'ANCHOR_NONE')
		end
		SheepMonitorGameTooltip:ClearLines()
		SheepMonitorGameTooltip:SetSpellByID(spellId)
		for _, region in ipairs({ SheepMonitorGameTooltip:GetRegions() }) do
			if region:GetObjectType() == "FontString" then
				local text = region:GetText()
				if text ~= nil then
					table.insert(spell.tooltips, text)
				end
			end
		end
		-- return all relevant spell data
		return spell
	end
end

function SheepMonitor:CacheSpellbook()
	self.spellbook = {}
	for i = 1, MAX_SPELLS do
		local spell = self:GetSpellInfo(i, true)
		if spell then
			table.insert(self.spellbook, spell)
		end
	end
end

function SheepMonitor:GetSpellInfoByName(name)
	self:CacheSpellBook()
	for _, spell in ipairs(self.spellbook) do
		if spell.name == name then
			return spell
		end
	end
end
