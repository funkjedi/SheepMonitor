local addonName, SheepMonitor = ...

local notifierFrame
local timerInstances = {}

SheepMonitorTimerMixin = {}

BACKDROP_SHEEPMONITOR_TIMER_32_1 = {
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    tile = true,
    tileSize = 32,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

SHEEPMONITOR_TEXT_FONT = [[Interface\AddOns\SheepMonitor\fonts\DroidSans.ttf]]

if not string.match(GetLocale(), '^en') then
    SHEEPMONITOR_TEXT_FONT = STANDARD_TEXT_FONT
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
    local timer = CreateFrame('Frame', frameName, createNotifierFrame(), 'SheepMonitorTimerTemplate')

    table.insert(timerInstances, timer)

    return timer, #timerInstances
end

function SheepMonitorTimerMixin:StartDragging(button)
    if button == 'RightButton' and not self.isMoving then
        self.isMoving = true
        notifierFrame:StartMoving()
    end
end

function SheepMonitorTimerMixin:StopDragging(button)
    if self.isMoving then
        self.isMoving = false
        notifierFrame:StopMovingOrSizing()

        if self:IsVisible() then -- save our new position
            local point, _, relativePoint, xOffset, yOffset = notifierFrame:GetPoint()
            SheepMonitor.db.char.notifierFramePosition = { point, _, relativePoint, xOffset, yOffset }
        end
    end
end

function SheepMonitorTimerMixin:Start(aura)
    if self.aura then
        self:Stop()
    end

    self.aura = aura

    if SheepMonitor.db.char.enableNotifier then
        self.Icon:SetTexture(aura.texture)
        self.StatusBar:SetMinMaxValues(0, aura.duration)
        self.StatusBar:SetValue(aura.duration)
        self.StatusBar.Countdown:SetText(aura.duration)
        self.StatusBar.Label:SetText(aura.destName)
        SheepMonitor:UpdateAuraTimers()
    end

    self:ScheduleRepeatingTimers()

    return self
end

function SheepMonitorTimerMixin:Stop()
    self:CancelRepeatingTimers()
    self:Hide()
    self.aura = nil
    SheepMonitor:UpdateAuraTimers()
end

function SheepMonitorTimerMixin:GetRemaining(raw)
    if not self.aura then
        return 0
    end

    local remaining = self.aura.duration - (GetTime() - self.aura.timestamp)
    return raw and remaining or floor(remaining)
end

function SheepMonitorTimerMixin:ScheduleRepeatingTimers()
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

function SheepMonitorTimerMixin:CancelRepeatingTimers()
    SheepMonitor:CancelTimer(self.onFinishedTimer, true)
    SheepMonitor:CancelTimer(self.onUpdateTimer, true)
end

function SheepMonitorTimerMixin:OnFinished(remaining)
    SheepMonitor:POLYMORPH_UPDATE(self.aura, remaining)

    if self:IsVisible() then
        self.StatusBar.Countdown:SetText(remaining)
    end
end

function SheepMonitorTimerMixin:OnUpdate(remaining)
    self.StatusBar:SetValue(remaining)
end

function SheepMonitor:StartAuraTimer(aura)
    for _, timer in ipairs(timerInstances) do
        if timer.aura and timer.aura.auraGUID == aura.auraGUID then
            return timer:Start(aura)
        end
    end

    return createAuraTimer():Start(aura) ---@diagnostic disable-line
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
