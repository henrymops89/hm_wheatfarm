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
        NotifyPlayer(source, 'Ungültige Menge!', 'error')
        return
    end
    
    -- Validate player has enough flour
    if not ValidateItemAmount(source, Config.Bakery.item, amount, 'bakery sell') then
        return
    end
    
    -- Calculate price (with dynamic pricing)
    local basePrice = Config.Bakery.pricePerItem
    local pricePerItem, isPeakHour, bonusPercent = CalculateDynamicPrice(basePrice, Config.Bakery.dynamicPricing)
    local totalPrice = pricePerItem * amount
    
    -- Remove flour
    local removed = RemoveItem(source, Config.Bakery.item, amount)
    
    if not removed then
        NotifyPlayer(source, 'Fehler beim Entfernen der Items!', 'error')
        return
    end
    
    -- Add money
    local moneyAdded = AddMoney(source, 'cash', totalPrice)
    
    if not moneyAdded then
        -- Refund flour if payment failed
        AddItem(source, Config.Bakery.item, amount)
        NotifyPlayer(source, 'Fehler bei der Zahlung!', 'error')
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
    
    NotifyPlayer(source, message, 'success')
end)