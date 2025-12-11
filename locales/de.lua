local Translations = {
    -- Blip
    blip_name = "Weizenfeld",
    
    -- TextUI
    textui_plow = "[E] Weizen pflügen | [G] Auto-Farm",
    
    -- Progress Bar
    progress_plowing = "Weizen wird gepflügt...",
    
    -- Benachrichtigungen
    notify_success = "Du hast %dx Weizen gepflügt! 🌾",
    notify_autofarm_start = "Auto-Farm aktiviert! (Weniger Ertrag)",
    notify_autofarm_stop = "Auto-Farm deaktiviert!",
    notify_action_cancelled = "Aktion abgebrochen - Feld verlassen!",
    notify_no_tool = "Du benötigst eine Hacke zum Farmen!",
    notify_tool_broken = "Deine Hacke ist kaputt gegangen! 💔",
    notify_tool_damaged = "Deine Hacke hat Schaden genommen (%d%% Haltbarkeit)",
    notify_cooldown = "Bitte warte noch einen Moment! ⏱️",
    
    -- Logging
    log_plow = "[WheatFarm] Spieler %s hat %dx Weizen gepflügt"
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
