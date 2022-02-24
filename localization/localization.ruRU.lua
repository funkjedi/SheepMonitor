local L = LibStub:GetLibrary('AceLocale-3.0'):NewLocale('SheepMonitor', 'ruRU', false);

if L then

    L['WARNING_APPLIED'] = '%s скастован на %s'
    L['WARNING_BROKEN'] = '%s сбит'
    L['WARNING_BROKEN_BY'] = '%s снят игроком %s (%s)'
    L['WARNING_BREAK_INCOMING'] = '%s будет снят через %d секунд'

    -- used for options
    L['DESCRIPTION'] =
        'SheepMonitor позволяет держать на виду все ваши виды кантроля для успешного контроля.'
    L['MONITOR_RAID'] = 'Монитор игроку/группе/рейду сдерживание толпы'
    L['ENABLE_NOTIFIER'] = 'Включить визуальное оповещение'
    L['GROW_UPWARDS'] = 'Пролистывание вверх'
    L['ENABLE_OMNICC'] = 'Включить интеграцию с OmniCC (Тест)'
    L['ENABLE_QUARTZ'] = 'Включить интеграцию с Quartz'
    L['WARNINGS_HEADER'] = 'Сообщения Предупреждений'
    L['ENABLE_PARTY'] = 'Отправлять предупреждения игроку/группе/рейду'
    L['ENABLE_RAID'] = 'Показ предупреждений на экране'
    L['ENABLE_CHAT'] = 'Показ предупреждений в окне чата'
    L['ENABLE_PARTY_TOOLTIP'] =
        'ИСПОЛЬЗУЙТЕ ВАШ ВЕСЬ ПОТЕНЦИАЛ В КОНТОРЕ И БУДЕТЕ СЧАСТЛИВЫ'
    L['ENABLE_POLYMORPH_MESSAGES'] = 'Когда цель законтролена'
    L['ENABLE_BREAK_MESSAGES'] = 'Когда контроль спадет'
    L['ENABLE_BREAK_WARNING_MESSAGE'] = '5 секунд до снятия контроля'
    L['AUDIBLE_BREAK_SOUND'] = 'Играть звук когда контроль снят.'
    L['AUDIBLE_BREAK_WARNING_SOUND'] =
        'Играть звук когда до снятия контроля осталось 5 секунд.'

end
