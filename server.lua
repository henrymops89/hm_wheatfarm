-- =====================================================
-- SERVER.LUA - MULTI-FRAMEWORK (QBox Native, QBCore, ESX)
-- =====================================================

local Framework = nil
local FrameworkName = nil
local ESX = nil
local InventorySystem = nil

-- Framework & Inventory Detection
CreateThread(function()
    -- Warte kurz damit alle Resources geladen sind
    Wait(1000)
    
    -- Framework Detection
    if GetResourceState('qbx_core') == 'started' then
        -- ✅ QBox - KEINE Core Object Zuweisung!
        FrameworkName = 'QBox'
        print('[WheatFarm] Framework detected: QBox (Native Exports)')
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
    
    -- Inventory System Detection
    print('[WheatFarm] Checking Inventory System... (Config: ' .. Config.Inventory .. ')')
    
    if Config.Inventory == "auto" then
        local oxState = GetResourceState('ox_inventory')
        local qsState = GetResourceState('qs-inventory')
        
        print('[WheatFarm] ox_inventory state: ' .. oxState)
        print('[WheatFarm] qs-inventory state: ' .. qsState)
        
        if oxState == 'started' then
            InventorySystem = 'ox_inventory'
            print('[WheatFarm] ✅ Inventory System detected: ox_inventory')
        elseif qsState == 'started' then
            InventorySystem = 'qs-inventory'
            print('[WheatFarm] ✅ Inventory System detected: qs-inventory')
        else
            -- Fallback: Prüfe welches Resource existiert
            if oxState ~= 'missing' then
                InventorySystem = 'ox_inventory'
                print('[WheatFarm] ⚠️ ox_inventory gefunden aber nicht gestartet! Verwende ox_inventory.')
            elseif qsState ~= 'missing' then
                InventorySystem = 'qs-inventory'
                print('[WheatFarm] ⚠️ qs-inventory gefunden aber nicht gestartet! Verwende qs-inventory.')
            else
                print('[WheatFarm] ^1ERROR: Kein Inventory System gefunden!^7')
                print('[WheatFarm] ^3Bitte installiere ox_inventory oder qs-inventory!^7')
                InventorySystem = 'ox_inventory' -- Default Fallback
            end
        end
    else
        -- Manuell gesetzt
        InventorySystem = Config.Inventory
        print('[WheatFarm] Inventory System (manual): ' .. InventorySystem)
    end
    
    print('[WheatFarm] =====================================')
    print('[WheatFarm] Initialization Complete!')
    print('[WheatFarm] Framework: ' .. (FrameworkName or 'Unknown'))
    print('[WheatFarm] Inventory: ' .. (InventorySystem or 'Unknown'))
    print('[WheatFarm] =====================================')
    
    -- Sende Info an alle Clients
    TriggerClientEvent('wheat:systemInfo', -1, {
        framework = FrameworkName or 'Unknown',
        inventory = InventorySystem or 'Unknown'
    })
end)

-- Debug Command
RegisterCommand('wheatdebug', function(source, args, rawCommand)
    if source == 0 then -- Server console only
        print('=== WheatFarm Debug Info ===')
        print('Framework: ' .. tostring(FrameworkName))
        print('Inventory System: ' .. tostring(InventorySystem))
        print('Config.Inventory: ' .. tostring(Config.Inventory))
        print('ox_inventory state: ' .. GetResourceState('ox_inventory'))
        print('qs-inventory state: ' .. GetResourceState('qs-inventory'))
    else
        -- Wenn vom Spieler aufgerufen, sende Info zurück
        TriggerClientEvent('wheat:systemInfo', source, {
            framework = FrameworkName or 'Unknown',
            inventory = InventorySystem or 'Unknown'
        })
    end
end, false)

-- =====================================================
-- UNIVERSAL INVENTORY HELPER FUNCTIONS
-- =====================================================

-- Add Item (Universal für ox_inventory & qs-inventory)
local function AddItem(source, item, amount, metadata)
    if InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:AddItem(source, item, amount, metadata or {})
    elseif InventorySystem == 'qs-inventory' then
        return exports['qs-inventory']:AddItem(source, item, amount, nil, metadata or {})
    end
    return false
end

-- Remove Item (Universal)
local function RemoveItem(source, item, amount, metadata)
    if InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(source, item, amount, metadata)
    elseif InventorySystem == 'qs-inventory' then
        return exports['qs-inventory']:RemoveItem(source, item, amount, nil, metadata)
    end
    return false
