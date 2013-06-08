

local NotifierFrame = CreateFrame('Frame', 'SheepMonitorNotifierFrame', UIParent)
NotifierFrame:SetMovable(true)
NotifierFrame:SetClampedToScreen(true)
NotifierFrame:SetWidth(140)
NotifierFrame:SetHeight(28)
NotifierFrame:SetPoint('CENTER')

function NotifierFrame_OnDrag(self, button)
	if button == "RightButton" and not NotifierFrame.isMoving then
		NotifierFrame:StartMoving()
		NotifierFrame.isMoving = true
	end
end

local function NotifierFrame_OnDragRelease(self, button)
	if NotifierFrame.isMoving then
		NotifierFrame:StopMovingOrSizing()
		NotifierFrame.isMoving = false
		if NotifierFrame:IsVisible() then
			SheepMonitor.db.char.notifierFramePosition = { NotifierFrame:GetPoint() }
		end
	end
end

local function NotifierFrame_OnUpdate(self, button)
	if NotifierFrame.isMoving then
		NotifierFrame:StopMovingOrSizing()
		NotifierFrame.isMoving = false
		if NotifierFrame:IsVisible() then
			SheepMonitor.db.char.notifierFramePosition = { NotifierFrame:GetPoint() }
		end
	end
end



local instances = {}

local CountdownBar = {}
CountdownBar.__index = CountdownBar;


-- since frames cant be cleanup/deleted/etc its important to
-- recycle the frames used for timers to avoid bloat
function SheepMonitor:CountdownBar(aura)
	for index, instance in ipairs(instances) do
		if instance.recycle then
			instance.recycle = false;
			return instance:SetAura(aura)
		end
	end
	local instance = CountdownBar.New()
	table.insert(instances, instance)
	return instance:SetAura(aura)
end


function CountdownBar.New()
	local self = { recycle=false }

	self.frame = CreateFrame('Frame', nil, NotifierFrame)
	self.frame:Hide()
	self.frame:EnableMouse(true)
	self.frame:SetWidth(140)
	self.frame:SetHeight(28)
	self.frame:SetPoint('CENTER')
	self.frame:SetBackdrop({
		bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
		edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
		tile = true,
		tileSize = 32,
		edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	self.frame:SetScript('OnMouseDown', NotifierFrame_OnDrag)
	self.frame:SetScript('OnMouseUp', NotifierFrame_OnDragRelease)
	self.frame:SetScript('OnHide', NotifierFrame_OnDragRelease)

	self.texture = self.frame:CreateTexture('ARTWORK')
	self.texture:SetTexture('Interface\\Icons\\Spell_nature_polymorph')
	self.texture:SetSize(23, 23)
	self.texture:SetPoint('LEFT', 3, 0)
	self.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	self.status = CreateFrame('StatusBar', nil, self.frame, 'TextStatusBar')
	self.status:EnableMouse(true)
	self.status:SetWidth(110)
	self.status:SetHeight(26)
	self.status:SetPoint('BOTTOMLEFT', 27, 1)
	self.status:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
	self.status:SetStatusBarColor(1, 0, 0)
	self.status:SetScript('OnMouseDown', NotifierFrame_OnDrag)
	self.status:SetScript('OnMouseUp', NotifierFrame_OnDragRelease)
	self.status:SetScript('OnHide', NotifierFrame_OnDragRelease)

	self.label = self.status:CreateFontString('ARTWORK', nil, 'GameFontHighlightSmall')
	self.label:SetFont('Interface\\AddOns\\SheepMonitor\\fonts\\DroidSansFallback.ttf', 11)
	self.label:SetJustifyH('LEFT')
	self.label:SetWordWrap(true)
	self.label:SetPoint('TOP')
	self.label:SetPoint('BOTTOM')
	self.label:SetPoint('LEFT', 4, 0)
	self.label:SetPoint('RIGHT', -26, 0)

	self.countdown = self.status:CreateFontString('ARTWORK', nil, 'GameFontNormal')
	self.countdown:SetFont('Interface\\AddOns\\SheepMonitor\\fonts\\DroidSansFallback.ttf', 13)
	self.countdown:SetPoint('TOP')
	self.countdown:SetPoint('BOTTOM')
	self.countdown:SetPoint('RIGHT', -4, 0)

	setmetatable(self, CountdownBar);
	return self
end

function CountdownBar:SetAura(aura)
	self:Stop()
	self.label:SetText(aura.destName)
	self.texture:SetTexture(aura.texture)
	self.status:SetMinMaxValues(0, aura.duration)
	self.status:SetValue(aura.duration)
	self.countdown:SetText(aura.duration)
	self.remaining = aura.duration
	self.aura = aura
	return self
end

function CountdownBar:Release(skipRefresh)
	self:Stop()
	self.label:SetText('')
	self.texture:SetTexture('Interface\\Icons\\Spell_nature_polymorph')
	self.status:SetMinMaxValues(0, 0)
	self.status:SetValue(0)
	self.countdown:SetText('')
	self.aura = nil
	self.recycle = true;
	return self
end

function CountdownBar:Start()
	if self.running then
		self:Stop()
	end
	self.running = true
	self.start = GetTime()
	self.expires = self.start + self.remaining
	self.looptimer = SheepMonitor:ScheduleRepeatingTimer(CountdownBar.OnLoop, 0.04, self)
	self.updatetimer = SheepMonitor:ScheduleRepeatingTimer(CountdownBar.OnUpdate, 1, self)
	self.frame:Show()
	self.Refresh()
	return self
end

function CountdownBar:Stop()
	if self.running then
		SheepMonitor:CancelTimer(self.looptimer, true)
		SheepMonitor:CancelTimer(self.updatetimer, true)
		self.frame:Hide()
		self.running = false
		self.start = nil
		self.expires = nil
		self.Refresh()
	end
	return self
end

function CountdownBar:OnLoop()
	local timestamp = GetTime()
	if timestamp >= self.expires then
		self:Stop()
	else
		self.remaining = self.expires - timestamp
		self.status:SetValue(self.remaining)
	end
end

function CountdownBar:OnUpdate()
	local remaining = floor(self.remaining)
	self.countdown:SetText(remaining)
	SheepMonitor:POLYMORPH_UPDATE(self.aura.spellName, remaining)
end


function CountdownBar.Refresh()
	local from, to = "BOTTOM", "TOP"
	local relativeTo = NotifierFrame

	if not SheepMonitor.db.char.growUpwards then
		local from, to = "TOP", "BOTTOM"
	end

	for index, instance in ipairs(instances) do
		if instance.running then
			local origTo = to
			if relativeTo == NotifierFrame then
				to = from
			end
			instance.frame:ClearAllPoints()
			instance.frame:Show()
			instance.frame:SetPoint(from.."LEFT",  relativeTo, to.."LEFT",  0, 0)
			instance.frame:SetPoint(from.."RIGHT", relativeTo, to.."RIGHT", 0, 0)
			relativeTo = instance.frame
			to = origTo
		else
			instance:Release(true)
		end
	end
end
