
function SheepMonitor:ToggleNotifier()
	if not self.notifier then
		self.notifier = CreateFrame('Frame', nil, UIParent)
		self.notifier:Hide()
		if self.db.char.notifierFramePosition then
			self.notifier:ClearAllPoints()
			self.notifier:SetPoint(unpack(self.db.char.notifierFramePosition))
		else
			self.notifier:SetPoint('CENTER')
		end
		self.notifier:SetWidth(140)
		self.notifier:SetHeight(28)
		self.notifier:SetMovable(true)
		self.notifier:SetClampedToScreen(true)
		self.notifier.mover = CreateFrame('Frame', nil, self.notifier)
		self.notifier.mover:SetWidth(140)
		self.notifier.mover:SetHeight(28)
		self.notifier.mover:EnableMouse(true)
		self.notifier.mover:RegisterForDrag('RightButton')
		self.notifier.mover:SetScript('OnDragStart', function(self, button) self:GetParent():StartMoving() end)
		self.notifier.mover:SetScript('OnDragStop', function(self, button)
			self:GetParent():StopMovingOrSizing() -- save our new position
			SheepMonitor.db.char.notifierFramePosition = { self:GetParent():GetPoint() }
		end)
	end
	if SheepMonitor.db.char.enableNotifier then
		self.notifier:Show()
	else
		self.notifier:Hide()
	end
end

function SheepMonitor:NotifierAuraApplied(aura)
	self:ToggleNotifier()

	aura.timer = SheepMonitor.Timer:Get(aura) or SheepMonitor.Timer:New(self.notifier)

	-- delay actions to accomodate any auras tiggered for removal
	self:ScheduleTimer(function()
		aura.timer:Start(aura)
		SheepMonitor:UpdateNotifierUI()
	end, 0.1)
end

function SheepMonitor:NotifierAuraRemoved(aura)
	if aura.timer then
		aura.timer:Stop()
	end
	self:UpdateNotifierUI()
end

-- wrap the call in a scheduled timer this will make sure the calls are buffered
-- this is important because if called to rapidly some of the aura timers will be invalid
function SheepMonitor:UpdateNotifierUI()
	-- reanchor all the timers
	for i = 1, #self.auras do
		if i == 1 then
			self.auras[1].timer:ClearAllPoints()
			self.auras[1].timer:SetPoint('TOPLEFT', self.notifier, 'TOPLEFT', 0, 0)
		else
			--auras[i].timer:ClearAllPoints()
			--auras[i].timer:SetPoint('TOPLEFT', self.auras[i - 1].timer, 'BOTTOMLEFT', 0, 0)
			FlyPaper.StickToPoint(self.auras[i].timer, self.auras[i - 1].timer, 'BL', 0, 0)
		end
	end
	-- adjust the height of the notifier
	self.notifier.mover:SetHeight(#self.auras == 0 and 28 or #self.auras * 28)
	self.notifier.mover:ClearAllPoints()
	self.notifier.mover:SetPoint('TOPLEFT', self.notifier, 'TOPLEFT')
--[[
	local top, left = n:GetTop(), n:GetLeft()
	n:SetHeight(#a == 0 and 28 or #a * 28)
	n:ClearAllPoints()
	n:SetPoint('TOPLEFT', left, top - n:GetParent():GetHeight() / n:GetScale())
]]
end

