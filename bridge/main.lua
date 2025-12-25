-- =====================================================
-- BRIDGE/MAIN.LUA - Main Bridge Initialization
-- Combines Framework & Inventory bridges
-- =====================================================

-- =====================================================
-- WAIT FOR INITIALIZATION
-- =====================================================

CreateThread(function()
    -- Wait for framework and inventory to initialize
    local attempts = 0
    while (not IsFrameworkReady() or not IsInventoryReady()) and attempts < 50 do
        Wait(100)
        attempts = attempts + 1
    end
    
    if not IsFrameworkReady() then
        print('^1[WheatFarm Bridge] ERROR: Framework not ready after 5 seconds!^7')
        return
    end
    
    if not IsInventoryReady() then
        print('^1[WheatFarm Bridge] ERROR: Inventory not ready after 5 seconds!^7')
        return
    end
    
    -- All systems ready
    print('[WheatFarm Bridge] =====================================')
    print('[WheatFarm Bridge] ✅ Bridge Initialized Successfully!')
    print('[WheatFarm Bridge] Framework: ' .. GetFrameworkName())
    print('[WheatFarm Bridge] Inventory: ' .. GetInventoryName())
    print('[WheatFarm Bridge] =====================================')
end)

-- =====================================================
-- UNIFIED EXPORTS
-- =====================================================

-- Export all bridge functions globally
if IsDuplicityVersion() then
    -- Server exports
    exports('GetPlayer', GetPlayer)
    exports('AddMoney', AddMoney)
    exports('RemoveMoney', RemoveMoney)
    exports('AddItem', AddItem)
    exports('RemoveItem', RemoveItem)
    exports('GetItemCount', GetItemCount)
    exports('CanCarryItem', CanCarryItem)
    exports('GetItemWithSlot', GetItemWithSlot)
    exports('Notify', Notify)
    exports('GetFrameworkName', GetFrameworkName)
    exports('GetInventoryName', GetInventoryName)
    exports('IsFrameworkReady', IsFrameworkReady)
    exports('IsInventoryReady', IsInventoryReady)
else
    -- Client exports
    exports('GetItemCountClient', GetItemCountClient)
    exports('HasRequiredTool', HasRequiredTool)
    exports('Notify', Notify)
    exports('GetFrameworkName', GetFrameworkName)
    exports('GetInventoryName', GetInventoryName)
    exports('IsFrameworkReady', IsFrameworkReady)
    exports('IsInventoryReady', IsInventoryReady)
end

print('[WheatFarm Bridge] Module loaded!')
