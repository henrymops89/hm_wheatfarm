-- =====================================================
-- SERVER/SECURITY.LUA - Anti-Cheat & Security System
-- Single Responsibility: Cooldowns, rate limiting, exploit prevention
-- =====================================================

-- =====================================================
-- STATE MANAGEMENT
-- =====================================================

local playerCooldowns = {}
local requestCounter = {}

-- =====================================================
-- COOLDOWN SYSTEM
-- =====================================================

-- Check if player is on cooldown for specific action
function IsOnCooldown(source, action)
    -- Guard: Security disabled
    if not Config.Security or not Config.Security.enabled then
        return false
    end
    
    -- Guard: Cooldown enforcement disabled
    if not Config.Security.enforceCooldown then
        return false
    end
    
    local key = source .. '_' .. action
    local lastAction = playerCooldowns[key]
    
    -- Guard: No previous action recorded
    if not lastAction then
        return false
    end
    
    local currentTime = os.time()
    local timePassed = currentTime - lastAction
    local minCooldown = Config.Security.minCooldownSeconds or 6
    
    return timePassed < minCooldown, (minCooldown - timePassed)
end

-- Set cooldown for player action
function SetCooldown(source, action)
    local key = source .. '_' .. action
    playerCooldowns[key] = os.time()
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] Cooldown set for player %s (action: %s)', source, action))
    end
end

-- Clear cooldown for player
function ClearCooldown(source, action)
    local key = source .. '_' .. action
    playerCooldowns[key] = nil
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] Cooldown cleared for player %s (action: %s)', source, action))
    end
end

-- Clear all cooldowns for a player
function ClearAllPlayerCooldowns(source)
    local cleared = 0
    
    for key, _ in pairs(playerCooldowns) do
        if string.match(key, '^' .. source .. '_') then
            playerCooldowns[key] = nil
            cleared = cleared + 1
        end
    end
    
    if Config.EnableLogging and cleared > 0 then
        print(string.format('[WheatFarm] Cleared %d cooldowns for player %s', cleared, source))
    end
end

-- Clear all cooldowns (admin command)
function ClearAllCooldowns()
    local count = 0
    for _ in pairs(playerCooldowns) do
        count = count + 1
    end
    
    playerCooldowns = {}
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] Cleared all cooldowns (%d total)', count))
    end
end

-- =====================================================
-- RATE LIMITING SYSTEM
-- =====================================================

-- Check if player exceeded rate limit
function CheckRateLimit(source)
    -- Guard: Security disabled
    if not Config.Security or not Config.Security.enabled then
        return true
    end
    
    local currentTime = os.time()
    local maxRequests = Config.Security.maxRequestsPerMinute or 20
    
    -- Initialize counter for new player
    if not requestCounter[source] then
        requestCounter[source] = {
            count = 1,
            resetTime = currentTime + 60
        }
        return true
    end
    
    -- Reset counter if time expired
    if currentTime >= requestCounter[source].resetTime then
        requestCounter[source] = {
            count = 1,
            resetTime = currentTime + 60
        }
        return true
    end
    
    -- Increment counter
    requestCounter[source].count = requestCounter[source].count + 1
    
    -- Check if limit exceeded
    if requestCounter[source].count > maxRequests then
        if Config.Security.logSuspiciousActivity then
            print(string.format('^3[WheatFarm] ⚠️ Rate limit exceeded: Player %s (%d requests/min)^7', 
                source, requestCounter[source].count))
        end
        
        -- Kick player if configured
        if Config.Security.kickOnRateLimit then
            DropPlayer(source, '[WheatFarm] Anti-Cheat: Rate limit exceeded')
        end
        
        return false
    end
    
    return true
end

-- Reset rate limit for player
function ResetRateLimit(source)
    requestCounter[source] = nil
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] Rate limit reset for player %s', source))
    end
end

-- =====================================================
-- DISTANCE EXPLOIT DETECTION
-- =====================================================

-- Validate player is near location (anti-teleport hack)
function ValidatePlayerDistance(source, location, maxDistance)
    -- Guard: Security disabled
    if not Config.Security or not Config.Security.enabled then
        return true
    end
    
    -- Guard: Distance check disabled
    if not Config.Security.enforceDistance then
        return true
    end
    
    local tolerance = Config.Security.distanceTolerance or 5.0
    local isValid, distance = ValidateDistance(source, location, maxDistance, tolerance)
    
    if not isValid then
        if Config.Security.logSuspiciousActivity then
            print(string.format('^1[WheatFarm] ⚠️ Distance exploit detected: Player %s is %.2fm away (max: %.2fm)^7', 
                source, distance, maxDistance + tolerance))
        end
        
        -- Kick player if configured
        if Config.Security.kickOnDistanceExploit then
            DropPlayer(source, '[WheatFarm] Anti-Cheat: Distance exploit detected')
        end
        
        return false
    end
    
    return true
end

-- =====================================================
-- COMBINED SECURITY CHECK
-- =====================================================

