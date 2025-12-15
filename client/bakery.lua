-- =====================================================
-- CLIENT/BAKERY.LUA - Bakery Selling System
-- Single Responsibility: Handle bakery PED & interaction
-- =====================================================

local bakeryPed = nil
local bakeryTarget = nil

-- =====================================================
-- SELL FLOUR FUNCTION
-- =====================================================

local function sellFlour()
    -- Check if player is near bakery
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - Config.Bakery.location)
    
    if distance > Config.Bakery.radius then
        Notify('Du bist zu weit von der Bäckerei entfernt!', 'error')
        return
    end
    
    -- Check if player has flour
    local flourCount = GetItemCount(Config.Bakery.item)
    
    if flourCount == 0 then
        Notify('Du hast kein Mehl!', 'error')
        return
    end
    
    -- Check if player can interact
    local canInteract, reason = CanPlayerInteract()
    if not canInteract then
        if reason == 'in_vehicle' then
            Notify('Du kannst nicht im Fahrzeug verkaufen!', 'error')
        end
        return
    end
    
    -- Ask for amount
    local input = lib.inputDialog('Mehl verkaufen', {
        {
            type = 'number',
            label = 'Menge',
            description = string.format('Du hast %dx Mehl', flourCount),
            required = true,
            min = 1,
            max = math.min(flourCount, Config.Bakery.maxSellAmount or 100),
            default = flourCount
        }
    })
    
    if not input or not input[1] then
        Notify('Verkauf abgebrochen!', 'error')
        return
    end
    
    local amount = tonumber(input[1])
    
    if not amount or amount <= 0 then
        Notify('Ungültige Menge!', 'error')
        return
    end
    
    if amount > flourCount then
        Notify('Du hast nicht genug Mehl!', 'error')
        return
    end
    
    -- Trigger server event
    TriggerServerEvent('wheat:bakery:sell', amount)
end

-- =====================================================
-- SPAWN BAKERY PED
-- =====================================================

local function spawnBakeryPed()
    if not Config.Bakery.ped or not Config.Bakery.ped.enabled then
        print('[WheatFarm] Bakery PED disabled')
        return
    end
    
    print('[WheatFarm] Spawning bakery PED...')
    
    bakeryPed = SpawnPed(Config.Bakery.ped)
    
    if bakeryPed then
        print('[WheatFarm] ✅ Bakery PED spawned: ' .. tostring(bakeryPed))
    else
        print('^1[WheatFarm] Failed to spawn bakery PED!^7')
    end
end

-- =====================================================
-- SETUP OX_TARGET
-- =====================================================

local function setupOxTarget()
    if GetResourceState('ox_target') ~= 'started' then
        print('^3[WheatFarm] ox_target not found!^7')
        return false
    end
    
    print('[WheatFarm] Setting up ox_target for bakery...')
    
    local targetConfig = Config.Bakery.target
    
    if bakeryPed then
        -- Target on PED
        exports.ox_target:addLocalEntity(bakeryPed, {
            {
                name = 'wheat_bakery_sell',
                icon = targetConfig.icon or 'fa-solid fa-dollar-sign',
                label = targetConfig.label or 'Mehl verkaufen',
                distance = targetConfig.distance or 3.0,
                onSelect = function()
                    sellFlour()
                end
            }
        })
        
        print('[WheatFarm] ✅ ox_target added to bakery PED')
    else
        -- Target on location (sphere)
        bakeryTarget = exports.ox_target:addSphereZone({
            coords = Config.Bakery.location,
            radius = targetConfig.distance or 3.0,
            options = {
                {
                    name = 'wheat_bakery_sell',
                    icon = targetConfig.icon or 'fa-solid fa-dollar-sign',
                    label = targetConfig.label or 'Mehl verkaufen',
                    onSelect = function()
                        sellFlour()
                    end
                }
            }
        })
        
        print('[WheatFarm] ✅ ox_target zone created for bakery')
    end
    
    return true
end

-- =====================================================
-- SETUP QB-TARGET
-- =====================================================

