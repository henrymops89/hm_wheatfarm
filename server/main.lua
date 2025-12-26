-- =====================================================
-- SERVER/MAIN.LUA - Server Initialization
-- Single Responsibility: Framework initialization
-- =====================================================

-- =====================================================
-- FRAMEWORK INITIALIZATION
-- =====================================================

CreateThread(function()
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
    
    Wait(500) -- Extra safety
    
    print('[WheatFarm] =====================================')
    print('[WheatFarm] Server Initialized Successfully!')
    print('[WheatFarm] Framework: ' .. GetFrameworkName())
    print('[WheatFarm] Inventory: ' .. GetInventoryName())
    print('[WheatFarm] Security: ' .. (Config.Security.enabled and 'Enabled' or 'Disabled'))
    print('[WheatFarm] Version: 2.2.1')
    print('[WheatFarm] =====================================')
end)

-- =====================================================
-- GENERIC NOTIFICATION EVENT
-- =====================================================

RegisterNetEvent('wheat:notify', function(message, type, duration)
    local source = source
    
    -- This event is triggered BY the server, so no security check needed
    -- It's used by utils.lua NotifyPlayer() function
end)

-- =====================================================
-- SYSTEM INFO REQUEST
-- =====================================================

RegisterNetEvent('wheat:requestInfo', function()
    local source = source
    
    TriggerClientEvent('wheat:systemInfo', source, {
        framework = GetFrameworkName(),
        inventory = GetInventoryName(),
        version = '2.2.1',
    })
end)

-- =====================================================
-- VERSION CHECK (Optional)
-- =====================================================

CreateThread(function()
    Wait(5000) -- Wait for server to start
    
    local currentVersion = '2.2.1'
    
    print('^2[WheatFarm] Running version: ' .. currentVersion .. '^7')
    print('^2[WheatFarm] Thanks for using HM Wheat Farm!^7')
end)

-- =====================================================
-- RESOURCE STOP HANDLER
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print('^3[WheatFarm] Resource stopping...^7')
    
    -- Any cleanup needed here
    
    print('^3[WheatFarm] Stopped successfully!^7')
end)
