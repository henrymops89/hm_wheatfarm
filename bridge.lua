-- =====================================================
-- BRIDGE.LUA - Universal Framework & Inventory Bridge
-- Follows Best Practices from Knowledge Base
-- =====================================================

Framework = {
    name = nil,
    object = nil
}

Inventory = {
    name = nil
}

-- =====================================================
-- FRAMEWORK DETECTION & INITIALIZATION
-- =====================================================

CreateThread(function()
    Wait(500)
    
    -- Framework Detection
    if GetResourceState('qbx_core') == 'started' then
        Framework.name = 'qbox'
        print('[WheatFarm] ✅ Framework: QBox (Native Exports)')
        
    elseif GetResourceState('qb-core') == 'started' then
        Framework.name = 'qbcore'
        Framework.object = exports['qb-core']:GetCoreObject()
        print('[WheatFarm] ✅ Framework: QBCore')
        
    elseif GetResourceState('es_extended') == 'started' then
        Framework.name = 'esx'
        local success, result = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        
        if success and result then
            Framework.object = result
            print('[WheatFarm] ✅ Framework: ESX Legacy')
        else
            print('^1[WheatFarm] ERROR: ESX not loaded!^7')
        end
    else
        print('^1[WheatFarm] ERROR: No supported framework found!^7')
    end
    
    -- Inventory Detection
    if GetResourceState('ox_inventory') == 'started' then
        Inventory.name = 'ox_inventory'
        print('[WheatFarm] ✅ Inventory: ox_inventory')
        
    elseif GetResourceState('qb-inventory') == 'started' then
        Inventory.name = 'qb-inventory'
        print('[WheatFarm] ✅ Inventory: qb-inventory')
        
    else
        print('^3[WheatFarm] WARNING: No inventory system detected!^7')
        Inventory.name = 'ox_inventory' -- Fallback
    end
    
    -- ✅ Target System Detection (INNERHALB des Threads!)
    if GetResourceState('ox_target') == 'started' then
        Config.TargetSystem = 'ox_target'
        print('[WheatFarm] ✅ Target: ox_target')
    elseif GetResourceState('qb-target') == 'started' then
        Config.TargetSystem = 'qb-target'
        print('[WheatFarm] ✅ Target: qb-target')
    else
        Config.TargetSystem = '3dtext'
        print('[WheatFarm] ⚠️ Target: Fallback zu 3dtext')
    end
    
    print('[WheatFarm] =====================================')
    print('[WheatFarm] Bridge Initialized Successfully!')
    print('[WheatFarm] =====================================')
end)  -- ✅ Hier fehlt das end)!

-- =====================================================
-- PLAYER FUNCTIONS
-- =====================================================

function GetPlayer(source)
    if not source then return nil end
    
    if Framework.name == 'qbox' then
        return exports.qbx_core:GetPlayer(source)
    elseif Framework.name == 'qbcore' then
        return Framework.object.Functions.GetPlayer(source)
    elseif Framework.name == 'esx' then
        return Framework.object.GetPlayerFromId(source)
    end
    
    return nil
end

-- =====================================================
-- MONEY FUNCTIONS
-- =====================================================

function AddMoney(source, amount, moneyType)
    moneyType = moneyType or 'cash'
    
    if Framework.name == 'qbox' then
        return exports.qbx_core:AddMoney(source, moneyType, amount)
        
    elseif Framework.name == 'qbcore' then
        local Player = GetPlayer(source)
        if Player then
            Player.Functions.AddMoney(moneyType, amount)
            return true
        end
        
    elseif Framework.name == 'esx' then
        local xPlayer = GetPlayer(source)
        if xPlayer then
            if moneyType == 'cash' or moneyType == 'money' then
                xPlayer.addMoney(amount)
            else
                xPlayer.addAccountMoney(moneyType, amount)
            end
            return true
        end
    end
    
    return false
end

