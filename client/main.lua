-- =====================================================
-- CLIENT/MAIN.LUA - Initialization (FIXED VERSION)
-- Single Responsibility: Framework initialization only
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
    print('[WheatFarm] Client Initialized Successfully!')
    print('[WheatFarm] Framework: ' .. GetFrameworkName())
    print('[WheatFarm] Inventory: ' .. GetInventoryName())
    print('[WheatFarm] Language: ' .. Config.Language)
    print('[WheatFarm] =====================================')
end)

-- =====================================================
-- EVENT HANDLERS
-- =====================================================

-- Generic notification from server
RegisterNetEvent('wheat:notify', function(message, type, duration)
    -- Security: Check for invoking resource
    if GetInvokingResource() then return end
    
    Notify(message, type, duration)
end)

-- Harvest Success Notification
RegisterNetEvent('wheat:notifySuccess', function(amount, cropType)
    -- Security: Check for invoking resource
    if GetInvokingResource() then return end
    
    -- Get localized crop name from crop type key
    local cropName = Lang:t('crop_' .. cropType)
    
    Notify(Lang:t('harvested_x', amount, cropName), 'success')
end)

-- Mill Success Notification
RegisterNetEvent('wheat:mill:success', function(outputAmount)
    if GetInvokingResource() then return end
    
    Notify(Lang:t('produced_flour', outputAmount), 'success')
end)

-- Bakery Success Notification
RegisterNetEvent('wheat:bakery:success', function(amount, totalPrice, pricePerItem)
    if GetInvokingResource() then return end
    
    Notify(Lang:t('sold_flour', amount, totalPrice, pricePerItem), 'success')
end)

-- System Info Display
RegisterNetEvent('wheat:systemInfo', function(data)
    if GetInvokingResource() then return end
    
    print('╔═══════════════════════════════════╗')
    print('║   🌾 HM Wheat Farm - System Info   ║')
    print('╠═══════════════════════════════════╣')
    print('║ Framework: ' .. data.framework .. string.rep(' ', 24 - #data.framework) .. '║')
    print('║ Inventory: ' .. data.inventory .. string.rep(' ', 24 - #data.inventory) .. '║')
    print('╚═══════════════════════════════════╝')
end)

-- =====================================================
-- COMMANDS
-- =====================================================

-- System Info Command
RegisterCommand('wheatinfo', function()
    TriggerServerEvent('wheat:requestInfo')
end, false)

-- =====================================================
-- CLEANUP ON RESOURCE STOP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Cleanup handled in individual modules
    TriggerEvent('wheat:cleanup')
end)