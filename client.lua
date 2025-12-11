-- =====================================================
-- CLIENT.LUA - MULTI-FRAMEWORK (QBox Native, QBCore, ESX)
-- =====================================================

local Framework = nil
local FrameworkName = nil

-- Framework Detection
CreateThread(function()
    if GetResourceState('qbx_core') == 'started' then
        -- ✅ QBox erkannt - KEINE Core Object Zuweisung!
        FrameworkName = 'QBox'
        print('[WheatFarm] Framework detected: QBox (Native)')
    elseif GetResourceState('qb-core') == 'started' then
        Framework = exports['qb-core']:GetCoreObject()
        FrameworkName = 'QBCore'
        print('[WheatFarm] Framework detected: QBCore')
elseif GetResourceState('es_extended') == 'started' then
    FrameworkName = 'ESX'
    -- ESX Import (moderne Methode)
    -- Stelle sicher dass @es_extended/imports.lua in fxmanifest ist
    print('[WheatFarm] Framework detected: ESX')
    else
        print('[WheatFarm] ^1ERROR: Kein unterstütztes Framework gefunden!^7')
    end
end)

-- Helper: Notification senden
local function Notify(text, type, duration)
    if FrameworkName == 'QBox' then
        exports.qbx_core:Notify(text, type, duration)
    elseif FrameworkName == 'QBCore' then
        Framework.Functions.Notify(text, type, duration)
    elseif FrameworkName == 'ESX' then
        ESX.ShowNotification(text)
    end
end

local inField = false
local isPlowing = false
local autoFarmActive = false

-- Locale laden
local lang = Config.Language or 'en'
local localeFile = ('locales/%s'):format(lang)

-- Locale-Datei laden (enthält bereits Lang Objekt)
require(localeFile)

-- Event für Erfolgs-Benachrichtigung (nur wenn im Kreis)
RegisterNetEvent('wheat:notifySuccess', function(amount)
    if inField then
        Notify(Lang:t('notify_success', amount), 'success')
    end
end)

-- Blip erstellen
CreateThread(function()
    if not Config.ShowBlip then return end
    
    local blip = AddBlipForCoord(Config.FieldLocation.x, Config.FieldLocation.y, Config.FieldLocation.z)
    SetBlipSprite(blip, Config.BlipSprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.BlipScale)
    SetBlipColour(blip, Config.BlipColor)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Lang:t('blip_name'))
    EndTextCommandSetBlipName(blip)
end)

-- Hilfsfunktion: Prüfe ob Spieler das Werkzeug besitzt
local function hasRequiredTool()
    if not Config.RequiredTool.enabled then
        return true
    end
    
    if Config.Inventory == "ox_inventory" then
        local count = exports.ox_inventory:Search('count', Config.RequiredTool.item)
        return count and count > 0
    elseif Config.Inventory == "qs-inventory" then
        if FrameworkName == 'QBox' then
            -- QBox: Verwende Client Module
            local QBX = require '@qbx_core/modules/playerdata'
            local PlayerData = QBX.PlayerData
            if not PlayerData or not PlayerData.items then
                return false
            end
            
            for _, item in pairs(PlayerData.items) do
                if item and item.name == Config.RequiredTool.item then
                    return true
                end
            end
        elseif FrameworkName == 'QBCore' then
            local PlayerData = Framework.Functions.GetPlayerData()
            if not PlayerData or not PlayerData.items then
                return false
            end
            
            for _, item in pairs(PlayerData.items) do
                if item and item.name == Config.RequiredTool.item then
                    return true
                end
            end
        elseif FrameworkName == 'ESX' then
elseif FrameworkName == 'ESX' then
    -- ESX Callbacks sind asynchron, daher hier schwierig
    -- Besser: Server-seitige Prüfung reicht aus
    -- Oder: Synchronen Check via ox_inventory machen
    if Config.Inventory == "ox_inventory" then
        local count = exports.ox_inventory:Search('count', Config.RequiredTool.item)
        return count and count > 0
    end
    return false  -- Fallback
        end
    end
    
    return false
end

