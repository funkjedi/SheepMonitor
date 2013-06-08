
function SheepMonitor_CreateTestTimer(duration)
	local aura = {
		auraGUID = 118 .. math.random(0,200),
		sourceGUID = 0,
		sourceName = 'Player',
		destGUID = 0,
		destName = 'Target',
		spellId = 118,
		spellName = 'Polymorph',
		texture = 'Interface\\Icons\\Spell_Nature_Polymorph',
		timestamp = GetTime(),
		duration = duration or 30
	}
	aura.timer = SheepMonitor.Timer:Get(aura) or SheepMonitor.Timer:New()
	aura.timer:Start(aura)
end



function SheepMonitor_GetSpellInfoByName(name)
	SheepMonitor_CacheSpellbook()
	for _, spell in ipairs(self.spellbook) do
		if spell.name == name then
			return spell
		end
	end
end

function SheepMonitor_CacheSpellbook()
	self.spellbook = {}
	for i = 1, MAX_SPELLS do
		local spell = SheepMonitor_GetSpellInfo(i, true)
		if spell then
			table.insert(self.spellbook, spell)
		end
	end
end

function SheepMonitor_GetSpellInfo(spellId, FROM_SPELLBOOK)
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
