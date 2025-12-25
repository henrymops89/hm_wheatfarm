-- =====================================================
-- CLIENT/PROCESSOR.LUA - Potato Processing System
-- Handles potato → fries conversion
-- =====================================================

local isProcessing = false
local processorPed = nil
local inProcessorZone = false

-- =====================================================
-- PROCESSOR INTERACTION
-- =====================================================

local function ProcessPotatoes()
    -- Guard: Already processing
    if isProcessing then
        Notify('Die Fritteuse ist bereits in Betrieb!', 'error')
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
    
    -- Check if player has enough potatoes
    local requiredAmount = Config.Processor.input.amount
    if not HasEnoughItems(Config.Processor.input.item, requiredAmount) then
        Notify(Lang:t('not_enough_potatoes', Config.Processor.input.item, requiredAmount), 'error')
        return
    end
    
    isProcessing = true
    
    -- Show progress bar
    local success = ShowProgressBar({
        duration = Config.Processor.processingTime or 10000,
        label = Lang:t('processing'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = Config.Processor.animation and {
            dict = Config.Processor.animation.dict,
            clip = Config.Processor.animation.clip,
        },
        prop = Config.Processor.animation and Config.Processor.animation.prop,
    })
    
    isProcessing = false
    
    -- Process result
    if success then
        TriggerServerEvent('wheat:processor:process')
    else
        Notify('Verarbeitung abgebrochen!', 'error')
    end
end

-- =====================================================
-- SPAWN PROCESSOR PED
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    if not Config.Processor or not Config.Processor.enabled then return end
    
    if Config.Processor.ped and Config.Processor.ped.enabled then
        processorPed = SpawnPed(Config.Processor.ped)
        
        if processorPed then
            DebugPrint('Processor ped spawned successfully')
            
            -- Add target interaction
            if Config.Processor.interactionType == 'auto' or Config.Processor.interactionType == 'ox_target' then
                if GetResourceState('ox_target') == 'started' then
                    exports.ox_target:addLocalEntity(processorPed, {
                        {
                            name = 'wheat_processor',
                            icon = Config.Processor.target.icon or 'fa-solid fa-fire-burner',
                            label = Lang:t('processor_target_label'),
                            distance = Config.Processor.target.distance or 3.0,
                            onSelect = function()
                                ProcessPotatoes()
                            end
                        }
                    })
                end
            elseif Config.Processor.interactionType == 'qb-target' then
                if GetResourceState('qb-target') == 'started' then
                    exports['qb-target']:AddTargetEntity(processorPed, {
                        options = {
                            {
                                icon = Config.Processor.target.icon or 'fa-solid fa-fire-burner',
                                label = Lang:t('processor_target_label'),
                                action = function()
                                    ProcessPotatoes()
                                end
                            }
                        },
                        distance = Config.Processor.target.distance or 3.0
                    })
                end
            end
        else
            print('^1[WheatFarm] ERROR: Failed to spawn processor ped!^7')
        end
    end
end)

-- =====================================================
-- ZONE MANAGEMENT
-- =====================================================

CreateThread(function()
    Wait(2000)
    
    if not Config.Processor or not Config.Processor.enabled then return end
    
    local point = lib.points.new({
        coords = Config.Processor.location,
        distance = Config.Processor.radius or 10.0,
    })
    
    function point:onEnter()
        inProcessorZone = true
        
        if Config.Processor.interactionType == '3dtext' then
            lib.showTextUI('[E] Kartoffeln verarbeiten', {
                position = 'left-center',
                icon = 'fire-burner',
            })
        end
    end
    
    function point:onExit()
        inProcessorZone = false
        
        if Config.Processor.interactionType == '3dtext' then
            lib.hideTextUI()
        end
    end
    
    function point:nearby()
        -- ✅ GEÄNDERT: Nur 3D-Text zeigen wenn explizit gewünscht
        if Config.Processor.interactionType == '3dtext' and Config.Processor.text3d and Config.Processor.text3d.show3DText ~= false then
            if processorPed and DoesEntityExist(processorPed) then
                local pedCoords = GetEntityCoords(processorPed)
                local textCoords = vector3(pedCoords.x, pedCoords.y, pedCoords.z + 2.0)
                
                Draw3DText(
                    textCoords,
                    Config.Processor.text3d.text or '[E] Kartoffeln verarbeiten',
                    Config.Processor.text3d.scale or 0.35
                )
            end
        end
    end
    
    DebugPrint('Processor zone created')
end)

-- =====================================================
-- KEY BINDING
-- =====================================================

if Config.Processor and Config.Processor.interactionType == '3dtext' then
    CreateThread(function()
        Wait(2000)
        
        RegisterCommand('+processorProcess', function()
            if inProcessorZone and not isProcessing then
                if processorPed and DoesEntityExist(processorPed) then
                    local pedCoords = GetEntityCoords(processorPed)
                    local distance = GetDistanceToLocation(pedCoords)
                    
                    if distance <= (Config.Processor.text3d.distance or 5.0) then
                        ProcessPotatoes()
                    end
                end
            end
        end, false)
        
        RegisterCommand('-processorProcess', function() end, false)
        
        RegisterKeyMapping('+processorProcess', 'Processor: Verarbeiten', 'keyboard', 'E')
    end)
end

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if processorPed and DoesEntityExist(processorPed) then
        DeleteEntity(processorPed)
    end
    
    if inProcessorZone then
        lib.hideTextUI()
    end
end)

AddEventHandler('wheat:cleanup', function()
    isProcessing = false
    inProcessorZone = false
    
    if inProcessorZone then
        lib.hideTextUI()
    end
end)