function RemoveMoney(source, amount, moneyType)
    moneyType = moneyType or 'cash'
    
    if Framework.name == 'qbox' then
        return exports.qbx_core:RemoveMoney(source, moneyType, amount)
        
    elseif Framework.name == 'qbcore' then
        local Player = GetPlayer(source)
        if Player then
            Player.Functions.RemoveMoney(moneyType, amount)
            return true
        end
        
    elseif Framework.name == 'esx' then
        local xPlayer = GetPlayer(source)
        if xPlayer then
            if moneyType == 'cash' or moneyType == 'money' then
                xPlayer.removeMoney(amount)
            else
                xPlayer.removeAccountMoney(moneyType, amount)
            end
            return true
        end
    end
    
    return false
end

-- =====================================================
-- INVENTORY FUNCTIONS
-- =====================================================

function AddItem(source, item, amount, metadata)
    if Inventory.name == 'ox_inventory' then
        local success, result = pcall(function()
            return exports.ox_inventory:AddItem(source, item, amount, metadata or {})
        end)
        
        if not success then
            if Config and Config.EnableLogging then
                print('^1[WheatFarm] AddItem pcall failed: ' .. tostring(result) .. '^7')
            end
            return false
        end
        
        -- ✅ IMPROVED: Better result handling with logging
        local canAdd = result == true or (type(result) == 'table' and result ~= false)
        
        if Config and Config.EnableLogging then
            print(string.format('[WheatFarm] AddItem result for %dx %s to player %s: %s (type: %s, canAdd: %s)', 
                amount, item, source, tostring(result), type(result), tostring(canAdd)))
        end
        
        -- If result is nil or false, try to check if item was actually added
        if not canAdd or result == nil then
            if Config and Config.EnableLogging then
                print('^3[WheatFarm] AddItem returned nil/false, verifying inventory...^7')
            end
            
            -- Wait a tick for inventory to update
            Wait(100)
            
            -- Check if item actually exists in inventory
            local count = exports.ox_inventory:Search(source, 'count', item)
            if count and count >= amount then
                if Config and Config.EnableLogging then
                    print('^2[WheatFarm] Item was added despite nil result!^7')
                end
                return true
            end
            
            if Config and Config.EnableLogging then
                print('^1[WheatFarm] AddItem FAILED - item not in inventory^7')
            end
            return false
        end
        
        return canAdd
        
    elseif Inventory.name == 'qb-inventory' then
        if Framework.name == 'qbox' then
            return exports.qbx_core:AddItem(source, item, amount, nil, metadata or {})
            
        elseif Framework.name == 'qbcore' then
            local Player = GetPlayer(source)
            if Player then
                return Player.Functions.AddItem(item, amount, nil, metadata or {})
            end
        end
    end
    
    return false
end

function RemoveItem(source, item, amount, metadata)
    if Inventory.name == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(source, item, amount, metadata)
        
    elseif Inventory.name == 'qb-inventory' then
        if Framework.name == 'qbox' then
            return exports.qbx_core:RemoveItem(source, item, amount, nil, metadata)
            
        elseif Framework.name == 'qbcore' then
            local Player = GetPlayer(source)
            if Player then
                return Player.Functions.RemoveItem(item, amount, nil, metadata)
            end
        end
    end
    
    return false
end

function GetItemCount(source, item)
    if Inventory.name == 'ox_inventory' then
        local success, count = pcall(function()
            return exports.ox_inventory:Search(source, 'count', item)
        end)
        return (success and count) or 0
        
    elseif Inventory.name == 'qb-inventory' then
        if Framework.name == 'qbox' then
            local inventory = exports.qbx_core:GetInventory(source)
            if not inventory then return 0 end
            
            local total = 0
            for _, itemData in pairs(inventory) do
                if itemData.name == item then
                    total = total + (itemData.amount or 0)
                end
            end
            return total
            
        elseif Framework.name == 'qbcore' then
            local Player = GetPlayer(source)
            if not Player then return 0 end
            
            local itemObj = Player.Functions.GetItemByName(item)
            return itemObj and itemObj.amount or 0
        end
    end
    
    return 0
