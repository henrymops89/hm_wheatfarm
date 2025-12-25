-- =====================================================
-- CLIENT/FARMING.LUA - Crop Harvesting System
-- Handles all farming interactions
-- =====================================================

local isHarvesting = false
local currentFarm = nil
local inFarmZone = false

-- =====================================================
-- FARM INTERACTION
-- =====================================================

local function StartHarvesting(farm)
    -- Guard: Already harvesting
    if isHarvesting then
        Notify(Lang:t('already_farming'), 'error')
        return
    end
    
    -- Guard: Player state check
    local canInteract, reason = CanPlayerInteract()
    if not canInteract then
        if reason == 'player_dead' then
            Notify(Lang:t('player_dead'), 'error')
        elseif reason == 'in_vehicle' then
            Notify(Lang:t('in_vehicle'), 'error')
        end
        return
    end
    
    local cropConfig = Config.Crops[farm.crop]
    
    -- Guard: Invalid crop
    if not cropConfig then
        print('^1[WheatFarm] ERROR: Invalid crop config for ' .. farm.id .. '^7')
        return
    end
    
    -- Tool check
    if cropConfig.requiredTool then
        if not HasRequiredTool(cropConfig.requiredTool) then
            local toolConfig = Config.Tools[cropConfig.requiredTool]
            Notify(Lang:t('need_tool', toolConfig and toolConfig.label or cropConfig.requiredTool), 'error')
            return
        end
    end
    
    isHarvesting = true
    
    -- Get animation config
    local animConfig = Config.Animations[Config.FarmDefaults.animation]
    if not animConfig then
        animConfig = Config.Animations.shovel -- Fallback
    end
    
    -- Get localized crop name
    local cropName = Lang:t('crop_' .. currentFarm.crop)
    
    -- Show progress bar
    local success = ShowProgressBar({
        duration = cropConfig.harvestTime or 5000,
        label = Lang:t('harvesting', cropName),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = animConfig and {
            dict = animConfig.dict,
            clip = animConfig.clip,
        },
        prop = animConfig and animConfig.prop,
    })
    
    isHarvesting = false
    
    -- Process result
    if success then
        -- Trigger server-side harvest
        TriggerServerEvent('wheat:harvest', farm.id, farm.crop)
    else
        Notify('Ernte abgebrochen!', 'error')
    end
end

-- =====================================================
-- AUTO-FARM SYSTEM (WITH CONTINUOUS LOOP)
-- =====================================================

local autoFarmActive = false
local autoFarmLoopRunning = false

-- Update TextUI based on auto-farm state
local function UpdateAutoFarmTextUI()
    if not inFarmZone or not currentFarm then return end
    if not Config.FarmDefaults.textUI or not Config.FarmDefaults.textUI.enabled then return end
    
    local cropConfig = Config.Crops[currentFarm.crop]
    if not cropConfig then return end
    
    -- Get localized crop name
    local cropName = Lang:t('crop_' .. currentFarm.crop)
    
    local text
    if autoFarmLoopRunning then
        -- Auto-Farm running - only show stop option
        text = Lang:t('autofarm_running_stop')
    else
        -- Auto-Farm off - show both options
        text = Lang:t('harvest_crop_or_autofarm', cropName)
    end
    
    lib.showTextUI(text, {
        position = Config.FarmDefaults.textUI.position or 'left-center',
        icon = Config.FarmDefaults.textUI.icon or 'wheat-awn',
    })
end

local function StopAutoFarm()
    if not autoFarmLoopRunning then return end
    
    autoFarmLoopRunning = false
    autoFarmActive = false
    
    Notify('Auto-Farm gestoppt! 🛑', 'info')
    
    -- Update TextUI
    UpdateAutoFarmTextUI()
end

local function StartAutoFarm(farm)
    -- Toggle: If already running, stop it
    if autoFarmLoopRunning then
        StopAutoFarm()
        return
    end
    
    -- Guard: Player state
    local canInteract = CanPlayerInteract()
    if not canInteract then
        return
    end
    
    local cropConfig = Config.Crops[farm.crop]
    
    -- Guard: Invalid crop
    if not cropConfig then return end
    
    -- Tool check (REQUIRED for auto-farm!)
    if cropConfig.requiredTool then
        if not HasRequiredTool(cropConfig.requiredTool) then
            local toolConfig = Config.Tools[cropConfig.requiredTool]
            Notify(Lang:t('need_tool', toolConfig and toolConfig.label or cropConfig.requiredTool), 'error')
            return
        end
    end
    
    -- Start auto-farm loop
    autoFarmLoopRunning = true
    
    Notify('Auto-Farm gestartet! Drücke [G] zum Stoppen 🔄', 'success', 5000)
    
    -- Update TextUI to show "running" state
    UpdateAutoFarmTextUI()
    
    -- Auto-farm loop
    CreateThread(function()
        while autoFarmLoopRunning do
            -- Check if still in zone
            if currentFarm ~= farm or not inFarmZone then
                Notify('Auto-Farm gestoppt: Zone verlassen!', 'info')
                StopAutoFarm()
                break
            end
            
            -- Check if still has tool
            if cropConfig.requiredTool then
                if not HasRequiredTool(cropConfig.requiredTool) then
                    Notify('Auto-Farm gestoppt: Kein Werkzeug mehr!', 'error')
                    StopAutoFarm()
                    break
                end
            end
            
            -- Check player state
            local canInteract = CanPlayerInteract()
            if not canInteract then
                Notify('Auto-Farm gestoppt!', 'error')
                StopAutoFarm()
                break
            end
            
            autoFarmActive = true
            
            -- Get animation
            local animConfig = Config.Animations[Config.FarmDefaults.animation]
            if not animConfig then
                animConfig = Config.Animations.shovel
            end
            
            -- Get localized crop name
            local cropName = Lang:t('crop_' .. currentFarm.crop)
            
            -- Shorter progress for auto-farm
            local duration = math.floor((cropConfig.harvestTime or 5000) * 0.6)
            
            local success = ShowProgressBar({
                duration = duration,
                label = Lang:t('autofarm_progress', cropName),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                },
                anim = animConfig and {
                    dict = animConfig.dict,
                    clip = animConfig.clip,
                },
                prop = animConfig and animConfig.prop,
            })
            
            autoFarmActive = false
            
            if success then
                -- Trigger auto-farm on server
                TriggerServerEvent('wheat:autoFarm', farm.id, farm.crop)
                
                -- Cooldown before next farm
                local cooldownTime = Config.FarmDefaults.autoFarm.cooldown or 8000
                Wait(cooldownTime)
            else
                -- Player cancelled
                Notify('Auto-Farm abgebrochen!', 'error')
                StopAutoFarm()
                break
            end
        end
    end)
