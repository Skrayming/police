fx_version 'adamant'
game 'gta5'
lua54 'yes'

escrow_ignore {
    'config.lua',
	"lib/RMenu.lua",
	"lib/menu/RageUI.lua",
	"lib/menu/Menu.lua",
	"lib/menu/MenuController.lua",
	"lib/components/*.lua",
	"lib/menu/elements/*.lua",
	"lib/menu/items/*.lua",
	"lib/menu/panels/*.lua",
	"lib/menu/panels/*.lua",
	"lib/menu/windows/*.lua",
	'data/vehicle_name.lua',
	'client/*.lua',
	'menu/*.lua',
}

shared_script 'config.lua'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server/*.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	"lib/RMenu.lua",
	"lib/menu/RageUI.lua",
	"lib/menu/Menu.lua",
	"lib/menu/MenuController.lua",
	"lib/components/*.lua",
	"lib/menu/elements/*.lua",
	"lib/menu/items/*.lua",
	"lib/menu/panels/*.lua",
	"lib/menu/panels/*.lua",
	"lib/menu/windows/*.lua",
	'data/vehicle_name.lua',
	'client/*.lua',
	'menu/*.lua',
}

files {
    'data/**/*.meta',
    'data/**/*.xml',
    'data/**/*.dat',
    'data/**/*.ytyp'
}


data_file 'HANDLING_FILE'            'data/**/handling*.meta'
data_file 'VEHICLE_LAYOUTS_FILE'    'data/**/vehiclelayouts*.meta'
data_file 'VEHICLE_METADATA_FILE'    'data/**/vehicles*.meta'
data_file 'CARCOLS_FILE'            'data/**/carcols*.meta'
data_file 'VEHICLE_VARIATION_FILE'    'data/**/carvariations*.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'data/**/*unlocks.meta'
data_file 'PTFXASSETINFO_FILE' 'data/**/ptfxassetinfo.meta'


dependencies {'es_extended'}