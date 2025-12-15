-- =====================================================
-- CONFIG.LUA - Wheat Economy System (FIXED VERSION)
-- Farm → Mill → Bakery Chain
-- =====================================================

Config = {}

-- =====================================================
-- GENERAL SETTINGS
-- =====================================================

Config.Language = "de"        -- de, en, fr, es, pl, tr
Config.EnableLogging = true   -- Debug logs in console

-- =====================================================
-- ANIMATIONS
-- =====================================================

Config.Animations = {
    plant = {
        dict = 'amb@world_human_gardener_plant@male@base',
        clip = 'base',
        prop = {
            model = 'prop_tool_shovel',
            bone = 28422,
            coords = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        }
    },
    dig = {
        dict = 'amb@world_human_const_drill@male@drill@base',
        clip = 'base',
        prop = {
            model = 'prop_tool_pickaxe',
            bone = 28422,
            coords = vector3(0.08, 0.0, -0.05),
            rotation = vector3(90.0, 0.0, 0.0)
        }
    },
    shovel = {
        dict = 'random@burial',
        clip = 'a_burial',
        prop = {
            model = 'prop_tool_shovel',
            bone = 28422,
            coords = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        }
    },
}

-- =====================================================
-- TOOLS
-- =====================================================

Config.Tools = {
    hoe = {
        item = "hoe",
        label = "Hacke",
        durabilityPerUse = 1,
        maxDurability = 100,
        breakChance = 5,
    },
    shovel = {
        item = "shovel",
        label = "Schaufel",
        durabilityPerUse = 2,
        maxDurability = 80,
        breakChance = 8,
    },
}

-- =====================================================
-- CROPS
-- =====================================================

Config.Crops = {
    wheat = {
        name = "Weizen",
        item = "wheat",
        harvestTime = 5000,
        minYield = 1,
        maxYield = 3,
        autoFarmMin = 1,
        autoFarmMax = 2,
        requiredTool = "hoe",
        blipColor = 46,
    },
    potato = {
        name = "Kartoffeln",
        item = "potato",
        harvestTime = 4000,
        minYield = 2,
        maxYield = 4,
        autoFarmMin = 2,
        autoFarmMax = 3,
        requiredTool = "shovel",
        blipColor = 20,
    },
}