end

-- =====================================================
-- ZONE MANAGEMENT
-- =====================================================

-- Create interaction zones for each farm
CreateThread(function()
    Wait(2000) -- Wait for config
    
    if not Config.Farms then return end
    
    for _, farm in ipairs(Config.Farms) do
        if farm.enabled then
            local cropConfig = Config.Crops[farm.crop]
            
            if not cropConfig then
                print('^1[WheatFarm] ERROR: Crop config missing for ' .. farm.id .. '^7')
                goto continue
            end
            
            -- Create sphere zone
            local point = lib.points.new({
                coords = farm.location,
                distance = farm.radius or Config.FarmDefaults.radius or 10.0,
            })
            
            function point:onEnter()
                currentFarm = farm
                inFarmZone = true
                
                -- Show TextUI if enabled
                if Config.FarmDefaults.textUI and Config.FarmDefaults.textUI.enabled then
                    UpdateAutoFarmTextUI()
                end
            end
            
            function point:onExit()
                currentFarm = nil
                inFarmZone = false
                
                -- Stop auto-farm if running
                if autoFarmLoopRunning then
                    StopAutoFarm()
                end
                
                if Config.FarmDefaults.textUI and Config.FarmDefaults.textUI.enabled then
                    lib.hideTextUI()
                end
            end
            
            function point:nearby()
                -- Draw marker if enabled
                if Config.FarmDefaults.showMarker then
                    -- Get actual interaction radius
                    local radius = farm.radius or Config.FarmDefaults.radius or 10.0
                    
                    -- DEBUG: Draw LARGE circle showing actual interaction radius
                    -- Marker Size is the DIAMETER (radius * 2), not radius!
                    DrawMarker(
                        1, -- Cylinder marker
                        farm.location.x, farm.location.y, farm.location.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        radius * 2.0, radius * 2.0, 0.5, -- Diameter = radius * 2
                        50, 200, 50, 80, -- Green, semi-transparent
                        false, true, 2, false, nil, nil, false
                    )
                    
                    -- Draw small center marker for visibility
                    local markerSize = farm.marker and farm.marker.size or vector3(2.0, 2.0, 1.0)
                    local markerColor = Config.FarmDefaults.markerColor or {r = 255, g = 215, b = 0, a = 100}
                    
                    DrawSimpleMarker(
                        farm.location,
                        Config.FarmDefaults.markerType or 1,
                        markerSize,
                        markerColor
                    )
                end
            end
            
            DebugPrint('Created farm zone: ' .. farm.id)
        end
        
        ::continue::
    end
end)

-- =====================================================
-- KEY BINDINGS
-- =====================================================

-- Register keybinds
CreateThread(function()
    Wait(2000)
    
    -- Main harvest key (E)
    RegisterCommand('+farmHarvest', function()
        if inFarmZone and currentFarm and not isHarvesting then
            StartHarvesting(currentFarm)
        end
    end, false)
    
    RegisterCommand('-farmHarvest', function() end, false)
    
    RegisterKeyMapping('+farmHarvest', 'Farm: Ernten', 'keyboard', 'E')
    
    -- Auto-farm key (G)
    if Config.FarmDefaults.autoFarm and Config.FarmDefaults.autoFarm.enabled then
        RegisterCommand('+farmAutoFarm', function()
            if inFarmZone and currentFarm and not autoFarmActive then
                StartAutoFarm(currentFarm)
            end
        end, false)
        
        RegisterCommand('-farmAutoFarm', function() end, false)
        
        RegisterKeyMapping('+farmAutoFarm', 'Farm: Auto-Farm', 'keyboard', 'G')
    end
end)

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('wheat:cleanup', function()
    isHarvesting = false
    autoFarmActive = false
    autoFarmLoopRunning = false  -- ✅ Stop auto-farm loop
    currentFarm = nil
    inFarmZone = false
    
    if Config.FarmDefaults.textUI and Config.FarmDefaults.textUI.enabled then
        lib.hideTextUI()
    end
end)