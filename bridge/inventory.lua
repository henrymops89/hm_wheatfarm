-- =====================================================
-- BRIDGE/INVENTORY.LUA - Inventory System Detection & Functions
-- Supports: ox_inventory, qs-inventory, tgiann-inventory
-- =====================================================

Inventory = {
    name = nil,
    ready = false
}

-- =====================================================
-- INVENTORY DETECTION
-- =====================================================

local function DetectInventory()
    -- ox_inventory Detection
    if GetResourceState('ox_inventory') == 'started' then
        Inventory.name = 'ox_inventory'
        Inventory.ready = true
        print('[WheatFarm Bridge] ✅ Inventory: ox_inventory')
        return true
    end
    
    -- qs-inventory Detection
    if GetResourceState('qs-inventory') == 'started' then
        Inventory.name = 'qs-inventory'
        Inventory.ready = true
        print('[WheatFarm Bridge] ✅ Inventory: qs-inventory')
        return true
    end
    
    -- tgiann-inventory Detection
    if GetResourceState('tgiann-inventory') == 'started' then
        Inventory.name = 'tgiann-inventory'
        Inventory.ready = true
        print('[WheatFarm Bridge] ✅ Inventory: tgiann-inventory')
        return true
    end
    
    -- qb-inventory Detection (fallback)
    if GetResourceState('qb-inventory') == 'started' then
        Inventory.name = 'qb-inventory'
        Inventory.ready = true
        print('[WheatFarm Bridge] ✅ Inventory: qb-inventory')
        return true
    end
    
    print('^3[WheatFarm Bridge] ⚠️ WARNING: No inventory system detected! Using ox_inventory as fallback.^7')
    Inventory.name = 'ox_inventory'
    return false
end

-- =====================================================
-- ITEM FUNCTIONS (SERVER-SIDE)
-- =====================================================

if IsDuplicityVersion() then
    
    -- Add Item
    function AddItem(source, item, amount, metadata)
        if not Inventory.ready then return false end
        
        metadata = metadata or {}
        
        if Inventory.name == 'ox_inventory' then
            local success, result = pcall(function()
                return exports.ox_inventory:AddItem(source, item, amount, metadata)
            end)
            
            if not success then
                if Config and Config.EnableLogging then
                    print('^1[WheatFarm] AddItem failed: ' .. tostring(result) .. '^7')
                end
                return false
            end
            
            -- Handle ox_inventory result
            local canAdd = result == true or (type(result) == 'table' and result ~= false)
            
            if not canAdd or result == nil then
                -- Verify item was actually added
                Wait(100)
                local count = exports.ox_inventory:Search(source, 'count', item)
                return count and count >= amount
            end
            
            return canAdd
            
        elseif Inventory.name == 'qs-inventory' then
            local success, result = pcall(function()
                return exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
            end)
            return success and result
            
        elseif Inventory.name == 'tgiann-inventory' then
            local success, result = pcall(function()
                return exports['tgiann-inventory']:AddItem(source, item, amount, metadata)
            end)
            return success and result
            
        elseif Inventory.name == 'qb-inventory' then
            if Framework.name == 'qbox' then
                return exports.qbx_core:AddItem(source, item, amount, nil, metadata)
            elseif Framework.name == 'qbcore' then
                local Player = GetPlayer(source)
                if Player then
                    return Player.Functions.AddItem(item, amount, nil, metadata)
                end
            end
        end
        
        return false
    end
    
    -- Remove Item
    function RemoveItem(source, item, amount, metadata)
        if not Inventory.ready then return false end
        
        if Inventory.name == 'ox_inventory' then
            local success, result = pcall(function()
                return exports.ox_inventory:RemoveItem(source, item, amount, metadata)
            end)
            return success and result
            
        elseif Inventory.name == 'qs-inventory' then
            local success, result = pcall(function()
                return exports['qs-inventory']:RemoveItem(source, item, amount, nil, metadata)
            end)
            return success and result
            
        elseif Inventory.name == 'tgiann-inventory' then
            local success, result = pcall(function()
                return exports['tgiann-inventory']:RemoveItem(source, item, amount)
            end)
            return success and result
            
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
    
    -- Get Item Count
    function GetItemCount(source, item)
        if not Inventory.ready then return 0 end
        
        if Inventory.name == 'ox_inventory' then
            local success, count = pcall(function()
                return exports.ox_inventory:Search(source, 'count', item)
            end)
            return (success and count) or 0
            
        elseif Inventory.name == 'qs-inventory' then
            local success, result = pcall(function()
                return exports['qs-inventory']:GetItemTotalAmount(source, item)
            end)
            return (success and result) or 0
            
        elseif Inventory.name == 'tgiann-inventory' then
            local success, result = pcall(function()
                return exports['tgiann-inventory']:GetItemCount(source, item)
            end)
            return (success and result) or 0
            
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
    
    -- Can Carry Item
    function CanCarryItem(source, item, amount)
        if not Inventory.ready then return true end
        
        if Inventory.name == 'ox_inventory' then
            local success, result = pcall(function()
                return exports.ox_inventory:CanCarryItem(source, item, amount)
            end)
            
            if not success then
                if Config and Config.EnableLogging then
                    print('^3[WheatFarm] CanCarryItem failed: ' .. tostring(result) .. '^7')
                end
                return true
            end
            
            if result == false then
                return false
            end
            
            return true
            
        elseif Inventory.name == 'qs-inventory' then
            local success, result = pcall(function()
                return exports['qs-inventory']:CanCarryItem(source, item, amount)
            end)
            return (success and result) or true
            
        elseif Inventory.name == 'tgiann-inventory' then
            -- tgiann-inventory doesn't have CanCarryItem, always return true
            return true
            
        elseif Inventory.name == 'qb-inventory' then
            -- qb-inventory doesn't have reliable CanCarryItem, always return true
            return true
        end
        
        return true
    end
    
    -- Get Item with Slot (for durability system)
    function GetItemWithSlot(source, itemName)
        if not Inventory.ready then return nil end
        
        if Inventory.name == 'ox_inventory' then
            local success, inventory = pcall(function()
                return exports.ox_inventory:GetInventory(source)
            end)
            
            if not success or not inventory or not inventory.items then 
                return nil 
            end
            
            for slot, itemData in pairs(inventory.items) do
                if itemData and itemData.name == itemName then
                    itemData.slot = slot
                    return itemData
                end
            end
            
        elseif Inventory.name == 'qs-inventory' then
            local success, inventory = pcall(function()
                return exports['qs-inventory']:GetInventory(source)
            end)
            
            if not success or not inventory then return nil end
            
            for slot, itemData in pairs(inventory) do
                if itemData.name == itemName then
                    itemData.slot = slot
                    return itemData
                end
            end
            
        elseif Inventory.name == 'tgiann-inventory' then
            local success, inventory = pcall(function()
                return exports['tgiann-inventory']:GetInventory(source)
            end)
            
            if not success or not inventory then return nil end
            
            for slot, itemData in pairs(inventory) do
                if itemData.name == itemName then
                    itemData.slot = slot
                    return itemData
                end
            end
            
        elseif Inventory.name == 'qb-inventory' then
            if Framework.name == 'qbox' then
                local inventory = exports.qbx_core:GetInventory(source)
                if not inventory then return nil end
                
                for slot, itemData in pairs(inventory) do
                    if itemData.name == itemName then
                        itemData.slot = slot
                        return itemData
                    end
                end
                
            elseif Framework.name == 'qbcore' then
                local Player = GetPlayer(source)
                if not Player then return nil end
                
                for slot, itemData in pairs(Player.PlayerData.items) do
                    if itemData and itemData.name == itemName then
                        itemData.slot = slot
                        return itemData
                    end
                end
            end
        end
        
        return nil
    end
    
    -- Exports
    exports('AddItem', AddItem)
    exports('RemoveItem', RemoveItem)
    exports('GetItemCount', GetItemCount)
    exports('CanCarryItem', CanCarryItem)
    exports('GetItemWithSlot', GetItemWithSlot)
