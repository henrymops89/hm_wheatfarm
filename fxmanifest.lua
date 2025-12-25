fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'henrymops89'
description 'HM Wheat Farm - Multi-Framework Economic System with Modular Bridge'
version '2.1.1'

-- =====================================================
-- SHARED SCRIPTS
-- =====================================================

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    
    -- ✅ NEW: Modular Bridge System
    'bridge/framework.lua',
    'bridge/inventory.lua',
    'bridge/main.lua',
    
    -- ✅ Localization (CRITICAL: locale.lua MUST load FIRST!)
    'locale.lua',        -- ✅ 1. Define Locale class and Locales table
    --'locales/de.lua',    -- ✅ 2. Then load languages
    'locales/en.lua',
    'locales/fr.lua',
    'locales/es.lua',
    'locales/pl.lua',
   'locales/tr.lua',
}

-- =====================================================
-- CLIENT SCRIPTS
-- =====================================================

client_scripts {
    'client/utils.lua',
    'client/main.lua',
    'client/blips.lua',
    'client/farming.lua',
    'client/mill.lua',
    'client/processor.lua',
    'client/bakery.lua',
    'client/restaurant.lua'
}

-- =====================================================
-- SERVER SCRIPTS
-- =====================================================

server_scripts {
    'server/utils.lua',
    'server/security.lua',
    'server/main.lua',
    'server/farming.lua',
    'server/mill.lua',
    'server/processor.lua',
    'server/bakery.lua',
    'server/restaurant.lua'
}

-- =====================================================
-- DEPENDENCIES
-- =====================================================

dependencies {
    'ox_lib',
    -- ONE framework required (auto-detected):
    -- 'qbx_core' OR 'qb-core' OR 'es_extended'
    
    -- ONE inventory required (auto-detected):
    -- 'ox_inventory' OR 'qs-inventory' OR 'tgiann-inventory' OR 'qb-inventory'
}

-- =====================================================
-- METADATA
-- =====================================================

files {
    'bridge/README.md'
}