end

-- Can Carry Item (Universal)
local function CanCarryItem(source, item, amount)
    if InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:CanCarryItem(source, item, amount)
    elseif InventorySystem == 'qs-inventory' then
        return exports['qs-inventory']:CanCarryItem(source, item, amount)
    end
    return false
end

-- Get Item (Universal)
local function GetItem(source, item)
    if InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:GetItem(source, item, nil, true)
    elseif InventorySystem == 'qs-inventory' then
        local inventory = exports['qs-inventory']:GetInventory(source)
        if not inventory then return nil end
        
        -- Suche Item in Inventory
        for slot, itemData in pairs(inventory) do
            if itemData.name == item then
                return itemData
            end
        end
        return nil
    end
    return nil
end

-- Get All Items of Type (Universal)
local function GetItems(source, item)
    if InventorySystem == 'ox_inventory' then
        return exports.ox_inventory:GetItem(source, item, nil, false) or {}
    elseif InventorySystem == 'qs-inventory' then
        local inventory = exports['qs-inventory']:GetInventory(source)
        if not inventory then return {} end
        
        local items = {}
        for slot, itemData in pairs(inventory) do
            if itemData.name == item then
                table.insert(items, itemData)
            end
        end
        return items
    end
    return {}
end

-- Set Item Metadata/Durability (Universal)
local function SetItemMetadata(source, slot, metadata)
    if InventorySystem == 'ox_inventory' then
        -- ox_inventory nutzt SetDurability für Durability
        if metadata.durability then
            return exports.ox_inventory:SetDurability(source, slot, metadata.durability)
        elseif metadata.quality then
            return exports.ox_inventory:SetDurability(source, slot, metadata.quality)
        end
        return false
    elseif InventorySystem == 'qs-inventory' then
        return exports['qs-inventory']:SetItemMetadata(source, slot, metadata)
    end
    return false
end

-- Get Item Slot (Universal)
local function GetItemSlot(source, item)
    if InventorySystem == 'ox_inventory' then
        local itemData = exports.ox_inventory:GetItem(source, item, nil, true)
        return itemData and itemData.slot or nil
    elseif InventorySystem == 'qs-inventory' then
        local inventory = exports['qs-inventory']:GetInventory(source)
        if not inventory then return nil end
        
        for slot, itemData in pairs(inventory) do
            if itemData.name == item then
                return slot
            end
        end
        return nil
    end
    return nil
end

-- =====================================================
-- FRAMEWORK HELPER FUNCTIONS
-- =====================================================

-- Helper: Notification senden
local function Notify(source, text, type, duration)
    if FrameworkName == 'QBox' then
        exports.qbx_core:Notify(source, text, type, duration or 5000)
    elseif FrameworkName == 'QBCore' then
        TriggerClientEvent('QBCore:Notify', source, text, type, duration)
    elseif FrameworkName == 'ESX' then
        TriggerClientEvent('esx:showNotification', source, text)
    end
end

-- Locale laden
local lang = Config.Language or 'en'
local localeFile = ('locales/%s'):format(lang)

-- Locale-Datei laden (enthält bereits Lang Objekt)
require(localeFile)

-- =====================================================
-- SECURITY: Cooldown & Anti-Exploit System
-- =====================================================

-- Cooldown Tracker: [source] = lastPlowTime
local playerCooldowns = {}

-- Anti-Spam: Maximale Requests pro Minute
local requestCounter = {}
local MAX_REQUESTS_PER_MINUTE = 20

-- Hilfsfunktion: Cooldown Check
local function isOnCooldown(source)
    local currentTime = os.time()
    local lastPlow = playerCooldowns[source]
    
    if not lastPlow then
        return false
    end
    
    -- Minimaler Cooldown: PlowTime (5 Sekunden) + 1 Sekunde Sicherheit
    local minCooldown = math.floor(Config.PlowTime / 1000) + 1
    local timeSinceLastPlow = currentTime - lastPlow
    
    return timeSinceLastPlow < minCooldown
end