end

function CanCarryItem(source, item, amount)
    if Inventory.name == 'ox_inventory' then
        local success, result = pcall(function()
            return exports.ox_inventory:CanCarryItem(source, item, amount)
        end)
        
        if not success then
            -- pcall failed - log error and return true (allow by default)
            if Config and Config.EnableLogging then
                print('^3[WheatFarm] CanCarryItem pcall failed: ' .. tostring(result) .. '^7')
            end
            return true
        end
        
        -- ✅ FIX: Properly handle the result
        -- ox_inventory returns: number (count), false (cannot carry), or nil (error)
        if result == false then
            if Config and Config.EnableLogging then
                print(string.format('[WheatFarm] Player %s CANNOT carry %dx %s (ox_inventory returned false)', 
                    source, amount, item))
            end
            return false
        end
        
        -- Result is number or true - can carry
        if Config and Config.EnableLogging then
            print(string.format('[WheatFarm] Player %s CAN carry %dx %s (ox_inventory result: %s)', 
                source, amount, item, tostring(result)))
        end
        return true
    end
    
    -- For qb-inventory or other inventories - always allow (no proper check available)
    return true
end

-- =====================================================
-- CLIENT-SIDE INVENTORY FUNCTIONS
-- =====================================================

if not IsDuplicityVersion() then
    -- Client-side item count check
    function GetItemCountClient(item)
        if Inventory.name == 'ox_inventory' then
            local success, count = pcall(function()
                return exports.ox_inventory:Search('count', item)
            end)
            return (success and count) or 0
        end
        
        return 0
    end
end

-- =====================================================
-- NOTIFICATION FUNCTION
-- =====================================================

function Notify(target, message, type, duration)
    duration = duration or 5000
    
    if IsDuplicityVersion() then
        -- Server-side
        if Framework.name == 'qbox' then
            exports.qbx_core:Notify(target, message, type, duration)
        elseif Framework.name == 'qbcore' then
            TriggerClientEvent('QBCore:Notify', target, message, type, duration)
        elseif Framework.name == 'esx' then
            TriggerClientEvent('esx:showNotification', target, message)
        end
    else
        -- Client-side
        if Framework.name == 'qbox' then
            exports.qbx_core:Notify(message, type, duration)
        elseif Framework.name == 'qbcore' then
            Framework.object.Functions.Notify(message, type, duration)
        elseif Framework.name == 'esx' then
            Framework.object.ShowNotification(message)
        end
    end
end

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

function GetFrameworkName()
    return Framework.name or 'unknown'
end

function GetInventoryName()
    return Inventory.name or 'unknown'
end

function IsFrameworkReady()
    if Framework.name == 'qbox' then
        return GetResourceState('qbx_core') == 'started'
    elseif Framework.name == 'qbcore' then
        return Framework.object ~= nil
    elseif Framework.name == 'esx' then
        return Framework.object ~= nil
    end
    return false
end

-- =====================================================
-- EXPORTS
-- =====================================================

if IsDuplicityVersion() then
    -- Server exports
    exports('GetPlayer', GetPlayer)
    exports('AddMoney', AddMoney)
    exports('RemoveMoney', RemoveMoney)
    exports('AddItem', AddItem)
    exports('RemoveItem', RemoveItem)
    exports('GetItemCount', GetItemCount)
    exports('CanCarryItem', CanCarryItem)
    exports('Notify', Notify)
    exports('GetFrameworkName', GetFrameworkName)
    exports('GetInventoryName', GetInventoryName)
else
    -- Client exports
    exports('Notify', Notify)
    exports('GetFrameworkName', GetFrameworkName)
    exports('GetInventoryName', GetInventoryName)
    exports('GetItemCountClient', GetItemCountClient)
end

print('[WheatFarm] Bridge module loaded!')
