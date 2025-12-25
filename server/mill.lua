-- =====================================================
-- SERVER/MILL.LUA - Mill Processing (Server)
-- Handles wheat → flour conversion
-- =====================================================

RegisterNetEvent('wheat:mill:process', function()
    local source = source
    
    -- Security: Rate limit
    if not CheckRateLimit(source) then
        return
    end
    
    -- Guard: Mill disabled
    if not Config.Mill or not Config.Mill.enabled then
        return
    end
    
    -- Security: Distance validation
    if not ValidateDistance(source, Config.Mill.location, 'mill process') then
        return
    end
    
    local inputItem = Config.Mill.input.item
    local inputAmount = Config.Mill.input.amount
    local outputItem = Config.Mill.output.item
    local outputAmount = Config.Mill.output.amount
    
    -- Validate player has enough input items
    if not ValidateItemAmount(source, inputItem, inputAmount, 'mill process') then
        return
    end
    
    -- Remove input items
    local removed = RemoveItem(source, inputItem, inputAmount)
    
    if not removed then
        NotifyPlayer(source, 'Fehler beim Entfernen der Items!', 'error')
        return
    end
    
    -- Add output items
    local added = AddItem(source, outputItem, outputAmount)
    
    if not added then
        -- Refund input items if output failed
        AddItem(source, inputItem, inputAmount)
        NotifyPlayer(source, 'Dein Inventar ist voll!', 'error')
        return
    end
    
    -- Log action
    LogAction('MILL_PROCESS', source, string.format(
        'Input: %dx %s | Output: %dx %s',
        inputAmount,
        inputItem,
        outputAmount,
        outputItem
    ))
    
    -- Notify success
    TriggerClientEvent('wheat:mill:success', source, outputAmount)
end)