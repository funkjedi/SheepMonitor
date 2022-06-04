local addonName, SheepMonitor = ...

local TimerMixin = {}

local notifierFrame
local timerInstances = {}

local fontFamily = [[Interface\AddOns\SheepMonitor\fonts\DroidSans.ttf]]

-- use default game font for non-English locales
if not string.match(GetLocale(), '^en') then
    fontFamily = [[Fonts\FRIZQT__.ttf]]
end

local function createNotifierFrame()
    if notifierFrame then
        return notifierFrame
    end

    notifierFrame = CreateFrame('Frame', 'SheepMonitorNotifier', UIParent)

    if SheepMonitor.db.char.notifierFramePosition then
        local point, _, relativePoint, xOffset, yOffset = unpack(SheepMonitor.db.char.notifierFramePosition)
        notifierFrame:ClearAllPoints()
        notifierFrame:SetPoint(point, UIParent, relativePoint, xOffset, yOffset)
    else
        notifierFrame:SetPoint('CENTER')
    end

    notifierFrame:SetWidth(140)
    notifierFrame:SetHeight(28)
    notifierFrame:SetMovable(true)
    notifierFrame:SetClampedToScreen(true)

    return notifierFrame
end

local function createAuraTimer()
    -- look for a timer frame which can be recycled
    -- this is important since frames can't be deleted once created
    for _, timer in ipairs(timerInstances) do
        if not timer.aura then
            return timer
        end
    end

    local frameName = 'SheepMonitorTimer' .. (#timerInstances + 1)
    local timer = CreateFrame('Frame', frameName, createNotifierFrame(), 'BackdropTemplate')

    Mixin(timer, TimerMixin)

    timer:Hide()
    timer:SetWidth(140)
    timer:SetHeight(28)
    timer:SetPoint('CENTER')
    timer:EnableMouse(true)
    timer:SetScript('OnHide', timer.StopDragging)
    timer:SetScript('OnMouseDown', timer.StartDragging)
    timer:SetScript('OnMouseUp', timer.StopDragging)

    timer:SetBackdrop({
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
        tile = true,
        tileSize = 32,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })

    -- create our icon texture; default to the polymorph spell
    local texture = timer:CreateTexture(frameName .. 'Icon', 'ARTWORK')
    texture:SetTexture('Interface\\Icons\\Spell_nature_polymorph')
    texture:SetSize(23, 23)
    texture:SetPoint('LEFT', 3, 0)
    texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- create our status bar
    local statusBar = CreateFrame('StatusBar', frameName .. 'StatusBar', timer, 'TextStatusBar')
    statusBar:SetWidth(110)
    statusBar:SetHeight(26)
    statusBar:SetPoint('BOTTOMLEFT', timer, 27, 1)
    statusBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
    statusBar:SetStatusBarColor(1, 0, 0)

    -- create our unit name label
    local label = statusBar:CreateFontString(frameName .. 'StatusBarLabel', 'ARTWORK', 'GameFontHighlightSmall')
    label:SetPoint('TOP')
    label:SetPoint('BOTTOM')
    label:SetPoint('LEFT', 4, 0)
    label:SetPoint('RIGHT', -26, 0)
    label:SetJustifyH('LEFT')
    label:SetWordWrap(true)
    label:SetFont(fontFamily, 11)

    -- create our timer text
    local countdown = statusBar:CreateFontString(frameName .. 'StatusBarCountdown', 'ARTWORK', 'GameFontNormal')
    countdown:SetPoint('TOP')
    countdown:SetPoint('BOTTOM')
    countdown:SetPoint('RIGHT', -4, 0)
    countdown:SetFont(fontFamily, 13)

    timer.countdown = countdown
    timer.label = label
    timer.statusBar = statusBar
    timer.texture = texture

    table.insert(timerInstances, timer)

    return timer, #timerInstances
end

function TimerMixin:StartDragging(button)
    if button == 'RightButton' and not self.isMoving then
        self.isMoving = true
        notifierFrame:StartMoving()
    end
end

function TimerMixin:StopDragging(button)
    if self.isMoving then
        self.isMoving = false
        notifierFrame:StopMovingOrSizing()

        if self:IsVisible() then -- save our new position
            local point, _, relativePoint, xOffset, yOffset = notifierFrame:GetPoint()
            SheepMonitor.db.char.notifierFramePosition = { point, _, relativePoint, xOffset, yOffset }
        end
    end
end

function TimerMixin:Start(aura)
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
        SheepMonitor:UpdateAuraTimers()
    end

    self:ScheduleRepeatingTimers()

    return self
end

function TimerMixin:Stop()
    self:CancelRepeatingTimers()
    self:Hide()
    self.aura = nil
    SheepMonitor:UpdateAuraTimers()
end

function TimerMixin:GetRemaining(raw)
    local remaining = self.aura.duration - (GetTime() - self.aura.timestamp)
    return raw and remaining or floor(remaining)
end

function TimerMixin:ScheduleRepeatingTimers()
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

function TimerMixin:CancelRepeatingTimers()
    SheepMonitor:CancelTimer(self.onFinishedTimer, true)
    SheepMonitor:CancelTimer(self.onUpdateTimer, true)
end

function TimerMixin:OnFinished(remaining)
    SheepMonitor:POLYMORPH_UPDATE(self.aura, remaining)

    if self:IsVisible() then
        self.countdown:SetText(remaining)
    end
end

function TimerMixin:OnUpdate(remaining)
    self.statusBar:SetValue(remaining)
end

function SheepMonitor:StartAuraTimer(aura)
    for _, timer in ipairs(timerInstances) do
        if timer.aura and timer.aura.auraGUID == aura.auraGUID then
            return timer:Start(aura)
        end
    end

    return createAuraTimer():Start(aura)
end

function SheepMonitor:UpdateAuraTimers()
    local lastBar = notifierFrame
    local from, to = 'BOTTOM', 'TOP'

    if not SheepMonitor.db.char.growUpwards then
        from = 'TOP'
        to = 'BOTTOM'
    end

    for _, timer in ipairs(timerInstances) do
        if timer.aura then
            local originalTo = to

            if lastBar == notifierFrame then
                to = from
            end

            timer:ClearAllPoints()
            timer:Show()
            timer:SetPoint(from .. 'LEFT', lastBar, to .. 'LEFT', 0, 0)
            timer:SetPoint(from .. 'RIGHT', lastBar, to .. 'RIGHT', 0, 0)

            lastBar = timer
            to = originalTo
        else
            timer:Hide()
        end
    end
end

-- FOR TESTING PURPOSES ONLY
function SheepMonitor:CreateTestTimer(duration)
    local aura = {
        auraGUID = 118 .. math.random(0, 200),
        sourceGUID = 0,
        sourceName = 'Player',
        destGUID = 0,
        destName = 'Target',
        spellId = 118,
        spellName = 'Polymorph',
        texture = self.trackableAuras[118],
        timestamp = GetTime(),
        duration = duration or 30,
    }

    aura.timer = SheepMonitor:StartAuraTimer(aura)
end
