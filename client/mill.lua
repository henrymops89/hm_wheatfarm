-- =====================================================
-- CLIENT/MILL.LUA - Mill Interaction System
-- Single Responsibility: Handle mill PED & interaction
-- =====================================================

local millPed = nil
local millTarget = nil

-- =====================================================
-- MILL PROCESSING FUNCTION
-- =====================================================

local function processMill()
    -- Check if player is near mill
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - Config.Mill.location)
    
    if distance > Config.Mill.radius then
        Notify('Du bist zu weit von der Mühle entfernt!', 'error')
        return
    end
    
    -- Check if player has enough wheat
    if not HasEnoughItems(Config.Mill.input.item, Config.Mill.input.amount) then
        Notify(string.format('Du brauchst mindestens %dx Weizen!', Config.Mill.input.amount), 'error')
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
    local animConfig = Config.Mill.animation
    if not animConfig then
        animConfig = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle',
        }
    end
    
    -- Show progress bar
    local success = ShowProgressBar({
        duration = Config.Mill.processingTime or 8000,
        label = 'Weizen wird verarbeitet...',
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
        TriggerServerEvent('wheat:mill:process')
    else
        Notify('Verarbeitung abgebrochen!', 'error')
    end
end

-- =====================================================
-- SPAWN MILL PED
-- =====================================================

local function spawnMillPed()
    if not Config.Mill.ped or not Config.Mill.ped.enabled then
        print('[WheatFarm] Mill PED disabled')
        return
    end
    
    print('[WheatFarm] Spawning mill PED...')
    
    millPed = SpawnPed(Config.Mill.ped)
    
    if millPed then
        print('[WheatFarm] ✅ Mill PED spawned: ' .. tostring(millPed))
    else
        print('^1[WheatFarm] Failed to spawn mill PED!^7')
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
    
    print('[WheatFarm] Setting up ox_target for mill...')
    
    local targetConfig = Config.Mill.target
    
    if millPed then
        -- Target on PED
        exports.ox_target:addLocalEntity(millPed, {
            {
                name = 'wheat_mill_process',
                icon = targetConfig.icon or 'fa-solid fa-wheat-awn',
                label = targetConfig.label or 'Weizen verarbeiten',
                distance = targetConfig.distance or 3.0,
                onSelect = function()
                    processMill()
                end
            }
        })
        
        print('[WheatFarm] ✅ ox_target added to mill PED')
    else
        -- Target on location (sphere)
        millTarget = exports.ox_target:addSphereZone({
            coords = Config.Mill.location,
            radius = targetConfig.distance or 3.0,
            options = {
                {
                    name = 'wheat_mill_process',
                    icon = targetConfig.icon or 'fa-solid fa-wheat-awn',
                    label = targetConfig.label or 'Weizen verarbeiten',
                    onSelect = function()
                        processMill()
                    end
                }
            }
        })
        
        print('[WheatFarm] ✅ ox_target zone created for mill')
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
    
    print('[WheatFarm] Setting up qb-target for mill...')
    
    local targetConfig = Config.Mill.target
    
    if millPed then
        -- Target on PED
        exports['qb-target']:AddTargetEntity(millPed, {
            options = {
                {
                    icon = targetConfig.icon or 'fa-solid fa-wheat-awn',
                    label = targetConfig.label or 'Weizen verarbeiten',
                    action = function()
                        processMill()
                    end
                }
            },
            distance = targetConfig.distance or 3.0
        })
        
        print('[WheatFarm] ✅ qb-target added to mill PED')
    else
        -- Target on location
        exports['qb-target']:AddBoxZone('wheat_mill', Config.Mill.location, 2.0, 2.0, {
            name = 'wheat_mill',
            heading = 0,
            debugPoly = false,
            minZ = Config.Mill.location.z - 1.0,
            maxZ = Config.Mill.location.z + 2.0,
        }, {
            options = {
                {
                    icon = targetConfig.icon or 'fa-solid fa-wheat-awn',
                    label = targetConfig.label or 'Weizen verarbeiten',
                    action = function()
                        processMill()
                    end
                }
            },
            distance = targetConfig.distance or 3.0
        })
        
        print('[WheatFarm] ✅ qb-target zone created for mill')
    end
    
    return true
end

-- =====================================================
-- SETUP 3D TEXT INTERACTION
-- =====================================================

local function setup3DText()
    print('[WheatFarm] Setting up 3D text for mill...')
    
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.Mill.location)
            
            if distance < (Config.Mill.text3d.distance or 5.0) then
                sleep = 0
                
                -- Draw 3D text
                Draw3DText(
                    Config.Mill.location,
                    Config.Mill.text3d.text or '[E] Weizen verarbeiten',
                    Config.Mill.text3d.scale or 0.35
                )
                
                -- Check for E key press
                if distance < Config.Mill.radius and IsControlJustPressed(0, 38) then -- E key
                    processMill()
                end
            end
            
            Wait(sleep)
        end
    end)
    
    print('[WheatFarm] ✅ 3D text thread started for mill')
end

-- =====================================================
-- INITIALIZE MILL
-- =====================================================

local function initializeMill()
    -- Guard: Mill disabled
    if not Config.Mill or not Config.Mill.enabled then
        print('[WheatFarm] Mill is disabled in config')
        return
    end
    
    print('[WheatFarm] 🏭 Initializing mill system...')
    
    -- Spawn PED
    spawnMillPed()
    
    Wait(500) -- Wait for PED to spawn
    
    -- Setup interaction based on type
    local interactionType = Config.Mill.interactionType or "ox_target"
    
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
    
    print('[WheatFarm] ✅ Mill initialized!')
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
        print('^1[WheatFarm] Mill: Framework not ready!^7')
        return
    end
    
    Wait(1500) -- Extra wait for resources
    
    initializeMill()
end)

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Delete PED
    if millPed and DoesEntityExist(millPed) then
        DeleteEntity(millPed)
    end
    
    -- Remove targets
    if millTarget and Config.Mill.interactionType == "ox_target" then
        exports.ox_target:removeZone(millTarget)
    end
    
    if Config.Mill.interactionType == "qb-target" then
        exports['qb-target']:RemoveZone('wheat_mill')
    end
    
    print('[WheatFarm] Mill cleaned up')
end)