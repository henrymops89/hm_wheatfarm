RegisterNetEvent('wheat:processor:process', function()
    local source = source
    
    DebugPrint(string.format('🔧 PROCESSOR: Event received from player %d', source))
    
    -- Security: Rate limit
    if not CheckRateLimit(source) then
        DebugPrint('❌ PROCESSOR: Rate limit hit for player ' .. source)
        return
    end
    
    DebugPrint('✅ PROCESSOR: Rate limit OK')
    
    -- Guard: Processor disabled
    if not Config.Processor or not Config.Processor.enabled then
        DebugPrint('❌ PROCESSOR: Processor is disabled in config!')
        return
    end
    
    DebugPrint('✅ PROCESSOR: Config enabled')
    
    -- Security: Distance validation
    if not ValidateDistance(source, Config.Processor.location, 'processor process') then
        DebugPrint('❌ PROCESSOR: Distance validation failed for player ' .. source)
        return
    end
    
    DebugPrint('✅ PROCESSOR: Distance OK')
    
    local inputItem = Config.Processor.input.item
    local inputAmount = Config.Processor.input.amount
    local outputItem = Config.Processor.output.item
    local outputAmount = Config.Processor.output.amount
    
    DebugPrint(string.format('PROCESSOR: Input=%dx%s, Output=%dx%s', inputAmount, inputItem, outputAmount, outputItem))
    
    -- ✅ NEU: Server-seitige Item-Validierung!
    local hasEnough = GetItemCount(source, inputItem)
    
    DebugPrint(string.format('Processor: Player %d has %d x %s (needs %d)', source, hasEnough, inputItem, inputAmount))
    
    if hasEnough < inputAmount then
        TriggerClientEvent('wheat:notify', source, Lang:t('not_enough_potatoes', inputItem, inputAmount), 'error')
        DebugPrint('❌ PROCESSOR: Not enough items')
        return
    end
    
    DebugPrint('✅ PROCESSOR: Item validation OK')
    
    -- Remove input items
    local removed = RemoveItem(source, inputItem, inputAmount)
    
    if not removed then
        DebugPrint('❌ PROCESSOR: RemoveItem failed')
        TriggerClientEvent('wheat:notify', source, 'Fehler beim Entfernen der Items!', 'error')
        return
    end
    
    DebugPrint('✅ PROCESSOR: Items removed')
    
    -- Add output items
    local added = AddItem(source, outputItem, outputAmount)
    
    if not added then
        DebugPrint('❌ PROCESSOR: AddItem failed - refunding')
        -- Refund input items if output failed
        AddItem(source, inputItem, inputAmount)
        TriggerClientEvent('wheat:notify', source, 'Dein Inventar ist voll!', 'error')
        return
    end
    
    DebugPrint('✅ PROCESSOR: Items added successfully!')
    
    -- Log action
    LogAction('PROCESSOR', source, string.format(
        'Input: %dx %s | Output: %dx %s',
        inputAmount,
        inputItem,
        outputAmount,
        outputItem
    ))
    
    -- Notify success
    TriggerClientEvent('wheat:notify', source, Lang:t('produced_items', outputAmount, outputItem), 'success')
    
    DebugPrint('🎉 PROCESSOR: Complete!')
end)