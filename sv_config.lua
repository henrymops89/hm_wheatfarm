-- sv_config.lua
-- SERVER-ONLY CONFIGURATION - HM Wheat Farm
-- ⚠️ WICHTIG: Diese Datei wird NUR server-side geladen!
-- ⚠️ Niemals sensitive Daten in config.lua (shared) packen!

SvConfig = {}

-- ═══════════════════════════════════════════════════════════════
-- DISCORD LOGGING
-- ═══════════════════════════════════════════════════════════════

SvConfig.Discord = {
    Enabled = false,                    -- Set true to enable Discord logging
    
    Webhook = '',                       -- Your Discord Webhook URL
    
    -- Welche Events loggen?
    LogEvents = {
        Harvest = true,                 -- Log wenn Spieler erntet
        AutoFarm = true,                -- Log Auto-Farm Aktionen
        MillProcess = true,             -- Log Mill Verarbeitung
        ProcessorProcess = true,        -- Log Processor Verarbeitung
        BakerySell = true,              -- Log Bakery Verkäufe
        RestaurantSell = true,          -- Log Restaurant Verkäufe
        RateLimit = true,               -- Log Rate Limit Violations
        DistanceCheat = true,           -- Log Distance Check Failures
        ToolBroke = true,               -- Log wenn Tools kaputt gehen
    },
    
    -- Embed Farben
    Colors = {
        Success = 3066993,              -- Grün
        Warning = 16776960,             -- Gelb
        Error = 15158332,               -- Rot
        Info = 3447003,                 -- Blau
    },
    
    -- Bot Informationen
    BotName = 'HM Wheat Farm Logger',
    BotAvatar = '',                     -- Optional: Bot Avatar URL
}

-- ═══════════════════════════════════════════════════════════════
-- ADMIN SETTINGS
-- ═══════════════════════════════════════════════════════════════

SvConfig.Admin = {
    -- ACE Permissions für Debug Commands
    DebugCommands = {
        RequireAce = true,
        AcePermission = 'hm_wheat.admin',  -- add_ace group.admin hm_wheat.admin allow
    },
    
    -- Wer kann Security resetten?
    SecurityCommands = {
        RequireAce = true,
        AcePermission = 'hm_wheat.admin',
    },
    
    -- Give Item Commands
    GiveItemCommands = {
        RequireAce = true,
        AcePermission = 'hm_wheat.admin',
    },
}

-- ═══════════════════════════════════════════════════════════════
-- BLACKLIST SYSTEM (Optional)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Blacklist = {
    Enabled = false,                    -- Set true to enable blacklist
    
    -- Blacklisted Spieler (by identifier)
    Players = {
        -- 'char1:1234567890',
        -- 'license:abc123def456',
    },
    
    -- Blacklist Message
    Message = 'Du wurdest vom Farming System ausgeschlossen.',
}

-- ═══════════════════════════════════════════════════════════════
-- ANTI-CHEAT SETTINGS (Enhanced Security)
-- ═══════════════════════════════════════════════════════════════

SvConfig.AntiCheat = {
    -- Ban Spieler nach X fehlgeschlagenen Versuchen?
    AutoBan = {
        Enabled = false,                -- Set true to enable auto-ban
        MaxViolations = 10,             -- Max violations before ban
        BanDuration = 86400,            -- Ban duration in seconds (24h)
        ResetAfter = 3600,              -- Reset violations after 1 hour
    },
    
    -- Welche Violations zählen?
    Violations = {
        RateLimit = true,               -- Rate Limit Exceed = Violation
        DistanceCheat = true,           -- Distance Check Fail = Violation
        InvalidData = true,             -- Invalid amounts etc = Violation
        ToolExploit = true,             -- Using without tool = Violation
    },
    
    -- Screenshot bei Verdacht? (requires screenshot-basic)
    Screenshot = {
        Enabled = false,                -- Set true to enable screenshots
        OnViolation = true,             -- Screenshot bei Violation
        WebhookUrl = '',                -- Discord Webhook für Screenshots
    },
}

-- ═══════════════════════════════════════════════════════════════
-- PERFORMANCE MONITORING (Optional)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Performance = {
    Enabled = false,                    -- Set true to enable performance monitoring
    
    LogInterval = 300,                  -- Log performance every 5 minutes
    WarnThreshold = 0.05,               -- Warn if > 0.05ms
    
    -- Webhook für Performance Alerts
    AlertWebhook = '',
}

-- ═══════════════════════════════════════════════════════════════
-- DATABASE SETTINGS (Optional - für künftige Features)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Database = {
    Enabled = false,                    -- Set true to enable database logging
    
    Type = 'mysql',                     -- mysql, oxmysql, ghmattimysql
    
    -- Welche Daten speichern?
    SaveData = {
        HarvestHistory = false,         -- Log alle Ernte-Aktionen
        ProcessHistory = false,         -- Log Verarbeitungen
        SalesHistory = false,           -- Log Verkäufe
        PlayerStats = false,            -- Spieler-Statistiken
        ToolUsage = false,              -- Tool-Nutzung tracken
    },
    
    -- Table Names (falls Database aktiviert)
    Tables = {
        Harvests = 'wheat_harvests',
        Processes = 'wheat_processes',
        Sales = 'wheat_sales',
        PlayerStats = 'wheat_player_stats',
    },
}

