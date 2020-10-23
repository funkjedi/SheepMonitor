
SheepMonitor.Timer = LibStub('Classy-1.0'):New('Frame')
SheepMonitor.Timer:Hide()

local timers = {}


-- utility functions for making frames draggable
local function startDragging(self, button)
	if button == "RightButton" and not self.isMoving then
		SheepMonitor.notifier:StartMoving()
		self.isMoving = true
	end
end
local function stopDragging(self, button)
	if self.isMoving then
		SheepMonitor.notifier:StopMovingOrSizing()
		if self:IsVisible() then -- save our new position
			local point, _, relativePoint, xOffset, yOffset = SheepMonitor.notifier:GetPoint()
			SheepMonitor.db.char.notifierFramePosition = {
				point, _, relativePoint, xOffset, yOffset
			}
		end
		self.isMoving = false
	end
end


function SheepMonitor.Timer:New()
	-- look for a timer which can be recycled
	-- this is important since frames can't be deleted once created
	for index, timer in ipairs(timers) do
		if not timer.aura then
			return timer
		end
	end

	-- create our notifier frame if it hasn't been created already
	if not SheepMonitor.notifier then
		SheepMonitor.notifier = CreateFrame('Frame', nil, UIParent)
		if SheepMonitor.db.char.notifierFramePosition then
			local point, _, relativePoint, xOffset, yOffset = unpack(SheepMonitor.db.char.notifierFramePosition)
			SheepMonitor.notifier:ClearAllPoints()
			SheepMonitor.notifier:SetPoint(point, UIParent, relativePoint, xOffset, yOffset)
		else
			SheepMonitor.notifier:SetPoint('CENTER')
		end
		SheepMonitor.notifier:SetWidth(140)
		SheepMonitor.notifier:SetHeight(28)
		SheepMonitor.notifier:SetMovable(true)
		SheepMonitor.notifier:SetClampedToScreen(true)
	end

	-- create a new timer
	local timer = SheepMonitor.Timer:Bind(CreateFrame('Frame', nil, SheepMonitor.notifier, BackdropTemplateMixin and 'BackdropTemplate' or nil))
	timer:Hide()
	timer:SetWidth(140)
	timer:SetHeight(28)
	timer:SetPoint('CENTER')
	timer:EnableMouse(true)
	timer:SetScript('OnHide', stopDragging)
	timer:SetScript('OnMouseUp', stopDragging)
	timer:SetScript('OnMouseDown', startDragging)
	timer:SetBackdrop({
		bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
		edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
		tile = true,
		tileSize = 32,
		edgeSize = 1,
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
	timer.statusBar:EnableMouse(true)
	timer.statusBar:SetScript('OnHide', stopDragging)
	timer.statusBar:SetScript('OnMouseUp', stopDragging)
	timer.statusBar:SetScript('OnMouseDown', startDragging)
	-- create our unit name label
	timer.label = timer.statusBar:CreateFontString('ARTWORK', nil, 'GameFontHighlightSmall')
	timer.label:SetPoint('TOP')
	timer.label:SetPoint('BOTTOM')
	timer.label:SetPoint('LEFT', 4, 0)
	timer.label:SetPoint('RIGHT', -26, 0)
	timer.label:SetJustifyH('LEFT')
	timer.label:SetWordWrap(true)
	--timer.label:SetTextHeight(11)
	timer.label:SetFont('Interface\\AddOns\\SheepMonitor\\fonts\\DroidSansFallback.ttf', 11)
	-- create our timer text
	timer.countdown = timer.statusBar:CreateFontString('ARTWORK', nil, 'GameFontNormal')
	timer.countdown:SetPoint('TOP')
	timer.countdown:SetPoint('BOTTOM')
	timer.countdown:SetPoint('RIGHT', -4, 0)
	--timer.countdown:SetTextHeight(13)
	timer.countdown:SetFont('Interface\\AddOns\\SheepMonitor\\fonts\\DroidSansFallback.ttf', 13)

	table.insert(timers, timer)
	return timer, #timers
end

function SheepMonitor.Timer:Get(aura)
	for index, timer in ipairs(timers) do
		if timer.aura and timer.aura.auraGUID == aura.auraGUID then
			return timer, index
		end
	end
end

function SheepMonitor.Timer:Start(aura)
	if self.aura then
		self:Stop()
	end
	self.aura = aura
	if SheepMonitor.db.char.enableNotifier then
		self.label:SetText(aura.destName)
		self.texture:SetTexture(aura.texture)
		self.statusBar:SetMinMaxValues(0, aura.duration)
		self.statusBar:SetValue(aura.duration)
		self.countdown:SetText(aura.duration)
		self:UpdateTimers()
	end
	self:ScheduleRepeatingTimers()
end

function SheepMonitor.Timer:Stop()
	self:CancelRepeatingTimers()
	self:Hide()
	self.aura = nil
	self:UpdateTimers()
end

function SheepMonitor.Timer:GetRemaining(raw)
	local remaining = self.aura.duration - (GetTime() - self.aura.timestamp)
	return raw and remaining or floor(remaining)
end

function SheepMonitor.Timer:ScheduleRepeatingTimers()
	local onFinished = function(timer)
		local remaining = timer:GetRemaining()
		if remaining > 0 then
			timer:OnFinished(remaining)
		else
			timer:OnFinished(0)
			timer:Stop()
		end
	end
	self.onFinishedTimer = SheepMonitor:ScheduleRepeatingTimer(onFinished, 1, self)
	if self:IsVisible() then
		local onUpdate = function(timer)
			local remaining = timer:GetRemaining(true)
			if remaining > 0 then
				timer:OnUpdate(remaining)
			end
		end
		self.onUpdateTimer = SheepMonitor:ScheduleRepeatingTimer(onUpdate, 0.1, self)
	end
end

function SheepMonitor.Timer:CancelRepeatingTimers()
	SheepMonitor:CancelTimer(self.onFinishedTimer, true)
	SheepMonitor:CancelTimer(self.onUpdateTimer, true)
end

function SheepMonitor.Timer:OnFinished(remaining)
	SheepMonitor:POLYMORPH_UPDATE(self.aura, remaining)
	if self:IsVisible() then
		self.countdown:SetText(remaining)
	end
end

function SheepMonitor.Timer:OnUpdate(remaining)
	self.statusBar:SetValue(remaining)
end

function SheepMonitor.Timer:UpdateTimers()
	local lastBar = SheepMonitor.notifier
	local from, to = "BOTTOM", "TOP"

	if not SheepMonitor.db.char.growUpwards then
		from = "TOP"
		to = "BOTTOM"
	end

	for i = 1, #timers do
		if timers[i].aura then
			local origTo = to
			if lastBar == SheepMonitor.notifier then
				to = from
			end
			timers[i]:ClearAllPoints()
			timers[i]:Show()
			timers[i]:SetPoint(from.."LEFT",  lastBar, to.."LEFT",  0, 0)
			timers[i]:SetPoint(from.."RIGHT", lastBar, to.."RIGHT", 0, 0)
			lastBar = timers[i]
			to = origTo
		else
			timers[i]:Hide()
		end
	end
end



-- FOR TESTING PURPOSES ONLY
function SheepMonitor:CreateTestTimer(duration)
	local aura = {
		auraGUID = 118 .. math.random(0,200),
		sourceGUID = 0,
		sourceName = 'Player',
		destGUID = 0,
		destName = 'Target',
		spellId = 118,
		spellName = 'Polymorph',
		texture = self.trackableAuras[118],
		timestamp = GetTime(),
		duration = duration or 30
	}
	aura.timer = SheepMonitor.Timer:Get(aura) or SheepMonitor.Timer:New()
	aura.timer:Start(aura)
end
