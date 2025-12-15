-- =====================================================
-- SERVER/UTILS.LUA - Server Helper Functions (FIXED)
-- Single Responsibility: Reusable server utilities
-- =====================================================

-- =====================================================
-- TOOL DURABILITY SYSTEM (FIXED - BUG #8, #12)
-- =====================================================

function GetItemWithSlot(source, itemName)
    if Inventory.name == 'ox_inventory' then
        -- ✅ FIXED: Use GetInventory instead of GetInventoryItems (BUG #8)
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
        return nil
        
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

function GetItemDurability(source, slot)
    if Inventory.name == 'ox_inventory' then
        local success, itemData = pcall(function()
            return exports.ox_inventory:GetSlot(source, slot)
        end)
        
        if success and itemData and itemData.metadata and itemData.metadata.durability then
            return itemData.metadata.durability
        end
        
    elseif Inventory.name == 'qb-inventory' then
        if Framework.name == 'qbox' then
            local inventory = exports.qbx_core:GetInventory(source)
            if inventory and inventory[slot] then
                local item = inventory[slot]
                if item.info and item.info.quality then
                    return item.info.quality
                end
            end
            
        elseif Framework.name == 'qbcore' then
            local Player = GetPlayer(source)
            if Player and Player.PlayerData.items[slot] then
                local item = Player.PlayerData.items[slot]
                if item.info and item.info.quality then
                    return item.info.quality
                end
            end
        end
    end
    
    return nil
end

function SetItemDurability(source, slot, durability)
    if Inventory.name == 'ox_inventory' then
        -- ✅ FIXED: Clamp durability to 0-100 range (BUG #12)
        local clampedDurability = math.max(0, math.min(100, durability))
        
        local success, result = pcall(function()
            return exports.ox_inventory:SetDurability(source, slot, clampedDurability)
        end)
        
        return success and result
        
    elseif Inventory.name == 'qb-inventory' then
        local metadata = { quality = durability }
        
        if Framework.name == 'qbox' then
            return exports.qbx_core:SetItemMetadata(source, slot, metadata)
            
        elseif Framework.name == 'qbcore' then
            local Player = GetPlayer(source)
            if Player and Player.PlayerData.items[slot] then
                Player.PlayerData.items[slot].info = metadata
                Player.Functions.SetPlayerData('items', Player.PlayerData.items)
                return true
            end
        end
    end
    
    return false
end

function ProcessToolDurability(source, toolConfig)
    -- Guard: No tool config
    if not toolConfig then return true end
    
    -- Get the tool item
    local toolItem = GetItemWithSlot(source, toolConfig.item)
    
    -- Guard: No tool found
    if not toolItem or not toolItem.slot then
        return false
    end
    
    local slot = toolItem.slot
    
    -- Get current durability
    local durability = GetItemDurability(source, slot)
    
    -- If no durability metadata, set max durability
    if not durability then
        durability = toolConfig.maxDurability
    end
    
    -- Reduce durability
    durability = durability - toolConfig.durabilityPerUse
    
    -- Check if tool breaks
    local breakRoll = math.random(1, 100)
    local toolBroke = breakRoll <= toolConfig.breakChance or durability <= 0
    
    if toolBroke then
        -- Remove tool
        RemoveItem(source, toolConfig.item, 1)
        Notify(source, 'Dein Werkzeug ist kaputt gegangen!', 'error')
        return false
    else
        -- Update durability
        SetItemDurability(source, slot, durability)
        
        -- Warn if durability low
        local durabilityPercent = math.floor((durability / toolConfig.maxDurability) * 100)
        if durabilityPercent <= 20 then
            Notify(source, string.format('Dein Werkzeug ist beschädigt (%d%%)!', durabilityPercent), 'warning')
        end
        
        return true
    end
end

-- =====================================================
-- VALIDATION FUNCTIONS
-- =====================================================

function ValidatePlayer(source)
    local Player = GetPlayer(source)
    
    if not Player then
        if Config.EnableLogging then
            print('[WheatFarm] ❌ Invalid player: ' .. tostring(source))
        end
        return false
    end
    
    return true
end

function ValidateItemCount(source, item, amount)
    local count = GetItemCount(source, item)
    
    if count < amount then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Player %s has %d %s (needs %d)', 
                source, count, item, amount))
        end
        return false
    end
    
    return true
end

function ValidateCanCarry(source, item, amount)
    local canCarry = CanCarryItem(source, item, amount)
    
    -- ✅ IMPROVED: If CanCarryItem returns true but ox_inventory gave nil, skip the check
    -- We'll let AddItem handle it and verify afterwards
    if canCarry == true then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] CanCarry check passed for %dx %s (player %s)', 
                amount, item, source))
        end
        return true
    end
    
    -- Only show notification if we're SURE it won't fit
    if not canCarry then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Player %s cannot carry %dx %s', 
                source, amount, item))
        end
        Notify(source, 'Dein Inventar ist voll oder zu schwer!', 'error')
        return false
    end
    
    return true
end

-- =====================================================
-- DISTANCE VALIDATION
-- =====================================================

function ValidateDistance(source, location, maxDistance, tolerance)
    tolerance = tolerance or 0.0
    
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end
    
    local coords = GetEntityCoords(ped)
    if not coords then return false end
    
    local distance = #(coords - location)
    local allowedDistance = maxDistance + tolerance
    
    if distance > allowedDistance then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Distance check failed: Player %s is %.2fm away (max: %.2fm)', 
                source, distance, allowedDistance))
        end
        return false, distance
    end
    
    return true, distance
