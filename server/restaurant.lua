-- =====================================================
-- SERVER/RESTAURANT.LUA - Fries Selling (Server)
-- Handles selling fries and payment
-- =====================================================

RegisterNetEvent('wheat:restaurant:sell', function(amount)
    local source = source
    
    -- Security: Rate limit
    if not CheckRateLimit(source) then
        return
    end
    
    -- Guard: Restaurant disabled
    if not Config.Restaurant or not Config.Restaurant.enabled then
        return
    end
    
    -- Security: Distance validation
    if not ValidateDistance(source, Config.Restaurant.location, 'restaurant sell') then
        return
    end
    
    -- Sanitize amount
    amount = SanitizeNumber(amount, 1, Config.Restaurant.maxSellAmount or 100, 0)
    
    if amount <= 0 then
        NotifyPlayer(source, 'Ungültige Menge!', 'error')
        return
    end
    
    -- Validate player has enough fries
    if not ValidateItemAmount(source, Config.Restaurant.item, amount, 'restaurant sell') then
        return
    end
    
    -- Calculate price (with dynamic pricing)
    local basePrice = Config.Restaurant.pricePerItem
    local pricePerItem = CalculateDynamicPrice(basePrice, Config.Restaurant.dynamicPricing)
    local totalPrice = pricePerItem * amount
    
    -- Remove fries
    local removed = RemoveItem(source, Config.Restaurant.item, amount)
    
    if not removed then
        NotifyPlayer(source, 'Fehler beim Entfernen der Items!', 'error')
        return
    end
    
    -- Add money
    local moneyAdded = AddMoney(source, 'cash', totalPrice)
    
    if not moneyAdded then
        -- Refund fries if payment failed
        AddItem(source, Config.Restaurant.item, amount)
        NotifyPlayer(source, 'Fehler bei der Zahlung!', 'error')
        return
    end
    
    -- Log action
    LogAction('RESTAURANT_SELL', source, string.format(
        'Amount: %dx %s | Price/Item: $%d | Total: $%d',
        amount,
        Config.Restaurant.item,
        pricePerItem,
        totalPrice
    ))
    
    -- Notify success
    NotifyPlayer(source, string.format(
        'Du hast %dx %s für $%d verkauft! ($%d pro Einheit)',
        amount,
        Config.Restaurant.item,
        totalPrice,
        pricePerItem
    ), 'success')
end)