
function SheepMonitor:ShowNotifier()
	if not self.notifier then
		self.notifier = CreateFrame('Frame', 'SheepMonitorVisualNotifier', UIParent)
		self.notifier:Hide()
		self.notifier:EnableMouse(true)
		self.notifier:SetMovable(true)
		self.notifier:SetClampedToScreen(true)
		self.notifier:SetWidth(140)
		self.notifier:SetHeight(30)
		if SheepMonitor.db.char.notifierFramePosition then
			self.notifier:SetPoint(unpack(SheepMonitor.db.char.notifierFramePosition))
		else
			self.notifier:SetPoint('CENTER')
		end
		self.notifier:SetBackdrop({
			bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',  
			edgeFile = 'Interface\\Tooltips\\UI-DialogBox-Border',
			tile = true,
			tileSize = 32,
			edgeSize = 6,
			insets = {
				left = 1,
				right = 1,
				top = 1,
				bottom = 1
			}
		})
		-- create our texture for the polymorph spell
		self.notifier.texture = self.notifier:CreateTexture('ARTWORK')
		self.notifier.texture:SetTexture('Interface\\Icons\\Spell_nature_polymorph')
		self.notifier.texture:SetSize(23, 23)
		self.notifier.texture:SetPoint('LEFT', 4, 0)
		self.notifier.texture:SetTexCoord(0.08,0.92,0.08,0.92)
		-- create our unit name label
		self.notifier.text = self.notifier:CreateFontString('ARTWORK', nil, 'GameFontHighlightSmall')
		self.notifier.text:SetPoint('TOP')
		self.notifier.text:SetPoint('BOTTOM')
		self.notifier.text:SetPoint('LEFT', 30, 0)
		self.notifier.text:SetPoint('RIGHT', -30, 0)
		self.notifier.text:SetJustifyH('LEFT')
		self.notifier.text:SetWordWrap(true)
		self.notifier.text:SetFont('Interface\\AddOns\\SheepMonitor\\fonts\\DroidSans.ttf', 11)
		-- create our timer text
		self.notifier.countdown = self.notifier:CreateFontString('ARTWORK', nil, 'GameFontNormal')
		self.notifier.countdown:SetPoint('TOP')
		self.notifier.countdown:SetPoint('BOTTOM')
		self.notifier.countdown:SetPoint('RIGHT', -5, 0)
		self.notifier.countdown:SetFont('Interface\\AddOns\\SheepMonitor\\fonts\\DroidSans.ttf', 13)
		-- create our status bar
		self.notifier.statusBar = CreateFrame('StatusBar', nil, self.notifier, 'TextStatusBar')
		self.notifier.statusBar:SetFrameLevel(1)
		self.notifier.statusBar:SetWidth(110)
		self.notifier.statusBar:SetHeight(24)
		self.notifier.statusBar:SetPoint('BOTTOMLEFT', self.notifier, 27, 3)
		self.notifier.statusBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
		self.notifier.statusBar:SetStatusBarColor(1, 0, 0)
		-- enable our notifier to be dragged around
		self.notifier:RegisterForDrag('RightButton')
		self.notifier:SetScript('OnDragStart', function(self, button) self:StartMoving() end)
		self.notifier:SetScript('OnDragStop', function(self, button)
			self:StopMovingOrSizing() -- save our new position
			SheepMonitor.db.char.notifierFramePosition = { self:GetPoint() }
		end)
	end
	-- update and show the notifier
	if self.polymorph then
		self.notifier.text:SetText(self.polymorph.destName)
		self.notifier.texture:SetTexture(self.polymorph.texture)
		self.notifier.countdown:SetText(self.polymorph.duration)
		self.notifier.statusBar:SetMinMaxValues(0, self.polymorph.duration)
		self.notifier.statusBar:SetValue(self.polymorph.duration)
		self.notifier:Show()
	end
end

function SheepMonitor:HideNotifier()
	if not self.db.char.enableNotifier then
		return
	end
	if self.notifier then
		self.notifier:Hide()
		-- clear all the polymorph information for the notifier
		self.notifier.text:SetText(UnitName('player'))
		self.notifier.texture:SetTexture('Interface\\Icons\\Spell_nature_polymorph')
		self.notifier.countdown:SetText(50)
		self.notifier.statusBar:SetMinMaxValues(0, 50)
		self.notifier.statusBar:SetValue(50)
	end
end

function SheepMonitor:UpdateNotifierCountdown()
	self.notifier.countdown:SetText(self.polymorph.remaining)
end

function SheepMonitor:UpdateNotifierStatusBar()
	self.notifier.statusBar:SetValue(self.polymorph.remainingRaw)
end

