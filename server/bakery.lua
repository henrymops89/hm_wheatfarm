-- =====================================================
-- SERVER/BAKERY.LUA - Flour Selling Event Handler
-- Single Responsibility: Handle flour → money selling
-- =====================================================

-- =====================================================
-- BAKERY SELLING EVENT HANDLER
-- =====================================================

RegisterNetEvent('wheat:bakery:sell', function(amount)
    local source = source
    
    -- Guard: Bakery disabled
    if not Config.Bakery or not Config.Bakery.enabled then
        if Config.EnableLogging then
            print('[WheatFarm] Bakery is disabled!')
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
        Notify(source, Lang:t('bakery_invalid_amount'), 'error')
        return
    end
    
    -- Limit to max sell amount
    if amount > Config.Bakery.maxSellAmount then
        amount = Config.Bakery.maxSellAmount
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Player %s tried to sell more than max (%d), limited to %d', 
                source, Config.Bakery.maxSellAmount, amount))
        end
    end
    
    -- Security Checks
    local securityPassed, reason = PerformSecurityChecks(
        source, 
        'bakery_sell', 
        Config.Bakery.location, 
        Config.Bakery.radius
    )
    
    if not securityPassed then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Bakery security check failed for player %s: %s', 
                source, reason))
        end
        return
    end
    
    -- Get actual flour count (player might not have the amount they requested)
    local flourCount = GetItemCount(source, Config.Bakery.item)
    
    -- Guard: No flour
    if flourCount <= 0 then
        Notify(source, Lang:t('bakery_no_flour'), 'error')
        return
    end
    
    -- Adjust amount to what player actually has
    if amount > flourCount then
        amount = flourCount
    end
    
    -- Calculate price (with dynamic pricing if enabled)
    local pricePerItem = CalculateDynamicPrice(
        Config.Bakery.pricePerItem, 
        Config.Bakery.dynamicPricing
    )
    
    local totalPrice = pricePerItem * amount
    
    -- Remove flour
    local removeSuccess, errorCode = SafeRemoveItem(source, Config.Bakery.item, amount)
    
    if not removeSuccess then
        Notify(source, 'Fehler beim Verkauf!', 'error')
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Failed to remove flour from player %s: %s', 
                source, errorCode))
        end
        return
    end
    
    -- Add money
    local moneySuccess = AddMoney(source, totalPrice)
    
    if moneySuccess then
        -- Success notification
        TriggerClientEvent('wheat:bakery:success', source, amount, totalPrice, pricePerItem)
        
        -- Log selling
        LogSelling(source, Config.Bakery.item, amount, totalPrice)
    else
        -- Money add failed - give flour back!
        AddItem(source, Config.Bakery.item, amount)
        Notify(source, 'Fehler beim Geld hinzufügen!', 'error')
        
        if Config.EnableLogging then
            print(string.format('^1[WheatFarm] Failed to add money to player %s! Flour returned.^7', source))
        end
    end
end)

-- =====================================================
-- UTILITY: CALCULATE SELL VALUE
-- =====================================================

-- Calculate total value of flour in player's inventory
function CalculateFlourValue(source)
    -- Guard: Bakery disabled
    if not Config.Bakery or not Config.Bakery.enabled then
        return 0
    end
    
    local flourCount = GetItemCount(source, Config.Bakery.item)
    
    if flourCount <= 0 then
        return 0
    end
    
    local pricePerItem = CalculateDynamicPrice(
        Config.Bakery.pricePerItem, 
        Config.Bakery.dynamicPricing
    )
    
    return flourCount * pricePerItem
end

-- =====================================================
-- UTILITY: GET CURRENT PRICE
-- =====================================================

-- Get current price (with dynamic pricing)
function GetCurrentFlourPrice()
    return CalculateDynamicPrice(
        Config.Bakery.pricePerItem, 
        Config.Bakery.dynamicPricing
    )
end

-- =====================================================
-- CALLBACK: GET BAKERY INFO (for UI)
-- =====================================================

