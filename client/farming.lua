-- =====================================================
-- CLIENT/FARMING.LUA - Multi-Crop Farming System
-- FIXED: INSTANT CANCEL with E and G during harvest!
-- =====================================================

-- =====================================================
-- STATE MANAGEMENT
-- =====================================================

local activeFarms = {}
local isHarvesting = false
local currentHarvestCancelled = false -- ✅ NEW: Track if current harvest was cancelled

-- =====================================================
-- CORE FUNCTION: HARVEST CROP
-- =====================================================

local function harvestCrop(farmConfig, cropConfig, isAutoFarm)
    -- Guard: Already harvesting
    if isHarvesting then return end
    
    -- Guard: Check if auto-farm was cancelled
    if isAutoFarm then
        if not activeFarms[farmConfig.id] or not activeFarms[farmConfig.id].autoFarmActive then
            print('[WheatFarm] 🛑 Auto-farm is OFF - aborting harvest start')
            return
        end
    end
    
    -- Guard: Check if player can interact
    local canInteract, reason = CanPlayerInteract()
    if not canInteract then
        if reason == 'in_vehicle' then
            Notify('Du kannst nicht im Fahrzeug farmen!', 'error')
        end
        return
    end
    
    -- Guard: Tool check
    if cropConfig.requiredTool then
        if not HasRequiredTool(cropConfig.requiredTool) then
            local toolConfig = Config.Tools[cropConfig.requiredTool]
            local toolName = (toolConfig and toolConfig.label) or cropConfig.requiredTool
            Notify(string.format('Du brauchst: %s!', toolName), 'error')
            return
        end
    end
    
    isHarvesting = true
    currentHarvestCancelled = false
    
    print('[WheatFarm] 🌾 Starting harvest (auto: ' .. tostring(isAutoFarm) .. ')')
    
    -- ✅ UPDATE TextUI for manual harvest
    if not isAutoFarm and Config.FarmDefaults.textUI.enabled then
        lib.showTextUI('[E] Farmen stoppen', {
            position = Config.FarmDefaults.textUI.position,
            icon = Config.FarmDefaults.textUI.icon,
        })
    end
    
    -- ✅ NEW: Start a parallel cancel-handler thread!
    CreateThread(function()
        local farmState = activeFarms[farmConfig.id]
        
        while isHarvesting do
            -- E Key - Cancel manual harvest
            if not isAutoFarm and IsControlJustPressed(0, Config.FarmDefaults.autoFarm.key) then
                print('[WheatFarm] 🛑 E pressed during manual harvest - CANCELLING!')
                lib.cancelProgress()
                currentHarvestCancelled = true
                
                -- ✅ Restore TextUI
                if Config.FarmDefaults.textUI.enabled and farmState.inField then
                    lib.showTextUI(string.format('[E] %s ernten | [G] Auto-Farm', cropConfig.name), {
                        position = Config.FarmDefaults.textUI.position,
                        icon = Config.FarmDefaults.textUI.icon,
                    })
                end
                
                Notify('❌ Ernten abgebrochen', 'error')
                break
            end
            
            -- G Key - Cancel auto-farm
            if isAutoFarm and Config.FarmDefaults.autoFarm.enabled and IsControlJustPressed(0, Config.FarmDefaults.autoFarm.confirmKey) then
                print('[WheatFarm] 🛑 G pressed during auto-farm - STOPPING!')
                
                -- Stop auto-farm IMMEDIATELY
                farmState.autoFarmActive = false
                
                -- Cancel current progress bar
                lib.cancelProgress()
                currentHarvestCancelled = true
                
                -- Update TextUI
                if Config.FarmDefaults.textUI.enabled then
                    lib.showTextUI(string.format('[E] %s ernten | [G] Auto-Farm', cropConfig.name), {
                        position = Config.FarmDefaults.textUI.position,
                        icon = Config.FarmDefaults.textUI.icon,
                    })
                end
                
                Notify('🔴 Auto-Farm gestoppt!', 'error')
                print('[WheatFarm] 🔴 Auto-farm CANCELLED by G key')
                break
            end
            
            Wait(0) -- Run every frame to catch input instantly
        end
    end)
    
    -- Get animation config
    local animConfig = Config.Animations[Config.FarmDefaults.animation]
    if not animConfig then
        animConfig = Config.Animations['shovel']
    end
    
    -- Show progress bar with animation and prop
    local success = ShowProgressBar({
        duration = cropConfig.harvestTime,
        label = string.format('%s wird geerntet...', cropConfig.name),
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
    
    isHarvesting = false
    
    -- ✅ Restore TextUI after manual harvest
    if not isAutoFarm and Config.FarmDefaults.textUI.enabled and activeFarms[farmConfig.id] and activeFarms[farmConfig.id].inField then
        lib.showTextUI(string.format('[E] %s ernten | [G] Auto-Farm', cropConfig.name), {
            position = Config.FarmDefaults.textUI.position,
            icon = Config.FarmDefaults.textUI.icon,
        })
    end
    
    -- If it was cancelled by our handler, success will be false
    if success and not currentHarvestCancelled then
        TriggerServerEvent('wheat:harvest', farmConfig.id, cropConfig.item, isAutoFarm or false)
    elseif currentHarvestCancelled then
        -- Already showed notification in cancel handler
        print('[WheatFarm] Harvest cancelled by user input')
    else
        -- Cancelled by X/ESC
        if isAutoFarm then
            Notify('⏸️ Auto-Farm pausiert', 'warning')
        else
            Notify('❌ Ernten abgebrochen', 'error')
        end
    end
    
    print('[WheatFarm] 🏁 Harvest complete (success: ' .. tostring(success) .. ', cancelled: ' .. tostring(currentHarvestCancelled) .. ')')
    
    -- Auto-Farm Loop
    if isAutoFarm then
        print('[WheatFarm] 📍 Checking auto-farm state...')
        
        -- Check if auto-farm is still active
        if not activeFarms[farmConfig.id] or not activeFarms[farmConfig.id].autoFarmActive then
            print('[WheatFarm] 🛑 Auto-farm was stopped - BREAKING LOOP!')
            return
        end
        
        if not success or currentHarvestCancelled then
            print('[WheatFarm] 🛑 Harvest failed/cancelled - stopping auto-farm')
            activeFarms[farmConfig.id].autoFarmActive = false
            return
        end
        
        if not activeFarms[farmConfig.id].inField then
            print('[WheatFarm] 🛑 Player left field - stopping auto-farm')
            activeFarms[farmConfig.id].autoFarmActive = false
            return
        end
        
        if IsEntityDead(PlayerPedId()) then
            print('[WheatFarm] 🛑 Player died - stopping auto-farm')
            activeFarms[farmConfig.id].autoFarmActive = false
            return
        end
        
        -- All checks passed - wait with progress bar
        print('[WheatFarm] ⏳ Waiting ' .. Config.FarmDefaults.autoFarm.cooldown .. 'ms before next harvest')
        
        -- ✅ Show progress bar during cooldown (cancellable with G!)
        local cooldownSeconds = math.floor(Config.FarmDefaults.autoFarm.cooldown / 1000)
        
        -- Start parallel cancel handler for cooldown
        local cooldownCancelled = false
        CreateThread(function()
            while not cooldownCancelled and activeFarms[farmConfig.id] and activeFarms[farmConfig.id].autoFarmActive do
                -- G Key - Stop auto-farm during cooldown
                if Config.FarmDefaults.autoFarm.enabled and IsControlJustPressed(0, Config.FarmDefaults.autoFarm.confirmKey) then
                    print('[WheatFarm] 🛑 G pressed during cooldown - STOPPING AUTO-FARM!')
                    
                    activeFarms[farmConfig.id].autoFarmActive = false
                    cooldownCancelled = true
                    
                    lib.cancelProgress()
                    
                    -- Update TextUI
                    if Config.FarmDefaults.textUI.enabled then
                        lib.showTextUI(string.format('[E] %s ernten | [G] Auto-Farm', cropConfig.name), {
                            position = Config.FarmDefaults.textUI.position,
                            icon = Config.FarmDefaults.textUI.icon,
                        })
                    end
                    
                    Notify('🔴 Auto-Farm gestoppt!', 'error')
                    break
                end
                Wait(0)
            end
        end)
        
        local cooldownSuccess = lib.progressBar({
            duration = Config.FarmDefaults.autoFarm.cooldown,
            label = string.format('⏱️ Nächste Ernte in %d Sekunden...', cooldownSeconds),
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = false,
                move = false,
                combat = false,
            },
        })
        
        -- Stop cancel handler
        cooldownCancelled = true
        
        -- Check if cancelled
        if not cooldownSuccess or not activeFarms[farmConfig.id] or not activeFarms[farmConfig.id].autoFarmActive then
            print('[WheatFarm] 🛑 Cooldown cancelled or auto-farm stopped')
            return
        end
        
        -- Final check before recursion
        if activeFarms[farmConfig.id] and activeFarms[farmConfig.id].autoFarmActive and activeFarms[farmConfig.id].inField then
            print('[WheatFarm] 🔄 Starting next auto-farm harvest')
            harvestCrop(farmConfig, cropConfig, true)
        else
            print('[WheatFarm] 🛑 Auto-farm conditions not met - stopping')
        end
    end
end

-- =====================================================
-- AUTO-FARM TOGGLE
-- =====================================================

local function toggleAutoFarm(farmId, cropConfig)
    local farmState = activeFarms[farmId]
    if not farmState then 
        print('[WheatFarm ERROR] Farm state not found for: ' .. tostring(farmId))
        return 
    end
    
    print('========================================')
    print('[WheatFarm] toggleAutoFarm called for: ' .. farmId)
    print('[WheatFarm] Current autoFarmActive: ' .. tostring(farmState.autoFarmActive))
    print('[WheatFarm] Current isHarvesting: ' .. tostring(isHarvesting))
    print('========================================')
    
    if not farmState.autoFarmActive then
        -- START AUTO-FARM
        farmState.autoFarmActive = true
        Notify('🟢 Auto-Farm gestartet!', 'success')
        
        if Config.FarmDefaults.textUI.enabled then
            lib.showTextUI('[G] Auto-Farm stoppen', {
                position = Config.FarmDefaults.textUI.position,
                icon = Config.FarmDefaults.textUI.icon,
            })
        end
        
        print('[WheatFarm] ✅ Auto-farm STARTED for: ' .. farmId)
        
        -- Start harvesting
        harvestCrop(farmState.config, cropConfig, true)
    else
        -- STOP AUTO-FARM (this branch is only reached when NOT harvesting, since G during harvest is handled in harvestCrop)
        farmState.autoFarmActive = false
        
        Notify('🔴 Auto-Farm gestoppt!', 'error')
        
        if Config.FarmDefaults.textUI.enabled then
            lib.showTextUI(string.format('[E] %s ernten | [G] Auto-Farm', cropConfig.name), {
                position = Config.FarmDefaults.textUI.position,
                icon = Config.FarmDefaults.textUI.icon,
            })
        end
        
        print('[WheatFarm] 🔴 Auto-farm STOPPED by player for: ' .. farmId)
    end
end

-- =====================================================
-- MARKER THREAD
-- =====================================================

local function createMarkerThread(farmConfig)
    if not Config.FarmDefaults.showMarker then 
        print('[WheatFarm] Markers disabled for: ' .. farmConfig.id)
        return 
    end
    
    print('[WheatFarm] 🎨 Creating marker thread for: ' .. farmConfig.id)
    
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - farmConfig.location)
            
            if distance < Config.FarmDefaults.drawDistance then
                sleep = 0
                
                DrawSimpleMarker(
                    farmConfig.location,
                    Config.FarmDefaults.markerType,
                    farmConfig.marker.size,
                    Config.FarmDefaults.markerColor
                )
            end
            
            Wait(sleep)
        end
    end)
