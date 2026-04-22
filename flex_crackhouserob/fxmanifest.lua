fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'flex_crackhouserob'
description 'Crack house robbery'
version '0.0.1'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/config.lua',
    'shared/sv_shared.lua',
    'client/bridge/*.lua',
    'server/bridge/*.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

files {
    'locales/*.json',
    '**/config.lua',
}

dependencies {
    'ox_lib',
    'qbx_core'
}