end

-- =====================================================
-- CROP YIELD CALCULATION
-- =====================================================

function CalculateHarvestYield(cropConfig, isAutoFarm)
    local amount
    
    if isAutoFarm then
        amount = math.random(cropConfig.autoFarmMin, cropConfig.autoFarmMax)
    else
        amount = math.random(cropConfig.minYield, cropConfig.maxYield)
    end
    
    return amount
end

-- =====================================================
-- DYNAMIC PRICING (for Bakery)
-- =====================================================

function CalculateDynamicPrice(basePrice, dynamicPricingConfig)
    -- Guard: Dynamic pricing disabled
    if not dynamicPricingConfig or not dynamicPricingConfig.enabled then
        return basePrice
    end
    
    local currentHour = tonumber(os.date('%H'))
    
    -- Check if current hour is peak hour
    for _, peakHour in ipairs(dynamicPricingConfig.peakHours) do
        if currentHour == peakHour then
            local multipliedPrice = math.floor(basePrice * dynamicPricingConfig.peakHourMultiplier)
            
            if Config.EnableLogging then
                print(string.format('[WheatFarm] Peak hour pricing: $%d → $%d (%.1fx)', 
                    basePrice, multipliedPrice, dynamicPricingConfig.peakHourMultiplier))
            end
            
            return multipliedPrice
        end
    end
    
    return basePrice
end

-- =====================================================
-- ITEM TRANSACTION HELPERS
-- =====================================================

function SafeAddItem(source, item, amount, metadata)
    -- Validate can carry
    if not ValidateCanCarry(source, item, amount) then
        return false, 'inventory_full'
    end
    
    -- Attempt to add item
    local success = AddItem(source, item, amount, metadata)
    
    if not success then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] ❌ Failed to add %dx %s to player %s', 
                amount, item, source))
        end
        return false, 'add_failed'
    end
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] ✅ Added %dx %s to player %s', 
            amount, item, source))
    end
    
    return true
end

function SafeRemoveItem(source, item, amount)
    -- Validate has items
    if not ValidateItemCount(source, item, amount) then
        return false, 'not_enough_items'
    end
    
    -- Attempt to remove item
    local success = RemoveItem(source, item, amount)
    
    if not success then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] ❌ Failed to remove %dx %s from player %s', 
                amount, item, source))
        end
        return false, 'remove_failed'
    end
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] ✅ Removed %dx %s from player %s', 
            amount, item, source))
    end
    
    return true
end

function ProcessTransaction(source, inputItem, inputAmount, outputItem, outputAmount)
    -- Step 1: Validate input
    if not ValidateItemCount(source, inputItem, inputAmount) then
        return false, 'not_enough_input'
    end
    
    -- Step 2: Validate can carry output
    if not ValidateCanCarry(source, outputItem, outputAmount) then
        return false, 'inventory_full'
    end
    
    -- Step 3: Remove input
    local removeSuccess = RemoveItem(source, inputItem, inputAmount)
    if not removeSuccess then
        return false, 'remove_failed'
    end
    
    -- Step 4: Add output
    local addSuccess = AddItem(source, outputItem, outputAmount)
    if not addSuccess then
        -- Rollback: Give input items back
        AddItem(source, inputItem, inputAmount)
        return false, 'add_failed'
    end
    
    return true
end

-- =====================================================
-- LOGGING HELPERS
-- =====================================================

function DebugPrint(message)
    if Config.EnableLogging then
        print('[WheatFarm DEBUG] ' .. tostring(message))
    end
end

function LogHarvest(source, farmId, cropName, amount, isAutoFarm)
    if not Config.EnableLogging then return end
    
    local mode = isAutoFarm and " (Auto-Farm)" or ""
    print(string.format('[WheatFarm] Player %s harvested %dx %s at %s%s', 
        source, amount, cropName, farmId, mode))
end

function LogProcessing(source, inputItem, inputAmount, outputItem, outputAmount)
    if not Config.EnableLogging then return end
    
    print(string.format('[WheatFarm] Player %s processed %dx %s → %dx %s', 
        source, inputAmount, inputItem, outputAmount, outputItem))
end

function LogSelling(source, item, amount, totalPrice)
    if not Config.EnableLogging then return end
    
    print(string.format('[WheatFarm] Player %s sold %dx %s for $%d', 
        source, amount, item, totalPrice))
end

-- =====================================================
-- EXPORTS
-- =====================================================

exports('GetItemWithSlot', GetItemWithSlot)
exports('GetItemDurability', GetItemDurability)
exports('SetItemDurability', SetItemDurability)
exports('ProcessToolDurability', ProcessToolDurability)
exports('ValidatePlayer', ValidatePlayer)
exports('ValidateItemCount', ValidateItemCount)
exports('ValidateCanCarry', ValidateCanCarry)
exports('ValidateDistance', ValidateDistance)
exports('CalculateHarvestYield', CalculateHarvestYield)
exports('CalculateDynamicPrice', CalculateDynamicPrice)
exports('SafeAddItem', SafeAddItem)
exports('SafeRemoveItem', SafeRemoveItem)
exports('ProcessTransaction', ProcessTransaction)