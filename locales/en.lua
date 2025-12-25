-- =====================================================
-- LOCALES/EN.LUA - English Translations (COMPLETE v2.2.1)
-- =====================================================
Locales['en'] = Locale:new({
    phrases = {
        -- General
        ['inventory_full'] = 'Your inventory is full!',
        ['not_enough_items'] = 'You don\'t have enough %s!',
        ['not_enough_item'] = 'You don\'t have enough %s!',
        ['invalid_amount'] = 'Invalid amount!',
        ['please_wait'] = 'Please wait %d more seconds!',
        ['too_far_away'] = 'You are too far away!',
        ['action_cancelled'] = 'Action cancelled!',
        ['sale_cancelled'] = 'Sale cancelled!',
        ['processing_cancelled'] = 'Processing cancelled!',
        ['harvest_cancelled'] = 'Harvest cancelled!',
        
        -- Tools
        ['tool_required'] = 'You need: %s',
        ['tool_broken'] = 'Your tool broke! 💔',
        ['tool_broke'] = 'Your tool broke! 💔',
        ['tool_almost_broken'] = 'Your tool almost broke, but you managed to repair it!',
        
        -- Farming
        ['harvesting'] = 'Harvesting %s...',
        ['harvested_success'] = 'You harvested %dx %s! 🌾',
        ['already_harvesting'] = 'You are already harvesting!',
        ['already_farming'] = 'You are already harvesting!',
        ['auto_farm_active'] = 'Auto-farm is already running!',
        ['auto_farm_cooldown'] = 'Wait before auto-farming again!',
        ['auto_farm_label'] = 'Auto-Farm: %s',
        ['autofarm_started'] = 'Auto-Farm started! Press [G] to stop 🔄',
        ['autofarm_stopped'] = 'Auto-Farm stopped! 🛑',
        ['autofarm_stopped_zone'] = 'Auto-Farm stopped: Left zone!',
        ['autofarm_stopped_no_tool'] = 'Auto-Farm stopped: No tool!',
        ['autofarm_cancelled'] = 'Auto-Farm cancelled!',
        
        -- Mill
        ['milling'] = 'Milling wheat...',
        ['mill_success'] = 'You produced %dx flour!',
        ['mill_processing'] = 'The mill is already processing!',
        ['mill_busy'] = 'The mill is already processing!',
        ['not_enough_wheat'] = 'Not enough wheat! Required: %d',
        
        -- Processor
        ['processing'] = 'Frying potatoes...',
        ['processor_success'] = 'You produced %dx fries!',
        ['processor_active'] = 'The fryer is already in use!',
        ['processor_busy'] = 'The fryer is already in use!',
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
        
        -- Target Labels
        ['mill_target_label'] = 'Process Wheat',
        ['processor_target_label'] = 'Process Potatoes',
        ['bakery_target_label'] = 'Sell Flour',
        ['restaurant_target_label'] = 'Sell Fries',
        
        -- Specific messages
        ['no_flour_to_sell'] = 'You have no %s to sell!',
        ['sell_flour_description'] = 'You have: %dx | Price: $%d per unit',
        ['not_enough_flour'] = 'You don\'t have enough %s!',
        ['sell_fries_description'] = 'You have: %dx | Price: $%d per unit',
        ['not_enough_fries'] = 'You don\'t have enough %s!',
        ['need_tool'] = 'You need: %s',
        
        -- Success Messages (Client Events)
        ['harvested_x'] = 'You harvested %dx %s! 🌾',
        ['produced_flour'] = 'You produced %dx flour!',
        ['sold_flour'] = 'You sold %dx flour for $%d! ($%d per unit)',
        
        -- Server Success Messages
        ['sold_for_total'] = 'You received $%d for %dx %s! ($%d per unit)',
        ['sold_with_peak_bonus'] = 'You received $%d for %dx %s! + $%d (Peak Hours Bonus: +%d%%)',
        ['produced_items'] = 'You produced %dx %s!',
        
        -- Security/Validation
        ['too_far_away_security'] = 'You are too far away!',
        ['not_enough_items_security'] = 'You don\'t have enough items!',
        ['no_tool_in_inventory'] = 'You don\'t have a %s!',
        
        -- Crop Names
        ['crop_wheat'] = 'Wheat',
        ['crop_potato'] = 'Potatoes',
        
        -- TextUI / Auto-Farm
        ['autofarm_running_stop'] = '[G] Auto-Farm running - Press G to stop 🔴',
        ['harvest_crop_or_autofarm'] = '[E] Harvest %s  \n[G] Start Auto-Farm 🔄',
        ['autofarm_progress'] = 'Auto-Farm: %s 🔄',
          
        -- UI Elements
        ['key_harvest'] = '[E]',
        ['key_autofarm'] = '[G]',
        ['key_process'] = '[E]',
        ['key_sell'] = '[E]',
        
        -- Dialog Buttons
        ['ui_confirm'] = 'Confirm',
        ['ui_cancel'] = 'Cancel',
        ['ui_close'] = 'Close',
        
        -- TextUI with dynamic keys
        ['textui_harvest'] = '%s Harvest %s',          -- [E] Harvest Wheat
        ['textui_autofarm'] = '%s Start Auto-Farm',    -- [G] Start Auto-Farm
        ['textui_process'] = '%s Process',             -- [E] Process
        ['textui_sell'] = '%s Sell',                   -- [E] Sell
        ['textui_autofarm_running'] = '%s Auto-Farm running - Press %s to stop 🔴',
        ['textui_harvest_or_autofarm'] = '%s Harvest %s  \n%s Start Auto-Farm 🔄',
    },
    warnOnMissing = true
})