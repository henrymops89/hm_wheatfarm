fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'henrymops89'
description 'HM Wheat Farm - Multi-Framework Wheat Farming System'
version '1.0.1'

shared_scripts {
    -- ⚠️ ESX USERS ONLY: Uncomment the line below if using ESX Legacy!
    -- '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'locale.lua'
}

files {
    'locales/*.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

-- Dependencies (at least one framework required)
dependencies {
    'ox_lib',
}

-- At least one framework required (choose one):
-- - qbx_core (for QBox)
-- - qb-core (for QBCore)
-- - es_extended (for ESX Legacy)

-- At least one inventory required (choose one):
-- - ox_inventory (recommended)
-- - qs-inventory
