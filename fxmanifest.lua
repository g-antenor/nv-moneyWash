fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Fivem MoneyWash by NiomeV2'
author 'NiomeV2'
version '1.0.0'

shared_scripts {
  '@qb-core/shared/locale.lua',
  '@ox_lib/init.lua',
  'locales/en.lua',
  'locales/*.lua',
  'config.lua',
}

client_scripts {
  'client/module/*.lua',
  'client/*.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua',
}
