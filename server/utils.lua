-- =====================================================
-- SERVER/UTILS.LUA - Server-Side Helper Functions
-- DRY Principle: Reusable server functions
-- =====================================================

-- =====================================================
-- PLAYER MONEY FUNCTIONS
-- =====================================================

function AddMoney(source, accountType, amount)
    -- Guard: Invalid source
    if not source or source <= 0 then return false end
    
    -- Guard: Invalid amount
    if not amount or amount <= 0 then return false end
    
    accountType = accountType or 'cash'
    
    -- Framework-specific money add
    if Framework.name == 'qbcore' then
        local Player = Framework.object.Functions.GetPlayer(source)
        if not Player then return false end
        
        return Player.Functions.AddMoney(accountType, amount, 'wheat-farm-payment')
        
    elseif Framework.name == 'qbox' then
        local success = exports.qbx_core:AddMoney(source, accountType, amount, 'wheat-farm-payment')
        return success
        
    elseif Framework.name == 'esx' then
        local xPlayer = Framework.object.GetPlayerFromId(source)
        if not xPlayer then return false end
        
        if accountType == 'cash' then
            xPlayer.addMoney(amount)
        elseif accountType == 'bank' then
            xPlayer.addAccountMoney('bank', amount)
        else
            xPlayer.addAccountMoney(accountType, amount)
        end
        
        return true
    end
    
    return false
end

function RemoveMoney(source, accountType, amount)
    if not source or source <= 0 then return false end
    if not amount or amount <= 0 then return false end
    
    accountType = accountType or 'cash'
    
    if Framework.name == 'qbcore' then
        local Player = Framework.object.Functions.GetPlayer(source)
        if not Player then return false end
        
        return Player.Functions.RemoveMoney(accountType, amount, 'wheat-farm-purchase')
        
    elseif Framework.name == 'qbox' then
        local success = exports.qbx_core:RemoveMoney(source, accountType, amount, 'wheat-farm-purchase')
        return success
        
    elseif Framework.name == 'esx' then
        local xPlayer = Framework.object.GetPlayerFromId(source)
        if not xPlayer then return false end
        
        if accountType == 'cash' then
            xPlayer.removeMoney(amount)
        elseif accountType == 'bank' then
            xPlayer.removeAccountMoney('bank', amount)
        else
            xPlayer.removeAccountMoney(accountType, amount)
        end
        
        return true
    end
    
    return false
end

function GetMoney(source, accountType)
    if not source or source <= 0 then return 0 end
    
    accountType = accountType or 'cash'
    
    if Framework.name == 'qbcore' then
        local Player = Framework.object.Functions.GetPlayer(source)
        if not Player then return 0 end
        
        return Player.Functions.GetMoney(accountType) or 0
        
    elseif Framework.name == 'qbox' then
        local money = exports.qbx_core:GetMoney(source, accountType)
        return money or 0
        
    elseif Framework.name == 'esx' then
        local xPlayer = Framework.object.GetPlayerFromId(source)
        if not xPlayer then return 0 end
        
        if accountType == 'cash' then
            return xPlayer.getMoney()
        elseif accountType == 'bank' then
            return xPlayer.getAccount('bank').money
        else
            local account = xPlayer.getAccount(accountType)
            return account and account.money or 0
        end
    end
    
    return 0
end

-- =====================================================
-- INVENTORY ITEM FUNCTIONS
-- =====================================================

