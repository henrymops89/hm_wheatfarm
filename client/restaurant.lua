-- =====================================================
-- CLIENT/RESTAURANT.LUA - Fast Food Restaurant System
-- Single Responsibility: Handle restaurant PED & interaction
-- =====================================================

local restaurantPed = nil
local restaurantTarget = nil

-- =====================================================
-- SELL FRIES FUNCTION
-- =====================================================

local function sellFries()
    -- Check if player is near restaurant
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - Config.Restaurant.location)
    
    if distance > Config.Restaurant.radius then
        Notify('Du bist zu weit vom Restaurant entfernt!', 'error')
        return
    end
    
    -- Check if player has fries
    local friesCount = GetItemCount(Config.Restaurant.item)
    
    if friesCount == 0 then
        Notify('Du hast keine Pommes!', 'error')
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
    local input = lib.inputDialog('Pommes verkaufen', {
        {
            type = 'number',
            label = 'Menge',
            description = string.format('Du hast %dx Pommes', friesCount),
            required = true,
            min = 1,
            max = math.min(friesCount, Config.Restaurant.maxSellAmount or 100),
            default = friesCount
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
    
    if amount > friesCount then
        Notify('Du hast nicht genug Pommes!', 'error')
        return
    end
    
    -- Trigger server event
    TriggerServerEvent('wheat:restaurant:sell', amount)
end

-- =====================================================
-- SPAWN RESTAURANT PED
-- =====================================================

local function spawnRestaurantPed()
    if not Config.Restaurant.ped or not Config.Restaurant.ped.enabled then
        print('[WheatFarm] Restaurant PED disabled')
        return
    end
    
    print('[WheatFarm] Spawning restaurant PED...')
    
    restaurantPed = SpawnPed(Config.Restaurant.ped)
    
    if restaurantPed then
        print('[WheatFarm] ✅ Restaurant PED spawned: ' .. tostring(restaurantPed))
    else
        print('^1[WheatFarm] Failed to spawn restaurant PED!^7')
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
    
    print('[WheatFarm] Setting up ox_target for restaurant...')
    
    local targetConfig = Config.Restaurant.target
    
    if restaurantPed then
        -- Target on PED
        exports.ox_target:addLocalEntity(restaurantPed, {
            {
                name = 'wheat_restaurant_sell',
                icon = targetConfig.icon or 'fa-solid fa-dollar-sign',
                label = targetConfig.label or 'Pommes verkaufen',
                distance = targetConfig.distance or 3.0,
                onSelect = function()
                    sellFries()
                end
            }
        })
        
        print('[WheatFarm] ✅ ox_target added to restaurant PED')
    else
        -- Target on location (sphere)
        restaurantTarget = exports.ox_target:addSphereZone({
            coords = Config.Restaurant.location,
            radius = targetConfig.distance or 3.0,
            options = {
                {
                    name = 'wheat_restaurant_sell',
                    icon = targetConfig.icon or 'fa-solid fa-dollar-sign',
                    label = targetConfig.label or 'Pommes verkaufen',
                    onSelect = function()
                        sellFries()
                    end
                }
            }
        })
        
        print('[WheatFarm] ✅ ox_target zone created for restaurant')
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
    
    print('[WheatFarm] Setting up qb-target for restaurant...')
    
    local targetConfig = Config.Restaurant.target
    
    if restaurantPed then
        -- Target on PED
        exports['qb-target']:AddTargetEntity(restaurantPed, {
            options = {
                {
                    icon = targetConfig.icon or 'fa-solid fa-dollar-sign',
                    label = targetConfig.label or 'Pommes verkaufen',
                    action = function()
                        sellFries()
                    end
                }
            },
            distance = targetConfig.distance or 3.0
        })
        
        print('[WheatFarm] ✅ qb-target added to restaurant PED')
    else
        -- Target on location
        exports['qb-target']:AddBoxZone('wheat_restaurant', Config.Restaurant.location, 2.0, 2.0, {
            name = 'wheat_restaurant',
            heading = 0,
            debugPoly = false,
            minZ = Config.Restaurant.location.z - 1.0,
            maxZ = Config.Restaurant.location.z + 2.0,
        }, {
            options = {
                {
                    icon = targetConfig.icon or 'fa-solid fa-dollar-sign',
                    label = targetConfig.label or 'Pommes verkaufen',
                    action = function()
                        sellFries()
                    end
                }
            },
            distance = targetConfig.distance or 3.0
        })
        
        print('[WheatFarm] ✅ qb-target zone created for restaurant')
    end
    
    return true
end

-- =====================================================
-- SETUP 3D TEXT INTERACTION
-- =====================================================

local function setup3DText()
    print('[WheatFarm] Setting up 3D text for restaurant...')
    
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.Restaurant.location)
            
            if distance < (Config.Restaurant.text3d.distance or 5.0) then
                sleep = 0
                
                -- Draw 3D text
                Draw3DText(
                    Config.Restaurant.location,
                    Config.Restaurant.text3d.text or '[E] Pommes verkaufen',
                    Config.Restaurant.text3d.scale or 0.35
                )
                
                -- Check for E key press
                if distance < Config.Restaurant.radius and IsControlJustPressed(0, 38) then -- E key
                    sellFries()
                end
            end
            
            Wait(sleep)
        end
    end)
    
    print('[WheatFarm] ✅ 3D text thread started for restaurant')
end

-- =====================================================
-- INITIALIZE RESTAURANT
-- =====================================================

local function initializeRestaurant()
    -- Guard: Restaurant disabled
    if not Config.Restaurant or not Config.Restaurant.enabled then
        print('[WheatFarm] Restaurant is disabled in config')
        return
    end
    
    print('[WheatFarm] 🍟 Initializing restaurant system...')
    
    -- Spawn PED
    spawnRestaurantPed()
    
    Wait(500) -- Wait for PED to spawn
    
    -- Setup interaction based on type
    local interactionType = Config.Restaurant.interactionType or "ox_target"
    
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
    
    print('[WheatFarm] ✅ Restaurant initialized!')
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
        print('^1[WheatFarm] Restaurant: Framework not ready!^7')
        return
    end
    
    Wait(2000) -- Extra wait for resources
    
    initializeRestaurant()
end)

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Delete PED
    if restaurantPed and DoesEntityExist(restaurantPed) then
        DeleteEntity(restaurantPed)
    end
    
    -- Remove targets
    if restaurantTarget and Config.Restaurant.interactionType == "ox_target" then
        exports.ox_target:removeZone(restaurantTarget)
    end
    
    if Config.Restaurant.interactionType == "qb-target" then
        exports['qb-target']:RemoveZone('wheat_restaurant')
    end
    
    print('[WheatFarm] Restaurant cleaned up')
end)