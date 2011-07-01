

function SheepMonitor:ShowQuartz()
	if IsAddOnLoaded('Quartz') and self.polymorph then
		local Mirror = LibStub("AceAddon-3.0"):GetAddon("Quartz3"):GetModule("Mirror")
		Mirror.ExternalTimers[self.polymorph.destName .. ' (' .. self.polymorph.spellName .. ')'] = {
			startTime = self.polymorph.timestamp,
			endTime = self.polymorph.timestamp + self.polymorph.duration,
			icon = self.polymorph.texture,
			color = {1, 0, 0},
			spellid = self.polymorph.spellId,
			spellname = self.polymorph.spellName,
			expires = self.polymorph.timestamp + self.polymorph.duration,
			cooldown = false,
			spelltype = "combatlog",
		}
		Mirror:SendMessage("Quartz3Mirror_UpdateCustom")
	end
end
function SheepMonitor:HideQuartz()
	if IsAddOnLoaded('Quartz') and self.polymorph then
		local Mirror = LibStub("AceAddon-3.0"):GetAddon("Quartz3"):GetModule("Mirror")
		for k,v in pairs(Mirror.ExternalTimers) do
			if (tostring(v.spellid) == tostring(self.polymorph.spellId)) and (v.spelltype == "combatlog") then
				Mirror.ExternalTimers[k] = nil
				Mirror:SendMessage("Quartz3Mirror_UpdateCustom")
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

function SheepMonitor:ShowOmniCC()
	if IsAddOnLoaded('OmniCC') and self.polymorph then
		for i = 1, 120 do
			local spellId = select(2, GetActionInfo(i))
			if spellId == self.polymorph.spellId then
				self.actionButton = GetActionBarButtonFrame(i)
				if self.actionButton then
					local timer = OmniCC.Timer:Get(self.actionButton) or OmniCC.Timer:New(self.actionButton)
					timer:Start(self.polymorph.timestamp, self.polymorph.duration)
				end
			end
		end
	end
end
function SheepMonitor:HideOmniCC()
	if IsAddOnLoaded('OmniCC') then
		local timer = OmniCC.Timer:Get(self.actionButton)
		if timer and timer.enabled then
			timer:Stop()
		end
	end
end


function SheepMonitor:CacheSpellbook()
	self.spellbook = {}
	for i = 1, MAX_SPELLS do
		local name, rank, icon, powerCost, isFunnel, powerType, castingTime, minRange, maxRange = GetSpellInfo(i, BOOKTYPE_SPELL)
		if name then
			self.spellbook[name] = {
				name = name,
				rank = rank,
				icon = icon,
				powerCost = powerCost,
				isFunnel = isFunnel,
				powerType = powerType,
				castingTime = castingTime,
				minRange = minRange,
				maxRange = maxRange,
				texture = GetSpellTexture(i, BOOKTYPE_SPELL),
				spellId = select(2, GetSpellBookItemInfo(name)),
				index = i,
			}
			-- retrieve the slot id for any actionbars the spell is in
			self.spellbook[name].actionbutton = {}
			for i = 1, 120 do
				local spellId = select(2, GetActionInfo(i))
				if spellId == self.spellbook[name].spellId then
					table.insert(self.spellbook[name].actionbutton, i)
				end
			end
			-- retrieve the tooltip information
			if not SheepMonitorGameTooltip then
				CreateFrame('GameTooltip', 'SheepMonitorGameTooltip', nil, 'GameTooltipTemplate'):SetOwner(WorldFrame, 'ANCHOR_NONE')
			end
			SheepMonitorGameTooltip:ClearLines()
			SheepMonitorGameTooltip:SetSpellBookItem(i, BOOKTYPE_SPELL)
			self.spellbook[name].tooltip = {}
			for _, region in ipairs({ SheepMonitorGameTooltip:GetRegions() }) do
				if region:GetObjectType() == "FontString" then
					local text = region:GetText()
					if text ~= nil then
						table.insert(self.spellbook[name].tooltip, text)
					end
				end
			end
		end
	end
end




























