-- =====================================================
-- LOCALES/EN.LUA - English Translations
-- =====================================================

Lang = Locale:new({
    phrases = {
        -- General
        ['inventory_full'] = 'Your inventory is full!',
        ['not_enough_items'] = 'You don\'t have enough %s!',
        ['invalid_amount'] = 'Invalid amount!',
        ['please_wait'] = 'Please wait %d more seconds!',
        ['too_far_away'] = 'You are too far away!',
        ['action_cancelled'] = 'Action cancelled!',
        
        -- Tools
        ['tool_required'] = 'You need: %s',
        ['tool_broken'] = 'Your tool broke! 💔',
        ['tool_almost_broken'] = 'Your tool almost broke, but you managed to repair it!',
        
        -- Farming
        ['harvesting'] = 'Harvesting %s...',
        ['harvested_success'] = 'You harvested %dx %s! 🌾',
        ['already_harvesting'] = 'You are already harvesting!',
        ['auto_farm_active'] = 'Auto-farm is already running!',
        ['auto_farm_cooldown'] = 'Wait before auto-farming again!',
        ['auto_farm_label'] = 'Auto-Farm: %s',
        
        -- Mill
        ['milling'] = 'Milling wheat...',
        ['mill_success'] = 'You produced %dx flour!',
        ['mill_processing'] = 'The mill is already processing!',
        ['not_enough_wheat'] = 'Not enough wheat! Required: %d',
        
        -- Processor
        ['processing'] = 'Frying potatoes...',
        ['processor_success'] = 'You produced %dx fries!',
        ['processor_active'] = 'The fryer is already in use!',
        ['not_enough_potatoes'] = 'Not enough potatoes! Required: %d',
        
        -- Bakery
        ['selling_flour'] = 'Selling flour...',
        ['bakery_success'] = 'You sold %dx flour for $%d! ($%d per unit)',
        ['no_flour'] = 'You have no flour to sell!',
        ['already_selling'] = 'You are already selling!',
        
        -- Restaurant
        ['selling_fries'] = 'Selling fries...',
        ['restaurant_success'] = 'You sold %dx fries for $%d! ($%d per unit)',
        ['no_fries'] = 'You have no fries to sell!',
        
        -- Player States
        ['player_dead'] = 'You can\'t do this while dead!',
        ['in_vehicle'] = 'You must exit the vehicle!',
        
        -- Errors
        ['error_remove_items'] = 'Error removing items!',
        ['error_payment'] = 'Payment error!',
        
        -- UI
        ['sell_flour_title'] = 'Sell Flour',
        ['sell_fries_title'] = 'Sell Fries',
        ['amount_label'] = 'Amount',
        ['you_have'] = 'You have: %dx',
        ['price_per_unit'] = 'Price: $%d per unit',
        
        -- Blips
        ['farm_blip'] = '%s Farm',
        ['mill_blip'] = 'Mill',
        ['processor_blip'] = 'Fry Shop',
        ['bakery_blip'] = 'Bakery',
        ['restaurant_blip'] = 'Fast-Food Restaurant',
        
        -- Interactions
        ['press_e_harvest'] = '[E] Harvest %s',
        ['press_g_autofarm'] = '[G] Confirm Auto-Farm',
        ['press_e_process'] = '[E] Process',
        ['press_e_sell'] = '[E] Sell',
    },
    warnOnMissing = true
})
