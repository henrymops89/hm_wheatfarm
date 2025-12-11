-- =====================================================
-- CONFIG.LUA
-- =====================================================

Config = {}

-- Framework: "auto", "QBox", "QBCore", "ESX"
-- "auto" = Automatische Erkennung (empfohlen)
Config.Framework = "auto"

-- Sprache: "de", "en", "fr", "es", "pl", "tr"
Config.Language = "de"

-- Inventory System: "ox_inventory", "qs-inventory"
Config.Inventory = "ox_inventory"

-- Weizenfeld Location (eine große Stelle)
Config.FieldLocation = vector3(2229.68, 5577.36, 53.85)
Config.FieldRadius = 2.0 -- Radius in dem gepflügt werden kann (2 Meter)

-- Zeiten (in Millisekunden)
Config.PlowTime = 5000  -- 5 Sekunden zum Pflügen

-- Animation beim Pflügen
-- Optionen: "plant", "dig", "shovel", "hammer"
Config.Animation = "shovel"

-- Animation Dictionary
Config.Animations = {
    plant = {
        dict = 'amb@world_human_gardener_plant@male@base',
        clip = 'base',
        label = 'Pflanzen/Gärtnern',
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
        label = 'Graben/Bohren',
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
        label = 'Schaufeln',
        prop = {
            model = 'prop_tool_shovel',
            bone = 28422,
            coords = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        }
    },
    hammer = {
        dict = 'melee@large_wpn@streamed_core',
        clip = 'ground_attack_on_spot',
        label = 'Hämmern/Schlagen',
        prop = {
            model = 'prop_tool_sledgeham',
            bone = 28422,
            coords = vector3(0.0, 0.0, 0.0),
            rotation = vector3(0.0, 0.0, 0.0)
        }
    }
}

-- Items
Config.WheatItem = "wheat"

-- Benötigtes Werkzeug System
Config.RequiredTool = {
    enabled = false,
    item = "hoe",                    -- Hacke/Werkzeug Item
    
    -- Option 1: Mit Haltbarkeit (verbrauchbar)
    -- Option 3: Permanent (nie kaputt)
    toolType = "durability",         -- "durability" oder "permanent"
    
    -- Nur für toolType = "durability"
    durabilityPerUse = 1,            -- Haltbarkeit pro Nutzung
    maxDurability = 100,             -- Maximale Haltbarkeit
    breakChance = 5,                 -- 5% Chance zu brechen pro Nutzung (zusätzlich zu Haltbarkeit)
}

-- Ertrag
Config.MinWheatPerPlow = 1
Config.MaxWheatPerPlow = 3

-- Auto-Farm Modus
Config.AutoFarm = {
    enabled = true,                    -- Auto-Farm aktivieren/deaktivieren
    minWheat = 1,                      -- Minimaler Ertrag im Auto-Modus
    maxWheat = 2,                      -- Maximaler Ertrag im Auto-Modus (weniger als normal!)
    cooldown = 8000,                   -- Cooldown zwischen Auto-Farms (8 Sekunden)
    key = 38,                          -- E Taste (38 = E)
    confirmKey = 47,                   -- G Taste zum Bestätigen (47 = G)
}

-- Marker
Config.DrawDistance = 10.0  -- Marker Sichtweite
Config.MarkerType = 1
Config.MarkerSize = vector3(2.0, 2.0, 1.0)  -- Marker passt jetzt zum 2m Radius
Config.MarkerColor = {r = 255, g = 215, b = 0, a = 100}

-- Blip
Config.ShowBlip = true
Config.BlipSprite = 285
Config.BlipColor = 46
Config.BlipScale = 0.8

-- TextUI Einstellungen
Config.TextUI = {
    enabled = true,
    icon = 'wheat-awn',  -- Font Awesome Icon
    position = 'left-center'  -- "right-center", "left-center", "top-center", "bottom-center"
}

-- =====================================================
-- SECURITY / ANTI-CHEAT SETTINGS
-- =====================================================
Config.Security = {
    -- Rate Limiting (Anti-Spam)
    enabled = true,                              -- Aktiviere Security Features
    maxRequestsPerMinute = 20,                   -- Max. 20 Requests pro Minute pro Spieler
    
    -- Cooldown Enforcement
    enforceCooldown = true,                      -- Erzwinge Cooldown server-seitig
    minCooldownSeconds = 6,                      -- Min. 6 Sekunden zwischen Plows (PlowTime + 1s)
    
    -- Distance Check
    enforceDistance = true,                      -- Prüfe Entfernung zum Feld
    distanceTolerance = 1.0,                     -- +1 Meter Toleranz für Netzwerk-Latenz
    
    -- Punishment (optional)
    kickOnRateLimit = false,                     -- Kick bei Rate Limit Überschreitung
    kickOnDistanceExploit = false,               -- Kick bei Distance Exploit
    
    -- Logging
    logSuspiciousActivity = true,                -- Logge verdächtige Aktivitäten in Console
}

-- Debug / Logging
Config.EnableLogging = true  -- Console Logs für jede Aktion und Security Events
