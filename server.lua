-- =====================================================
-- SERVER.LUA - MULTI-FRAMEWORK (QBox Native, QBCore, ESX)
-- =====================================================

local Framework = nil
local FrameworkName = nil

-- Framework Detection
CreateThread(function()
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
        print('[WheatFarm] Framework detected: ESX')
    else
        print('[WheatFarm] ^1ERROR: Kein unterstütztes Framework gefunden!^7')
    end
end)

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
-- Inventory Helper Funktionen (Multi-Framework)
-- =====================================================

local function AddItem(source, item, amount)
    if Config.Inventory == "ox_inventory" then
        return exports.ox_inventory:AddItem(source, item, amount)
    elseif Config.Inventory == "qs-inventory" then
        if FrameworkName == 'QBox' then
            -- QBox mit qs-inventory (falls jemand das nutzt)
            local player = exports.qbx_core:GetPlayer(source)
            if player then
                return player.Functions.AddItem(item, amount)
            end
        elseif FrameworkName == 'QBCore' then
            local Player = Framework.Functions.GetPlayer(source)
            if Player then
                return Player.Functions.AddItem(item, amount)
            end
        elseif FrameworkName == 'ESX' then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                xPlayer.addInventoryItem(item, amount)
                return true
            end
        end
    end
    return false
end

local function RemoveItem(source, item, amount)
    if Config.Inventory == "ox_inventory" then
        return exports.ox_inventory:RemoveItem(source, item, amount)
    elseif Config.Inventory == "qs-inventory" then
        if FrameworkName == 'QBox' then
            local player = exports.qbx_core:GetPlayer(source)
            if player then
                return player.Functions.RemoveItem(item, amount)
            end
        elseif FrameworkName == 'QBCore' then
            local Player = Framework.Functions.GetPlayer(source)
            if Player then
                return Player.Functions.RemoveItem(item, amount)
            end
        elseif FrameworkName == 'ESX' then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                xPlayer.removeInventoryItem(item, amount)
                return true
            end
        end
    end
    return false
end

local function GetItemDurability(source, item, slot)
    if Config.Inventory == "ox_inventory" then
        local itemData = exports.ox_inventory:GetSlot(source, slot)
        if itemData and itemData.metadata and itemData.metadata.durability then
            return itemData.metadata.durability
        end
    end
    return nil
end

local function SetItemDurability(source, item, slot, durability)
    if Config.Inventory == "ox_inventory" then
        local itemData = exports.ox_inventory:GetSlot(source, slot)
        if itemData then
            itemData.metadata = itemData.metadata or {}
            itemData.metadata.durability = durability
            exports.ox_inventory:SetMetadata(source, slot, itemData.metadata)
            return true
        end
    end
    return false
end

local function HasTool(source)
    if not Config.RequiredTool.enabled then
        return true, nil
    end
    
    if Config.Inventory == "ox_inventory" then
        -- ox_inventory: Prüfe ob Item existiert und finde den Slot
        local count = exports.ox_inventory:Search(source, 'count', Config.RequiredTool.item)
        if count and count > 0 then
            -- Finde Slot des Items
            local inventory = exports.ox_inventory:GetInventory(source)
            if inventory and inventory.items then
                for slot, itemData in pairs(inventory.items) do
                    if itemData and itemData.name == Config.RequiredTool.item then
                        return true, slot
                    end
                end
            end
        end
    elseif Config.Inventory == "qs-inventory" then
        if FrameworkName == 'QBox' then
            -- QBox Native Exports
            local player = exports.qbx_core:GetPlayer(source)
            if not player then
                if Config.EnableLogging then
                    print(('[WheatFarm] ERROR: Spieler %s nicht gefunden!'):format(source))
                end
                return false, nil
            end
            
            -- Prüfe ob Spieler das Item hat
            local item = player.Functions.GetItemByName(Config.RequiredTool.item)
            if item and item.amount and item.amount > 0 then
                return true, nil
            end
        elseif FrameworkName == 'QBCore' then
            local Player = Framework.Functions.GetPlayer(source)
            if not Player then
                return false, nil
            end
            
            local item = Player.Functions.GetItemByName(Config.RequiredTool.item)
            if item and item.amount and item.amount > 0 then
                return true, nil
            end
        elseif FrameworkName == 'ESX' then
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then
                return false, nil
            end
            
            local item = xPlayer.getInventoryItem(Config.RequiredTool.item)
            if item and item.count > 0 then
                return true, nil
            end
        end
    end
    
    return false, nil
end

-- =====================================================
-- SECURED EVENT: wheat:plow
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
        local durability = GetItemDurability(source, Config.RequiredTool.item, toolSlot)
        
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
            SetItemDurability(source, Config.RequiredTool.item, toolSlot, durability)
            
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
-- ESX Callback für hasItem Check
-- =====================================================
if FrameworkName == 'ESX' then
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
