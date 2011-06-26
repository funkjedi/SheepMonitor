
local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale('SheepMonitor', 'enUS', true);


if L then

	L['WARNING_APPLIED'] = '%s has been cast on %s'
	L['WARNING_BROKEN'] = '%s has broken'
	L['WARNING_BROKEN_BY'] = '%s broken by %s (%s)'
	L['WARNING_BREAK_INCOMING'] = '%s breaks in %d seconds'

	-- used for options
	L['DESCRIPTION'] = 'SheepMonitor provides various methods of notification to help you keep track of your flock.'
	L['ENABLE_NOTIFIER'] = 'Enable visual notifier'
	L['ENABLE_OMNICC'] = 'Enable OmniCC integration (experimental)'
	L['ENABLE_QUARTZ'] = 'Enable Quartz integration'
	L['WARNINGS_HEADER'] = 'Warning Messages'
	L['ENABLE_PARTY'] = 'Send warnings to party/battleground/raid members'
	L['ENABLE_RAID'] = 'Show warnings on screen'
	L['ENABLE_CHAT'] = 'Show warnings in chat window'
	L['ENABLE_PARTY_TOOLTIP'] = 'USE WITH CAUTION THIS HAS THE POTENTIAL TO REALLY ANNOY PEOPLE YOUR PUGGING WITH'
	L['ENABLE_POLYMORPH_MESSAGES'] = 'When target is polymorphed'
	L['ENABLE_BREAK_MESSAGES'] = 'When sheep breaks polymorph'
	L['ENABLE_BREAK_WARNING_MESSAGE'] = '5 second countdown to sheep breaking polymorph'
	L['AUDIBLE_BREAK_SOUND'] = 'Play sound when sheep breaks polymorph.'
	L['AUDIBLE_BREAK_WARNING_SOUND'] = 'Play sound 5 seconds before sheep breaks polymorph.'

end