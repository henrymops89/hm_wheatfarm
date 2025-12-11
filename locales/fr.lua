local Translations = {
    -- Blip
    blip_name = "Champ de Blé",
    
    -- TextUI
    textui_plow = "[E] Labourer le Blé | [G] Auto-Farm",
    
    -- Progress Bar
    progress_plowing = "Labour du blé...",
    
    -- Notifications
    notify_success = "Vous avez labouré %dx blé! 🌾",
    notify_autofarm_start = "Auto-Farm activé! (Moins de rendement)",
    notify_autofarm_stop = "Auto-Farm désactivé!",
    notify_action_cancelled = "Action annulée - Champ quitté!",
    notify_no_tool = "Vous avez besoin d'une houe pour cultiver!",
    notify_tool_broken = "Votre houe s'est cassée! 💔",
    notify_tool_damaged = "Votre houe a pris des dégâts (%d%% durabilité)",
    
    -- Logging
    log_plow = "[WheatFarm] Joueur %s a labouré %dx blé"
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})