-- Perform all security checks at once
function PerformSecurityChecks(source, action, location, maxDistance)
    -- Guard: Security disabled
    if not Config.Security or not Config.Security.enabled then
        return true, nil
    end
    
    -- Check 1: Rate Limiting
    if not CheckRateLimit(source) then
        return false, 'rate_limit'
    end
    
    -- Check 2: Cooldown
    local onCooldown, remaining = IsOnCooldown(source, action)
    if onCooldown then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Player %s is on cooldown (%ds remaining)', 
                source, remaining))
        end
        Notify(source, Lang:t('notify_cooldown'), 'error')
        return false, 'cooldown'
    end
    
    -- Check 3: Distance (if location provided)
    if location and maxDistance then
        if not ValidatePlayerDistance(source, location, maxDistance) then
            Notify(source, Lang:t('notify_too_far'), 'error')
            return false, 'distance'
        end
    end
    
    -- All checks passed - set cooldown
    SetCooldown(source, action)
    
    return true, nil
end

-- =====================================================
-- CLEANUP SYSTEM
-- =====================================================

-- Cleanup data for disconnected player
local function cleanupPlayer(source)
    -- Clear cooldowns
    ClearAllPlayerCooldowns(source)
    
    -- Clear rate limit
    ResetRateLimit(source)
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] Security cleanup for player %s', source))
    end
end

-- Event handler for player disconnect
RegisterNetEvent('wheat:playerDisconnected', function(source)
    cleanupPlayer(source)
end)

-- =====================================================
-- PERIODIC CLEANUP THREAD
-- =====================================================

-- Clean up inactive players every 5 minutes
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        
        local activePlayers = {}
        for _, playerId in ipairs(GetPlayers()) do
            activePlayers[tonumber(playerId)] = true
        end
        
        -- Cleanup cooldowns
        local cooldownsCleaned = 0
        for key, _ in pairs(playerCooldowns) do
            local playerId = tonumber(string.match(key, '^(%d+)_'))
            if playerId and not activePlayers[playerId] then
                playerCooldowns[key] = nil
                cooldownsCleaned = cooldownsCleaned + 1
            end
        end
        
        -- Cleanup request counters
        local countersCleaned = 0
        for playerId, _ in pairs(requestCounter) do
            if not activePlayers[playerId] then
                requestCounter[playerId] = nil
                countersCleaned = countersCleaned + 1
            end
        end
        
        if Config.EnableLogging and (cooldownsCleaned > 0 or countersCleaned > 0) then
            print(string.format('[WheatFarm] Security cleanup: %d cooldowns, %d rate limits', 
                cooldownsCleaned, countersCleaned))
        end
    end
end)

-- =====================================================
-- ADMIN COMMANDS
-- =====================================================

-- Event: Clear cooldown for specific player
RegisterNetEvent('wheat:clearCooldown', function(target)
    local source = source
    
    -- TODO: Add permission check here
    -- if not IsPlayerAdmin(source) then return end
    
    local targetSource = target or source
    ClearAllPlayerCooldowns(targetSource)
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] Admin %s cleared cooldowns for player %s', 
            source, targetSource))
    end
end)

-- Event: Clear all cooldowns
RegisterNetEvent('wheat:clearAllCooldowns', function()
    local source = source
    
    -- TODO: Add permission check here
    -- if not IsPlayerAdmin(source) then return end
    
    ClearAllCooldowns()
    
    if Config.EnableLogging then
        print(string.format('[WheatFarm] Admin %s cleared all cooldowns', source))
    end
end)

-- =====================================================
-- CLEANUP ON RESOURCE STOP
-- =====================================================

AddEventHandler('wheat:cleanup', function()
    playerCooldowns = {}
    requestCounter = {}
    print('[WheatFarm] Security data cleared')
end)

-- =====================================================
-- DEBUG INFO
-- =====================================================

-- Get security stats
function GetSecurityStats()
    local activeCooldowns = 0
    for _ in pairs(playerCooldowns) do
        activeCooldowns = activeCooldowns + 1
    end
    
    local activeRateLimits = 0
    for _ in pairs(requestCounter) do
        activeRateLimits = activeRateLimits + 1
    end
    
    return {
        cooldowns = activeCooldowns,
        rateLimits = activeRateLimits,
        enabled = Config.Security.enabled,
        enforceCooldown = Config.Security.enforceCooldown,
        enforceDistance = Config.Security.enforceDistance,
    }
end

-- Debug command
RegisterCommand('wheatsecurity', function(source, args, rawCommand)
    if source ~= 0 then return end -- Console only
    
    local stats = GetSecurityStats()
    
    print('=== WheatFarm Security Stats ===')
    print('Enabled: ' .. tostring(stats.enabled))
    print('Enforce Cooldown: ' .. tostring(stats.enforceCooldown))
    print('Enforce Distance: ' .. tostring(stats.enforceDistance))
    print('Active Cooldowns: ' .. stats.cooldowns)
    print('Active Rate Limits: ' .. stats.rateLimits)
    print('===============================')
end, false)

-- =====================================================
-- EXPORTS
-- =====================================================

exports('IsOnCooldown', IsOnCooldown)
exports('SetCooldown', SetCooldown)
exports('ClearCooldown', ClearCooldown)
exports('ClearAllPlayerCooldowns', ClearAllPlayerCooldowns)
exports('CheckRateLimit', CheckRateLimit)
exports('ResetRateLimit', ResetRateLimit)
exports('ValidatePlayerDistance', ValidatePlayerDistance)
exports('PerformSecurityChecks', PerformSecurityChecks)
exports('GetSecurityStats', GetSecurityStats)