-- =====================================================
-- SERVER/MAIN.LUA - Server Initialization (FIXED)
-- Single Responsibility: Framework init & system management
-- =====================================================

-- =====================================================
-- FRAMEWORK INITIALIZATION
-- =====================================================

CreateThread(function()
    Wait(1000)
    
    -- Wait for bridge to be ready
    local attempts = 0
    while not IsFrameworkReady() and attempts < 50 do
        Wait(100)
        attempts = attempts + 1
    end
    
    if not IsFrameworkReady() then
        print('^1[WheatFarm] ERROR: Framework not ready after 5 seconds!^7')
        return
    end
    
    print('[WheatFarm] =====================================')
    print('[WheatFarm] Server Initialized Successfully!')
    print('[WheatFarm] Framework: ' .. GetFrameworkName())
    print('[WheatFarm] Inventory: ' .. GetInventoryName())
    print('[WheatFarm] =====================================')
    
    -- Broadcast system info to all clients
    TriggerClientEvent('wheat:systemInfo', -1, {
        framework = GetFrameworkName(),
        inventory = GetInventoryName()
    })
end)

-- =====================================================
-- SYSTEM INFO COMMAND
-- =====================================================

RegisterCommand('wheatdebug', function(source, args, rawCommand)
    if source == 0 then
        -- Console command
        print('=== WheatFarm Debug Info ===')
        print('Framework: ' .. GetFrameworkName())
        print('Inventory: ' .. GetInventoryName())
        print('Config.Language: ' .. Config.Language)
        print('Config.EnableLogging: ' .. tostring(Config.EnableLogging))
        print('Security Enabled: ' .. tostring(Config.Security.enabled))
    else
        -- Player command
        TriggerClientEvent('wheat:systemInfo', source, {
            framework = GetFrameworkName(),
            inventory = GetInventoryName()
        })
    end
end, false)

-- =====================================================
-- CLIENT INFO REQUEST HANDLER
-- =====================================================

RegisterNetEvent('wheat:requestInfo', function()
    local source = source
    
    TriggerClientEvent('wheat:systemInfo', source, {
        framework = GetFrameworkName(),
        inventory = GetInventoryName()
    })
end)

-- =====================================================
-- PLAYER DISCONNECT CLEANUP
-- =====================================================

AddEventHandler('playerDropped', function(reason)
    local source = source
    
    -- Trigger cleanup in security module
    TriggerEvent('wheat:playerDisconnected', source)
    
    if Config.EnableLogging then
        print('[WheatFarm] Player ' .. source .. ' disconnected - cleaned up')
    end
end)

-- =====================================================
-- DEBUG COMMANDS (only if logging enabled)
-- =====================================================

if Config.EnableLogging then
    -- Test wheat item
    RegisterCommand('testwheat', function(source)
        if source == 0 then
            print('[WheatFarm] This command must be run in-game')
            return
        end
        
        print('[WheatFarm DEBUG] Testing wheat item for player ' .. source)
        
        local success = AddItem(source, 'wheat', 1)
        
        if success then
            print('[WheatFarm DEBUG] ✅ Successfully added 1 wheat!')
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"[WheatFarm]", "✅ Wheat item works!"}
            })
        else
            print('[WheatFarm DEBUG] ❌ Failed to add wheat!')
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[WheatFarm]", "❌ Wheat item doesn't exist!"}
            })
        end
    end, false)
    
    -- Test flour item
    RegisterCommand('testflour', function(source)
        if source == 0 then
            print('[WheatFarm] This command must be run in-game')
            return
        end
        
        print('[WheatFarm DEBUG] Testing flour item for player ' .. source)
        
        local success = AddItem(source, 'flour', 1)
        
        if success then
            print('[WheatFarm DEBUG] ✅ Successfully added 1 flour!')
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"[WheatFarm]", "✅ Flour item works!"}
            })
        else
            print('[WheatFarm DEBUG] ❌ Failed to add flour!')
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[WheatFarm]", "❌ Flour item doesn't exist!"}
            })
        end
    end, false)
    
    -- Test hoe item
    RegisterCommand('testhoe', function(source)
        if source == 0 then
            print('[WheatFarm] This command must be run in-game')
            return
        end
        
        print('[WheatFarm DEBUG] Testing hoe item for player ' .. source)
        
        local success = AddItem(source, 'hoe', 1)
        
        if success then
            print('[WheatFarm DEBUG] ✅ Successfully added 1 hoe!')
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"[WheatFarm]", "✅ Hoe item works! You can now farm!"}
            })
        else
            print('[WheatFarm DEBUG] ❌ Failed to add hoe!')
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[WheatFarm]", "❌ Hoe item doesn't exist in items.lua!"}
            })
        end
    end, false)
    
    -- Give test kit
    RegisterCommand('wheatkit', function(source)
        if source == 0 then
            print('[WheatFarm] This command must be run in-game')
            return
        end
        
        print('[WheatFarm DEBUG] Giving test kit to player ' .. source)
        
        AddItem(source, 'hoe', 1)
        AddItem(source, 'wheat', 10)
        
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 255},
            args = {"[WheatFarm]", "✅ Test kit given! (1x Hoe, 10x Wheat)"}
        })
    end, false)
    
    -- Clear cooldowns
    RegisterCommand('wheatclearcooldown', function(source)
        if source == 0 then
            TriggerEvent('wheat:clearAllCooldowns')
            print('[WheatFarm] All cooldowns cleared')
        else
            TriggerEvent('wheat:clearCooldown', source)
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 255},
                args = {"[WheatFarm]", "✅ Your cooldown cleared!"}
            })
        end
    end, false)
end

-- =====================================================
-- RESOURCE STOP HANDLER
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if Config.EnableLogging then
        print('[WheatFarm] Resource stopping - cleaning up...')
    end
    
    if Config.EnableLogging then
        print('[WheatFarm] Cleanup complete')
    end
end)

-- =====================================================
-- STARTUP MESSAGE
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    print('')
    print('^2========================================^7')
    print('^2    🌾 HM Wheat Farm System v2.0     ^7')
    print('^2========================================^7')
    print('^6Framework:^7 ' .. GetFrameworkName())
    print('^6Inventory:^7 ' .. GetInventoryName())
    print('^6Language:^7 ' .. Config.Language)
    print('^6Security:^7 ' .. (Config.Security.enabled and '^2Enabled^7' or '^1Disabled^7'))
    print('^6Logging:^7 ' .. (Config.EnableLogging and '^2Enabled^7' or '^1Disabled^7'))
    print('')
    print('^6Active Farms:^7 ' .. (Config.Farms and #Config.Farms or 0))
    print('^6Mill:^7 ' .. (Config.Mill.enabled and '^2Enabled^7' or '^1Disabled^7'))
    print('^6Bakery:^7 ' .. (Config.Bakery.enabled and '^2Enabled^7' or '^1Disabled^7'))
    print('^2========================================^7')
    print('')
end)