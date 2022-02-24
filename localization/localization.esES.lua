local L = LibStub:GetLibrary('AceLocale-3.0'):NewLocale('SheepMonitor', 'esES', false);

if L then

    L['WARNING_APPLIED'] = '%s ha sido hechizado sobre %s'
    L['WARNING_BROKEN'] = '%s ha escapado'
    L['WARNING_BROKEN_BY'] = '%s rota por %s (%s)'
    L['WARNING_BREAK_INCOMING'] = '%s escapa en %d segundos'

    -- used for options
    L['DESCRIPTION'] = 'SheepMonitor provee varios métodos de notificación para ayudarte cuidar a tu manada.'
    L['MONITOR_RAID'] = 'Monitorear grupo/campo de batalla/raid cc'
    L['ENABLE_NOTIFIER'] = 'Activar notificaciones visuales'
    L['GROW_UPWARDS'] = 'Lista abre hacia arriba'
    L['ENABLE_OMNICC'] = 'Activar integración de OmniCC (experimental)'
    L['ENABLE_QUARTZ'] = 'Activar integración de Quartz'
    L['WARNINGS_HEADER'] = 'Mensajes de Avisos'
    L['ENABLE_PARTY'] = 'Enviar avisos a tu grupo/campo de batalla/miembros del raid'
    L['ENABLE_RAID'] = 'Mostrar avisos en la pantalla'
    L['ENABLE_CHAT'] = 'Mostrar avisos en la ventana del chat'
    L['ENABLE_PARTY_TOOLTIP'] =
        'USA MUCHO CUIDADO CON ESTA ADDON, YA QUE TIENE LA POTENCIAL DE MOLESTAR MUCHO A LOS OTROS MIEMBROS DE TU GRUPO'
    L['ENABLE_POLYMORPH_MESSAGES'] = 'Cuando el objetivo está transformado'
    L['ENABLE_BREAK_MESSAGES'] = 'Cuando una oveja rompe la polimorfia'
    L['ENABLE_BREAK_WARNING_MESSAGE'] = 'Cuenta regresiva de 5 segundos antes de que una oveja rompe la polimorfia'
    L['AUDIBLE_BREAK_SOUND'] = 'Reproducir sonido cuando una oveja rompe la polimorfia.'
    L['AUDIBLE_BREAK_WARNING_SOUND'] = 'Reproducir sonido antes que una oveja rompe la polimorfia.'

end
