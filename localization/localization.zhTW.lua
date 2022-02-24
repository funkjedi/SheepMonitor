local L = LibStub:GetLibrary('AceLocale-3.0'):NewLocale('SheepMonitor', 'zhTW', false);

if L then

    L['WARNING_APPLIED'] = '%s 已施放在 %s'
    L['WARNING_BROKEN'] = '%s 已被破除'
    L['WARNING_BROKEN_BY'] = '%s破除在%s(%s)'
    L['WARNING_BREAK_INCOMING'] = '%s將在%d秒後解除'

    -- used for options
    L['DESCRIPTION'] = 'SheepMonitor提供了各種方法的通知，以幫助您追踪您的控場。'
    L['MONITOR_RAID'] = '監視器 隊伍/戰場/團隊 人群控制'
    L['ENABLE_NOTIFIER'] = '啟用視覺通知'
    L['GROW_UPWARDS'] = 'List grows upwards'
    L['ENABLE_OMNICC'] = '啟用OmniCC整合(試驗性質)'
    L['ENABLE_QUARTZ'] = '啟用Quartz整合'
    L['WARNINGS_HEADER'] = '警告訊息'
    L['ENABLE_PARTY'] = '發送警告到隊伍/戰場/團隊成員'
    L['ENABLE_RAID'] = '顯示警告在螢幕'
    L['ENABLE_CHAT'] = '顯示警告在聊天視窗'
    L['ENABLE_PARTY_TOOLTIP'] = '請謹慎使用此有可能去惹惱人們'
    L['ENABLE_POLYMORPH_MESSAGES'] = '當目標被變形'
    L['ENABLE_BREAK_MESSAGES'] = '當羊解除變形'
    L['ENABLE_BREAK_WARNING_MESSAGE'] = '羊解除變形的5秒倒數'
    L['AUDIBLE_BREAK_SOUND'] = '當羊解除變形時播放音效'
    L['AUDIBLE_BREAK_WARNING_SOUND'] = '當羊解除變形前5秒播放音效'

end