function AddItem(source, item, amount, metadata)
    if not source or source <= 0 then 
        print('^1[WheatFarm] AddItem ERROR: Invalid source^7')
        return false 
    end
    if not item then 
        print('^1[WheatFarm] AddItem ERROR: No item specified^7')
        return false 
    end
    amount = amount or 1
    
    -- Direct inventory system calls (server-side)
    local inventoryName = GetInventoryName()
    
    DebugPrint(string.format('AddItem: source=%d, item=%s, amount=%d, inventory=%s', source, item, amount, inventoryName))
    
    if inventoryName == 'ox_inventory' then
        -- ox_inventory specific handling
        local success, result = pcall(function()
            -- Check if inventory has space first
            local canCarry = exports.ox_inventory:CanCarryItem(source, item, amount)
            
            if not canCarry then
                DebugPrint('ox_inventory: Cannot carry item (inventory full)')
                return false
            end
            
            -- Add the item
            local added = exports.ox_inventory:AddItem(source, item, amount, metadata)
            DebugPrint(string.format('ox_inventory:AddItem returned: %s', tostring(added)))
            
            return added
        end)
        
        if not success then
            print('^1[WheatFarm] ox_inventory:AddItem ERROR: ' .. tostring(result) .. '^7')
            return false
        end
        
        DebugPrint(string.format('ox_inventory AddItem success=%s, result=%s', tostring(success), tostring(result)))
        return result ~= false -- ox_inventory returns false on failure
        
    elseif inventoryName == 'tgiann-inventory' then
        local success, result = pcall(function()
            exports['tgiann-inventory']:AddItem(source, item, amount, nil, metadata)
            return true
        end)
        
        if not success then
            print('^1[WheatFarm] tgiann-inventory:AddItem ERROR: ' .. tostring(result) .. '^7')
            return false
        end
        
        return true
        
    elseif inventoryName == 'qs-inventory' then
        local success, result = pcall(function()
            exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
            return true
        end)
        
        if not success then
            print('^1[WheatFarm] qs-inventory:AddItem ERROR: ' .. tostring(result) .. '^7')
            return false
        end
        
        return true
        
    elseif inventoryName == 'qb-inventory' then
        local frameworkName = GetFrameworkName()
        
        if frameworkName == 'qbcore' then
            local Player = Framework.object.Functions.GetPlayer(source)
            if not Player then 
                print('^1[WheatFarm] qbcore: Player not found^7')
                return false 
            end
            
            local success = Player.Functions.AddItem(item, amount, nil, metadata)
            DebugPrint(string.format('qbcore AddItem: %s', tostring(success)))
            return success
            
        elseif frameworkName == 'qbox' then
            local success, result = pcall(function()
                return exports.qbx_core:AddItem(source, item, amount, metadata)
            end)
            
            if not success then
                print('^1[WheatFarm] qbox:AddItem ERROR: ' .. tostring(result) .. '^7')
                return false
            end
            
            return result
        end
    end
    
    print('^1[WheatFarm] AddItem ERROR: Unknown inventory system^7')
    return false
end

function RemoveItem(source, item, amount)
    if not source or source <= 0 then 
        print('^1[WheatFarm] RemoveItem ERROR: Invalid source^7')
        return false 
    end
    if not item then 
        print('^1[WheatFarm] RemoveItem ERROR: No item specified^7')
        return false 
    end
    amount = amount or 1
    
    -- Direct inventory system calls (server-side)
    local inventoryName = GetInventoryName()
    
    DebugPrint(string.format('RemoveItem: source=%d, item=%s, amount=%d, inventory=%s', source, item, amount, inventoryName))
    
    if inventoryName == 'ox_inventory' then
        local success, result = pcall(function()
            local removed = exports.ox_inventory:RemoveItem(source, item, amount)
            DebugPrint(string.format('ox_inventory:RemoveItem returned: %s', tostring(removed)))
            return removed
        end)
        
        if not success then
            print('^1[WheatFarm] ox_inventory:RemoveItem ERROR: ' .. tostring(result) .. '^7')
            return false
        end
        
        return result ~= false
        
    elseif inventoryName == 'tgiann-inventory' then
        local success, result = pcall(function()
            exports['tgiann-inventory']:RemoveItem(source, item, amount)
            return true
        end)
        
        if not success then
            print('^1[WheatFarm] tgiann-inventory:RemoveItem ERROR: ' .. tostring(result) .. '^7')
            return false
        end
        
        return true
        
    elseif inventoryName == 'qs-inventory' then
        local success, result = pcall(function()
            exports['qs-inventory']:RemoveItem(source, item, amount)
            return true
        end)
        
        if not success then
            print('^1[WheatFarm] qs-inventory:RemoveItem ERROR: ' .. tostring(result) .. '^7')
            return false
        end
        
        return true
        
    elseif inventoryName == 'qb-inventory' then
        local frameworkName = GetFrameworkName()
        
        if frameworkName == 'qbcore' then
            local Player = Framework.object.Functions.GetPlayer(source)
            if not Player then 
                print('^1[WheatFarm] qbcore: Player not found^7')
                return false 
            end
            
            local success = Player.Functions.RemoveItem(item, amount)
            DebugPrint(string.format('qbcore RemoveItem: %s', tostring(success)))
            return success
            
        elseif frameworkName == 'qbox' then
            local success, result = pcall(function()
                return exports.qbx_core:RemoveItem(source, item, amount)
            end)
            
            if not success then
                print('^1[WheatFarm] qbox:RemoveItem ERROR: ' .. tostring(result) .. '^7')
                return false
            end
            
            return result
        end
    end
    
    print('^1[WheatFarm] RemoveItem ERROR: Unknown inventory system^7')
    return false
