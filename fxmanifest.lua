fx_version "cerulean"

description "Allows players to place certain objects"
author "Niklas Gschaider <niklas.gschaider@gschaider-systems.at>"

lua54 "yes"

games {
	"gta5",
}

escrow_ignore {
	"config.lua",
	"locales/*.lua",
}

ui_page "ui/index.html"

files {
	"ui/**",
}

client_scripts {
	"@NativeUI/NativeUI.lua",
	"@es_extended/locale.lua",
	"locales/*",
	"config.lua",
	"shared/*",
	"client/*",
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"@es_extended/locale.lua",
	"locales/*",
	"config.lua",
	"shared/*",
	"server/*",
}
