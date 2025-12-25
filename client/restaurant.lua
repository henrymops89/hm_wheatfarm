-- =====================================================
-- CLIENT/RESTAURANT.LUA - Fries Selling System
-- Handles selling fries to restaurant
-- =====================================================

local isSelling = false
local restaurantPed = nil
local inRestaurantZone = false

-- =====================================================
-- RESTAURANT INTERACTION
-- =====================================================

local function SellFries()
    -- Guard: Already selling
    if isSelling then
        Notify('Du verkaufst bereits!', 'error')
        return
    end
    
    -- Guard: Player state
    local canInteract, reason = CanPlayerInteract()
    if not canInteract then
        if reason == 'player_dead' then
            Notify('Du kannst nicht verkaufen während du tot bist!', 'error')
        elseif reason == 'in_vehicle' then
            Notify('Du musst aus dem Fahrzeug aussteigen!', 'error')
        end
        return
    end
    
    -- Check if player has fries
    local friesCount = GetItemCount(Config.Restaurant.item)
    
    if friesCount <= 0 then
        Notify('Du hast keine ' .. Config.Restaurant.item .. ' zum Verkaufen!', 'error')
        return
    end
    
    -- Ask how much to sell
    local input = lib.inputDialog('Pommes verkaufen', {
        {
            type = 'number',
            label = 'Menge',
            description = 'Du hast: ' .. friesCount .. 'x | Preis: $' .. Config.Restaurant.pricePerItem .. ' pro Einheit',
            required = true,
            min = 1,
            max = math.min(friesCount, Config.Restaurant.maxSellAmount or 100)
        }
    })
    
    -- Guard: Cancelled or invalid
    if not input or not input[1] then
        Notify('Verkauf abgebrochen!', 'error')
        return
    end
    
    local amount = tonumber(input[1])
    
    -- Validate amount
    if not amount or amount <= 0 then
        Notify('Ungültige Menge!', 'error')
        return
    end
    
    if amount > friesCount then
        Notify('Du hast nicht genug ' .. Config.Restaurant.item .. '!', 'error')
        return
    end
    
    isSelling = true
    
    -- Show progress bar
    local success = ShowProgressBar({
        duration = 3000,
        label = 'Pommes werden verkauft...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = 'mp_common',
            clip = 'givetake1_a',
        }
    })
    
    isSelling = false
    
    -- Process result
    if success then
        TriggerServerEvent('wheat:restaurant:sell', amount)
    else
        Notify('Verkauf abgebrochen!', 'error')
    end
end

-- =====================================================
-- SPAWN RESTAURANT PED
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    if not Config.Restaurant or not Config.Restaurant.enabled then return end
    
    if Config.Restaurant.ped and Config.Restaurant.ped.enabled then
        restaurantPed = SpawnPed(Config.Restaurant.ped)
        
        if restaurantPed then
            DebugPrint('Restaurant ped spawned successfully')
            
            -- Add target interaction
            if Config.Restaurant.interactionType == 'auto' or Config.Restaurant.interactionType == 'ox_target' then
                if GetResourceState('ox_target') == 'started' then
                    exports.ox_target:addLocalEntity(restaurantPed, {
                        {
                            name = 'wheat_restaurant',
                            icon = Config.Restaurant.target.icon or 'fa-solid fa-dollar-sign',
                            label = Config.Restaurant.target.label or 'Pommes verkaufen',
                            distance = Config.Restaurant.target.distance or 3.0,
                            onSelect = function()
                                SellFries()
                            end
                        }
                    })
                end
            elseif Config.Restaurant.interactionType == 'qb-target' then
                if GetResourceState('qb-target') == 'started' then
                    exports['qb-target']:AddTargetEntity(restaurantPed, {
                        options = {
                            {
                                icon = Config.Restaurant.target.icon or 'fa-solid fa-dollar-sign',
                                label = Config.Restaurant.target.label or 'Pommes verkaufen',
                                action = function()
                                    SellFries()
                                end
                            }
                        },
                        distance = Config.Restaurant.target.distance or 3.0
                    })
                end
            end
        else
            print('^1[WheatFarm] ERROR: Failed to spawn restaurant ped!^7')
        end
    end
end)

-- =====================================================
-- ZONE MANAGEMENT
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    if not Config.Restaurant or not Config.Restaurant.enabled then return end
    
    local point = lib.points.new({
        coords = Config.Restaurant.location,
        distance = Config.Restaurant.radius or 10.0,
    })
    
    function point:onEnter()
        inRestaurantZone = true
        
        if Config.Restaurant.interactionType == '3dtext' then
            lib.showTextUI('[E] Pommes verkaufen', {
                position = 'left-center',
                icon = 'dollar-sign',
            })
        end
    end
    
    function point:onExit()
        inRestaurantZone = false
        
        if Config.Restaurant.interactionType == '3dtext' then
            lib.hideTextUI()
        end
    end
    
    function point:nearby()
        if Config.Restaurant.interactionType == '3dtext' and Config.Restaurant.text3d then
            if restaurantPed and DoesEntityExist(restaurantPed) then
                local pedCoords = GetEntityCoords(restaurantPed)
                local textCoords = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 2.0)
                
                Draw3DText(
                    textCoords,
                    Config.Restaurant.text3d.text or '[E] Pommes verkaufen',
                    Config.Restaurant.text3d.scale or 0.35
                )
            end
        end
    end
    
    DebugPrint('Restaurant zone created')
end)

-- =====================================================
-- KEY BINDING
-- =====================================================

if Config.Restaurant and Config.Restaurant.interactionType == '3dtext' then
    CreateThread(function()
        Wait(2000)
        
        RegisterCommand('+restaurantSell', function()
            if inRestaurantZone and not isSelling then
                if restaurantPed and DoesEntityExist(restaurantPed) then
                    local pedCoords = GetEntityCoords(restaurantPed)
                    local distance = GetDistanceToLocation(pedCoords)
                    
                    if distance <= (Config.Restaurant.text3d.distance or 5.0) then
                        SellFries()
                    end
                end
            end
        end, false)
        
        RegisterCommand('-restaurantSell', function() end, false)
        
        RegisterKeyMapping('+restaurantSell', 'Restaurant: Verkaufen', 'keyboard', 'E')
    end)
end

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if restaurantPed and DoesEntityExist(restaurantPed) then
        DeleteEntity(restaurantPed)
    end
    
    if inRestaurantZone then
        lib.hideTextUI()
    end
end)

AddEventHandler('wheat:cleanup', function()
    isSelling = false
    inRestaurantZone = false
    
    if inRestaurantZone then
        lib.hideTextUI()
    end
end)
