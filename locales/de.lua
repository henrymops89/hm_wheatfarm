-- =====================================================
-- LOCALES/DE.LUA - German Translations (COMPLETE v2.2.1)
-- =====================================================
Locales['de'] = Locale:new({
    phrases = {
        -- General
        ['inventory_full'] = 'Dein Inventar ist voll!',
        ['not_enough_items'] = 'Du hast nicht genug %s!',
        ['not_enough_item'] = 'Du hast nicht genug %s!',
        ['invalid_amount'] = 'Ungültige Menge!',
        ['please_wait'] = 'Bitte warte noch %d Sekunden!',
        ['too_far_away'] = 'Du bist zu weit entfernt!',
        ['action_cancelled'] = 'Aktion abgebrochen!',
        ['sale_cancelled'] = 'Verkauf abgebrochen!',
        ['processing_cancelled'] = 'Verarbeitung abgebrochen!',
        ['harvest_cancelled'] = 'Ernte abgebrochen!',
        
        -- Tools
        ['tool_required'] = 'Du benötigst: %s',
        ['tool_broken'] = 'Dein Werkzeug ist kaputt gegangen! 💔',
        ['tool_broke'] = 'Dein Werkzeug ist kaputt gegangen! 💔',
        ['tool_almost_broken'] = 'Dein Werkzeug ist fast kaputt, aber du konntest es reparieren!',
        
        -- Farming
        ['harvesting'] = '%s ernten...',
        ['harvested_success'] = 'Du hast %dx %s geerntet! 🌾',
        ['already_harvesting'] = 'Du erntest bereits!',
        ['already_farming'] = 'Du erntest bereits!',
        ['auto_farm_active'] = 'Auto-Farm läuft bereits!',
        ['auto_farm_cooldown'] = 'Warte kurz bevor du wieder auto-farmst!',
        ['auto_farm_label'] = 'Auto-Farm: %s',
        ['autofarm_started'] = 'Auto-Farm gestartet! Drücke [G] zum Stoppen 🔄',
        ['autofarm_stopped'] = 'Auto-Farm gestoppt! 🛑',
        ['autofarm_stopped_zone'] = 'Auto-Farm gestoppt: Zone verlassen!',
        ['autofarm_stopped_no_tool'] = 'Auto-Farm gestoppt: Kein Werkzeug mehr!',
        ['autofarm_cancelled'] = 'Auto-Farm abgebrochen!',
        
        -- Mill
        ['milling'] = 'Weizen wird gemahlen...',
        ['mill_success'] = 'Du hast %dx Mehl produziert!',
        ['mill_processing'] = 'Die Mühle verarbeitet bereits!',
        ['mill_busy'] = 'Die Mühle verarbeitet bereits!',
        ['not_enough_wheat'] = 'Du hast nicht genug Weizen! Benötigt: %d',
        
        -- Processor
        ['processing'] = 'Kartoffeln werden frittiert...',
        ['processor_success'] = 'Du hast %dx Pommes produziert!',
        ['processor_active'] = 'Die Fritteuse ist bereits in Betrieb!',
        ['processor_busy'] = 'Die Fritteuse ist bereits in Betrieb!',
        ['not_enough_potatoes'] = 'Du hast nicht genug Kartoffeln! Benötigt: %d',
        
        -- Bakery
        ['selling_flour'] = 'Mehl wird verkauft...',
        ['bakery_success'] = 'Du hast %dx Mehl für $%d verkauft! ($%d pro Einheit)',
        ['no_flour'] = 'Du hast kein Mehl zum Verkaufen!',
        ['already_selling'] = 'Du verkaufst bereits!',
        
        -- Restaurant
        ['selling_fries'] = 'Pommes werden verkauft...',
        ['restaurant_success'] = 'Du hast %dx Pommes für $%d verkauft! ($%d pro Einheit)',
        ['no_fries'] = 'Du hast keine Pommes zum Verkaufen!',
        
        -- Player States
        ['player_dead'] = 'Du kannst das nicht während du tot bist!',
        ['in_vehicle'] = 'Du musst aus dem Fahrzeug aussteigen!',
        
        -- Errors
        ['error_remove_items'] = 'Fehler beim Entfernen der Items!',
        ['error_payment'] = 'Fehler bei der Zahlung!',
        
        -- UI
        ['sell_flour_title'] = 'Mehl verkaufen',
        ['sell_fries_title'] = 'Pommes verkaufen',
        ['amount_label'] = 'Menge',
        ['you_have'] = 'Du hast: %dx',
        ['price_per_unit'] = 'Preis: $%d pro Einheit',
        
        -- Blips
        ['farm_blip'] = '%s Farm',
        ['mill_blip'] = 'Mühle',
        ['processor_blip'] = 'Frittenbude',
        ['bakery_blip'] = 'Bäckerei',
        ['restaurant_blip'] = 'Fast-Food Restaurant',
        
        -- Interactions
        ['press_e_harvest'] = '[E] %s ernten',
        ['press_g_autofarm'] = '[G] Auto-Farm bestätigen',
        ['press_e_process'] = '[E] Verarbeiten',
        ['press_e_sell'] = '[E] Verkaufen',
        
        -- Target Labels
        ['mill_target_label'] = 'Weizen verarbeiten',
        ['processor_target_label'] = 'Kartoffeln verarbeiten',
        ['bakery_target_label'] = 'Mehl verkaufen',
        ['restaurant_target_label'] = 'Pommes verkaufen',
        
        -- Specific messages
        ['no_flour_to_sell'] = 'Du hast kein %s zum Verkaufen!',
        ['sell_flour_description'] = 'Du hast: %dx | Preis: $%d pro Einheit',
        ['not_enough_flour'] = 'Du hast nicht genug %s!',
        ['sell_fries_description'] = 'Du hast: %dx | Preis: $%d pro Einheit',
        ['not_enough_fries'] = 'Du hast nicht genug %s!',
        ['need_tool'] = 'Du benötigst: %s',
        
        -- Success Messages (Client Events)
        ['harvested_x'] = 'Du hast %dx %s geerntet! 🌾',
        ['produced_flour'] = 'Du hast %dx Mehl produziert!',
        ['sold_flour'] = 'Du hast %dx Mehl für $%d verkauft! ($%d pro Einheit)',
        
        -- Server Success Messages
        ['sold_for_total'] = 'Du hast $%d für %dx %s bekommen! ($%d pro Einheit)',
        ['sold_with_peak_bonus'] = 'Du hast $%d für %dx %s bekommen! + $%d (Peak Hours Bonus: +%d%%)',
        ['produced_items'] = 'Du hast %dx %s produziert!',
        
        -- Security/Validation
        ['too_far_away_security'] = 'Du bist zu weit entfernt!',
        ['not_enough_items_security'] = 'Du hast nicht genug Items!',
        ['no_tool_in_inventory'] = 'Du hast kein %s!',
        
        -- Crop Names
        ['crop_wheat'] = 'Weizen',
        ['crop_potato'] = 'Kartoffeln',
        
        -- TextUI / Auto-Farm
        ['autofarm_running_stop'] = '[G] Auto-Farm läuft - Drücke G zum Stoppen 🔴',
        ['harvest_crop_or_autofarm'] = '[E] %s ernten  \n[G] Auto-Farm starten 🔄',
        ['autofarm_progress'] = 'Auto-Farm: %s 🔄',
        -- UI Elements
        ['key_harvest'] = '[E]',
        ['key_autofarm'] = '[G]',
        ['key_process'] = '[E]',
        ['key_sell'] = '[E]',
        
        -- Dialog Buttons
        ['ui_confirm'] = 'Bestätigen',
        ['ui_cancel'] = 'Abbrechen',
        ['ui_close'] = 'Schließen',
        
        -- TextUI with dynamic keys
        ['textui_harvest'] = '%s %s ernten',           -- [E] Weizen ernten
        ['textui_autofarm'] = '%s Auto-Farm starten',  -- [G] Auto-Farm starten
        ['textui_process'] = '%s Verarbeiten',         -- [E] Verarbeiten
        ['textui_sell'] = '%s Verkaufen',              -- [E] Verkaufen
        ['textui_autofarm_running'] = '%s Auto-Farm läuft - Drücke %s zum Stoppen 🔴',
        ['textui_harvest_or_autofarm'] = '%s %s ernten  \n%s Auto-Farm starten 🔄',
        -- UI Elements
        ['key_harvest'] = '[E]',
        ['key_autofarm'] = '[G]',
        ['key_process'] = '[E]',
        ['key_sell'] = '[E]',
    },
    warnOnMissing = true
})