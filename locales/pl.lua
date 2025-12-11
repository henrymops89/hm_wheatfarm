local Translations = {
    -- Blip
    blip_name = "Pole Pszenicy",
    
    -- TextUI
    textui_plow = "[E] Orz Pszenicę | [G] Auto-Farm",
    
    -- Progress Bar
    progress_plowing = "Orkowanie pszenicy...",
    
    -- Notifications
    notify_success = "Zebrałeś %dx pszenicy! 🌾",
    notify_autofarm_start = "Auto-Farm aktywowany! (Mniej plonów)",
    notify_autofarm_stop = "Auto-Farm wyłączony!",
    notify_action_cancelled = "Akcja anulowana - Opuściłeś pole!",
    notify_no_tool = "Potrzebujesz motyki do uprawy!",
    notify_tool_broken = "Twoja motyka się zepsuła! 💔",
    notify_tool_damaged = "Twoja motyka została uszkodzona (%d%% wytrzymałości)",
    
    -- Logging
    log_plow = "[WheatFarm] Gracz %s zebrał %dx pszenicy"
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})