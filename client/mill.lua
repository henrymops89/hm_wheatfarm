-- =====================================================
-- CLIENT/MILL.LUA - Mill Processing System
-- Handles wheat → flour conversion
-- =====================================================

local isProcessing = false
local millPed = nil
local inMillZone = false

-- =====================================================
-- MILL INTERACTION
-- =====================================================

local function ProcessMill()
    -- Guard: Already processing
    if isProcessing then
        Notify(Lang:t('mill_busy'), 'error')
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
    
    -- Check if player has enough wheat (client-side check)
    local requiredAmount = Config.Mill.input.amount
    if not HasEnoughItems(Config.Mill.input.item, requiredAmount) then
        Notify(Lang:t('not_enough_wheat', Config.Mill.input.item, requiredAmount), 'error')
        return
    end
    
    isProcessing = true
    
    -- Show progress bar
    local success = ShowProgressBar({
        duration = Config.Mill.processingTime or 8000,
        label = Lang:t('milling'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = Config.Mill.animation and {
            dict = Config.Mill.animation.dict,
            clip = Config.Mill.animation.clip,
        },
        prop = Config.Mill.animation and Config.Mill.animation.prop,
    })
    
    isProcessing = false
    
    -- Process result
    if success then
        -- Trigger server to process
        TriggerServerEvent('wheat:mill:process')
    else
        Notify('Verarbeitung abgebrochen!', 'error')
    end
end

-- =====================================================
-- SPAWN MILL PED
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    if not Config.Mill or not Config.Mill.enabled then return end
    
    if Config.Mill.ped and Config.Mill.ped.enabled then
        millPed = SpawnPed(Config.Mill.ped)
        
        if millPed then
            DebugPrint('Mill ped spawned successfully')
            
            -- Add target interaction if using target system
            if Config.Mill.interactionType == 'auto' or Config.Mill.interactionType == 'ox_target' then
                if GetResourceState('ox_target') == 'started' then
                    exports.ox_target:addLocalEntity(millPed, {
                        {
                            name = 'wheat_mill',
                            icon = Config.Mill.target.icon or 'fa-solid fa-wheat-awn',
                            label = Lang:t('mill_target_label'),
                            distance = Config.Mill.target.distance or 3.0,
                            onSelect = function()
                                ProcessMill()
                            end
                        }
                    })
                end
            elseif Config.Mill.interactionType == 'qb-target' then
                if GetResourceState('qb-target') == 'started' then
                    exports['qb-target']:AddTargetEntity(millPed, {
                        options = {
                            {
                                icon = Config.Mill.target.icon or 'fa-solid fa-wheat-awn',
                                label = Lang:t('mill_target_label'),
                                action = function()
                                    ProcessMill()
                                end
                            }
                        },
                        distance = Config.Mill.target.distance or 3.0
                    })
                end
            end
        else
            print('^1[WheatFarm] ERROR: Failed to spawn mill ped!^7')
        end
    end
end)

-- =====================================================
-- ZONE MANAGEMENT (for 3D text / marker)
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    if not Config.Mill or not Config.Mill.enabled then return end
    
    -- Create zone
    local point = lib.points.new({
        coords = Config.Mill.location,
        distance = Config.Mill.radius or 10.0,
    })
    
    function point:onEnter()
        inMillZone = true
        
        -- Show TextUI if using 3D text
        if Config.Mill.interactionType == '3dtext' then
            lib.showTextUI('[E] Weizen verarbeiten', {
                position = 'left-center',
                icon = 'wheat-awn',
            })
        end
    end
    
    function point:onExit()
        inMillZone = false
        
        if Config.Mill.interactionType == '3dtext' then
            lib.hideTextUI()
        end
    end
    
    function point:nearby()
        -- ✅ GEÄNDERT: Nur 3D-Text zeigen wenn explizit gewünscht
        if Config.Mill.interactionType == '3dtext' and Config.Mill.text3d and Config.Mill.text3d.show3DText ~= false then
            if millPed and DoesEntityExist(millPed) then
                local pedCoords = GetEntityCoords(millPed)
                local textCoords = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 2.0)
                
                Draw3DText(
                    textCoords,
                    Config.Mill.text3d.text or '[E] Weizen verarbeiten',
                    Config.Mill.text3d.scale or 0.35
                )
            end
        end
    end
    
    DebugPrint('Mill zone created')
end)

-- =====================================================
-- KEY BINDING (for 3D text interaction)
-- =====================================================

if Config.Mill and Config.Mill.interactionType == '3dtext' then
    CreateThread(function()
        Wait(2000)
        
        RegisterCommand('+millProcess', function()
            if inMillZone and not isProcessing then
                -- Check distance to ped
                if millPed and DoesEntityExist(millPed) then
                    local pedCoords = GetEntityCoords(millPed)
                    local distance = GetDistanceToLocation(pedCoords)
                    
                    if distance <= (Config.Mill.text3d.distance or 5.0) then
                        ProcessMill()
                    end
                end
            end
        end, false)
        
        RegisterCommand('-millProcess', function() end, false)
        
        RegisterKeyMapping('+millProcess', 'Mühle: Verarbeiten', 'keyboard', 'E')
    end)
end

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Delete ped
    if millPed and DoesEntityExist(millPed) then
        DeleteEntity(millPed)
    end
    
    -- Hide TextUI
    if inMillZone then
        lib.hideTextUI()
    end
end)

AddEventHandler('wheat:cleanup', function()
    isProcessing = false
    inMillZone = false
    
    if inMillZone then
        lib.hideTextUI()
    end
end)