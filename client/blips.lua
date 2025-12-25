-- =====================================================
-- CLIENT/BLIPS.LUA - Map Blips Management
-- Single Responsibility: Creating & managing map blips
-- =====================================================

local createdBlips = {}

-- =====================================================
-- CREATE BLIP FUNCTION
-- =====================================================

local function CreateLocationBlip(config, location, name)
    -- Guard: Blip disabled
    if not config.enabled then return nil end
    
    -- Guard: No location
    if not location then 
        print('^3[WheatFarm] Cannot create blip: No location provided^7')
        return nil 
    end
    
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    
    -- Configure blip
    SetBlipSprite(blip, config.sprite or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, config.scale or 0.8)
    SetBlipColour(blip, config.color or 1)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(config.name or name or "Wheat Farm")
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- =====================================================
-- INITIALIZE ALL BLIPS
-- =====================================================

CreateThread(function()
    Wait(1000) -- Wait for config to load
    
    -- Farm Blips
    if Config.Farms then
        for i, farm in ipairs(Config.Farms) do
            if farm.enabled and farm.blip then
                local cropName = Lang:t('crop_' .. farm.crop) -- ✅ Localized
                
                local blip = CreateLocationBlip(farm.blip, farm.location, cropName .. " Farm")
                
                if blip then
                    table.insert(createdBlips, blip)
                    DebugPrint('Created farm blip: ' .. farm.id)
                end
            end
        end
    end
    
    -- Mill Blip
    if Config.Mill and Config.Mill.enabled and Config.Mill.blip then
        local blip = CreateLocationBlip(Config.Mill.blip, Config.Mill.location, "Mühle")
        
        if blip then
            table.insert(createdBlips, blip)
            DebugPrint('Created mill blip')
        end
    end
    
    -- Processor Blip
    if Config.Processor and Config.Processor.enabled and Config.Processor.blip then
        local blip = CreateLocationBlip(Config.Processor.blip, Config.Processor.location, "Verarbeitung")
        
        if blip then
            table.insert(createdBlips, blip)
            DebugPrint('Created processor blip')
        end
    end
    
    -- Bakery Blip
    if Config.Bakery and Config.Bakery.enabled and Config.Bakery.blip then
        local blip = CreateLocationBlip(Config.Bakery.blip, Config.Bakery.location, "Bäckerei")
        
        if blip then
            table.insert(createdBlips, blip)
            DebugPrint('Created bakery blip')
        end
    end
    
    -- Restaurant Blip
    if Config.Restaurant and Config.Restaurant.enabled and Config.Restaurant.blip then
        local blip = CreateLocationBlip(Config.Restaurant.blip, Config.Restaurant.location, "Restaurant")
        
        if blip then
            table.insert(createdBlips, blip)
            DebugPrint('Created restaurant blip')
        end
    end
    
    print('^2[WheatFarm] Created ' .. #createdBlips .. ' blips^7')
end)

-- =====================================================
-- CLEANUP ON RESOURCE STOP
-- =====================================================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Remove all created blips
    for _, blip in ipairs(createdBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    
    DebugPrint('Removed ' .. #createdBlips .. ' blips')
end)