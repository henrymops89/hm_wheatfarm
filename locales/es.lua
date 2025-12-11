-- =====================================================
-- LOCALES/ES.LUA
-- =====================================================

local Translations = {
    -- Blip
    blip_name = "Campo de Trigo",
    
    -- TextUI
    textui_plow = "[E] Arar Trigo | [G] Auto-Farm",
    
    -- Progress Bar
    progress_plowing = "Arando trigo...",
    
    -- Notifications
    notify_success = "¡Has arado %dx trigo! 🌾",
    notify_autofarm_start = "¡Auto-Farm activado! (Menos rendimiento)",
    notify_autofarm_stop = "¡Auto-Farm desactivado!",
    notify_action_cancelled = "¡Acción cancelada - Campo abandonado!",
    notify_no_tool = "¡Necesitas una azada para cultivar!",
    notify_tool_broken = "¡Tu azada se ha roto! 💔",
    notify_tool_damaged = "Tu azada ha recibido daño (%d%% durabilidad)",
    
    -- Logging
    log_plow = "[WheatFarm] Jugador %s ha arado %dx trigo"
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
