fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dein Name'
description 'Einfaches Weizenfeld System für QBox'
version '1.0.0'

shared_scripts {
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

dependencies {
    'qbx_core',
    'ox_inventory',
    'ox_lib'
}