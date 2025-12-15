-- =====================================================
-- SERVER/RESTAURANT.LUA - Fries Selling Event Handler
-- Single Responsibility: Handle fries → money selling
-- =====================================================

RegisterNetEvent('wheat:restaurant:sell', function(amount)
    local source = source
    
    -- Guard: Restaurant disabled
    if not Config.Restaurant or not Config.Restaurant.enabled then
        if Config.EnableLogging then
            print('[WheatFarm] Restaurant is disabled!')
        end
        return
    end
    
    -- Guard: Validate player
    if not ValidatePlayer(source) then
        return
    end
    
    -- Guard: Validate amount
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        Notify(source, 'Ungültige Menge!', 'error')
        return
    end
    
    if amount > (Config.Restaurant.maxSellAmount or 100) then
        Notify(source, string.format('Du kannst maximal %dx verkaufen!', Config.Restaurant.maxSellAmount), 'error')
        return
    end
    
    -- Security: Cooldown check
    local onCooldown, remaining = IsOnCooldown(source, 'restaurant_sell')
    if onCooldown then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Player %s is on cooldown (%ds remaining)', 
                source, remaining))
        end
        Notify(source, Lang:t('notify_cooldown'), 'error')
        return
    end
    
    -- Set cooldown
    SetCooldown(source, 'restaurant_sell')
    
    -- Get actual fries count (player might not have the amount they requested)
    local friesCount = GetItemCount(source, Config.Restaurant.item)
    
    -- Guard: No fries
    if friesCount <= 0 then
        Notify(source, 'Du hast keine Pommes!', 'error')
        return
    end
    
    -- Adjust amount to what player actually has
    if amount > friesCount then
        amount = friesCount
    end
    
    -- Calculate price (with dynamic pricing)
    local pricePerItem = CalculateDynamicPrice(
        Config.Restaurant.pricePerItem, 
        Config.Restaurant.dynamicPricing
    )
    local totalPrice = pricePerItem * amount
    
    -- Remove fries
    local removeSuccess, errorCode = SafeRemoveItem(source, Config.Restaurant.item, amount)
    
    if not removeSuccess then
        Notify(source, 'Fehler beim Entfernen der Pommes!', 'error')
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Failed to remove fries from player %s: %s', 
                source, errorCode))
        end
        return
    end
    
    -- Add money
    local moneyAdded = AddMoney(source, totalPrice)
    
    if moneyAdded then
        -- Success notification
        TriggerClientEvent('wheat:restaurant:success', source, amount, totalPrice, pricePerItem)
        
        -- Log selling
        LogSelling(source, Config.Restaurant.item, amount, totalPrice)
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] ✅ Player %s sold %dx fries for $%d', 
                source, amount, totalPrice))
        end
    else
        -- Rollback: Give fries back
        AddItem(source, Config.Restaurant.item, amount)
        Notify(source, 'Fehler beim Hinzufügen von Geld!', 'error')
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] ❌ Failed to add money for player %s - rolled back', source))
        end
    end
end)

-- Client event registration (handled on client)
RegisterNetEvent('wheat:restaurant:success', function(amount, totalPrice, pricePerItem)
    -- Registered on client side
end)