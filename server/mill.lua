-- =====================================================
-- SERVER/MILL.LUA - Mill Processing Event Handler
-- Single Responsibility: Handle wheat → flour processing
-- =====================================================

-- =====================================================
-- MILL PROCESSING EVENT HANDLER
-- =====================================================

RegisterNetEvent('wheat:mill:process', function()
    local source = source
    
    -- Guard: Mill disabled
    if not Config.Mill or not Config.Mill.enabled then
        if Config.EnableLogging then
            print('[WheatFarm] Mill is disabled!')
        end
        return
    end
    
    -- Guard: Validate player
    if not ValidatePlayer(source) then
        return
    end
    
    -- Security Checks
    local securityPassed, reason = PerformSecurityChecks(
        source, 
        'mill_process', 
        Config.Mill.location, 
        Config.Mill.radius
    )
    
    if not securityPassed then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Mill security check failed for player %s: %s', 
                source, reason))
        end
        return
    end
    
    -- Validate has enough input items
    if not ValidateItemCount(source, Config.Mill.input.item, Config.Mill.input.amount) then
        Notify(source, string.format('Du brauchst mindestens %dx Weizen!', Config.Mill.input.amount), 'error')
        return
    end
    
    -- Process transaction (remove wheat, add flour)
    local success = ProcessTransaction(
        source,
        Config.Mill.input.item,
        Config.Mill.input.amount,
        Config.Mill.output.item,
        Config.Mill.output.amount
    )
    
    if success then
        -- Success notification
        TriggerClientEvent('wheat:mill:success', source, Config.Mill.output.amount)
        
        -- Log processing
        LogProcessing(
            source, 
            Config.Mill.input.item, 
            Config.Mill.input.amount, 
            Config.Mill.output.item, 
            Config.Mill.output.amount
        )
    else
        -- Transaction failed (inventory full or error)
        Notify(source, 'Verarbeitung fehlgeschlagen! Inventar voll?', 'error')
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Mill transaction failed for player %s', source))
        end
    end
end)

-- =====================================================
-- UTILITY: CALCULATE MILL BATCH
-- =====================================================

-- Calculate how many batches player can process
function CalculateMillBatches(source)
    -- Guard: Mill disabled
    if not Config.Mill or not Config.Mill.enabled then
        return 0
    end
    
    local wheatCount = GetItemCount(source, Config.Mill.input.item)
    local possibleBatches = math.floor(wheatCount / Config.Mill.input.amount)
    
    -- Limit by max batch size if configured
    if Config.Mill.maxBatchSize then
        local maxBatches = math.floor(Config.Mill.maxBatchSize / Config.Mill.input.amount)
        possibleBatches = math.min(possibleBatches, maxBatches)
    end
    
    return possibleBatches
end

-- =====================================================
-- ADVANCED: BATCH PROCESSING (Future Feature)
-- =====================================================

-- Process multiple batches at once
RegisterNetEvent('wheat:mill:processBatch', function(batchCount)
    local source = source
    
    -- Guard: Mill disabled
    if not Config.Mill or not Config.Mill.enabled then
        return
    end
    
    -- Guard: Validate player
    if not ValidatePlayer(source) then
        return
    end
    
    -- Validate batch count
    batchCount = tonumber(batchCount)
    if not batchCount or batchCount < 1 then
        Notify(source, 'Ungültige Batch-Anzahl!', 'error')
        return
    end
    
    -- Security Checks
    local securityPassed, reason = PerformSecurityChecks(
        source, 
        'mill_batch', 
        Config.Mill.location, 
        Config.Mill.radius
    )
    
    if not securityPassed then
        return
    end
    
    -- Calculate total required items
    local totalWheatNeeded = Config.Mill.input.amount * batchCount
    local totalFlourOutput = Config.Mill.output.amount * batchCount
    
    -- Validate has enough wheat
    if not ValidateItemCount(source, Config.Mill.input.item, totalWheatNeeded) then
        Notify(source, string.format('Du brauchst %dx %s!', totalWheatNeeded, Config.Mill.input.item), 'error')
        return
    end
    
    -- Validate can carry output
    if not ValidateCanCarry(source, Config.Mill.output.item, totalFlourOutput) then
        return
    end
    
    -- Process transaction
    local success = ProcessTransaction(
        source,
        Config.Mill.input.item,
        totalWheatNeeded,
        Config.Mill.output.item,
        totalFlourOutput
    )
    
    if success then
        TriggerClientEvent('wheat:mill:success', source, totalFlourOutput)
        
        LogProcessing(
            source, 
            Config.Mill.input.item, 
            totalWheatNeeded, 
            Config.Mill.output.item, 
            totalFlourOutput
        )
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Player %s processed %d batches', source, batchCount))
        end
    else
        Notify(source, 'Batch-Verarbeitung fehlgeschlagen!', 'error')
    end
end)