end

-- =====================================================
-- CLIENT-SIDE FUNCTIONS
-- =====================================================

if not IsDuplicityVersion() then
    
    -- Get Item Count (Client)
    function GetItemCountClient(item)
        if not Inventory.ready then return 0 end
        
        if Inventory.name == 'ox_inventory' then
            local success, count = pcall(function()
                return exports.ox_inventory:Search('count', item)
            end)
            return (success and count) or 0
            
        elseif Inventory.name == 'qs-inventory' then
            -- qs-inventory server-side only
            return 0
            
        elseif Inventory.name == 'tgiann-inventory' then
            local success, count = pcall(function()
                return exports['tgiann-inventory']:Search('count', item)
            end)
            return (success and count) or 0
        end
        
        return 0
    end
    
    -- Has Item Check (Client)
    function HasRequiredTool(toolName)
        if not toolName then return true end
        
        local toolConfig = Config.Tools[toolName]
        if not toolConfig then return true end
        
        if Inventory.name == 'ox_inventory' then
            local count = GetItemCountClient(toolConfig.item)
            return count > 0
            
        elseif Inventory.name == 'tgiann-inventory' then
            local count = GetItemCountClient(toolConfig.item)
            return count > 0
            
        elseif Inventory.name == 'qs-inventory' or Inventory.name == 'qb-inventory' then
            -- Fallback to framework check
            if Framework.name == 'qbcore' then
                local PlayerData = Framework.object.Functions.GetPlayerData()
                if not PlayerData or not PlayerData.items then return false end
                
                for _, item in pairs(PlayerData.items) do
                    if item and item.name == toolConfig.item and item.amount and item.amount > 0 then
                        return true
                    end
                end
            elseif Framework.name == 'qbox' then
                local success, QBX = pcall(require, '@qbx_core/modules/playerdata')
                if not success then return false end
                
                local PlayerData = QBX.PlayerData
                if not PlayerData or not PlayerData.items then return false end
                
                for _, item in pairs(PlayerData.items) do
                    if item and item.name == toolConfig.item and item.amount and item.amount > 0 then
                        return true
                    end
                end
            end
        end
        
        return false
    end
    
    -- Exports
    exports('GetItemCountClient', GetItemCountClient)
    exports('HasRequiredTool', HasRequiredTool)
end

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

function GetInventoryName()
    return Inventory.name or 'unknown'
end

function IsInventoryReady()
    return Inventory.ready
end

-- Exports
exports('GetInventoryName', GetInventoryName)
exports('IsInventoryReady', IsInventoryReady)

-- =====================================================
-- INITIALIZATION
-- =====================================================

CreateThread(function()
    Wait(500)
    DetectInventory()
end)
