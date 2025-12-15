-- =====================================================
-- CLIENT/BLIPS.LUA - Blip Management
-- Single Responsibility: Create and manage all blips
-- =====================================================

local createdBlips = {}

-- =====================================================
-- HELPER: CREATE BLIP
-- =====================================================

-- Single function to create any blip (DRY Principle!)
local function createBlip(coords, sprite, color, scale, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

-- =====================================================
-- FARM BLIPS
-- =====================================================

local function createFarmBlips()
    -- Guard: No farms configured
    if not Config.Farms or type(Config.Farms) ~= 'table' then
        DebugPrint('No farms configured for blips')
        return
    end
    
    for _, farmConfig in pairs(Config.Farms) do
        -- Guard: Farm disabled or blip disabled
        if not farmConfig.enabled then goto continue end
        if not farmConfig.blip or not farmConfig.blip.enabled then goto continue end
        
        -- Get crop config for color and name
        local cropConfig = Config.Crops[farmConfig.crop]
        
        -- Guard: Invalid crop
        if not cropConfig then
            print('^3[WheatFarm] WARNING: Invalid crop "' .. tostring(farmConfig.crop) .. '" for farm "' .. farmConfig.id .. '"^7')
            goto continue
        end
        
        -- Create blip
        local blipName = cropConfig.name .. '-Feld'
        local blip = createBlip(
            farmConfig.location,
            farmConfig.blip.sprite,
            cropConfig.blipColor,
            farmConfig.blip.scale,
            blipName
        )
        
        -- Store for cleanup
        table.insert(createdBlips, {
            id = 'farm_' .. farmConfig.id,
            blip = blip
        })
        
        DebugPrint('Created blip for farm: ' .. farmConfig.id)
        
        ::continue::
    end
end

-- =====================================================
-- MILL BLIP
-- =====================================================

local function createMillBlip()
    -- Guard: Mill disabled
    if not Config.Mill or not Config.Mill.enabled then
        DebugPrint('Mill disabled, skipping blip')
        return
    end
    
    -- Guard: Blip disabled
    if not Config.Mill.blip or not Config.Mill.blip.enabled then
        DebugPrint('Mill blip disabled')
        return
    end
    
    -- Create blip
    local blip = createBlip(
        Config.Mill.location,
        Config.Mill.blip.sprite,
        Config.Mill.blip.color,
        Config.Mill.blip.scale,
        Config.Mill.blip.name
    )
    
    -- Store for cleanup
    table.insert(createdBlips, {
        id = 'mill',
        blip = blip
    })
    
    DebugPrint('Created blip for mill')
end

-- =====================================================
-- BAKERY BLIP
-- =====================================================

local function createBakeryBlip()
    -- Guard: Bakery disabled
    if not Config.Bakery or not Config.Bakery.enabled then
        DebugPrint('Bakery disabled, skipping blip')
        return
    end
    
    -- Guard: Blip disabled
    if not Config.Bakery.blip or not Config.Bakery.blip.enabled then
        DebugPrint('Bakery blip disabled')
        return
    end
    
    -- Create blip
    local blip = createBlip(
        Config.Bakery.location,
        Config.Bakery.blip.sprite,
        Config.Bakery.blip.color,
        Config.Bakery.blip.scale,
        Config.Bakery.blip.name
    )
    
    -- Store for cleanup
    table.insert(createdBlips, {
        id = 'bakery',
        blip = blip
    })
    
    DebugPrint('Created blip for bakery')
end

-- =====================================================
-- PROCESSOR BLIP
-- =====================================================

local function createProcessorBlip()
    -- Guard: Processor disabled
    if not Config.Processor or not Config.Processor.enabled then
        DebugPrint('Processor disabled, skipping blip')
        return
    end
    
    -- Guard: Blip disabled
    if not Config.Processor.blip or not Config.Processor.blip.enabled then
        DebugPrint('Processor blip disabled')
        return
    end
    
    -- Create blip
    local blip = createBlip(
        Config.Processor.location,
        Config.Processor.blip.sprite,
        Config.Processor.blip.color,
        Config.Processor.blip.scale,
        Config.Processor.blip.name
    )
    
    -- Store for cleanup
    table.insert(createdBlips, {
        id = 'processor',
        blip = blip
    })
    
    DebugPrint('Created blip for processor')
end

-- =====================================================
-- RESTAURANT BLIP
-- =====================================================

local function createRestaurantBlip()
    -- Guard: Restaurant disabled
    if not Config.Restaurant or not Config.Restaurant.enabled then
        DebugPrint('Restaurant disabled, skipping blip')
        return
    end
    
    -- Guard: Blip disabled
    if not Config.Restaurant.blip or not Config.Restaurant.blip.enabled then
        DebugPrint('Restaurant blip disabled')
        return
    end
    
    -- Create blip
    local blip = createBlip(
        Config.Restaurant.location,
        Config.Restaurant.blip.sprite,
        Config.Restaurant.blip.color,
        Config.Restaurant.blip.scale,
        Config.Restaurant.blip.name
    )
    
    -- Store for cleanup
    table.insert(createdBlips, {
        id = 'restaurant',
        blip = blip
    })
    
    DebugPrint('Created blip for restaurant')
end

-- =====================================================
-- INITIALIZATION
-- =====================================================

CreateThread(function()
    -- Wait for framework to be ready
    local attempts = 0
    while not IsFrameworkReady() and attempts < 50 do
        Wait(100)
        attempts = attempts + 1
    end
    
    if not IsFrameworkReady() then
        print('^1[WheatFarm] Blips: Framework not ready!^7')
        return
    end
    
    Wait(1000) -- Extra safety for game load
    
    -- Create all blips
    createFarmBlips()
    createMillBlip()
    createProcessorBlip()
    createBakeryBlip()
    createRestaurantBlip()
    
    print('[WheatFarm] ✅ Blips created: ' .. #createdBlips)
end)

-- =====================================================
-- CLEANUP
-- =====================================================

local function cleanupBlips()
    for _, blipData in pairs(createdBlips) do
        if blipData.blip and DoesBlipExist(blipData.blip) then
            RemoveBlip(blipData.blip)
            DebugPrint('Removed blip: ' .. blipData.id)
        end
    end
    
    createdBlips = {}
    print('[WheatFarm] Blips cleaned up')
end

-- Cleanup on resource stop
AddEventHandler('wheat:cleanup', function()
    cleanupBlips()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    cleanupBlips()
end)

-- =====================================================
-- EXPORTS (for external use)
-- =====================================================

exports('GetCreatedBlips', function()
    return createdBlips
end)

exports('RefreshBlips', function()
    cleanupBlips()
    Wait(100)
    createFarmBlips()
    createMillBlip()
    createProcessorBlip()
    createBakeryBlip()
    createRestaurantBlip()
end)