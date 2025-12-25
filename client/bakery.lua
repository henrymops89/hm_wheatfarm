-- =====================================================
-- CLIENT/BAKERY.LUA - Flour Selling System
-- Handles selling flour to bakery
-- =====================================================

local isSelling = false
local bakeryPed = nil
local inBakeryZone = false

-- =====================================================
-- BAKERY INTERACTION
-- =====================================================

local function SellFlour()
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
    local input = lib.inputDialog(Lang:t('sell_flour_title'), {
        {
            type = 'number',
            label = Lang:t('amount_label'),
            description = Lang:t('price_per_unit', Config.Bakery.pricePerItem),
            required = true,
            min = 1,
            max = Config.Bakery.maxSellAmount or 100
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
        label = Lang:t('selling_flour'),
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
        -- Server validiert ob genug Mehl vorhanden ist!
        TriggerServerEvent('wheat:bakery:sell', amount)
    else
        Notify(Lang:t('sale_cancelled'), 'error')
    end
end

-- =====================================================
-- SPAWN BAKERY PED
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    if not Config.Bakery or not Config.Bakery.enabled then return end
    
    if Config.Bakery.ped and Config.Bakery.ped.enabled then
        bakeryPed = SpawnPed(Config.Bakery.ped)
        
        if bakeryPed then
            DebugPrint('Bakery ped spawned successfully')
            
            -- Add target interaction
            if Config.Bakery.interactionType == 'auto' or Config.Bakery.interactionType == 'ox_target' then
                if GetResourceState('ox_target') == 'started' then
                    exports.ox_target:addLocalEntity(bakeryPed, {
                        {
                            name = 'wheat_bakery',
                            icon = Config.Bakery.target.icon or 'fa-solid fa-dollar-sign',
                            label = Lang:t('bakery_target_label'),
                            distance = Config.Bakery.target.distance or 3.0,
                            onSelect = function()
                                SellFlour()
                            end
                        }
                    })
                end
            elseif Config.Bakery.interactionType == 'qb-target' then
                if GetResourceState('qb-target') == 'started' then
                    exports['qb-target']:AddTargetEntity(bakeryPed, {
                        options = {
                            {
                                icon = Config.Bakery.target.icon or 'fa-solid fa-dollar-sign',
                                label = Lang:t('bakery_target_label'),
                                action = function()
                                    SellFlour()
                                end
                            }
                        },
                        distance = Config.Bakery.target.distance or 3.0
                    })
                end
            end
        else
            print('^1[WheatFarm] ERROR: Failed to spawn bakery ped!^7')
        end
    end
end)

-- =====================================================
-- ZONE MANAGEMENT
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    if not Config.Bakery or not Config.Bakery.enabled then return end
    
    local point = lib.points.new({
        coords = Config.Bakery.location,
        distance = Config.Bakery.radius or 10.0,
    })
    
function point:onEnter()
    inBakeryZone = true
    
    if Config.Bakery.interactionType == '3dtext' then
        local sellKey = Config.Keybinds.bakerySell.key
        local text = Lang:t('textui_sell', '[' .. sellKey .. ']')
        
        lib.showTextUI(text, {
            position = 'left-center',
            icon = 'dollar-sign',
        })
    end
end
    
    function point:onExit()
        inBakeryZone = false
        
        if Config.Bakery.interactionType == '3dtext' then
            lib.hideTextUI()
        end
    end
    
function point:nearby()
    if Config.Bakery.interactionType == '3dtext' and Config.Bakery.text3d and Config.Bakery.text3d.show3DText ~= false then
        if bakeryPed and DoesEntityExist(bakeryPed) then
            local pedCoords = GetEntityCoords(bakeryPed)
            local textCoords = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 2.0)
            
            local sellKey = Config.Keybinds.bakerySell.key
            local text = Lang:t('textui_sell', '[' .. sellKey .. ']')
            
            Draw3DText(
                textCoords,
                Config.Bakery.text3d.text or text,
                Config.Bakery.text3d.scale or 0.35
            )
        end
    end
end
    
    DebugPrint('Bakery zone created')
end)

-- =====================================================
-- KEY BINDING
-- =====================================================

if Config.Bakery and Config.Bakery.interactionType == '3dtext' then
    CreateThread(function()
        Wait(2000)
        
        RegisterCommand('+bakerySell', function()
            if inBakeryZone and not isSelling then
                if bakeryPed and DoesEntityExist(bakeryPed) then
                    local pedCoords = GetEntityCoords(bakeryPed)
                    local distance = GetDistanceToLocation(pedCoords)
                    
                    if distance <= (Config.Bakery.text3d.distance or 5.0) then
                        SellFlour()
                    end
                end
            end
        end, false)
        
        RegisterCommand('-bakerySell', function() end, false)
        
        RegisterKeyMapping('+bakerySell', 'Bäckerei: Verkaufen', 'keyboard', 'E')
    end)
end

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if bakeryPed and DoesEntityExist(bakeryPed) then
        DeleteEntity(bakeryPed)
    end
    
    if inBakeryZone then
        lib.hideTextUI()
    end
end)

AddEventHandler('wheat:cleanup', function()
    isSelling = false
    inBakeryZone = false
    
    if inBakeryZone then
        lib.hideTextUI()
    end
end)