-- =====================================================
-- LOCALES/EN.LUA
-- =====================================================

local Translations = {
    -- Blip
    blip_name = "Wheat Field",
    
    -- TextUI
    textui_plow = "[E] Plow Wheat | [G] Auto-Farm",
    
    -- Progress Bar
    progress_plowing = "Plowing wheat...",
    
    -- Notifications
    notify_success = "You plowed %dx wheat! 🌾",
    notify_autofarm_start = "Auto-Farm activated! (Less yield)",
    notify_autofarm_stop = "Auto-Farm deactivated!",
    notify_action_cancelled = "Action cancelled - Left field!",
    notify_no_tool = "You need a hoe to farm!",
    notify_tool_broken = "Your hoe broke! 💔",
    notify_tool_damaged = "Your hoe took damage (%d%% durability)",
    
    -- Logging
    log_plow = "[WheatFarm] Player %s plowed %dx wheat"
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})