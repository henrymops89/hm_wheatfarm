local Translations = {
    -- Blip
    blip_name = "Buğday Tarlası",
    
    -- TextUI
    textui_plow = "[E] Buğday Sür | [G] Otomatik-Farm",
    
    -- Progress Bar
    progress_plowing = "Sürülüyor...",
    progress_cooldown = "Bekleniyor...",
    progress_cancel = "İptal",
    
    -- Notifications
    notify_success = "%dx buğday sürdün! 🌾",
    notify_autofarm_start = "Otomatik-Farm aktif! (Daha az verim)",
    notify_autofarm_stop = "Otomatik-Farm devre dışı!",
    notify_action_cancelled = "İşlem iptal edildi - Tarlayı terk ettin!",
    notify_action_cancelled_manual = "İşlem iptal edildi!",
    notify_no_tool = "Tarım yapmak için çapaya ihtiyacın var!",
    notify_tool_broken = "Çapan kırıldı! 💔",
    notify_tool_damaged = "Çapan hasar gördü (%d%% dayanıklılık)",
    notify_cooldown = "Lütfen bekleyin! ⏱️",
    
    -- Logging
    log_plow = "[WheatFarm] Oyuncu %s %dx buğday sürdü"
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