local function setupQBTarget()
    if GetResourceState('qb-target') ~= 'started' then
        print('^3[WheatFarm] qb-target not found!^7')
        return false
    end
    
    print('[WheatFarm] Setting up qb-target for bakery...')
    
    local targetConfig = Config.Bakery.target
    
    if bakeryPed then
        -- Target on PED
        exports['qb-target']:AddTargetEntity(bakeryPed, {
            options = {
                {
                    icon = targetConfig.icon or 'fa-solid fa-dollar-sign',
                    label = targetConfig.label or 'Mehl verkaufen',
                    action = function()
                        sellFlour()
                    end
                }
            },
            distance = targetConfig.distance or 3.0
        })
        
        print('[WheatFarm] ✅ qb-target added to bakery PED')
    else
        -- Target on location
        exports['qb-target']:AddBoxZone('wheat_bakery', Config.Bakery.location, 2.0, 2.0, {
            name = 'wheat_bakery',
            heading = 0,
            debugPoly = false,
            minZ = Config.Bakery.location.z - 1.0,
            maxZ = Config.Bakery.location.z + 2.0,
        }, {
            options = {
                {
                    icon = targetConfig.icon or 'fa-solid fa-dollar-sign',
                    label = targetConfig.label or 'Mehl verkaufen',
                    action = function()
                        sellFlour()
                    end
                }
            },
            distance = targetConfig.distance or 3.0
        })
        
        print('[WheatFarm] ✅ qb-target zone created for bakery')
    end
    
    return true
end

-- =====================================================
-- SETUP 3D TEXT INTERACTION
-- =====================================================

local function setup3DText()
    print('[WheatFarm] Setting up 3D text for bakery...')
    
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.Bakery.location)
            
            if distance < (Config.Bakery.text3d.distance or 5.0) then
                sleep = 0
                
                -- Draw 3D text
                Draw3DText(
                    Config.Bakery.location,
                    Config.Bakery.text3d.text or '[E] Mehl verkaufen',
                    Config.Bakery.text3d.scale or 0.35
                )
                
                -- Check for E key press
                if distance < Config.Bakery.radius and IsControlJustPressed(0, 38) then -- E key
                    sellFlour()
                end
            end
            
            Wait(sleep)
        end
    end)
    
    print('[WheatFarm] ✅ 3D text thread started for bakery')
end

-- =====================================================
-- INITIALIZE BAKERY
-- =====================================================

local function initializeBakery()
    -- Guard: Bakery disabled
    if not Config.Bakery or not Config.Bakery.enabled then
        print('[WheatFarm] Bakery is disabled in config')
        return
    end
    
    print('[WheatFarm] 🏪 Initializing bakery system...')
    
    -- Spawn PED
    spawnBakeryPed()
    
    Wait(500) -- Wait for PED to spawn
    
    -- Setup interaction based on type
    local interactionType = Config.Bakery.interactionType or "ox_target"
    
    if interactionType == "ox_target" then
        if not setupOxTarget() then
            print('^3[WheatFarm] ox_target failed, falling back to 3D text^7')
            setup3DText()
        end
    elseif interactionType == "qb-target" then
        if not setupQBTarget() then
            print('^3[WheatFarm] qb-target failed, falling back to 3D text^7')
            setup3DText()
        end
    elseif interactionType == "3dtext" then
        setup3DText()
    else
        print('^3[WheatFarm] Unknown interaction type: ' .. tostring(interactionType) .. ', using 3D text^7')
        setup3DText()
    end
    
    print('[WheatFarm] ✅ Bakery initialized!')
end

-- =====================================================
-- START INITIALIZATION
-- =====================================================

CreateThread(function()
    -- Wait for framework
    local attempts = 0
    while not IsFrameworkReady() and attempts < 50 do
        Wait(100)
        attempts = attempts + 1
    end
    
    if not IsFrameworkReady() then
        print('^1[WheatFarm] Bakery: Framework not ready!^7')
        return
    end
    
    Wait(2000) -- Extra wait for resources
    
    initializeBakery()
end)

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Delete PED
    if bakeryPed and DoesEntityExist(bakeryPed) then
        DeleteEntity(bakeryPed)
    end
    
    -- Remove targets
    if bakeryTarget and Config.Bakery.interactionType == "ox_target" then
        exports.ox_target:removeZone(bakeryTarget)
    end
    
    if Config.Bakery.interactionType == "qb-target" then
        exports['qb-target']:RemoveZone('wheat_bakery')
    end
    
    print('[WheatFarm] Bakery cleaned up')
end)