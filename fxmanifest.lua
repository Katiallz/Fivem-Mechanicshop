fx_version 'cerulean'
game 'gta5'

author 'Katiaallz'
description 'Loja de Mecânicos - ryze_mechanicshop'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    '@vrp/lib/utils.lua',
    'client-side/client.lua'
}

server_scripts {
    '@vrp/config/Item.lua',
    '@vrp/lib/utils.lua',
    'server-side/server.lua'
}
