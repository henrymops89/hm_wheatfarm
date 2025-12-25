-- =====================================================
-- LOCALES/DE.LUA - German Translations
-- Hauptsprache: Deutsch
-- =====================================================

Lang = Locale:new({
    phrases = {
        -- General
        ['inventory_full'] = 'Dein Inventar ist voll!',
        ['not_enough_items'] = 'Du hast nicht genug %s!',
        ['invalid_amount'] = 'Ungültige Menge!',
        ['please_wait'] = 'Bitte warte noch %d Sekunden!',
        ['too_far_away'] = 'Du bist zu weit entfernt!',
        ['action_cancelled'] = 'Aktion abgebrochen!',
        
        -- Tools
        ['tool_required'] = 'Du benötigst: %s',
        ['tool_broken'] = 'Dein Werkzeug ist kaputt gegangen! 💔',
        ['tool_almost_broken'] = 'Dein Werkzeug ist fast kaputt, aber du konntest es reparieren!',
        
        -- Farming
        ['harvesting'] = '%s ernten...',
        ['harvested_success'] = 'Du hast %dx %s geerntet! 🌾',
        ['already_harvesting'] = 'Du erntest bereits!',
        ['auto_farm_active'] = 'Auto-Farm läuft bereits!',
        ['auto_farm_cooldown'] = 'Warte kurz bevor du wieder auto-farmst!',
        ['auto_farm_label'] = 'Auto-Farm: %s',
        
        -- Mill
        ['milling'] = 'Weizen wird gemahlen...',
        ['mill_success'] = 'Du hast %dx Mehl produziert!',
        ['mill_processing'] = 'Die Mühle verarbeitet bereits!',
        ['not_enough_wheat'] = 'Du hast nicht genug Weizen! Benötigt: %d',
        
        -- Processor
        ['processing'] = 'Kartoffeln werden frittiert...',
        ['processor_success'] = 'Du hast %dx Pommes produziert!',
        ['processor_active'] = 'Die Fritteuse ist bereits in Betrieb!',
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
    },
    warnOnMissing = true
})
