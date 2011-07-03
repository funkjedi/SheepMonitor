
local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale('SheepMonitor', 'zhTW', false);


if L then

	L['WARNING_APPLIED'] = '%s 已施放在 %s'
	L['WARNING_BROKEN'] = '%s 已失效'
	L['WARNING_BROKEN_BY'] = '%s 已被 %s 的 %s 破壞'
	L['WARNING_BREAK_INCOMING'] = '%s 剩餘 %d 秒失效'

	-- used for options
	L['DESCRIPTION'] = 'SheepMonitor 協助你追蹤控場及各種警告方式。'
	L['ENABLE_NOTIFIER'] = '啟用控場計時器'
	L['GROW_UPWARDS'] = 'List grows upwards'
	L['ENABLE_OMNICC'] = '啟用 OmniCC 整合 (測試性)'
	L['ENABLE_QUARTZ'] = '啟用 Quartz 整合'
	L['WARNINGS_HEADER'] = '警告訊息'
	L['ENABLE_PARTY'] = '發送警告給 隊伍/戰場/團隊 成員'
	L['ENABLE_RAID'] = '在螢幕中間顯示警告'
	L['ENABLE_CHAT'] = '在聊天視窗顯示警告'
	L['ENABLE_PARTY_TOOLTIP'] = '請謹慎使用此功能，過多的警告可能會使成員反感。'
	L['ENABLE_POLYMORPH_MESSAGES'] = '目標被控場時發送警告'
	L['ENABLE_BREAK_MESSAGES'] = '控場被破壞時發送警告'
	L['ENABLE_BREAK_WARNING_MESSAGE'] = '控場時間剩餘 5 秒時開始發送警告'
	L['AUDIBLE_BREAK_SOUND'] = '控場失效時播放音效'
	L['AUDIBLE_BREAK_WARNING_SOUND'] = '控場時間剩餘 5 秒時播放音效'

end