end

function GetItemCount(source, item)
    if not source or source <= 0 then return 0 end
    if not item then return 0 end
    
    local inventoryName = GetInventoryName()
    
    if inventoryName == 'ox_inventory' then
        local success, count = pcall(function()
            return exports.ox_inventory:GetItemCount(source, item)
        end)
        return (success and count) or 0
        
    elseif inventoryName == 'tgiann-inventory' then
        -- ✅ Method 2 funktioniert perfekt!
        local success, count = pcall(function()
            return exports['tgiann-inventory']:GetItemCount(source, item)
        end)
        
        if success and count and tonumber(count) then
            return tonumber(count)
        end
        
        -- Fallback: Framework-basiert (falls GetItemCount fehlschlägt)
        local frameworkName = GetFrameworkName()
        
        if frameworkName == 'qbcore' then
            local Player = Framework.object.Functions.GetPlayer(source)
            if Player then
                local itemData = Player.Functions.GetItemByName(item)
                return itemData and itemData.amount or 0
            end
        elseif frameworkName == 'qbox' then
            local success, result = pcall(function()
                return exports.qbx_core:GetPlayer(source)
            end)
            
            if success and result then
                local itemData = result.Functions.GetItemByName(item)
                return itemData and itemData.amount or 0
            end
        end
        
        return 0
        
    elseif inventoryName == 'qs-inventory' then
        local success, count = pcall(function()
            return exports['qs-inventory']:GetItemTotalAmount(source, item)
        end)
        return (success and count) or 0
        
    elseif inventoryName == 'qb-inventory' then
        local frameworkName = GetFrameworkName()
        
        if frameworkName == 'qbcore' then
            local Player = Framework.object.Functions.GetPlayer(source)
            if not Player then return 0 end
            
            local itemData = Player.Functions.GetItemByName(item)
            return itemData and itemData.amount or 0
            
        elseif frameworkName == 'qbox' then
            local success, result = pcall(function()
                return exports.qbx_core:GetPlayer(source)
            end)
            
            if not success or not result then return 0 end
            
            local itemData = result.Functions.GetItemByName(item)
            return itemData and itemData.amount or 0
        end
    end
    
    return 0
end

-- =====================================================
-- TOOL DURABILITY SYSTEM
-- =====================================================

function DamageToolDurability(source, toolName)
    -- Guard: No tool specified - that's OK! No tool configured.
    if not toolName then return true end
    
    local toolConfig = Config.Tools[toolName]
    
    -- Guard: Tool not in config - that's OK! No tool configured.
    if not toolConfig then return true end
    
    -- Check if player has the tool (REQUIRED!)
    local hasItem = GetItemCount(source, toolConfig.item) > 0
    
    if not hasItem then
        -- Player doesn't have the required tool - FAIL!
        TriggerClientEvent('wheat:notify', source, Lang:t('no_tool_in_inventory', toolConfig.label or toolConfig.item), 'error')
        return false
    end
    
    -- Player HAS the tool - apply durability
    -- Simple durability system: Small random chance to break tool
    local breakChance = (toolConfig.breakChance or 5) / 20  -- Much lower chance (5% becomes 0.25%)
    local randomRoll = math.random(1, 10000)
    
    DebugPrint(string.format('Tool durability check: %s, breakChance=%d/10000, roll=%d', toolConfig.item, breakChance * 100, randomRoll))
    
    if randomRoll <= (breakChance * 100) then
        -- Tool broke!
        local removed = RemoveItem(source, toolConfig.item, 1)
        
        if removed then
            TriggerClientEvent('wheat:notify', source, Lang:t('tool_broke'), 'error')
            DebugPrint(string.format('Tool %s broke for player %d', toolConfig.item, source))
            return false  -- Tool broke - stop farming!
        end
    end
    
    return true
end

