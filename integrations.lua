

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


