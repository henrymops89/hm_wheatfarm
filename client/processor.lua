-- =====================================================
-- CLIENT/PROCESSOR.LUA - Potato Processing System
-- Single Responsibility: Handle processor PED & interaction
-- =====================================================

local processorPed = nil
local processorTarget = nil

-- =====================================================
-- POTATO PROCESSING FUNCTION
-- =====================================================

local function processPatato()
    -- Check if player is near processor
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - Config.Processor.location)
    
    if distance > Config.Processor.radius then
        Notify('Du bist zu weit vom Verarbeiter entfernt!', 'error')
        return
    end
    
    -- Check if player has enough potatoes
    if not HasEnoughItems(Config.Processor.input.item, Config.Processor.input.amount) then
        Notify(string.format('Du brauchst mindestens %dx Kartoffeln!', Config.Processor.input.amount), 'error')
        return
    end
    
    -- Check if player can interact
    local canInteract, reason = CanPlayerInteract()
    if not canInteract then
        if reason == 'in_vehicle' then
            Notify('Du kannst nicht im Fahrzeug verarbeiten!', 'error')
        end
        return
    end
    
    -- Get animation config
    local animConfig = Config.Processor.animation
    if not animConfig then
        animConfig = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        }
    end
    
    -- Show progress bar
    local success = ShowProgressBar({
        duration = Config.Processor.processingTime or 10000,
        label = 'Kartoffeln werden verarbeitet...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = animConfig.dict,
            clip = animConfig.clip,
        },
        prop = animConfig.prop
    })
    
    if success then
        -- Trigger server event
        TriggerServerEvent('wheat:processor:process')
    else
        Notify('Verarbeitung abgebrochen!', 'error')
    end
end

-- =====================================================
-- SPAWN PROCESSOR PED
-- =====================================================

local function spawnProcessorPed()
    if not Config.Processor.ped or not Config.Processor.ped.enabled then
        print('[WheatFarm] Processor PED disabled')
        return
    end
    
    print('[WheatFarm] Spawning processor PED...')
    
    processorPed = SpawnPed(Config.Processor.ped)
    
    if processorPed then
        print('[WheatFarm] ✅ Processor PED spawned: ' .. tostring(processorPed))
    else
        print('^1[WheatFarm] Failed to spawn processor PED!^7')
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
    
    print('[WheatFarm] Setting up ox_target for processor...')
    
    local targetConfig = Config.Processor.target
    
    if processorPed then
        -- Target on PED
        exports.ox_target:addLocalEntity(processorPed, {
            {
                name = 'wheat_processor_process',
                icon = targetConfig.icon or 'fa-solid fa-fire-burner',
                label = targetConfig.label or 'Kartoffeln verarbeiten',
                distance = targetConfig.distance or 3.0,
                onSelect = function()
                    processPatato()
                end
            }
        })
        
        print('[WheatFarm] ✅ ox_target added to processor PED')
    else
        -- Target on location (sphere)
        processorTarget = exports.ox_target:addSphereZone({
            coords = Config.Processor.location,
            radius = targetConfig.distance or 3.0,
            options = {
                {
                    name = 'wheat_processor_process',
                    icon = targetConfig.icon or 'fa-solid fa-fire-burner',
                    label = targetConfig.label or 'Kartoffeln verarbeiten',
                    onSelect = function()
                        processPatato()
                    end
                }
            }
        })
        
        print('[WheatFarm] ✅ ox_target zone created for processor')
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
    
    print('[WheatFarm] Setting up qb-target for processor...')
    
    local targetConfig = Config.Processor.target
    
    if processorPed then
        -- Target on PED
        exports['qb-target']:AddTargetEntity(processorPed, {
            options = {
                {
                    icon = targetConfig.icon or 'fa-solid fa-fire-burner',
                    label = targetConfig.label or 'Kartoffeln verarbeiten',
                    action = function()
                        processPatato()
                    end
                }
            },
            distance = targetConfig.distance or 3.0
        })
        
        print('[WheatFarm] ✅ qb-target added to processor PED')
    else
        -- Target on location
        exports['qb-target']:AddBoxZone('wheat_processor', Config.Processor.location, 2.0, 2.0, {
            name = 'wheat_processor',
            heading = 0,
            debugPoly = false,
            minZ = Config.Processor.location.z - 1.0,
            maxZ = Config.Processor.location.z + 2.0,
        }, {
            options = {
                {
                    icon = targetConfig.icon or 'fa-solid fa-fire-burner',
                    label = targetConfig.label or 'Kartoffeln verarbeiten',
                    action = function()
                        processPatato()
                    end
                }
            },
            distance = targetConfig.distance or 3.0
        })
        
        print('[WheatFarm] ✅ qb-target zone created for processor')
    end
    
    return true
end

-- =====================================================
-- SETUP 3D TEXT INTERACTION
-- =====================================================

local function setup3DText()
    print('[WheatFarm] Setting up 3D text for processor...')
    
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.Processor.location)
            
            if distance < (Config.Processor.text3d.distance or 5.0) then
                sleep = 0
                
                -- Draw 3D text
                Draw3DText(
                    Config.Processor.location,
                    Config.Processor.text3d.text or '[E] Kartoffeln verarbeiten',
                    Config.Processor.text3d.scale or 0.35
                )
                
                -- Check for E key press
                if distance < Config.Processor.radius and IsControlJustPressed(0, 38) then -- E key
                    processPatato()
                end
            end
            
            Wait(sleep)
        end
    end)
    
    print('[WheatFarm] ✅ 3D text thread started for processor')
end

-- =====================================================
-- INITIALIZE PROCESSOR
-- =====================================================

local function initializeProcessor()
    -- Guard: Processor disabled
    if not Config.Processor or not Config.Processor.enabled then
        print('[WheatFarm] Processor is disabled in config')
        return
    end
    
    print('[WheatFarm] 🥔 Initializing processor system...')
    
    -- Spawn PED
    spawnProcessorPed()
    
    Wait(500) -- Wait for PED to spawn
    
    -- Setup interaction based on type
    local interactionType = Config.Processor.interactionType or "ox_target"
    
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
    
    print('[WheatFarm] ✅ Processor initialized!')
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
        print('^1[WheatFarm] Processor: Framework not ready!^7')
        return
    end
    
    Wait(1500) -- Extra wait for resources
    
    initializeProcessor()
end)

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Delete PED
    if processorPed and DoesEntityExist(processorPed) then
        DeleteEntity(processorPed)
    end
    
    -- Remove targets
    if processorTarget and Config.Processor.interactionType == "ox_target" then
        exports.ox_target:removeZone(processorTarget)
    end
    
    if Config.Processor.interactionType == "qb-target" then
        exports['qb-target']:RemoveZone('wheat_processor')
    end
    
    print('[WheatFarm] Processor cleaned up')
end)