-- Weizen pflügen
local function plowWheat(isAutoFarm)
    if isPlowing then return end
    
    -- Client-seitige Werkzeug-Prüfung
    if not hasRequiredTool() then
        Notify(Lang:t('notify_no_tool'), 'error')
        return
    end
    
    isPlowing = true
    
    -- Animation aus Config holen
    local selectedAnim = Config.Animations[Config.Animation]
    if not selectedAnim then
        selectedAnim = Config.Animations.plant
    end
    
    -- Prop (Schaufel) spawnen falls vorhanden
    local prop = nil
    if selectedAnim.prop then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        -- Model laden
        local propModel = GetHashKey(selectedAnim.prop.model)
        RequestModel(propModel)
        while not HasModelLoaded(propModel) do
            Wait(10)
        end
        
        -- Prop erstellen und an Hand attachen
        prop = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, true)
        AttachEntityToEntity(
            prop, 
            ped, 
            GetPedBoneIndex(ped, selectedAnim.prop.bone),
            selectedAnim.prop.coords.x,
            selectedAnim.prop.coords.y,
            selectedAnim.prop.coords.z,
            selectedAnim.prop.rotation.x,
            selectedAnim.prop.rotation.y,
            selectedAnim.prop.rotation.z,
            true, true, false, true, 1, true
        )
    end
    
    -- Thread zum Überwachen ob Spieler Feld verlässt oder stirbt
    local cancelled = false
    CreateThread(function()
        while isPlowing do
            Wait(100)
            if not inField or IsEntityDead(PlayerPedId()) then
                cancelled = true
                exports['ox_lib']:cancelProgress()
                break
            end
        end
    end)
    
    local success = lib.progressBar({
        duration = Config.PlowTime,
        label = Lang:t('progress_plowing'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = selectedAnim.dict,
            clip = selectedAnim.clip,
        },
    })
    
    if success and not cancelled then
        -- Event mit Auto-Farm Flag senden
        TriggerServerEvent('wheat:plow', isAutoFarm or false)
    elseif cancelled then
        -- Benachrichtigung bei Abbruch durch Feld verlassen
        Notify(Lang:t('notify_action_cancelled'), 'error')
    end
    
    -- Prop wieder entfernen
    if prop then
        DeleteObject(prop)
    end
    
    isPlowing = false
end

-- Auto-Farm Loop
CreateThread(function()
    while true do
        Wait(500)
        
        if autoFarmActive and inField then
            local ped = PlayerPedId()
            
            if not isPlowing and not IsEntityDead(ped) then
                plowWheat(true)  -- Auto-Farm mit Flag
                Wait(Config.AutoFarm.cooldown)  -- Warte Cooldown ab NACH der Farm-Aktion
            end
        end
    end
end)

-- Marker und Interaktion
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local distance = #(coords - Config.FieldLocation)
        
        if distance < Config.DrawDistance then
            sleep = 0
            
            DrawMarker(
                Config.MarkerType,
                Config.FieldLocation.x, Config.FieldLocation.y, Config.FieldLocation.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                false, true, 2, false, nil, nil, false
            )
            
            if distance < Config.FieldRadius then
                if not inField then
                    inField = true
                end
                
                -- TextUI nur anzeigen wenn NICHT am Farmen
                if not isPlowing and Config.TextUI.enabled then
                    lib.showTextUI(Lang:t('textui_plow'), {
                        position = Config.TextUI.position,
                        icon = Config.TextUI.icon,
                    })
                elseif isPlowing and Config.TextUI.enabled then
                    lib.hideTextUI()
                end
                
                -- Normale Interaktion: E drücken (nur wenn Auto-Farm AUS ist)
                if IsControlJustPressed(0, Config.AutoFarm.key) and not isPlowing and not autoFarmActive and not IsEntityDead(ped) then
                    plowWheat(false)
                end
                
                -- Auto-Farm: G drücken
                if Config.AutoFarm.enabled and IsControlJustPressed(0, Config.AutoFarm.confirmKey) and not isPlowing and not IsEntityDead(ped) then
                    if not autoFarmActive then
                        -- Auto-Farm starten
                        autoFarmActive = true
                        Notify(Lang:t('notify_autofarm_start'), 'inform')
                        plowWheat(true)  -- Sofort erste Farm-Aktion starten
                    else
                        -- Auto-Farm stoppen
                        autoFarmActive = false
                        Notify(Lang:t('notify_autofarm_stop'), 'inform')
                    end
                end
            else
                -- Außerhalb FieldRadius
                if inField then
                    inField = false
                    if autoFarmActive then
                        autoFarmActive = false
                        Notify(Lang:t('notify_autofarm_stop'), 'inform')
                    end
                    if Config.TextUI.enabled then
                        lib.hideTextUI()
                    end
                end
            end
        else
            -- Außerhalb DrawDistance
            if inField then
                inField = false
                if autoFarmActive then
                    autoFarmActive = false
                    Notify(Lang:t('notify_autofarm_stop'), 'inform')
                end
                if Config.TextUI.enabled then
                    lib.hideTextUI()
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- ESX Callback für hasItem (nur wenn ESX)
if FrameworkName == 'ESX' then
    ESX.TriggerServerCallback('wheat:hasItem', function(hasItem)
        -- Callback registriert
    end, Config.RequiredTool.item)
end
