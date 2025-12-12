local Translations = {
    -- Blip
    blip_name = "Wheat Field",
    
    -- TextUI
    textui_plow = "[E] Plow Wheat | [G] Auto-Farm",
    
    -- Progress Bar
    progress_plowing = "Plowing wheat...",
    progress_cooldown = "Waiting for next harvest...",
    progress_cancel = "Cancel",
    
    -- Notifications
    notify_success = "You plowed %dx wheat! 🌾",
    notify_autofarm_start = "Auto-Farm activated! (Less yield)",
    notify_autofarm_stop = "Auto-Farm deactivated!",
    notify_action_cancelled = "Action cancelled - Left field!",
    notify_action_cancelled_manual = "Action cancelled!",
    notify_no_tool = "You need a hoe to farm!",
    notify_tool_broken = "Your hoe broke! 💔",
    notify_tool_damaged = "Your hoe took damage (%d%% durability)",
    notify_cooldown = "Please wait a moment! ⏱️",
    
    -- Logging
    log_plow = "[WheatFarm] Player %s plowed %dx wheat"
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