-- =====================================================
-- FARMS (FIXED RADIUS - BUG #4)
-- =====================================================

Config.FarmDefaults = {
    animation = "shovel",
    showMarker = true,
    drawDistance = 15.0,
    markerType = 1,
    markerColor = {r = 255, g = 215, b = 0, a = 100},
    textUI = {
        enabled = true,
        icon = 'wheat-awn',
        position = 'left-center'
    },
    autoFarm = {
        enabled = true,
        key = 38,           -- E
        confirmKey = 47,    -- G
        cooldown = 8000,
    },
}

Config.Farms = {
    {
        id = "wheat_farm",
        enabled = true,
        crop = "wheat",
        location = vector3(2229.68, 5577.36, 53.85),
        radius = 10.0,  -- ✅ FIXED: Was 2.0, now 10.0 (BUG #4)
        blip = {
            enabled = true,
            sprite = 285,
            scale = 0.8,
        },
        marker = {
            size = vector3(4.0, 4.0, 1.0),
        },
    },
    {
        id = "potato_farm",
        enabled = true,
        crop = "potato",
        location = vector3(2214.38, 5577.54, 53.87),
        radius = 10.0,  -- ✅ FIXED: Was 2.0, now 10.0
        blip = {
            enabled = true,
            sprite = 285,
            scale = 0.8,
        },
        marker = {
            size = vector3(4.0, 4.0, 1.0),
        },
    },
}

-- =====================================================
-- MILL (FIXED RADIUS & PED COORDS - BUG #5, #14)
-- =====================================================

Config.Mill = {
    enabled = true,
    location = vector3(2452.87, 4960.77, 46.81),
    radius = 10.0,  -- ✅ FIXED: Was 2.5, now 10.0 (BUG #5)
    
    input = {
        item = "wheat",
        amount = 10,
    },
    output = {
        item = "flour",
        amount = 5,
    },
    
    processingTime = 8000,
    
    animation = {
        dict = 'anim@heists@box_carry@',
        clip = 'idle',
        prop = {
            model = 'prop_cs_sack_01',
            bone = 28422,
            coords = vector3(0.0, 0.0, -0.3),
            rotation = vector3(0.0, 0.0, 0.0)
        }
    },
    
    ped = {
        enabled = true,
        model = 's_m_m_gaffer_01',
        coords = vector3(2452.11, 4960.86, 45.81),  -- ✅ FIXED: Was 44.52 (underground!), now 45.81 (BUG #14)
        heading = 234.0,
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        frozen = true,
        invincible = true,
        blockevents = true,
    },
    
    interactionType = "ox_target",  -- "3dtext", "ox_target", "qb-target"
    
    text3d = {
        text = "[E] Weizen verarbeiten",
        distance = 5.0,  -- ✅ IMPROVED: Was 2.5, now 5.0
        font = 4,
        scale = 0.35,
    },
    
    target = {
        distance = 3.0,  -- ✅ IMPROVED: Was 2.5, now 3.0
        icon = 'fa-solid fa-wheat-awn',
        label = 'Weizen verarbeiten',
        size = vec3(2, 2, 2),
        rotation = 45,
    },
    
    blip = {
        enabled = true,
        sprite = 478,
        color = 5,
        scale = 0.8,
        name = "Mühle"
    },
}

-- =====================================================
-- BAKERY (FIXED RADIUS & PED COORDS - BUG #6, #14)
-- =====================================================

Config.Bakery = {
    enabled = true,
    location = vector3(-285.44, 6226.90, 31.49),
    radius = 10.0,  -- ✅ FIXED: Was 2.5, now 10.0 (BUG #6)
    
    item = "flour",
    pricePerItem = 175,
    maxSellAmount = 100,
    
    dynamicPricing = {
        enabled = true,
        peakHourMultiplier = 1.2,
        peakHours = {7, 8, 12, 13, 18, 19},
    },
    
    ped = {
        enabled = true,
        model = 's_m_m_autoshop_01',
        coords = vector3(-285.44, 6226.90, 30.49),  -- ✅ CHECKED: 1m below location (correct)
        heading = 270.0,
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        frozen = true,
        invincible = true,
        blockevents = true,
    },
    
    interactionType = "ox_target",  -- "3dtext", "ox_target", "qb-target"
    
    text3d = {
        text = "[E] Mehl verkaufen",
        distance = 5.0,  -- ✅ IMPROVED: Was 2.5, now 5.0
        font = 4,
        scale = 0.35,
    },
    
    target = {
        distance = 3.0,  -- ✅ IMPROVED: Was 2.5, now 3.0
        icon = 'fa-solid fa-dollar-sign',
        label = 'Mehl verkaufen',
        size = vec3(2, 2, 2),
        rotation = 45,
    },
    
    blip = {
        enabled = true,
        sprite = 106,
        color = 46,
        scale = 0.8,
        name = "Bäckerei"
    },
}

-- =====================================================
-- PROCESSOR (Potato → Fries Processing)
-- =====================================================

Config.Processor = {
    enabled = true,
    location = vector3(2194.63, 5595.23, 53.76),
    radius = 10.0,
    
    input = {
        item = "potato",
        amount = 8,
    },
    output = {
        item = "fries",
        amount = 4,
    },
    
    processingTime = 10000,
    cooldown = 5000,
    
    animation = {
        dict = 'anim@heists@box_carry@',
        clip = 'idle',
        prop = {
            model = 'prop_cs_cardbox_01',
            bone = 28422,
            coords = vector3(0.0, 0.0, -0.3),
            rotation = vector3(0.0, 0.0, 0.0)
        }
    },
    
    ped = {
        enabled = true,
        model = 's_m_y_chef_01',
        coords = vector3(2194.63, 5595.23, 52.76),
        heading = 180.0,
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        frozen = true,
        invincible = true,
        blockevents = true,
    },
    
    interactionType = "ox_target",  -- "3dtext", "ox_target", "qb-target"
    
    text3d = {
        text = "[E] Kartoffeln verarbeiten",
        distance = 5.0,
        font = 4,
        scale = 0.35,
    },
    
    target = {
        distance = 3.0,
        icon = 'fa-solid fa-fire-burner',
        label = 'Kartoffeln verarbeiten',
        size = vec3(2, 2, 2),
        rotation = 45,
    },
    
    blip = {
        enabled = true,
        sprite = 478,
        color = 20,
        scale = 0.8,
        name = "Frittenbude"
    },
}

-- =====================================================
-- RESTAURANT (Fries Selling)
-- =====================================================

Config.Restaurant = {
    enabled = true,
    location = vector3(-170.99, 6381.32, 31.49),  -- ✅ NEW: Paleto Bay - Cluckin' Bell Area
    radius = 10.0,
    
    item = "fries",
    pricePerItem = 125,
    maxSellAmount = 100,
    cooldown = 5000,
    
    dynamicPricing = {
        enabled = true,
        peakHourMultiplier = 1.3,
        peakHours = {11, 12, 13, 17, 18, 19, 20},
    },
    
    ped = {
        enabled = true,
        model = 's_m_y_busboy_01',
        coords = vector3(-170.99, 6381.32, 30.49),  -- ✅ 1m below location (correct)
        heading = 135.0,
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        frozen = true,
        invincible = true,
        blockevents = true,
    },
    
    interactionType = "3dtext",  -- "3dtext", "ox_target", "qb-target"
    
    text3d = {
        text = "[E] Pommes verkaufen",
        distance = 5.0,
        font = 4,
        scale = 0.35,
    },
    
    target = {
        distance = 3.0,
        icon = 'fa-solid fa-dollar-sign',
        label = 'Pommes verkaufen',
        size = vec3(2, 2, 2),
        rotation = 45,
    },
    
    blip = {
        enabled = true,
        sprite = 106,
        color = 47,
        scale = 0.8,
        name = "Fast-Food Restaurant"
    },
}

-- =====================================================
-- SECURITY (IMPROVED - BUG #11)
-- =====================================================

Config.Security = {
    enabled = true,
    maxRequestsPerMinute = 20,
    enforceCooldown = true,
    minCooldownSeconds = 6,
    enforceDistance = true,
    distanceTolerance = 2.0,  -- ✅ FIXED: Was 5.0 (too generous!), now 2.0 (BUG #11)
    kickOnRateLimit = false,
    kickOnDistanceExploit = false,
    logSuspiciousActivity = true,
}