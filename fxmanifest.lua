fx_version "bodacious"
author 'Wini'
game "gta5"
lua54 "yes"

shared_scripts {
    "@ox_lib/init.lua",
    "shared/config.lua"
}

client_scripts {
	"@vrp/lib/utils.lua",
	"client/*"
}
server_scripts {
	"@vrp/lib/utils.lua",
	"server/*"
}
