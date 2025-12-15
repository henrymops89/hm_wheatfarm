-- =====================================================
-- CLIENT/UTILS.LUA - Helper Functions (FIXED VERSION)
-- Single Responsibility: Reusable utility functions
-- DRY Principle: Don't Repeat Yourself!
-- =====================================================

-- =====================================================
-- NOTIFICATION FUNCTION (FIX FOR BUG #1)
-- =====================================================

function Notify(message, type, duration)
    -- Guard: Check if ox_lib is available
    if GetResourceState('ox_lib') == 'started' then
        lib.notify({
            description = message,
            type = type or 'info',
            duration = duration or 5000
        })
    else
        -- Fallback to print if ox_lib not available
        print('[WheatFarm] ' .. tostring(message))
    end
end

-- =====================================================
-- TOOL CHECK FUNCTION (FIXED FOR BUG #10)
-- =====================================================

function HasRequiredTool(toolName)
    -- Guard: No tool required
    if not toolName then return true end
    
    local toolConfig = Config.Tools[toolName]
    
    -- Guard: Tool not in config
    if not toolConfig then return true end
    
    -- ox_inventory Client Check (CORRECT METHOD!)
    if Inventory.name == 'ox_inventory' then
        local success, count = pcall(function()
            return exports.ox_inventory:Search('count', toolConfig.item)
        end)
        
        return success and count and count > 0
    end
    
    -- qb-inventory fallback (FIXED!)
    if Inventory.name == 'qb-inventory' then
        if Framework.name == 'qbcore' then
            -- Fixed: Don't use require for QBCore
            local PlayerData = Framework.object.Functions.GetPlayerData()
            if not PlayerData or not PlayerData.items then return false end
            
            for _, item in pairs(PlayerData.items) do
                if item and item.name == toolConfig.item and item.amount and item.amount > 0 then
                    return true
                end
            end
        elseif Framework.name == 'qbox' then
            local success, QBX = pcall(require, '@qbx_core/modules/playerdata')
            if not success then return false end
            
            local PlayerData = QBX.PlayerData
            if not PlayerData or not PlayerData.items then return false end
            
            for _, item in pairs(PlayerData.items) do
                if item and item.name == toolConfig.item and item.amount and item.amount > 0 then
                    return true
                end
            end
        end
    end
    
    return false
end

-- =====================================================
-- ITEM COUNT FUNCTIONS (IMPROVED)
-- =====================================================

function GetItemCount(item)
    -- Guard: No item specified
    if not item then return 0 end
    
    -- ox_inventory Client Check
    if Inventory.name == 'ox_inventory' then
        local success, count = pcall(function()
            return exports.ox_inventory:Search('count', item)
        end)
        
        return (success and count) or 0
    end
    
    -- qb-inventory fallback
    if Inventory.name == 'qb-inventory' then
        if Framework.name == 'qbcore' then
            local PlayerData = Framework.object.Functions.GetPlayerData()
            if not PlayerData or not PlayerData.items then return 0 end
            
            local total = 0
            for _, itemData in pairs(PlayerData.items) do
                if itemData and itemData.name == item then
                    total = total + (itemData.amount or 0)
                end
            end
            return total
            
        elseif Framework.name == 'qbox' then
            local success, QBX = pcall(require, '@qbx_core/modules/playerdata')
            if not success then return 0 end
            
            local PlayerData = QBX.PlayerData
            if not PlayerData or not PlayerData.items then return 0 end
            
            local total = 0
            for _, itemData in pairs(PlayerData.items) do
                if itemData and itemData.name == item then
                    total = total + (itemData.amount or 0)
                end
            end
            return total
        end
    end
    
    return 0
end

-- Check if player has enough of an item
function HasEnoughItems(item, amount)
    return GetItemCount(item) >= amount
end

-- =====================================================
-- 3D TEXT DRAWING (DRY - used in multiple places!)
-- =====================================================

function Draw3DText(coords, text, scale)
    scale = scale or 0.35
    
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    
    -- Guard: Not on screen
    if not onScreen then return end
    
    local camCoords = GetGameplayCamCoords()
    local distance = #(camCoords - coords)
    local fov = (1 / GetGameplayCamFov()) * 100
    local textScale = (scale / distance) * 2 * fov
    
    SetTextScale(0.0, textScale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(x, y)
end

-- =====================================================
-- ANIMATION & PROP LOADING
-- =====================================================

function LoadAnimDict(dict, timeout)
    timeout = timeout or 5000
    
    RequestAnimDict(dict)
    
    local timeWaited = 0
    while not HasAnimDictLoaded(dict) do
        Wait(10)
        timeWaited = timeWaited + 10
        
        if timeWaited >= timeout then
            print('^3[WheatFarm] WARNING: Animation dict "' .. dict .. '" failed to load!^7')
            return false
        end
    end
    
    return true
end

function LoadModel(model, timeout)
    timeout = timeout or 5000
    
    local modelHash = type(model) == 'string' and GetHashKey(model) or model
    
    RequestModel(modelHash)
    
    local timeWaited = 0
    while not HasModelLoaded(modelHash) do
        Wait(10)
        timeWaited = timeWaited + 10
        
        if timeWaited >= timeout then
            print('^3[WheatFarm] WARNING: Model "' .. tostring(model) .. '" failed to load!^7')
            return false
        end
    end
    
    return true
end

-- =====================================================
-- PROP CREATION & ATTACHMENT
-- =====================================================

function CreateAttachedProp(propConfig)
    -- Guard: Invalid config
    if not propConfig or not propConfig.model then 
        return nil 
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Load model
    if not LoadModel(propConfig.model, 3000) then
        return nil
    end
    
    -- Create prop
    local propHash = GetHashKey(propConfig.model)
    local prop = CreateObject(propHash, coords.x, coords.y, coords.z, true, true, true)
    
    -- Guard: Prop creation failed
    if not prop or prop == 0 then
        return nil
    end
    
    -- Attach to ped
    AttachEntityToEntity(
        prop, ped,
        GetPedBoneIndex(ped, propConfig.bone or 28422),
        propConfig.coords.x,
        propConfig.coords.y,
        propConfig.coords.z,
        propConfig.rotation.x,
        propConfig.rotation.y,
        propConfig.rotation.z,
        true, true, false, true, 1, true
    )
    
    return prop
end

function DeletePropSafe(prop)
    if prop and DoesEntityExist(prop) then
        -- Make sure we can delete it
        SetEntityAsMissionEntity(prop, true, true)
        DeleteEntity(prop)
        
        -- Double check it's gone
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
        
        return true
    end
    return false
end

-- =====================================================
-- PROGRESS BAR WRAPPER
-- =====================================================

function ShowProgressBar(options)
    -- Guard: Invalid options
    if not options then return false end
    
    local ped = PlayerPedId()
    local prop = nil
    
    -- Load animation if specified
    if options.anim and options.anim.dict then
        if not LoadAnimDict(options.anim.dict) then
            print('^3[WheatFarm] Animation failed, continuing without animation^7')
        end
    end
    
    -- Create prop if specified
    if options.prop then
        prop = CreateAttachedProp(options.prop)
    end
    
    -- Show progress bar
    local success = lib.progressBar({
        duration = options.duration or 5000,
        label = options.label or 'Processing...',
        useWhileDead = options.useWhileDead or false,
        canCancel = options.canCancel or true,
        disable = options.disable or {
            car = true,
            move = true,
            combat = true,
        },
        anim = options.anim,
    })
    
    -- Cleanup (IMPROVED!)
    Wait(100) -- Slightly longer wait for smoother cleanup
    
    -- Stop animation immediately
    ClearPedTasks(ped)
    
    -- Delete prop with proper cleanup
    if prop then
        -- Detach first
        DetachEntity(prop, true, true)
        -- Then delete
        DeletePropSafe(prop)
    end
    
    -- Final safety wait
    Wait(50)
    
    return success
end

-- =====================================================
-- DISTANCE CALCULATIONS
-- =====================================================

function IsPlayerNearLocation(coords, maxDistance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - coords)
    return distance <= maxDistance, distance
end

function GetDistanceToLocation(coords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return #(playerCoords - coords)
end

-- =====================================================
-- PLAYER STATE CHECKS
-- =====================================================

function CanPlayerInteract()
    local ped = PlayerPedId()
    
    -- Guard: Player is dead
    if IsEntityDead(ped) then
        return false, 'player_dead'
    end
    
    -- Guard: Player in vehicle
    if IsPedInAnyVehicle(ped, false) then
        return false, 'in_vehicle'
    end
    
    return true
end

-- =====================================================
-- MARKER DRAWING
-- =====================================================

function DrawSimpleMarker(coords, markerType, size, color)
    markerType = markerType or 1
    size = size or vector3(2.0, 2.0, 1.0)
    color = color or {r = 255, g = 255, b = 255, a = 100}
    
    DrawMarker(
        markerType,
        coords.x, coords.y, coords.z - 1.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        size.x, size.y, size.z,
        color.r, color.g, color.b, color.a,
        false, true, 2, false, nil, nil, false
    )
end

-- =====================================================
-- PED SPAWNING
-- =====================================================

function SpawnPed(pedConfig)
    -- Guard: Invalid config
    if not pedConfig or not pedConfig.model or not pedConfig.coords then
        return nil
    end
    
    -- Load model
    if not LoadModel(pedConfig.model, 5000) then
        print('^1[WheatFarm] Failed to load ped model: ' .. pedConfig.model .. '^7')
        return nil
    end
    
    local modelHash = GetHashKey(pedConfig.model)
    
    -- Create ped
    local ped = CreatePed(
        4, -- Ped type (civilian)
        modelHash,
        pedConfig.coords.x,
        pedConfig.coords.y,
        pedConfig.coords.z,
        pedConfig.heading or 0.0,
        false, -- network
        true   -- dynamic
    )
    
    -- Guard: Ped creation failed
    if not ped or ped == 0 then
        print('^1[WheatFarm] Failed to create ped!^7')
        return nil
    end
    
    -- Configure ped
    SetBlockingOfNonTemporaryEvents(ped, pedConfig.blockevents or true)
    SetEntityInvincible(ped, pedConfig.invincible or true)
    FreezeEntityPosition(ped, pedConfig.frozen or true)
    
    -- Apply scenario if specified
    if pedConfig.scenario then
        TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)
    end
    
    return ped
end

-- =====================================================
-- DEBUG HELPERS
-- =====================================================

function DebugPrint(message)
    if Config.EnableLogging then
        print('[WheatFarm DEBUG] ' .. tostring(message))
    end
end

function DebugTable(tbl, indent)
    if not Config.EnableLogging then return end
    
    indent = indent or 0
    local indentStr = string.rep('  ', indent)
    
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            print(indentStr .. tostring(k) .. ':')
            DebugTable(v, indent + 1)
        else
            print(indentStr .. tostring(k) .. ': ' .. tostring(v))
        end
    end
end

-- =====================================================
-- EXPORTS (for external use)
-- =====================================================

exports('Notify', Notify)
exports('HasRequiredTool', HasRequiredTool)
exports('GetItemCount', GetItemCount)
exports('HasEnoughItems', HasEnoughItems)
exports('Draw3DText', Draw3DText)
exports('ShowProgressBar', ShowProgressBar)
exports('IsPlayerNearLocation', IsPlayerNearLocation)
exports('CanPlayerInteract', CanPlayerInteract)
exports('SpawnPed', SpawnPed)