lib.callback.register('wheat:bakery:getInfo', function(source)
    -- Guard: Bakery disabled
    if not Config.Bakery or not Config.Bakery.enabled then
        return nil
    end
    
    local flourCount = GetItemCount(source, Config.Bakery.item)
    local currentPrice = GetCurrentFlourPrice()
    local totalValue = flourCount * currentPrice
    
    return {
        flourCount = flourCount,
        pricePerItem = currentPrice,
        totalValue = totalValue,
        maxSellAmount = Config.Bakery.maxSellAmount,
        isPeakHour = currentPrice > Config.Bakery.pricePerItem,
    }
end)

-- =====================================================
-- DEBUG COMMANDS
-- =====================================================

if Config.EnableLogging then
    -- Force sell flour (admin/testing)
    RegisterCommand('wheatsell', function(source, args, rawCommand)
        if source == 0 then
            print('[WheatFarm] This command must be run in-game')
            return
        end
        
        local amount = tonumber(args[1])
        
        if not amount then
            -- Sell all flour
            amount = GetItemCount(source, Config.Bakery.item)
        end
        
        if amount <= 0 then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[WheatFarm]", "❌ No flour to sell!"}
            })
            return
        end
        
        -- Bypass security for testing
        local pricePerItem = GetCurrentFlourPrice()
        local totalPrice = pricePerItem * amount
        
        local removeSuccess = SafeRemoveItem(source, Config.Bakery.item, amount)
        
        if removeSuccess then
            AddMoney(source, totalPrice)
            
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"[WheatFarm]", string.format("✅ Sold %dx flour for $%d ($%d each)", 
                    amount, totalPrice, pricePerItem)}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[WheatFarm]", "❌ Selling failed!"}
            })
        end
    end, false)
    
    -- Check bakery price
    RegisterCommand('wheatprice', function(source, args, rawCommand)
        local currentPrice = GetCurrentFlourPrice()
        local basePrice = Config.Bakery.pricePerItem
        local isPeakHour = currentPrice > basePrice
        
        local currentHour = tonumber(os.date('%H'))
        
        if source == 0 then
            -- Console
            print('=== Bakery Price ===')
            print('Current Hour: ' .. currentHour)
            print('Base Price: $' .. basePrice)
            print('Current Price: $' .. currentPrice)
            print('Peak Hour: ' .. tostring(isPeakHour))
            if isPeakHour then
                local multiplier = Config.Bakery.dynamicPricing.peakHourMultiplier
                print('Multiplier: ' .. multiplier .. 'x')
            end
            print('===================')
        else
            -- Player
            local flourCount = GetItemCount(source, Config.Bakery.item)
            local totalValue = flourCount * currentPrice
            
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 255},
                args = {"[WheatFarm]", "=== Bakery Info ==="}
            })
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 255},
                args = {"", string.format("Current Price: $%d per flour %s", 
                    currentPrice, isPeakHour and "🔥 PEAK HOUR!" or "")}
            })
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 255},
                args = {"", string.format("Your flour: %d (worth $%d)", flourCount, totalValue)}
            })
            
            if Config.Bakery.dynamicPricing.enabled then
                local peakHours = table.concat(Config.Bakery.dynamicPricing.peakHours, ', ')
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 255, 255},
                    args = {"", string.format("Peak hours: %s", peakHours)}
                })
            end
        end
    end, false)
    
    -- Show bakery stats
    RegisterCommand('wheatbakerystats', function(source, args, rawCommand)
        if source ~= 0 then return end -- Console only
        
        print('=== Bakery Statistics ===')
        print('Enabled: ' .. tostring(Config.Bakery.enabled))
        print('Item: ' .. Config.Bakery.item)
        print('Base Price: $' .. Config.Bakery.pricePerItem)
        print('Max Sell Amount: ' .. Config.Bakery.maxSellAmount)
        print('Dynamic Pricing: ' .. tostring(Config.Bakery.dynamicPricing.enabled))
        
        if Config.Bakery.dynamicPricing.enabled then
            print('Peak Hour Multiplier: ' .. Config.Bakery.dynamicPricing.peakHourMultiplier .. 'x')
            print('Peak Hours: ' .. table.concat(Config.Bakery.dynamicPricing.peakHours, ', '))
        end
        
        print('========================')
    end, false)
end

-- =====================================================
-- EXPORTS
-- =====================================================

exports('CalculateFlourValue', CalculateFlourValue)
exports('GetCurrentFlourPrice', GetCurrentFlourPrice)