-- Hilfsfunktion: Rate Limit Check
local function checkRateLimit(source)
    local currentTime = os.time()
    
    if not requestCounter[source] then
        requestCounter[source] = {
            count = 1,
            resetTime = currentTime + 60
        }
        return true
    end
    
    -- Reset Counter nach 1 Minute
    if currentTime >= requestCounter[source].resetTime then
        requestCounter[source] = {
            count = 1,
            resetTime = currentTime + 60
        }
        return true
    end
    
    -- Increment Counter
    requestCounter[source].count = requestCounter[source].count + 1
    
    -- Check if exceeded
    if requestCounter[source].count > MAX_REQUESTS_PER_MINUTE then
        if Config.EnableLogging then
            print(('[WheatFarm] ^3WARNUNG: Spieler %s überschreitet Rate Limit! (%d requests/min)^7'):format(source, requestCounter[source].count))
        end
        return false
    end
    
    return true
end

-- Hilfsfunktion: Distance Check
local function isPlayerNearField(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then
        return false
    end
    
    local coords = GetEntityCoords(ped)
    if not coords then
        return false
    end
    
    local distance = #(coords - Config.FieldLocation)
    
    -- Spieler muss innerhalb des konfigurierten Radius sein
    -- + 1.0 meter Toleranz für Netzwerk-Latenz
    return distance <= (Config.FieldRadius + 1.0)
end

-- Cleanup: Entferne inaktive Spieler aus Cooldown-Tabelle
CreateThread(function()
    while true do
        Wait(300000) -- Alle 5 Minuten
        
        local currentTime = os.time()
        local activePlayers = {}
        
        -- Sammle alle aktiven Spieler
        for _, playerId in ipairs(GetPlayers()) do
            activePlayers[tonumber(playerId)] = true
        end
        
        -- Entferne inaktive Spieler aus Cooldowns
        for source, _ in pairs(playerCooldowns) do
            if not activePlayers[source] then
                playerCooldowns[source] = nil
                requestCounter[source] = nil
            end
        end
        
        if Config.EnableLogging then
            print('[WheatFarm] Cooldown-Tabelle bereinigt.')
        end
    end
end)

-- =====================================================
-- TOOL DURABILITY & VALIDATION
-- =====================================================

-- Get Item Durability/Quality (Universal)
local function GetItemDurability(source, slot)
    if InventorySystem == "ox_inventory" then
        local itemData = exports.ox_inventory:GetSlot(source, slot)
        if itemData and itemData.metadata and itemData.metadata.durability then
            return itemData.metadata.durability
        end
    elseif InventorySystem == "qs-inventory" then
        local inventory = exports['qs-inventory']:GetInventory(source)
        if inventory and inventory[slot] then
            local item = inventory[slot]
            -- qs-inventory nutzt 'info.quality' für Durability
            if item.info and item.info.quality then
                return item.info.quality
            end
        end
    end
    return nil
end

-- Set Item Durability/Quality (Universal)
local function SetItemDurability(source, slot, durability)
    if InventorySystem == "ox_inventory" then
        return exports.ox_inventory:SetDurability(source, slot, durability)
    elseif InventorySystem == "qs-inventory" then
        local metadata = { quality = durability }
        return exports['qs-inventory']:SetItemMetadata(source, slot, metadata)
    end
    return false
end

-- Has Tool Check (Universal)
local function HasTool(source)
    if not Config.RequiredTool.enabled then
        return true, nil
    end
    
    local toolItem = GetItem(source, Config.RequiredTool.item)
    if toolItem then
        return true, toolItem.slot
    end
    
    return false, nil
end

-- =====================================================
-- MAIN WHEAT FARMING EVENT
-- =====================================================

RegisterNetEvent('wheat:plow', function(isAutoFarm)
    local source = source
    
    -- =====================================================
    -- SECURITY CHECK 1: Rate Limit (Anti-Spam)
    -- =====================================================
    if Config.Security and Config.Security.enabled then
        if not checkRateLimit(source) then
            if Config.EnableLogging then
                print(('[WheatFarm] ^1EXPLOIT VERSUCH: Spieler %s wurde wegen Rate Limiting blockiert!^7'):format(source))
            end
            -- Kick bei zu vielen Requests (optional)
            if Config.Security.kickOnRateLimit then
                DropPlayer(source, '[WheatFarm] Anti-Cheat: Rate Limit überschritten')
            end
            return
        end
        
        -- =====================================================
        -- SECURITY CHECK 2: Cooldown Check
        -- =====================================================
        if Config.Security.enforceCooldown and isOnCooldown(source) then
            if Config.EnableLogging then
                print(('[WheatFarm] ^3WARNUNG: Spieler %s ignoriert Cooldown!^7'):format(source))
            end
            Notify(source, Lang:t('notify_cooldown'), 'error')
            return
        end
        
        -- =====================================================
        -- SECURITY CHECK 3: Distance Check
        -- =====================================================
        if Config.Security.enforceDistance and not isPlayerNearField(source) then
            if Config.EnableLogging then
                print(('[WheatFarm] ^1EXPLOIT VERSUCH: Spieler %s ist zu weit vom Feld entfernt!^7'):format(source))
            end
            
            -- Kick bei Distance-Exploit (optional)
            if Config.Security.kickOnDistanceExploit then
                DropPlayer(source, '[WheatFarm] Anti-Cheat: Distance Exploit erkannt')
            end
            return
        end
    end
    
    -- =====================================================
    -- SECURITY CHECK 4: Tool Verification
    -- =====================================================
    local hasTool, toolSlot = HasTool(source)
    
    if not hasTool then
        Notify(source, Lang:t('notify_no_tool'), 'error')
        return
    end
    
    -- =====================================================
    -- Setze Cooldown NACH erfolgreichen Checks
    -- =====================================================
    playerCooldowns[source] = os.time()
    
    -- =====================================================
    -- Werkzeug-System: Haltbarkeit oder Permanent
    -- =====================================================
    if Config.RequiredTool.enabled and Config.RequiredTool.toolType == "durability" and toolSlot then
        local durability = GetItemDurability(source, toolSlot)
        
        if not durability then
            -- Erstes Mal benutzt - setze volle Haltbarkeit
            durability = Config.RequiredTool.maxDurability
        end
        
        -- Reduziere Haltbarkeit
        durability = durability - Config.RequiredTool.durabilityPerUse
        
        -- Prüfe ob Werkzeug kaputt geht
        local breakRoll = math.random(1, 100)
        if breakRoll <= Config.RequiredTool.breakChance or durability <= 0 then
            -- Werkzeug zerstören
            RemoveItem(source, Config.RequiredTool.item, 1)
            Notify(source, Lang:t('notify_tool_broken'), 'error')
            return
        else
            -- Haltbarkeit aktualisieren
            SetItemDurability(source, toolSlot, durability)
            
            -- Benachrichtigung bei niedriger Haltbarkeit
            local durabilityPercent = math.floor((durability / Config.RequiredTool.maxDurability) * 100)
            if durabilityPercent <= 20 then
                Notify(source, Lang:t('notify_tool_damaged', durabilityPercent), 'warning')
            end
        end
    end
    
    -- =====================================================
    -- Ertrag berechnen
    -- =====================================================
    local amount
    if isAutoFarm then
        amount = math.random(Config.AutoFarm.minWheat, Config.AutoFarm.maxWheat)
    else
        amount = math.random(Config.MinWheatPerPlow, Config.MaxWheatPerPlow)
    end
    
    -- =====================================================
    -- Item hinzufügen
    -- =====================================================
    local success = AddItem(source, Config.WheatItem, amount)
    
    if success then
        -- Benachrichtigung wird client-seitig gesendet
        TriggerClientEvent('wheat:notifySuccess', source, amount)
        
        -- Optional: Logging
        if Config.EnableLogging then
            local mode = isAutoFarm and " (Auto-Farm)" or ""
            print(Lang:t('log_plow', source, amount) .. mode)
        end
    end
end)

-- =====================================================
-- ESX Callback für hasItem Check (nur wenn ESX geladen)
-- =====================================================
if FrameworkName == 'ESX' and ESX then
    ESX.RegisterServerCallback('wheat:hasItem', function(source, cb, itemName)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then
            cb(false)
            return
        end
        
        local item = xPlayer.getInventoryItem(itemName)
        cb(item and item.count > 0)
    end)
end

-- =====================================================
-- Player Disconnect Cleanup
-- =====================================================
AddEventHandler('playerDropped', function()
    local source = source
    
    -- Entferne Spieler aus Cooldown-Tabellen
    if playerCooldowns[source] then
        playerCooldowns[source] = nil
    end
    
    if requestCounter[source] then
        requestCounter[source] = nil
    end
end)

-- =====================================================
-- Client Info Request
-- =====================================================
RegisterNetEvent('wheat:requestInfo', function()
    local source = source
    TriggerClientEvent('wheat:systemInfo', source, {
        framework = FrameworkName or 'Unknown',
        inventory = InventorySystem or 'Unknown'
    })
end)
