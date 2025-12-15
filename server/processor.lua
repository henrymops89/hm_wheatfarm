-- =====================================================
-- SERVER/PROCESSOR.LUA - Potato Processing Event Handler
-- Single Responsibility: Handle potato → fries processing
-- =====================================================

RegisterNetEvent('wheat:processor:process', function()
    local source = source
    
    -- Guard: Processor disabled
    if not Config.Processor or not Config.Processor.enabled then
        if Config.EnableLogging then
            print('[WheatFarm] Processor is disabled!')
        end
        return
    end
    
    -- Guard: Validate player
    if not ValidatePlayer(source) then
        return
    end
    
    -- Security: Cooldown check
    local onCooldown, remaining = IsOnCooldown(source, 'processor_process')
    if onCooldown then
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Player %s is on cooldown (%ds remaining)', 
                source, remaining))
        end
        Notify(source, Lang:t('notify_cooldown'), 'error')
        return
    end
    
    -- Set cooldown
    SetCooldown(source, 'processor_process')
    
    -- Validate has enough input items
    if not ValidateItemCount(source, Config.Processor.input.item, Config.Processor.input.amount) then
        Notify(source, string.format('Du brauchst mindestens %dx Kartoffeln!', Config.Processor.input.amount), 'error')
        return
    end
    
    -- Process transaction (remove potatoes, add fries)
    local success = ProcessTransaction(
        source,
        Config.Processor.input.item,
        Config.Processor.input.amount,
        Config.Processor.output.item,
        Config.Processor.output.amount
    )
    
    if success then
        -- Success notification
        TriggerClientEvent('wheat:processor:success', source, Config.Processor.output.amount)
        
        -- Log processing
        LogProcessing(
            source, 
            Config.Processor.input.item, 
            Config.Processor.input.amount, 
            Config.Processor.output.item, 
            Config.Processor.output.amount
        )
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] ✅ Player %s processed %dx potatoes → %dx fries', 
                source, Config.Processor.input.amount, Config.Processor.output.amount))
        end
    else
        -- Transaction failed (inventory full or error)
        Notify(source, 'Verarbeitung fehlgeschlagen! Inventar voll?', 'error')
        
        if Config.EnableLogging then
            print(string.format('[WheatFarm] Processor transaction failed for player %s', source))
        end
    end
end)

-- Client event registration (handled on client)
RegisterNetEvent('wheat:processor:success', function(amount)
    -- Registered on client side
end)