-- ═══════════════════════════════════════════════════════════════
-- ECONOMY SETTINGS (Server-Side)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Economy = {
    -- Multiplier für alle Preise (nur Server-Side änderbar!)
    GlobalPriceMultiplier = 1.0,        -- 1.0 = 100%, 1.5 = 150%, etc.
    
    -- Tax System (Optional)
    Tax = {
        Enabled = false,                -- Set true to enable tax
        Rate = 0.10,                    -- 10% tax
        Destination = 'society_gov',    -- Wohin geht die Steuer?
    },
    
    -- Price Caps (Anti-Exploit)
    PriceCaps = {
        MaxFlourPrice = 500,            -- Max price per flour
        MaxFriesPrice = 400,            -- Max price per fries
    },
}

-- ═══════════════════════════════════════════════════════════════
-- WEBHOOK TEMPLATES (für Discord Logging)
-- ═══════════════════════════════════════════════════════════════

SvConfig.WebhookTemplates = {
    Harvest = {
        title = '🌾 Ernte',
        description = 'Spieler **{player}** hat **{amount}x {crop}** geerntet',
        color = 3066993,  -- Grün
    },
    
    AutoFarm = {
        title = '🔄 Auto-Farm',
        description = 'Spieler **{player}** hat **{amount}x {crop}** auto-gefarmt',
        color = 3447003,  -- Blau
    },
    
    MillProcess = {
        title = '⚙️ Mühle',
        description = 'Spieler **{player}** hat **{input_amount}x {input_item}** zu **{output_amount}x {output_item}** verarbeitet',
        color = 3066993,
    },
    
    ProcessorProcess = {
        title = '🍟 Processor',
        description = 'Spieler **{player}** hat **{input_amount}x {input_item}** zu **{output_amount}x {output_item}** verarbeitet',
        color = 3066993,
    },
    
    BakerySell = {
        title = '💰 Bäckerei',
        description = 'Spieler **{player}** hat **{amount}x {item}** für **${price}** verkauft',
        color = 3066993,
    },
    
    RestaurantSell = {
        title = '🍔 Restaurant',
        description = 'Spieler **{player}** hat **{amount}x {item}** für **${price}** verkauft',
        color = 3066993,
    },
    
    RateLimit = {
        title = '⚠️ Rate Limit',
        description = 'Spieler **{player}** hat Rate Limit überschritten (**{count}** Requests)',
        color = 16776960,  -- Gelb
    },
    
    DistanceCheat = {
        title = '🚨 Distance Exploit',
        description = 'Spieler **{player}** versuchte von **{distance}m** entfernt zu interagieren',
        color = 15158332,  -- Rot
    },
    
    ToolBroke = {
        title = '🔨 Tool kaputt',
        description = 'Spieler **{player}** - Tool **{tool}** ist kaputt gegangen',
        color = 16776960,
    },
}

-- ═══════════════════════════════════════════════════════════════
-- EXPORTS FÜR ANDERE RESOURCES (Optional)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Exports = {
    Enabled = false,                    -- Set true to enable exports
    
    -- Andere Resources die auf Wheat-Daten zugreifen dürfen
    AllowedResources = {
        'hm_market',
        'hm_economy',
        'hm_statistics',
    },
}

-- ═══════════════════════════════════════════════════════════════
-- API KEYS (für künftige Features)
-- ═══════════════════════════════════════════════════════════════

SvConfig.ApiKeys = {
    -- Beispiel: Externe Market API
    MarketAPI = '',
    
    -- Beispiel: Weather API für Dynamic Pricing
    WeatherAPI = '',
    
    -- Beispiel: Statistics API
    StatsAPI = '',
}

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATIONS OVERRIDE (Server-Side)
-- ═══════════════════════════════════════════════════════════════

SvConfig.Notifications = {
    -- Use custom notification system?
    UseCustom = false,
    
    -- Custom notification handler
    CustomHandler = function(source, message, type)
        -- Beispiel: okokNotify
        -- TriggerClientEvent('okokNotify:Alert', source, 'Wheat Farm', message, 5000, type)
        
        -- Beispiel: mythic_notify
        -- TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = type, text = message })
        
        -- Fallback: Default
        TriggerClientEvent('wheat:notify', source, message, type)
    end,
}

-- ═══════════════════════════════════════════════════════════════
-- NOTES
-- ═══════════════════════════════════════════════════════════════

--[[
    WICHTIGE HINWEISE:
    
    1. Diese Datei ist SERVER-ONLY!
       → Wird NUR in fxmanifest.lua server_scripts geladen
       → Client hat KEINEN Zugriff darauf
    
    2. Sensitive Daten NIEMALS in config.lua!
       → config.lua ist shared_scripts (Client + Server)
       → Webhooks, API Keys, etc. NUR hier!
    
    3. Für Production:
       → SvConfig.Discord.Enabled = true
       → Webhook URL eintragen
       → Admin ACE Permissions setzen
    
    4. Für Testing/Development:
       → Alles auf false lassen
       → Keine Webhooks nötig
    
    5. Neue Features in der Zukunft:
       → Database Logging
       → Statistics System
       → Market Economy
       → Weather Effects
       → Company System
]]

print('^2[HM Wheat Farm] Server-Only Config loaded^0')