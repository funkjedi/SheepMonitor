
local L = LibStub('AceLocale-3.0'):NewLocale('SheepMonitor', 'enUS', true);

L['DESCRIPTION'] = 'SheepMonitor provides various methods of notification to help you keep track of your flock.'

L['ENABLE_NOTIFIER'] = 'Enable visual notifier'
L['ENABLE_OMNICC'] = 'Enable OmniCC integration (experimental)'
L['ENABLE_RAID'] = 'Enable raid-style warnings'
L['ENABLE_RAID_TOOLTIP'] = 'NO ACTUAL RAID WARNINGS ARE SENT TO ANYONE OTHER THAN YOU'
L['ENABLE_CHAT'] = 'Enable chat message warnings'
L['ENABLE_PARTY'] = 'Enable party/raid notifications'
L['ENABLE_BREAK_MESSAGES'] = 'Show warning when sheep breaks polymorph'
L['ENABLE_BREAK_WARNING_MESSAGE'] = 'Show 5 second countdown to sheep breaking polymorph'
L['AUDIBLE_BREAK_SOUND'] = 'Play sound when sheep breaks polymorph.'
L['AUDIBLE_BREAK_WARNING_SOUND'] = 'Play sound 5 seconds before sheep breaks polymorph.'

L['WARNING_BROKEN'] = '%s has broken'
L['WARNING_BROKEN_BY'] = '%s broken by %s (%s)'
L['WARNING_BREAK_INCOMING'] = '%s breaks in %d seconds'
