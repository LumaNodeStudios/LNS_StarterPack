fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'LumaNode Studios'
description 'LumaNode Studios - Starter Pack System'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'LUA_Shared/*.lua'
}

client_scripts {
    'LUA_Client/*.lua'
}

server_scripts {
    'LUA_Server/*.lua'
}