-- =====================================================
-- DEBUG COMMANDS
-- =====================================================

if Config.EnableLogging then
    -- Force mill processing (admin/testing)
    RegisterCommand('wheatmill', function(source, args, rawCommand)
        if source == 0 then
            print('[WheatFarm] This command must be run in-game')
            return
        end
        
        local batchCount = tonumber(args[1]) or 1
        
        -- Calculate requirements
        local totalWheatNeeded = Config.Mill.input.amount * batchCount
        local totalFlourOutput = Config.Mill.output.amount * batchCount
        
        -- Bypass security for testing
        if ValidateItemCount(source, Config.Mill.input.item, totalWheatNeeded) then
            if ValidateCanCarry(source, Config.Mill.output.item, totalFlourOutput) then
                local success = ProcessTransaction(
                    source,
                    Config.Mill.input.item,
                    totalWheatNeeded,
                    Config.Mill.output.item,
                    totalFlourOutput
                )
                
                if success then
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {0, 255, 0},
                        args = {"[WheatFarm]", string.format("✅ Processed %dx batches (%dx flour)", batchCount, totalFlourOutput)}
                    })
                else
                    TriggerClientEvent('chat:addMessage', source, {
                        color = {255, 0, 0},
                        args = {"[WheatFarm]", "❌ Processing failed!"}
                    })
                end
            else
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 0, 0},
                    args = {"[WheatFarm]", "❌ Inventory full!"}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"[WheatFarm]", string.format("❌ Need %dx wheat!", totalWheatNeeded)}
            })
        end
    end, false)
    
    -- Check mill status
    RegisterCommand('wheatmillstatus', function(source, args, rawCommand)
        if source == 0 then
            -- Console
            print('=== Mill Status ===')
            print('Enabled: ' .. tostring(Config.Mill.enabled))
            print('Input: ' .. Config.Mill.input.amount .. 'x ' .. Config.Mill.input.item)
            print('Output: ' .. Config.Mill.output.amount .. 'x ' .. Config.Mill.output.item)
            print('Processing Time: ' .. Config.Mill.processingTime .. 'ms')
            print('==================')
        else
            -- Player
            local batches = CalculateMillBatches(source)
            local wheatCount = GetItemCount(source, Config.Mill.input.item)
            
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 255},
                args = {"[WheatFarm]", "=== Mill Status ==="}
            })
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 255},
                args = {"", string.format("Your wheat: %d", wheatCount)}
            })
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 255},
                args = {"", string.format("Possible batches: %d", batches)}
            })
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 255},
                args = {"", string.format("Recipe: %dx %s → %dx %s", 
                    Config.Mill.input.amount, 
                    Config.Mill.input.item,
                    Config.Mill.output.amount, 
                    Config.Mill.output.item)}
            })
        end
    end, false)
end

-- =====================================================
-- EXPORTS
-- =====================================================

exports('CalculateMillBatches', CalculateMillBatches)