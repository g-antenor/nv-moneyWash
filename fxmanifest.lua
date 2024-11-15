fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Fivem MoneyWash by NiomeV2'
author 'NiomeV2'
version '1.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'locales/*.lua',
}

client_scripts {
  'client/targets/*.lua',
  'client/*.lua',
}

server_scripts {
  'server/*.lua',
  '@oxmysql/lib/MySQL.lua',
}
