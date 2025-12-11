-- =====================================================
-- SERVER.LUA
-- =====================================================

-- Locale laden
local lang = Config.Language or 'en'
local localeFile = ('locales/%s'):format(lang)

-- Locale-Datei laden (enthält bereits Lang Objekt)
require(localeFile)

-- Inventory Helper Funktionen
local function AddItem(source, item, amount)
    if Config.Inventory == "ox_inventory" then
        return exports.ox_inventory:AddItem(source, item, amount)
    elseif Config.Inventory == "qs-inventory" then
        return exports['qs-inventory']:AddItem(source, item, amount)
    end
    return false
end

local function RemoveItem(source, item, amount)
    if Config.Inventory == "ox_inventory" then
        return exports.ox_inventory:RemoveItem(source, item, amount)
    elseif Config.Inventory == "qs-inventory" then
        return exports['qs-inventory']:RemoveItem(source, item, amount)
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
        local item = exports.ox_inventory:Search(source, 'count', Config.RequiredTool.item)
        if item and item > 0 then
            -- Finde Slot des Items
            local inventory = exports.ox_inventory:GetInventory(source)
            for slot, itemData in pairs(inventory.items) do
                if itemData.name == Config.RequiredTool.item then
                    return true, slot
                end
            end
        end
    elseif Config.Inventory == "qs-inventory" then
        -- qs-inventory hat kein Haltbarkeitssystem, nur Item-Check
        return exports['qs-inventory']:HasItem(source, Config.RequiredTool.item, 1), nil
    end
    
    return false, nil
end

-- Weizen pflügen
RegisterNetEvent('wheat:plow', function(isAutoFarm)
    local source = source
    
    -- Prüfe ob Spieler Werkzeug hat
    local hasTool, toolSlot = HasTool(source)
    
    if not hasTool then
        exports.qbx_core:Notify(source, Lang:t('notify_no_tool'), 'error')
        return
    end
    
    -- Werkzeug-System: Option 1 (Haltbarkeit) oder Option 3 (Permanent)
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
            exports.qbx_core:Notify(source, Lang:t('notify_tool_broken'), 'error')
            return
        else
            -- Haltbarkeit aktualisieren
            SetItemDurability(source, Config.RequiredTool.item, toolSlot, durability)
            
            -- Benachrichtigung bei niedriger Haltbarkeit
            local durabilityPercent = math.floor((durability / Config.RequiredTool.maxDurability) * 100)
            if durabilityPercent <= 20 then
                exports.qbx_core:Notify(source, Lang:t('notify_tool_damaged', durabilityPercent), 'warning')
            end
        end
    end
    -- Bei toolType = "permanent" passiert nichts - Werkzeug wird nur gecheckt
    
    -- Ertrag basierend auf Modus berechnen
    local amount
    if isAutoFarm then
        amount = math.random(Config.AutoFarm.minWheat, Config.AutoFarm.maxWheat)
    else
        amount = math.random(Config.MinWheatPerPlow, Config.MaxWheatPerPlow)
    end
    
    -- Item hinzufügen (mit gewähltem Inventory System)
    local success = AddItem(source, Config.WheatItem, amount)
    
    if success then
        -- Benachrichtigung wird nun client-seitig gesendet (nur wenn im Kreis)
        TriggerClientEvent('wheat:notifySuccess', source, amount)
        
        -- Optional: Logging
        if Config.EnableLogging then
            local mode = isAutoFarm and " (Auto-Farm)" or ""
            print(Lang:t('log_plow', source, amount) .. mode)
        end
    end
end)