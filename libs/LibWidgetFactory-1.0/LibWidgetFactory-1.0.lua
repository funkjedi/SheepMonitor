--[[

	COMMON OPTIONS
		width, height, get, set, disabled, tooltip, parent, key

	WIDGET SPECIFIC OPTIONS

		CheckBox - label, tristate
		ColorPicker - label, hasAlpha
		Dropdown - label, values
		EditBox - label
		Keybinding - label
		MultiLineEditBox - label, lines
		Sliders - label, min, max, bigStep, step, isPercent

]]

local MAJOR, MINOR = "LibWidgetFactory-1.0", 2
local wf = LibStub:NewLibrary(MAJOR, MINOR)

if not wf then return end -- No upgrade needed



-- provide nice little tooltips for all our widgets
local GameTooltip = GameTooltip
local function ShowTooltip(widget, event)
	GameTooltip:SetOwner(widget.frame, "ANCHOR_TOP")	
	GameTooltip:SetText(widget.wf.tooltip, 1, 1, 1, 1, true)
	GameTooltip:Show()
end
local function HideTooltip(widget, event)
	GameTooltip:Hide()
end


-- most controls are activated when the value of the widgets change
-- but this is not necessarily the case; to be sure check the WidgetFactory
local function ActivateControl(widget, event, ...)
	if widget.wf.set then
		if type(widget.wf.set) == "function" then
			assert(pcall(widget.wf.set, widget.wf.key, ...))
		elseif type(widget.wf.set) == "string" and _G[widget.wf.set] then
			assert(pcall(_G[widget.wf.set], widget.wf.key, ...))
		end
	end
end

-- should return the current value to be assigned to the widget
local function GetValue(widget)
	if widget.wf.get then
		if type(widget.wf.get) == "function" then
			return widget.wf.get(widget.wf.key)
		elseif type(widget.wf.get) == "string" and _G[widget.wf.get] then
			return _G[widget.wf.get](widget.wf.key)
		end
	end
end


--contains the widget specific configurations
--and adjustments
local factories = {}
function factories:CheckBox(widget, value)
	widget:SetLabel(widget.wf.label)
	widget:SetTriState(widget.wf.tristate)
	widget:SetValue(value)
	widget:SetCallback("OnValueChanged", ActivateControl)
	if widget.wf.fontSize then
		widget.text:SetFontObject(widget.wf.fontSize == 'small' and 'GameFontHighlightSmall' or 'GameFontHighlight')
	end
end
function factories:ColorPicker(widget, value)
	widget:SetLabel(widget.wf.label)
	widget:SetHasAlpha(widget.wf.hasAlpha)
	widget:SetColor(value)
	widget:SetCallback("OnValueChanged", ActivateControl)
	widget:SetCallback("OnValueConfirmed", ActivateControl)
end
function factories:Dropdown(widget, value)
	widget:SetLabel(widget.wf.label)
	widget:SetList(widget.wf.values)
	widget:SetValue(value)
	widget:SetCallback("OnValueChanged", ActivateControl)
	widget.dropdown:SetPoint('TOPLEFT', widget.label, 'BOTTOMLEFT', -18, 0)
end
function factories:EditBox(widget, value)
	widget:SetLabel(widget.wf.label)
	widget:SetText(type(value) == "string" and value or "")
	widget:SetCallback("OnEnterPressed", ActivateControl)
end
function factories:Keybinding(widget, value)
	widget:SetLabel(widget.wf.label)
	widget:SetKey(value)
	widget:SetCallback("OnKeyChanged", ActivateControl)
end
function factories:MultiLineEditBox(widget, value)
	self:EditBox(widget, value)
	widget:SetNumLines(widget.wf.lines)
end
function factories:Slider(widget, value)
	widget:SetLabel(widget.wf.label)
	widget:SetSliderValues(widget.wf.min or 0, widget.wf.max or 100, widget.wf.bigStep or widget.wf.step or 0)
	widget:SetIsPercent(widget.wf.isPercent)
	widget:SetValue(type(value) == "number" and value or 0)
	widget:SetCallback("OnValueChanged", ActivateControl)
	widget:SetCallback("OnMouseUp", ActivateControl)
end


local AceGUI = LibStub('AceGUI-3.0')
function wf.factory(widgetType, options)
	local widget = AceGUI:Create(widgetType)
	widget.wf = options or {}

	-- by default the new widgets are created
	-- with UIParent as their parent switch this to the frame passed in
	if widget.wf.parent then
		widget.frame:SetParent(widget.wf.parent)
	end

	-- perform specific widget type configurations
	if factories[widgetType] then
		factories[widgetType](factories, widget, GetValue(widget))
	end

	-- perform common configurations	
	if widget.wf.width then
		widget:SetWidth(widget.wf.width)
	end
	if widget.wf.height then
		widget:SetHeight(widget.wf.height)
	end
	if widget.wf.disabled then
		widget:SetDisabled(widget.wf.disabled)
	end

	-- setup tooltips for the widget
	if widget.wf.tooltip then
		widget:SetCallback('OnLeave', HideTooltip)
		widget:SetCallback('OnEnter', ShowTooltip)
	end

	widget.frame:Show()
	return widget
end


function wf.dialog(parent, width, height)
	local frame = CreateFrame('Frame', nil, parent or UIParent)
	frame:SetFrameStrata('FULLSCREEN_DIALOG')
	frame:SetWidth(width or 350)
	frame:SetHeight(height or 225)
	frame:SetPoint('CENTER', InterfaceOptionsFrame, 'CENTER', 0, 40)
	frame:SetBackdrop({
		bgFile = 'Interface/CharacterFrame/UI-Party-Background',
		edgeFile = 'Interface/DialogFrame/UI-DialogBox-Border',
		tile = true,
		tileSize = 32,
		edgeSize = 32,
	  insets = {
	    left = 11,
	    right = 12,
	    top = 12,
	    bottom = 11
	  }
	})

	-- create a mask to block out all the other interface options
	frame.mask = CreateFrame('Frame', nil, InterfaceOptionsFrame)
	frame.mask:SetPoint('TOPLEFT')
	frame.mask:SetPoint('BOTTOMRIGHT')
	frame.mask:SetBackdrop({
		bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
		tile = true,
		tileSize = 16
	})
	frame.mask:SetBackdropColor(0.2, 0.2, 0.2)
	frame.mask:SetFrameLevel(129)
	frame.mask:EnableMouse(true)
	frame.mask:Hide()

	-- setup our dialog to hide/show our mask whenever it is shown/hidden
	frame:SetScript('OnHide', function() frame.mask:Hide() end)
	frame:SetScript('OnShow', function() frame.mask:Show() end)
	frame:Hide()

	return frame
end
