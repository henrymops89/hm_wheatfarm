-- =====================================================
-- CLIENT.LUA - MULTI-FRAMEWORK (QBox Native, QBCore, ESX)
-- =====================================================

local Framework = nil
local FrameworkName = nil
local ESX = nil

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
        -- ESX Dynamic Import
        local success, result = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        
        if success and result then
            ESX = result
            print('[WheatFarm] ✅ ESX erfolgreich geladen')
        else
            print('[WheatFarm] ^1ERROR: ESX konnte nicht geladen werden!^7')
            print('[WheatFarm] ^3LÖSUNG: Füge "@es_extended/imports.lua" zu fxmanifest.lua hinzu^7')
        end
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
        if ESX then
            ESX.ShowNotification(text)
        end
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
            -- QBox: Verwende Client Module mit Error Handling
            local success, QBX = pcall(require, '@qbx_core/modules/playerdata')
            if not success then
                print('[WheatFarm] ERROR: QBox PlayerData Module konnte nicht geladen werden!')
                return false
            end
            
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
            -- ESX: Für client-side check nutzen wir ox_inventory wenn verfügbar
            -- Ansonsten verlassen wir uns auf server-seitige Prüfung
            if Config.Inventory == "ox_inventory" then
                local count = exports.ox_inventory:Search('count', Config.RequiredTool.item)
                return count and count > 0
            end
            -- Fallback: Annahme dass Tool vorhanden (server prüft nochmal)
            return true
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
    
    -- TextUI ausblenden während Farming
    if Config.TextUI.enabled then
        lib.hideTextUI()
    end
    
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
    
    -- Thread zum Überwachen ob Spieler Feld verlässt, stirbt oder Cancel drückt
    local cancelled = false
    local cancelKey = isAutoFarm and Config.AutoFarm.confirmKey or Config.AutoFarm.key
    
    CreateThread(function()
        while isPlowing do
            Wait(0)  -- 0ms für instant Cancel-Detection
            
            -- Cancel mit E (Normal) oder G (Auto-Farm)
            if IsControlJustPressed(0, cancelKey) then
                cancelled = true
                
                -- Bei Auto-Farm: Auto-Farm komplett deaktivieren
                if isAutoFarm then
                    autoFarmActive = false
                    Notify(Lang:t('notify_autofarm_stop'), 'inform')
                else
                    Notify(Lang:t('notify_action_cancelled_manual'), 'error')
                end
                
                exports['ox_lib']:cancelProgress()
                break
            end
            
            -- Auto-Cancel bei Feld verlassen oder Tod
            if not inField or IsEntityDead(PlayerPedId()) then
                cancelled = true
                exports['ox_lib']:cancelProgress()
                break
            end
        end
    end)
    
    -- Cancel-Taste Name für Anzeige
    local cancelKeyName = isAutoFarm and "G" or "E"
    
    local success = lib.progressBar({
        duration = Config.PlowTime,
        label = Lang:t('progress_plowing') .. ' | [' .. cancelKeyName .. '] ' .. Lang:t('progress_cancel'),
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
    
    -- Warte kurz damit cancelled-Flag gesetzt werden kann
    Wait(50)
    
    if success and not cancelled then
        -- Event mit Auto-Farm Flag senden
        TriggerServerEvent('wheat:plow', isAutoFarm or false)
    elseif cancelled then
        -- Benachrichtigung nur bei Feld verlassen (nicht bei manuellem Cancel)
        if not inField then
            Notify(Lang:t('notify_action_cancelled'), 'error')
        end
    end
    
    -- Prop wieder entfernen
    if prop then
        DeleteObject(prop)
    end
    
    isPlowing = false
    
    -- TextUI wieder anzeigen wenn im Feld
    if inField and Config.TextUI.enabled then
        lib.showTextUI(Lang:t('textui_plow'), {
            position = Config.TextUI.position,
            icon = Config.TextUI.icon,
        })
    end
end

-- =====================================================
-- OPTIMIZED AUTO-FARM LOOP mit Cooldown Progressbar
-- =====================================================
CreateThread(function()
    while true do
        -- Längerer Sleep wenn Auto-Farm inaktiv
        if not autoFarmActive then
            Wait(1000)  -- 1 Sekunde wenn nicht aktiv
        else
            Wait(500)  -- 500ms wenn aktiv
            
            if inField then
                local ped = PlayerPedId()
                
                if not isPlowing and not IsEntityDead(ped) then
                    -- Farm-Aktion starten
                    plowWheat(true)
                    
                    -- Cooldown Progressbar (nur wenn noch im Feld und Auto-Farm noch aktiv)
                    if autoFarmActive and inField then
                        -- TextUI während Cooldown ausblenden
                        if Config.TextUI.enabled then
                            lib.hideTextUI()
                        end
                        
                        -- Cancel-Check Thread für Cooldown
                        local cooldownCancelled = false
                        CreateThread(function()
                            while not cooldownCancelled do
                                Wait(0)  -- Instant Cancel Detection
                                
                                -- Cancel mit G während Cooldown
                                if IsControlJustPressed(0, Config.AutoFarm.confirmKey) then
                                    cooldownCancelled = true
                                    autoFarmActive = false
                                    exports['ox_lib']:cancelProgress()
                                    Notify(Lang:t('notify_autofarm_stop'), 'inform')
                                    break
                                end
                                
                                -- Auto-Stop wenn Feld verlassen
                                if not inField or not autoFarmActive then
                                    cooldownCancelled = true
                                    exports['ox_lib']:cancelProgress()
                                    break
                                end
                            end
                        end)
                        
                        -- Cooldown Progressbar mit Cancel-Anweisung
                        local cooldownSuccess = lib.progressBar({
                            duration = Config.AutoFarm.cooldown,
                            label = Lang:t('progress_cooldown') .. ' | [G] ' .. Lang:t('progress_cancel'),
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = false,
                                move = false,
                                combat = false,
                            },
                        })
                        
                        cooldownCancelled = true  -- Stop Cancel-Thread
                        
                        -- TextUI wieder anzeigen wenn im Feld und Auto-Farm noch aktiv
                        if inField and autoFarmActive and Config.TextUI.enabled then
                            lib.showTextUI(Lang:t('textui_plow'), {
                                position = Config.TextUI.position,
                                icon = Config.TextUI.icon,
                            })
                        end
                    end
                end
            end
        end
    end
end)

-- =====================================================
-- OPTIMIZED MARKER & INTERACTION LOOP (0.00ms resmon!)
-- =====================================================

-- Marker Drawing Thread (nur für Marker)
CreateThread(function()
    -- Wenn Marker deaktiviert, Thread beenden
    if not Config.ShowMarker then
        return
    end
    
    while true do
        local sleep = 1000  -- Default: 1 Sekunde
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local distance = #(coords - Config.FieldLocation)
        
        if distance < Config.DrawDistance then
            sleep = 0  -- Nur wenn nah am Feld
            
            DrawMarker(
                Config.MarkerType,
                Config.FieldLocation.x, Config.FieldLocation.y, Config.FieldLocation.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                false, true, 2, false, nil, nil, false
            )
        end
        
        Wait(sleep)
    end
end)

-- Interaction Thread (separate für bessere Performance)
CreateThread(function()
    local lastDistanceCheck = 0
    
    while true do
        local currentTime = GetGameTimer()
        local ped = PlayerPedId()
        
        -- Distance Check nur alle 200ms
        local shouldCheckDistance = (currentTime - lastDistanceCheck) >= 200
        
        if shouldCheckDistance then
            lastDistanceCheck = currentTime
            local coords = GetEntityCoords(ped)
            local distance = #(coords - Config.FieldLocation)
            
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
        end
        
        -- Key Checks mit optimaler Balance
        if inField and not IsEntityDead(ped) then
            -- Normale Interaktion: E drücken (nur wenn Auto-Farm AUS ist)
            if IsControlJustPressed(0, Config.AutoFarm.key) and not isPlowing and not autoFarmActive then
                plowWheat(false)
            end
            
            -- Auto-Farm: G drücken
            if Config.AutoFarm.enabled and IsControlJustPressed(0, Config.AutoFarm.confirmKey) and not isPlowing then
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
            
            Wait(0)  -- Im Feld: Sofortige Key-Reaktion
        else
            Wait(500)  -- Außerhalb: Niedriger CPU-Verbrauch
        end
    end
end)

-- =====================================================
-- SYSTEM INFO EVENT (für Client Console)
-- =====================================================
RegisterNetEvent('wheat:systemInfo', function(data)
    print('╔════════════════════════════════════╗')
    print('║   🌾 HM Wheat Farm - System Info   ║')
    print('╠════════════════════════════════════╣')
    print('║ Framework: ' .. data.framework .. string.rep(' ', 24 - #data.framework) .. '║')
    print('║ Inventory: ' .. data.inventory .. string.rep(' ', 24 - #data.inventory) .. '║')
    print('╚════════════════════════════════════╝')
end)

-- Debug Command für Client Console (F8)
RegisterCommand('wheatinfo', function()
    -- Fordere Info vom Server an
    TriggerServerEvent('wheat:requestInfo')
end, false)
