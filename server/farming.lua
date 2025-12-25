-- =====================================================
-- SERVER/FARMING.LUA - Crop Harvesting (Server)
-- Handles harvest validation and rewards
-- =====================================================

-- =====================================================
-- HARVEST EVENT
-- =====================================================

RegisterNetEvent('wheat:harvest', function(farmId, cropType)
    local source = source
    
    -- Security: Rate limit check
    if not CheckRateLimit(source) then
        return
    end
    
    -- Security: Cooldown check
    if not CheckCooldown(source, 'harvest', 5) then
        return
    end
    
    -- Validate farm exists
    local farm = nil
    for _, f in ipairs(Config.Farms) do
        if f.id == farmId and f.enabled then
            farm = f
            break
        end
    end
    
    if not farm then
        print('^3[WheatFarm] Invalid farm ID: ' .. tostring(farmId) .. '^7')
        return
    end
    
    -- Validate crop config
    local cropConfig = Config.Crops[cropType]
    if not cropConfig then
        print('^3[WheatFarm] Invalid crop type: ' .. tostring(cropType) .. '^7')
        return
    end
    
    -- Security: Distance validation
    if not ValidateDistance(source, farm.location, 'harvest') then
        return
    end
    
    -- ✅ SERVER-SEITIGE Tool-Prüfung!
    if cropConfig.requiredTool then
        local toolConfig = Config.Tools[cropConfig.requiredTool]
        
        if toolConfig then
            -- Prüfe ob Spieler das Tool hat
            local hasItem = GetItemCount(source, toolConfig.item) > 0
            
            if not hasItem then
                -- Spieler hat das Tool nicht!
                TriggerClientEvent('wheat:notify', source, Lang:t('need_tool', toolConfig.label or toolConfig.item), 'error')
                DebugPrint(string.format('Player %d tried to harvest without tool: %s', source, toolConfig.item))
                return
            end
            
            DebugPrint(string.format('Player %d has required tool: %s', source, toolConfig.item))
        end
    end
    
    -- Tool durability check (if required)
    if cropConfig.requiredTool then
        local toolStillUsable = DamageToolDurability(source, cropConfig.requiredTool)
        
        if not toolStillUsable then
            TriggerClientEvent('wheat:notify', source, 'Dein Werkzeug ist kaputt!', 'error')
            return
        end
    end
    
    -- Calculate yield
    local amount = math.random(cropConfig.minYield or 1, cropConfig.maxYield or 3)
    
    -- Give items
    local success = AddItem(source, cropConfig.item, amount)
    
    if success then
        -- Log action
        LogAction('HARVEST', source, string.format(
            'Farm: %s | Crop: %s | Amount: %d',
            farmId,
            cropType,
            amount
        ))
        
        -- Notify player
        TriggerClientEvent('wheat:notifySuccess', source, amount, cropType)
    else
        TriggerClientEvent('wheat:notify', source, 'Dein Inventar ist voll!', 'error')
    end
end)

-- =====================================================
-- AUTO-FARM EVENT
-- =====================================================

RegisterNetEvent('wheat:autoFarm', function(farmId, cropType)
    local source = source
    
    -- Security: Rate limit check
    if not CheckRateLimit(source) then
        return
    end
    
    -- Security: Cooldown check (longer for auto-farm)
    if not CheckCooldown(source, 'autofarm', 8) then
        return
    end
    
    -- Validate farm
    local farm = nil
    for _, f in ipairs(Config.Farms) do
        if f.id == farmId and f.enabled then
            farm = f
            break
        end
    end
    
    if not farm then
        return
    end
    
    -- Validate crop
    local cropConfig = Config.Crops[cropType]
    if not cropConfig then
        return
    end
    
    -- Security: Distance validation
    if not ValidateDistance(source, farm.location, 'auto-farm') then
        return
    end
    
    -- ✅ SERVER-SEITIGE Tool-Prüfung für Auto-Farm!
    if cropConfig.requiredTool then
        local toolConfig = Config.Tools[cropConfig.requiredTool]
        
        if toolConfig then
            -- Prüfe ob Spieler das Tool hat
            local hasItem = GetItemCount(source, toolConfig.item) > 0
            
            if not hasItem then
                -- Spieler hat das Tool nicht mehr - Auto-Farm stoppen!
                TriggerClientEvent('wheat:notify', source, 'Auto-Farm gestoppt: Kein Werkzeug mehr!', 'error')
                DebugPrint(string.format('Player %d auto-farm stopped - no tool: %s', source, toolConfig.item))
                return
            end
            
            DebugPrint(string.format('Player %d auto-farm - has tool: %s', source, toolConfig.item))
        end
    end
    
    -- Tool durability
    if cropConfig.requiredTool then
        local toolStillUsable = DamageToolDurability(source, cropConfig.requiredTool)
        
        if not toolStillUsable then
            TriggerClientEvent('wheat:notify', source, 'Dein Werkzeug ist kaputt!', 'error')
            return
        end
    end
    
    -- Calculate auto-farm yield (usually less than manual)
    local amount = math.random(
        cropConfig.autoFarmMin or cropConfig.minYield or 1,
        cropConfig.autoFarmMax or cropConfig.maxYield or 2
    )
    
    -- Give items
    local success = AddItem(source, cropConfig.item, amount)
    
    if success then
        LogAction('AUTO-FARM', source, string.format(
            'Farm: %s | Crop: %s | Amount: %d',
            farmId,
            cropType,
            amount
        ))
        
        TriggerClientEvent('wheat:notifySuccess', source, amount, cropType)
    else
        TriggerClientEvent('wheat:notify', source, 'Dein Inventar ist voll!', 'error')
    end
end)