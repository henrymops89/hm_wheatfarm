-- =====================================================
-- SERVER/SECURITY.LUA - Anti-Exploit & Rate Limiting
-- Protects against cheaters and exploits
-- =====================================================

local playerRequestCounts = {}
local playerLastAction = {}
local suspiciousPlayers = {}

-- =====================================================
-- RATE LIMITING
-- =====================================================

function CheckRateLimit(source)
    -- Guard: Security disabled
    if not Config.Security or not Config.Security.enabled then
        return true
    end
    
    local currentTime = os.time()
    local playerId = tostring(source)
    
    -- Initialize tracking for new player
    if not playerRequestCounts[playerId] then
        playerRequestCounts[playerId] = {
            count = 0,
            resetTime = currentTime + 60 -- Reset every minute
        }
    end
    
    local playerData = playerRequestCounts[playerId]
    
    -- Reset counter if minute has passed
    if currentTime >= playerData.resetTime then
        playerData.count = 0
        playerData.resetTime = currentTime + 60
    end
    
    -- Increment request count
    playerData.count = playerData.count + 1
    
    -- Check if exceeded limit
    if playerData.count > Config.Security.maxRequestsPerMinute then
        -- Log suspicious activity
        if Config.Security.logSuspiciousActivity then
            local playerName = GetPlayerName(source) or 'Unknown'
            print(string.format(
                '^3[WheatFarm] SECURITY: Player %s (ID: %d) exceeded rate limit! (%d requests/min)^7',
                playerName,
                source,
                playerData.count
            ))
        end
        
        -- Mark as suspicious
        suspiciousPlayers[playerId] = (suspiciousPlayers[playerId] or 0) + 1
        
        -- Kick if configured
        if Config.Security.kickOnRateLimit and suspiciousPlayers[playerId] >= 3 then
            DropPlayer(source, '[WheatFarm] Zu viele Anfragen! (Anti-Cheat)')
        end
        
        return false
    end
    
    return true
end

-- =====================================================
-- COOLDOWN SYSTEM
-- =====================================================

function CheckCooldown(source, actionType, cooldownSeconds)
    -- Guard: Cooldown enforcement disabled
    if not Config.Security or not Config.Security.enforceCooldown then
        return true
    end
    
    cooldownSeconds = cooldownSeconds or Config.Security.minCooldownSeconds or 6
    
    local currentTime = os.time()
    local playerId = tostring(source)
    local key = playerId .. '_' .. actionType
    
    -- Check last action time
    local lastTime = playerLastAction[key]
    
    if lastTime then
        local timePassed = currentTime - lastTime
        
        if timePassed < cooldownSeconds then
            -- Still in cooldown
            local remainingTime = cooldownSeconds - timePassed
            
            TriggerClientEvent('wheat:notify', source, 
                string.format('Bitte warte noch %d Sekunden!', remainingTime), 
                'error'
            )
            
            return false
        end
    end
    
    -- Update last action time
    playerLastAction[key] = currentTime
    
    return true
end

-- =====================================================
-- DISTANCE VALIDATION (Anti-Teleport Exploit)
-- =====================================================

function ValidateDistance(source, expectedLocation, actionName)
    -- Guard: Distance check disabled
    if not Config.Security or not Config.Security.enforceDistance then
        return true
    end
    
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - expectedLocation)
    
    local tolerance = Config.Security.distanceTolerance or 2.0
    
    -- Player is too far away
    if distance > tolerance then
        local playerName = GetPlayerName(source) or 'Unknown'
        
        if Config.Security.logSuspiciousActivity then
            print(string.format(
                '^3[WheatFarm] SECURITY: Player %s (ID: %d) attempted %s from %.2fm away!^7',
                playerName,
                source,
                actionName,
                distance
            ))
        end
        
        -- Mark as suspicious
        local playerId = tostring(source)
        suspiciousPlayers[playerId] = (suspiciousPlayers[playerId] or 0) + 1
        
        -- Kick if severe violation
        if Config.Security.kickOnDistanceExploit and distance > (tolerance * 3) then
            DropPlayer(source, '[WheatFarm] Distanz-Exploit erkannt! (Anti-Cheat)')
        end
        
        TriggerClientEvent('wheat:notify', source, 
            'Du bist zu weit entfernt!', 
            'error'
        )
        
        return false
    end
    
    return true
end

-- =====================================================
-- ITEM VALIDATION (Anti-Duplication)
-- =====================================================

function ValidateItemAmount(source, item, expectedAmount, actionName)
    -- Get actual item count
    local actualCount = GetItemCount(source, item)
    
    -- Player doesn't have enough items
    if actualCount < expectedAmount then
        local playerName = GetPlayerName(source) or 'Unknown'
        
        if Config.Security.logSuspiciousActivity then
            print(string.format(
                '^3[WheatFarm] SECURITY: Player %s (ID: %d) attempted %s without having items! (Has: %d, Needs: %d)^7',
                playerName,
                source,
                actionName,
                actualCount,
                expectedAmount
            ))
        end
        
        -- Mark as suspicious
        local playerId = tostring(source)
        suspiciousPlayers[playerId] = (suspiciousPlayers[playerId] or 0) + 1
        
        TriggerClientEvent('wheat:notify', source, 
            'Du hast nicht genug Items!', 
            'error'
        )
        
        return false
    end
    
    return true
end

-- =====================================================
-- INPUT SANITIZATION
-- =====================================================

function SanitizeNumber(input, min, max, default)
    -- Convert to number
    local num = tonumber(input)
    
    -- Guard: Invalid number
    if not num then
        return default or 0
    end
    
    -- Clamp to range
    if min and num < min then
        num = min
    end
    
    if max and num > max then
        num = max
    end
    
    return num
end

function SanitizeString(input, maxLength)
    -- Guard: Not a string
    if type(input) ~= 'string' then
        return ''
    end
    
    -- Remove dangerous characters
    local cleaned = input:gsub('[<>"\']', '')
    
    -- Limit length
    if maxLength and #cleaned > maxLength then
        cleaned = cleaned:sub(1, maxLength)
    end
    
    return cleaned
end

-- =====================================================
-- CLEANUP ON DISCONNECT
-- =====================================================

AddEventHandler('playerDropped', function(reason)
    local source = source
    local playerId = tostring(source)
    
    -- Cleanup tracking data
    playerRequestCounts[playerId] = nil
    suspiciousPlayers[playerId] = nil
    
    -- Cleanup cooldowns for this player
    for key, _ in pairs(playerLastAction) do
        if key:match('^' .. playerId .. '_') then
            playerLastAction[key] = nil
        end
    end
end)

-- =====================================================
-- PERIODIC CLEANUP (Prevent memory leak)
-- =====================================================

CreateThread(function()
    while true do
        Wait(300000) -- Every 5 minutes
        
        local currentTime = os.time()
        
        -- Clean up old cooldown data
        for key, lastTime in pairs(playerLastAction) do
            if currentTime - lastTime > 600 then -- 10 minutes old
                playerLastAction[key] = nil
            end
        end
        
        DebugPrint('Security: Cleaned up old cooldown data')
    end
end)

-- =====================================================
-- EXPORTS
-- =====================================================

exports('CheckRateLimit', CheckRateLimit)
exports('CheckCooldown', CheckCooldown)
exports('ValidateDistance', ValidateDistance)
exports('ValidateItemAmount', ValidateItemAmount)
exports('SanitizeNumber', SanitizeNumber)
exports('SanitizeString', SanitizeString)