-- Advanced ox_inventory durability (optional, currently disabled)
-- If you want proper durability bars, implement metadata handling here
-- For now, we use the simple random-break system above which works everywhere

-- =====================================================
-- NOTIFICATION WRAPPER
-- =====================================================

function NotifyPlayer(source, message, type, duration)
    TriggerClientEvent('wheat:notify', source, message, type, duration)
end

-- =====================================================
-- DISTANCE VALIDATION (Security)
-- =====================================================

function IsPlayerNearLocation(source, location, maxDistance)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local distance = #(playerCoords - location)
    return distance <= maxDistance, distance
end

-- =====================================================
-- LOGGING FUNCTIONS
-- =====================================================

function LogAction(action, source, details)
    if not Config.EnableLogging then return end
    
    local playerName = GetPlayerName(source) or 'Unknown'
    local identifier = GetPlayerIdentifierByType(source, 'license') or 'Unknown'
    
    print(string.format(
        '[WheatFarm] %s | Player: %s (%s) | Details: %s',
        action,
        playerName,
        identifier,
        details or 'N/A'
    ))
end

-- =====================================================
-- DYNAMIC PRICING CALCULATOR
-- =====================================================

function CalculateDynamicPrice(basePrice, config)
    -- Guard: Dynamic pricing disabled
    if not config or not config.enabled then
        DebugPrint('CalculateDynamicPrice: Dynamic pricing disabled')
        return basePrice, false, 0
    end
    
    local currentHour = os.date('%H', os.time())
    currentHour = tonumber(currentHour)
    
    DebugPrint(string.format('CalculateDynamicPrice: Current hour = %d', currentHour))
    
    -- Check if current hour is peak hour
    local isPeakHour = false
    if config.peakHours then
        for _, hour in ipairs(config.peakHours) do
            if currentHour == hour then
                isPeakHour = true
                break
            end
        end
    end
    
    DebugPrint(string.format('CalculateDynamicPrice: isPeakHour = %s', tostring(isPeakHour)))
    
    -- Apply multiplier
    if isPeakHour and config.peakHourMultiplier then
        local finalPrice = math.floor(basePrice * config.peakHourMultiplier)
        local bonusPercent = math.floor((config.peakHourMultiplier - 1.0) * 100)
        
        DebugPrint(string.format('CalculateDynamicPrice: PEAK HOUR! basePrice=%d, finalPrice=%d, bonus=%d%%', 
            basePrice, finalPrice, bonusPercent))
        
        return finalPrice, true, bonusPercent
    end
    
    DebugPrint('CalculateDynamicPrice: No peak hour bonus')
    return basePrice, false, 0
end

-- =====================================================
-- PLAYER IDENTIFIER HELPER
-- =====================================================

function GetPlayerIdentifierByType(source, idType)
    local identifiers = GetPlayerIdentifiers(source)
    
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, idType) then
            return identifier
        end
    end
    
    return nil
end

-- =====================================================
-- DEBUG FUNCTIONS
-- =====================================================

function DebugPrint(message)
    if Config.EnableLogging then
        print('[WheatFarm DEBUG] ' .. tostring(message))
    end
end

function DebugTable(tbl, indent)
    if not Config.EnableLogging then return end
    
    indent = indent or 0
    local indentStr = string.rep('  ', indent)
    
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(indentStr .. tostring(k) .. ':')
            DebugTable(v, indent + 1)
        else
            print(indentStr .. tostring(k) .. ': ' .. tostring(v))
        end
    end
end

-- =====================================================
-- EXPORTS (damit andere Files die Funktionen nutzen können)
-- =====================================================

exports('AddMoney', AddMoney)
exports('RemoveMoney', RemoveMoney)
exports('GetMoney', GetMoney)
exports('AddItem', AddItem)
exports('RemoveItem', RemoveItem)
exports('GetItemCount', GetItemCount)
exports('HasItem', HasItem)
exports('DamageToolDurability', DamageToolDurability)
exports('NotifyPlayer', NotifyPlayer)
exports('IsPlayerNearLocation', IsPlayerNearLocation)
exports('LogAction', LogAction)
exports('CalculateDynamicPrice', CalculateDynamicPrice)
exports('GetPlayerIdentifierByType', GetPlayerIdentifierByType)
exports('DebugPrint', DebugPrint)
exports('DebugTable', DebugTable)