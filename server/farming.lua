-- =====================================================
-- SERVER/FARMING.LUA - Harvest Event Handler
-- Single Responsibility: Handle farming events
-- =====================================================

-- =====================================================
-- HARVEST EVENT HANDLER
-- =====================================================

RegisterNetEvent('wheat:harvest', function(farmId, cropItem, isAutoFarm)
    local source = source
    
    -- Guard: Validate player
    if not ValidatePlayer(source) then
        return
    end
    
    -- Find farm and crop config
    local farmConfig = nil
    local cropConfig = nil
    
    -- Search for farm in config
    if Config.Farms and type(Config.Farms) == 'table' then
        for _, farm in pairs(Config.Farms) do
            if farm.id == farmId then
                farmConfig = farm
                if Config.Crops and Config.Crops[farm.crop] then
                    cropConfig = Config.Crops[farm.crop]
                end
                break
            end
        end
    end
    
    -- Guard: Invalid farm or crop
    if not farmConfig or not cropConfig then
        if Config.EnableLogging then
            print(string.format('^1[WheatFarm] Invalid farm or crop! FarmID: %s, CropItem: %s^7', 
                tostring(farmId), tostring(cropItem)))
        end
        return
    end
    
    -- Security Checks
    local securityPassed, reason = PerformSecurityChecks(
        source, 
        'harvest_' .. farmId, 
        farmConfig.location, 
        farmConfig.radius
    )
    
    if not securityPassed then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Security check failed for player %s: %s', 
                source, reason))
        end
        return
    end
    
    -- Tool Check & Durability
    if cropConfig.requiredTool then
        local toolConfig = Config.Tools[cropConfig.requiredTool]
        
        if not toolConfig then
            if Config.EnableLogging then
                print(string.format('^3[WheatFarm] WARNING: Tool config not found: %s^7', 
                    cropConfig.requiredTool))
            end
        else
            -- Check if player has tool
            local hasTool = GetItemCount(source, toolConfig.item) > 0
            
            if not hasTool then
                Notify(source, 'Du brauchst ein Werkzeug!', 'error')
                return
            end
            
            -- Process tool durability
            local toolUsable = ProcessToolDurability(source, toolConfig)
            
            if not toolUsable then
                return
            end
        end
    end
    
    -- Calculate yield
    local amount = CalculateHarvestYield(cropConfig, isAutoFarm)
    
    -- Validate can carry
    if not ValidateCanCarry(source, cropConfig.item, amount) then
        return
    end
    
    -- Add item
    local success, errorCode = SafeAddItem(source, cropConfig.item, amount)
    
    if success then
        TriggerClientEvent('wheat:notifySuccess', source, amount, cropConfig.name)
        LogHarvest(source, farmId, cropConfig.name, amount, isAutoFarm)
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] ✅ Player %s harvested %dx %s', source, amount, cropConfig.name))
        end
    else
        if Config.EnableLogging then
            print(string.format('^1[WheatFarm] Failed to add item: %s (Player: %s, Item: %s, Amount: %d)^7', 
                errorCode, source, cropConfig.item, amount))
        end
        
        Notify(source, 'Fehler beim Hinzufügen des Items!', 'error')
    end
end)