end

-- =====================================================
-- INTERACTION THREAD
-- =====================================================

local function createInteractionThread(farmConfig, cropConfig)
    print('[WheatFarm] 🎮 Creating interaction threads for: ' .. farmConfig.id)
    
    -- THREAD 1: Distance Check & TextUI
    CreateThread(function()
        local farmState = activeFarms[farmConfig.id]
        local lastDistanceCheck = 0
        
        while true do
            local currentTime = GetGameTimer()
            local shouldCheckDistance = (currentTime - lastDistanceCheck) >= 200
            
            if shouldCheckDistance then
                lastDistanceCheck = currentTime
                
                local isNear, distance = IsPlayerNearLocation(farmConfig.location, farmConfig.radius)
                
                if isNear then
                    -- Entering field
                    if not farmState.inField then
                        farmState.inField = true
                        
                        if Config.FarmDefaults.textUI.enabled and not isHarvesting then
                            local text = string.format('[E] %s ernten | [G] Auto-Farm', cropConfig.name)
                            lib.showTextUI(text, {
                                position = Config.FarmDefaults.textUI.position,
                                icon = Config.FarmDefaults.textUI.icon,
                            })
                        end
                    end
                else
                    -- Leaving field
                    if farmState.inField then
                        farmState.inField = false
                        farmState.autoFarmActive = false
                        
                        if Config.FarmDefaults.textUI.enabled then
                            lib.hideTextUI()
                        end
                        
                        print('[WheatFarm] Player left field - auto-farm stopped')
                    end
                end
            end
            
            Wait(200)
        end
    end)
    
    -- THREAD 2: Input Handling (ONLY when NOT harvesting - during harvest is handled in harvestCrop!)
    CreateThread(function()
        local farmState = activeFarms[farmConfig.id]
        
        while true do
            local ped = PlayerPedId()
            
            if farmState.inField and not IsEntityDead(ped) then
                -- E Key - Manual Harvest (only when NOT harvesting)
                if not isHarvesting and IsControlJustPressed(0, Config.FarmDefaults.autoFarm.key) then
                    print('[WheatFarm] ⌨️ E key pressed - manual harvest')
                    harvestCrop(farmConfig, cropConfig, false)
                end
                
                -- G Key - Auto-Farm Toggle (only when NOT harvesting - during harvest it's handled in harvestCrop!)
                if not isHarvesting and Config.FarmDefaults.autoFarm.enabled and IsControlJustPressed(0, Config.FarmDefaults.autoFarm.confirmKey) then
                    print('[WheatFarm] ⌨️ G key pressed (not harvesting)')
                    
                    -- Debounce
                    local currentTime = GetGameTimer()
                    if (currentTime - farmState.lastToggle) > 500 then
                        farmState.lastToggle = currentTime
                        toggleAutoFarm(farmConfig.id, cropConfig)
                    else
                        print('[WheatFarm] Auto-farm toggle ignored (debounce)')
                    end
                end
                
                Wait(0)
            else
                Wait(500)
            end
        end
    end)
end

-- =====================================================
-- FARM INITIALIZATION
-- =====================================================

local function initializeFarms()
    if not Config.Farms then
        print('^1[WheatFarm] ERROR: Config.Farms is nil!^7')
        return
    end
    
    if type(Config.Farms) ~= 'table' then
        print('^1[WheatFarm] ERROR: Config.Farms is not a table!^7')
        return
    end
    
    if #Config.Farms == 0 then
        print('^1[WheatFarm] ERROR: Config.Farms is empty!^7')
        return
    end
    
    print('[WheatFarm] Found ' .. #Config.Farms .. ' farms in config')
    
    for _, farmConfig in pairs(Config.Farms) do
        if not farmConfig.enabled then
            print('[WheatFarm] ⏭️ Skipping disabled farm: ' .. farmConfig.id)
            goto continue
        end
        
        local cropConfig = Config.Crops[farmConfig.crop]
        
        if not cropConfig then
            print('^1[WheatFarm] ERROR: Invalid crop "' .. tostring(farmConfig.crop) .. '" for farm "' .. farmConfig.id .. '"^7')
            goto continue
        end
        
        print('[WheatFarm] 🌾 Initializing farm: ' .. farmConfig.id .. ' (Crop: ' .. farmConfig.crop .. ')')
        
        -- Initialize farm state
        activeFarms[farmConfig.id] = {
            id = farmConfig.id,
            config = farmConfig,
            inField = false,
            autoFarmActive = false,
            lastToggle = 0,
        }
        
        -- Create threads
        createMarkerThread(farmConfig)
        createInteractionThread(farmConfig, cropConfig)
        
        print('[WheatFarm] ✅ Farm initialized: ' .. farmConfig.id)
        
        ::continue::
    end
    
    print('[WheatFarm] ✅ All farms initialized!')
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
        print('^1[WheatFarm] Farming: Framework not ready!^7')
        return
    end
    
    Wait(1000)
    
    initializeFarms()
end)

-- =====================================================
-- CLEANUP
-- =====================================================

AddEventHandler('wheat:cleanup', function()
    for farmId, _ in pairs(activeFarms) do
        if Config.FarmDefaults.textUI.enabled then
            lib.hideTextUI()
        end
    end
    activeFarms = {}
    print('[WheatFarm] Farming cleaned up')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for farmId, _ in pairs(activeFarms) do
        if Config.FarmDefaults.textUI.enabled then
            lib.hideTextUI()
        end
    end
end)