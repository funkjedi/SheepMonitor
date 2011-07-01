
SheepMonitor.Timer = LibStub('Classy-1.0'):New('Frame')
SheepMonitor.Timer:Hide()

SheepMonitor.Timer.instances = {}


function SheepMonitor.Timer:New(parent)
	-- look for a timer which can be recycled
	-- this is important since frames can't be deleted once created
	for index, timer in ipairs(self.instances) do
		if not timer.aura then
			return timer
		end
	end

	local timer = SheepMonitor.Timer:Bind(CreateFrame('Frame', nil, parent or UIParent))
	timer:Hide()
	timer:SetWidth(140)
	timer:SetHeight(28)
	timer:SetPoint('CENTER')
	timer:SetBackdrop({
		bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
		edgeFile = 'Interface\\Tooltips\\UI-DialogBox-Border',
		tile = true,
		tileSize = 32,
		edgeSize = 6,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		}
	})
	-- create our icon texture; default to the polymorph spell
	timer.texture = timer:CreateTexture('ARTWORK')
	timer.texture:SetTexture('Interface\\Icons\\Spell_nature_polymorph')
	timer.texture:SetSize(23, 23)
	timer.texture:SetPoint('LEFT', 3, 0)
	timer.texture:SetTexCoord(0.08,0.92,0.08,0.92)
	-- create our status bar
	timer.statusBar = CreateFrame('StatusBar', nil, timer, 'TextStatusBar')
	timer.statusBar:SetWidth(110)
	timer.statusBar:SetHeight(26)
	timer.statusBar:SetPoint('BOTTOMLEFT', timer, 27, 1)
	timer.statusBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
	timer.statusBar:SetStatusBarColor(1, 0, 0)
	-- create our unit name label
	timer.label = timer.statusBar:CreateFontString('ARTWORK', nil, 'GameFontHighlightSmall')
	timer.label:SetPoint('TOP')
	timer.label:SetPoint('BOTTOM')
	timer.label:SetPoint('LEFT', 4, 0)
	timer.label:SetPoint('RIGHT', -26, 0)
	timer.label:SetJustifyH('LEFT')
	timer.label:SetWordWrap(true)
	timer.label:SetFont('Interface\\AddOns\\SheepMonitor\\fonts\\DroidSans.ttf', 11)
	-- create our timer text
	timer.countdown = timer.statusBar:CreateFontString('ARTWORK', nil, 'GameFontNormal')
	timer.countdown:SetPoint('TOP')
	timer.countdown:SetPoint('BOTTOM')
	timer.countdown:SetPoint('RIGHT', -4, 0)
	timer.countdown:SetFont('Interface\\AddOns\\SheepMonitor\\fonts\\DroidSans.ttf', 13)

	table.insert(self.instances, timer)
	return timer, #self.instances
end

function SheepMonitor.Timer:Get(aura)
	for index, timer in ipairs(self.instances) do
		if timer.aura and timer.aura.auraGUID == aura.auraGUID then
			return timer, index
		end
	end
end

function SheepMonitor.Timer:Start(aura)
	if self.aura then
		self:Stop()
	end
	if SheepMonitor.db.char.enableNotifier then
		self.label:SetText(aura.destName)
		self.texture:SetTexture(aura.texture)
		self.statusBar:SetMinMaxValues(0, aura.duration)
		self.statusBar:SetValue(aura.duration)
		self:Show()
	end
	self.aura = aura
	self:OnFinished(aura.duration)
	self:ScheduleRepeatingTimers()
end

function SheepMonitor.Timer:Stop()
	self:CancelRepeatingTimers()
	self:Hide()

	self.aura = nil
end

function SheepMonitor.Timer:GetRemaining(raw)
	local remaining = self.aura.duration - (GetTime() - self.aura.timestamp)
	return raw and remaining or ceil(remaining)
end

function SheepMonitor.Timer:ScheduleRepeatingTimers()
	local onFinished = function(timer)
		local remaining = timer:GetRemaining()
		if remaining > 0 then
			timer:OnFinished(remaining)
		else
			timer:Stop()
		end
	end
	self.onFinishedTimer = SheepMonitor:ScheduleRepeatingTimer(onFinished, 1, self)
	-- the onupdate timer is only needed if we are using the visual notifier
	if SheepMonitor.db.char.enableNotifier then
		local onUpdate = function(timer)
			local remaining = timer:GetRemaining(true)
			if remaining > 0 then
				timer:OnUpdate(remaining)
			end
		end
		self.onUpdateTimer = SheepMonitor:ScheduleRepeatingTimer(onUpdate, 0.01, self)
	end
end

function SheepMonitor.Timer:CancelRepeatingTimers()
	SheepMonitor:CancelTimer(self.onFinishedTimer, true)
	SheepMonitor:CancelTimer(self.onUpdateTimer, true)
end

function SheepMonitor.Timer:OnFinished(remaining)
	SheepMonitor:POLYMORPH_UPDATE(self.aura, remaining)
	if SheepMonitor.db.char.enableNotifier then
		self.countdown:SetText(remaining)
	end
end

function SheepMonitor.Timer:OnUpdate(remaining)
	self.statusBar:SetValue(remaining)
end

