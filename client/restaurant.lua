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
        Notify(Lang:t('already_selling'), 'error')
        return
    end
    
    -- Guard: Player state
    local canInteract, reason = CanPlayerInteract()
    if not canInteract then
        if reason == 'player_dead' then
            Notify(Lang:t('player_dead'), 'error')
        elseif reason == 'in_vehicle' then
            Notify(Lang:t('in_vehicle'), 'error')
        end
        return
    end
    
    -- Ask how much to sell
    local input = lib.inputDialog(Lang:t('sell_fries_title'), {
        {
            type = 'number',
            label = Lang:t('amount_label'),
            description = Lang:t('price_per_unit', Config.Restaurant.pricePerItem),
            required = true,
            min = 1,
            max = Config.Restaurant.maxSellAmount or 100
        }
    })
    
    -- Guard: Cancelled or invalid
    if not input or not input[1] then
        Notify(Lang:t('sale_cancelled'), 'error')
        return
    end
    
    local amount = tonumber(input[1])
    
    -- Validate amount
    if not amount or amount <= 0 then
        Notify(Lang:t('invalid_amount'), 'error')
        return
    end
    
    isSelling = true
    
    -- Show progress bar
    local success = ShowProgressBar({
        duration = 3000,
        label = Lang:t('selling_fries'),
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
        -- Server validiert ob genug Pommes vorhanden sind!
        TriggerServerEvent('wheat:restaurant:sell', amount)
    else
        Notify(Lang:t('sale_cancelled'), 'error')
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
                            label = Lang:t('restaurant_target_label'),
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
                                label = Lang:t('restaurant_target_label'),
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
        local sellKey = Config.Keybinds.restaurantSell.key
        local text = Lang:t('textui_sell', '[' .. sellKey .. ']')
        
        lib.showTextUI(text, {
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
    if Config.Restaurant.interactionType == '3dtext' and Config.Restaurant.text3d and Config.Restaurant.text3d.show3DText ~= false then
        if restaurantPed and DoesEntityExist(restaurantPed) then
            local pedCoords = GetEntityCoords(restaurantPed)
            local textCoords = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 2.0)
            
            local sellKey = Config.Keybinds.restaurantSell.key
            local text = Lang:t('textui_sell', '[' .. sellKey .. ']')
            
            Draw3DText(
                textCoords,
                Config.Restaurant.text3d.text or text,
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