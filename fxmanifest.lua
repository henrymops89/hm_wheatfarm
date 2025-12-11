fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Your Name'
description 'Multi-Framework Wheat Farm System (QBox Native, QBCore, ESX)'
version '2.0.0'

shared_scripts {
   -- '@es_extended/imports.lua',  -- ESX Import hinzufügen
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

-- Optional dependencies (only needed if using specific inventory)
-- ox_inventory or qs-inventory
