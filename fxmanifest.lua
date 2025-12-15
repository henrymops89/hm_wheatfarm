fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'henrymops89'
description 'HM Wheat Farm - Multi-Framework Economic System (FIXED v2.0.1)'
version '2.0.1'

-- =====================================================
-- SHARED SCRIPTS (FIXED LOADING ORDER - BUG #3, #9)
-- =====================================================

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'bridge.lua',
    
    -- ✅ FIXED: Load locale files BEFORE main.lua (BUG #3, #9)
    -- Change 'de' to your language: de, en, fr, es, pl, tr
    'locales/de.lua',  
    'locale.lua'
}

-- =====================================================
-- CLIENT SCRIPTS (Modular)
-- =====================================================

client_scripts {
    'client/utils.lua',     -- ✅ Utils FIRST (contains Notify, etc.)
    'client/main.lua',      -- Initialization
    'client/blips.lua',     -- Blip Management
    'client/farming.lua',   -- Farm System
    'client/mill.lua',      -- Mill System
    'client/processor.lua', -- Processor System
    'client/bakery.lua',    -- Bakery System
    'client/restaurant.lua' -- Restaurant System
}

-- =====================================================
-- SERVER SCRIPTS (Modular)
-- =====================================================

server_scripts {
    'server/utils.lua',     -- ✅ Utils FIRST (needed by others)
    'server/security.lua',  -- Security SECOND (needed by events)
    'server/main.lua',      -- Initialization
    'server/farming.lua',   -- Farm Events
    'server/mill.lua',      -- Mill Events
    'server/processor.lua', -- Processor Events
    'server/bakery.lua',    -- Bakery Events
    'server/restaurant.lua' -- Restaurant Events
}

-- =====================================================
-- DEPENDENCIES
-- =====================================================

dependencies {
    'ox_lib',
    -- ONE framework required (auto-detected):
    -- 'qbx_core' OR 'qb-core' OR 'es_extended'
    
    -- ONE inventory required (auto-detected):
    -- 'ox_inventory' OR 'qb-inventory'
}