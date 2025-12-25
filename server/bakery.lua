-- =====================================================
-- SERVER/BAKERY.LUA - Flour Selling (Server)
-- Handles selling flour and payment
-- =====================================================

RegisterNetEvent('wheat:bakery:sell', function(amount)
    local source = source
    
    -- Security: Rate limit
    if not CheckRateLimit(source) then
        return
    end
    
    -- Guard: Bakery disabled
    if not Config.Bakery or not Config.Bakery.enabled then
        return
    end
    
    -- Security: Distance validation
    if not ValidateDistance(source, Config.Bakery.location, 'bakery sell') then
        return
    end
    
    -- Sanitize amount
    amount = SanitizeNumber(amount, 1, Config.Bakery.maxSellAmount or 100, 0)
    
    if amount <= 0 then
        TriggerClientEvent('wheat:notify', source, Lang:t('invalid_amount'), 'error')
        return
    end
    
    -- Server-seitige Item-Validierung!
    local hasEnough = GetItemCount(source, Config.Bakery.item)
    
    DebugPrint(string.format('Bakery: Player %d has %d x %s (wants to sell %d)', source, hasEnough, Config.Bakery.item, amount))
    
    if hasEnough < amount then
        TriggerClientEvent('wheat:notify', source, Lang:t('not_enough_item', Config.Bakery.item), 'error')
        return
    end
    
    -- Calculate price (with dynamic pricing)
    local basePrice = Config.Bakery.pricePerItem
    local pricePerItem, isPeakHour, bonusPercent = CalculateDynamicPrice(basePrice, Config.Bakery.dynamicPricing)
    local totalPrice = pricePerItem * amount
    
    -- Remove flour
    local removed = RemoveItem(source, Config.Bakery.item, amount)
    
    if not removed then
        TriggerClientEvent('wheat:notify', source, Lang:t('error_remove_items'), 'error')
        return
    end
    
    -- Add money
    local moneyAdded = AddMoney(source, 'cash', totalPrice)
    
    if not moneyAdded then
        -- Refund flour if payment failed
        AddItem(source, Config.Bakery.item, amount)
        TriggerClientEvent('wheat:notify', source, Lang:t('error_payment'), 'error')
        return
    end
    
    -- Log action
    LogAction('BAKERY_SELL', source, string.format(
        'Amount: %dx %s | Price/Item: $%d | Total: $%d%s',
        amount,
        Config.Bakery.item,
        pricePerItem,
        totalPrice,
        isPeakHour and ' | PEAK HOUR BONUS: +' .. bonusPercent .. '%' or ''
    ))
    
    -- Notify success with peak hour info
    local message
    if isPeakHour then
        local bonusAmount = totalPrice - (basePrice * amount)
        message = Lang:t('sold_with_peak_bonus', 
            totalPrice, amount, Config.Bakery.item, bonusAmount, bonusPercent)
    else
        message = Lang:t('sold_for_total', 
            totalPrice, amount, Config.Bakery.item, pricePerItem)
    end
    
    TriggerClientEvent('wheat:notify', source, message, 'success')
end)