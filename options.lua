
local L = LibStub('AceLocale-3.0'):GetLocale('SheepMonitor')
local wf = LibStub('LibWidgetFactory-1.0')


local frame = CreateFrame('Frame', nil, InterfaceOptionsFrame)
frame.name = 'SheepMonitor'

InterfaceOptions_AddCategory(frame)

--generic getter and setter functions for our notifier
local function getOption(key)
	return SheepMonitor.db.char[key]
end
local function setOption(key, value)
	SheepMonitor.db.char[key] = value
end
local function setOptionPreview(key, value)
	SheepMonitor.db.char[key] = value
	PlaySoundFile(value)
end


function SheepMonitor:CreateInterfaceOptions()
	local header = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	header:SetText('SheepMonitor')
	header:SetPoint('TOPLEFT', 16, -16)

	header.subheading = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	header.subheading:SetText(L['DESCRIPTION'])
	header.subheading:SetHeight(38)
	header.subheading:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', 0, -8)
	header.subheading:SetPoint('RIGHT', frame, -32, 0)
	header.subheading:SetNonSpaceWrap(true)
	header.subheading:SetJustifyH('LEFT')
	header.subheading:SetJustifyV('TOP')

	local enableNotifier = wf.factory('CheckBox', {
		key = 'enableNotifier',
		parent = frame,
		label = L['ENABLE_NOTIFIER'],
		width = 400,
		get = getOption,
		set = setOption
	})
	enableNotifier.frame:SetPoint('TOPLEFT', header.subheading, 'BOTTOMLEFT', 0, 0)

	local growUpwards = wf.factory('CheckBox', {
		key = 'growUpwards',
		parent = frame,
		label = L['GROW_UPWARDS'],
		width = 400,
		fontSize = 'small',
		get = getOption,
		set = setOption
	})
	growUpwards.frame:SetPoint('TOPLEFT', enableNotifier.frame, 'BOTTOMLEFT', 20, 6)

	local enableOmniCC = wf.factory('CheckBox', {
		key = 'enableOmniCC',
		parent = frame,
		label = L['ENABLE_OMNICC'],
		width = 400,
		get = getOption,
		set = setOption
	})
	enableOmniCC.frame:SetPoint('TOPLEFT', growUpwards.frame, 'BOTTOMLEFT', -20, 0)

	local enableQuartz = wf.factory('CheckBox', {
		key = 'enableQuartz',
		parent = frame,
		label = L['ENABLE_QUARTZ'],
		width = 400,
		get = getOption,
		set = setOption
	})
	enableQuartz.frame:SetPoint('TOPLEFT', enableOmniCC.frame, 'BOTTOMLEFT', 0, 4)

	local monitorRaid = wf.factory('CheckBox', {
		key = 'monitorRaid',
		parent = frame,
		label = L['MONITOR_RAID'],
		width = 400,
		get = getOption,
		set = setOption
	})
	monitorRaid.frame:SetPoint('TOPLEFT', enableQuartz.frame, 'BOTTOMLEFT', 0, -10)


	local raidheader = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	raidheader:SetText(L['WARNINGS_HEADER'])
	raidheader:SetPoint('TOPLEFT', monitorRaid.frame, 'BOTTOMLEFT', 0, -20)

	local enableRaid = wf.factory('CheckBox', {
		key = 'enableRaid',
		parent = frame,
		label = L['ENABLE_RAID'],
		width = 400,
		get = getOption,
		set = setOption
	})
	enableRaid.frame:SetPoint('TOPLEFT', raidheader, 'BOTTOMLEFT', 0, -10)

	local enableChat = wf.factory('CheckBox', {
		key = 'enableChat',
		parent = frame,
		label = L['ENABLE_CHAT'],
		width = 400,
		get = getOption,
		set = setOption
	})
	enableChat.frame:SetPoint('TOPLEFT', enableRaid.frame, 'BOTTOMLEFT', 0, 4)

	local enableParty = wf.factory('CheckBox', {
		key = 'enableParty',
		parent = frame,
		label = L['ENABLE_PARTY'],
		tooltip = L['ENABLE_PARTY_TOOLTIP'],
		width = 400,
		get = getOption,
		set = setOption
	})
	enableParty.frame:SetPoint('TOPLEFT', enableChat.frame, 'BOTTOMLEFT', 0, 4)


	local enablePolymorphMessages = wf.factory('CheckBox', {
		key = 'enablePolymorphMessages',
		parent = frame,
		label = L['ENABLE_POLYMORPH_MESSAGES'],
		width = 400,
		fontSize = 'small',
		get = getOption,
		set = setOption
	})
	enablePolymorphMessages.frame:SetPoint('TOPLEFT', enableParty.frame, 'BOTTOMLEFT', 20, 0)

	local enableBreakMessages = wf.factory('CheckBox', {
		key = 'enableBreakMessages',
		parent = frame,
		label = L['ENABLE_BREAK_MESSAGES'],
		width = 400,
		fontSize = 'small',
		get = getOption,
		set = setOption
	})
	enableBreakMessages.frame:SetPoint('TOPLEFT', enablePolymorphMessages.frame, 'BOTTOMLEFT', 0, 6)

	local enableBreakWarningMessages = wf.factory('CheckBox', {
		key = 'enableBreakWarningMessages',
		parent = frame,
		label = L['ENABLE_BREAK_WARNING_MESSAGE'],
		width = 400,
		fontSize = 'small',
		get = getOption,
		set = setOption
	})
	enableBreakWarningMessages.frame:SetPoint('TOPLEFT', enableBreakMessages.frame, 'BOTTOMLEFT', 0, 6)


	local sounds = {
		['Sound\\Interface\\AlarmClockWarning3.wav'] = 'Alarm Clock Warning 3',
		['Sound\\Interface\\RaidWarning.wav'] = 'Raid Warning',
		['Interface\\AddOns\\SheepMonitor\\sounds\\blip.mp3'] = 'Blip',
		['Interface\\AddOns\\SheepMonitor\\sounds\\boing1.mp3'] = 'Boing 1',
		['Interface\\AddOns\\SheepMonitor\\sounds\\boing2.mp3'] = 'Boing 2',
		['Interface\\AddOns\\SheepMonitor\\sounds\\boing3.mp3'] = 'Boing 3',
		['Interface\\AddOns\\SheepMonitor\\sounds\\boxing_bell.mp3'] = 'Boxing bell',
		['Interface\\AddOns\\SheepMonitor\\sounds\\bubbles_sfx.mp3'] = 'Bubbles',
		['Interface\\AddOns\\SheepMonitor\\sounds\\buzzer_x.mp3'] = 'Buzzer',
		['Interface\\AddOns\\SheepMonitor\\sounds\\cork_pop_x.mp3'] = 'Cork popping',
		['Interface\\AddOns\\SheepMonitor\\sounds\\gasp_x.mp3'] = 'Gasp',
		['Interface\\AddOns\\SheepMonitor\\sounds\\gdi_warning.mp3'] = 'GDI Warning',
		['Interface\\AddOns\\SheepMonitor\\sounds\\pluck.mp3'] = 'Pluck',
		['Interface\\AddOns\\SheepMonitor\\sounds\\whah_whah.mp3'] = 'Whah whah whah',
		['Interface\\AddOns\\SheepMonitor\\sounds\\cant_takeit.mp3'] = 'Iago (Aladdin)',
		['Interface\\AddOns\\SheepMonitor\\sounds\\big_bopper_hello_baby.mp3'] = 'The Big Bopper',
	}

	local enableAudibleBreak = wf.factory('CheckBox', {
		key = 'enableAudibleBreak',
		parent = frame,
		label = ' ',
		width = 30,
		get = getOption,
		set = setOption
	})
	enableAudibleBreak.frame:SetPoint('TOPLEFT', enableBreakWarningMessages.frame, 'BOTTOMLEFT', -20, -20)

	local audibleBreakSound = wf.factory('Dropdown', {
		key = 'audibleBreakSound',
		parent = frame,
		label = ' ',
		values = sounds,
		width = 175,
		get = getOption,
		set = setOptionPreview
	})
	audibleBreakSound.frame:SetPoint('LEFT', enableAudibleBreak.frame, 'RIGHT', 0, 10)

	audibleBreakDesc = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	audibleBreakDesc:SetText(L['AUDIBLE_BREAK_SOUND'])
	audibleBreakDesc:SetHeight(32)
	audibleBreakDesc:SetPoint('TOPLEFT', audibleBreakSound.frame, 'TOPRIGHT', 8, -16)
	audibleBreakDesc:SetPoint('RIGHT', frame, -16, 0)
	audibleBreakDesc:SetNonSpaceWrap(true)
	audibleBreakDesc:SetJustifyH('LEFT')
	audibleBreakDesc:SetJustifyV('MIDDLE')


	local enableAudibleBreakWarning = wf.factory('CheckBox', {
		key = 'enableAudibleBreakWarning',
		parent = frame,
		label = ' ',
		width = 30,
		get = getOption,
		set = setOption
	})
	enableAudibleBreakWarning.frame:SetPoint('TOPLEFT', enableAudibleBreak.frame, 'BOTTOMLEFT', 0, -10)

	local audibleBreakWarningSound = wf.factory('Dropdown', {
		key = 'audibleBreakWarningSound',
		parent = frame,
		label = ' ',
		values = sounds,
		width = 175,
		get = getOption,
		set = setOptionPreview
	})
	audibleBreakWarningSound.frame:SetPoint('LEFT', enableAudibleBreakWarning.frame, 'RIGHT', 0, 10)

	audibleBreakWarningDesc = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	audibleBreakWarningDesc:SetText(L['AUDIBLE_BREAK_WARNING_SOUND'])
	audibleBreakWarningDesc:SetHeight(32)
	audibleBreakWarningDesc:SetPoint('TOPLEFT', audibleBreakWarningSound.frame, 'TOPRIGHT', 8, -16)
	audibleBreakWarningDesc:SetPoint('RIGHT', frame, -16, 0)
	audibleBreakWarningDesc:SetNonSpaceWrap(true)
	audibleBreakWarningDesc:SetJustifyH('LEFT')
	audibleBreakWarningDesc:SetJustifyV('MIDDLE')
end

