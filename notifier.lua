

function SheepMonitor:NotifierAuraApplied(aura)
	if not self.notifier then
		self.notifier = CreateFrame('Frame', nil, UIParent)
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
	end

	aura.timer = SheepMonitor.Timer:Get(aura) or SheepMonitor.Timer:New(self.notifier)
	aura.timer:Start(aura)
end

function SheepMonitor:NotifierAuraRemoved(aura)
	if aura.timer then
		aura.timer:Stop()
	end
	self.Timer:UpdateTimers()
end
