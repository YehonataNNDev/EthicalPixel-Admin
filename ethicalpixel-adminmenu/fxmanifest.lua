fx_version 'cerulean'
games { 'gta5' }



ui_page "ui-build/index.html"

files {
  "ui-build/*",
}

client_scripts {
  '@unwind-rpc/client/cl_main.lua',
  'config.lua',
  'client/cl_*.lua',
}

server_scripts {
  '@unwind-rpc/server/sv_main.lua',
  'config.lua',
  'server/sv_*.lua',
}

