-- =====================================================
-- BRIDGE/FRAMEWORK.LUA - Framework Detection & Functions
-- Supports: QBox, QBCore, ESX Legacy
-- =====================================================

Framework = {
    name = nil,
    object = nil,
    ready = false
}

-- =====================================================
-- FRAMEWORK DETECTION
-- =====================================================

local function DetectFramework()
    -- QBox Detection
    if GetResourceState('qbx_core') == 'started' then
        Framework.name = 'qbox'
        Framework.ready = true
        print('[WheatFarm Bridge] ✅ Framework: QBox (Native Exports)')
        return true
    end
    
    -- QBCore Detection
    if GetResourceState('qb-core') == 'started' then
        local success, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        
        if success and core then
            Framework.name = 'qbcore'
            Framework.object = core
            Framework.ready = true
            print('[WheatFarm Bridge] ✅ Framework: QBCore')
            return true
        end
    end
    
    -- ESX Detection
    if GetResourceState('es_extended') == 'started' then
        local success, esx = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        
        if success and esx then
            Framework.name = 'esx'
            Framework.object = esx
            Framework.ready = true
            print('[WheatFarm Bridge] ✅ Framework: ESX Legacy')
            return true
        end
    end
    
    print('^1[WheatFarm Bridge] ❌ ERROR: No supported framework found!^7')
    return false
end

-- =====================================================
-- PLAYER FUNCTIONS
-- =====================================================

function GetPlayer(source)
    if not Framework.ready then return nil end
    
    if Framework.name == 'qbox' then
        return exports.qbx_core:GetPlayer(source)
        
    elseif Framework.name == 'qbcore' then
        return Framework.object.Functions.GetPlayer(source)
        
    elseif Framework.name == 'esx' then
        return Framework.object.GetPlayerFromId(source)
    end
    
    return nil
end

-- =====================================================
-- MONEY FUNCTIONS
-- =====================================================

function AddMoney(source, amount, moneyType)
    if not Framework.ready then return false end
    
    moneyType = moneyType or 'cash'
    
    if Framework.name == 'qbox' then
        return exports.qbx_core:AddMoney(source, moneyType, amount)
        
    elseif Framework.name == 'qbcore' then
        local Player = GetPlayer(source)
        if Player then
            Player.Functions.AddMoney(moneyType, amount)
            return true
        end
        
    elseif Framework.name == 'esx' then
        local xPlayer = GetPlayer(source)
        if xPlayer then
            if moneyType == 'cash' or moneyType == 'money' then
                xPlayer.addMoney(amount)
            else
                xPlayer.addAccountMoney(moneyType, amount)
            end
            return true
        end
    end
    
    return false
end

function RemoveMoney(source, amount, moneyType)
    if not Framework.ready then return false end
    
    moneyType = moneyType or 'cash'
    
    if Framework.name == 'qbox' then
        return exports.qbx_core:RemoveMoney(source, moneyType, amount)
        
    elseif Framework.name == 'qbcore' then
        local Player = GetPlayer(source)
        if Player then
            Player.Functions.RemoveMoney(moneyType, amount)
            return true
        end
        
    elseif Framework.name == 'esx' then
        local xPlayer = GetPlayer(source)
        if xPlayer then
            if moneyType == 'cash' or moneyType == 'money' then
                xPlayer.removeMoney(amount)
            else
                xPlayer.removeAccountMoney(moneyType, amount)
            end
            return true
        end
    end
    
    return false
end

-- =====================================================
-- NOTIFICATION FUNCTION
-- =====================================================

function Notify(target, message, type, duration)
    if not Framework.ready then return end
    
    duration = duration or 5000
    
    if IsDuplicityVersion() then
        -- Server-side
        if Framework.name == 'qbox' then
            exports.qbx_core:Notify(target, message, type, duration)
            
        elseif Framework.name == 'qbcore' then
            TriggerClientEvent('QBCore:Notify', target, message, type, duration)
            
        elseif Framework.name == 'esx' then
            TriggerClientEvent('esx:showNotification', target, message)
        end
    else
        -- Client-side
        if Framework.name == 'qbox' then
            exports.qbx_core:Notify(message, type, duration)
            
        elseif Framework.name == 'qbcore' then
            Framework.object.Functions.Notify(message, type, duration)
            
        elseif Framework.name == 'esx' then
            Framework.object.ShowNotification(message)
        end
    end
end

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

function GetFrameworkName()
    return Framework.name or 'unknown'
end

function IsFrameworkReady()
    return Framework.ready
end

-- =====================================================
-- INITIALIZATION
-- =====================================================

CreateThread(function()
    Wait(500)
    DetectFramework()
end)

-- =====================================================
-- EXPORTS
-- =====================================================

if IsDuplicityVersion() then
    -- Server exports
    exports('GetPlayer', GetPlayer)
    exports('AddMoney', AddMoney)
    exports('RemoveMoney', RemoveMoney)
    exports('Notify', Notify)
    exports('GetFrameworkName', GetFrameworkName)
    exports('IsFrameworkReady', IsFrameworkReady)
else
    -- Client exports
    exports('Notify', Notify)
    exports('GetFrameworkName', GetFrameworkName)
    exports('IsFrameworkReady', IsFrameworkReady)
end
