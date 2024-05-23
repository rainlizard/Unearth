extends Node
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]


# These are dictionaries containing dictionaries.
# objects_cfg["section_name"]["key"] will return the "value"
# If there's a space in the value string, then the value will be an array of strings or integers.

#var campaign_cfg : Dictionary
#var terrain_cfg : Dictionary
#var objects_cfg : Dictionary
#var creature_cfg : Dictionary
#var trapdoor_cfg : Dictionary


enum {
	LOAD_CFG_FXDATA,
	LOAD_CFG_CAMPAIGN,
	LOAD_CFG_CURRENT_MAP,
}

func start(mapPath):
	
	if Cube.tex.empty():
		Cube.read_cubes_cfg()
	
	var CODETIME_LOADCFG_START = OS.get_ticks_msec()
	
	Things.reset_thing_data_to_default()
	
	var campaign_cfg = load_campaign_data(mapPath)
	
	var config_dirs = {
		LOAD_CFG_FXDATA: oGame.DK_FXDATA_DIRECTORY,
		LOAD_CFG_CAMPAIGN: oGame.GAME_DIRECTORY.plus_file(campaign_cfg.get("common", {}).get("CONFIGS_LOCATION", "")),
		LOAD_CFG_CURRENT_MAP: mapPath.get_basename()
	}
	for cfg_type in [LOAD_CFG_FXDATA, LOAD_CFG_CAMPAIGN, LOAD_CFG_CURRENT_MAP]:
		var cfg_dir = config_dirs[cfg_type]
		for file_name in ["objects.cfg", "creature.cfg", "trapdoor.cfg", "terrain.cfg"]:
			var file_path = cfg_dir.plus_file(file_name)
			if cfg_type == LOAD_CFG_CURRENT_MAP:
				file_path = cfg_dir + "." + file_name
			match file_name:
				"objects.cfg": load_objects_data(file_path)
				"creature.cfg": load_creatures_data(file_path)
				"trapdoor.cfg": load_trapdoor_data(file_path)
				"terrain.cfg": load_terrain_data(file_path)
	
	print('Loaded things from cfg files: ' + str(OS.get_ticks_msec() - CODETIME_LOADCFG_START) + 'ms')

func load_objects_data(path):
	var objects_cfg = Utils.read_dkcfg_file(path)
	for section in objects_cfg:
		if section.begins_with("object"):
			var id = int(section)
			if id == 0: continue
			if id >= 136 or id in [100, 101, 102, 103, 104, 105]: # Dummy Boxes should be overwritten
				var objSection = objects_cfg[section]
				var newName = objSection["Name"]
				var animID = objSection["AnimationID"]
				var newSprite = get_sprite(animID, newName)
				var newGenre = objSection.get("Genre", null)
				var newEditorTab = Things.GENRE_TO_TAB[newGenre]
				Things.DATA_OBJECT[id] = [newName, newSprite, newEditorTab]

func load_terrain_data(path):
	return #!!!!!!!
	
	var terrain_cfg = Utils.read_dkcfg_file(path)
	for section in terrain_cfg:
		if section.begins_with("slab"):
			var id = int(section)
			if id >= 55: # Beyond Slabs.PURPLE_PATH
				var slabSection = terrain_cfg[section]
				
				var setName = slabSection.get("Name", "Unknown")
				if setName != "Unknown":
					setName = Slabs.NAME_MAPPINGS.get(setName, setName.capitalize())
				
# BlockFlagsHeight
# BlockHealthIndex
# BlockFlags
# NoBlockFlags #; Possible (no)block flags are: VALUABLE, IS_ROOM, UNEXPLORED, DIGGABLE, FILLED, IS_DOOR, and TAGGED_VALUABLE.
# FillStyle # ; The type of terrain this slab fills adjacent slabs with if possible. 1 = Lava. 2 = Water.
# Category # ; 0 = Unclaimed. 1 = Diggable dirt. 2 = Claimed path. 3 = Fortified wall. 4 = Room interior. 5 = Obstacle.
# SlbID
# Indestructible # ; If set to 1 the slab cannot be dug, is immune to vandalizing and eruption effect.
# Wibble # ; The amount of distortion the slab has in normal view. The higher the value, the less distortion there is.
# Animated
# IsSafeLand
# IsDiggable
# IsOwnable
# WlbType
				
				Slabs.data[id] = [
					setName,
					Slabs.BLOCK_SLAB,
					Slabs.BITMASK_BLOCK,
					Slabs.PANEL_TOP_VIEW,
					0,
					Slabs.TAB_MAINSLAB,
					Slabs.WIBBLE_ON,
					Slabs.REMEMBER_PATH,
					Slabs.NOT_OWNABLE,
				]


func load_creatures_data(path):
	var creature_cfg = Utils.read_dkcfg_file(path)
	var creatures = creature_cfg.get("common", {}).get("Creatures", [])
	for id_number in creatures.size():
		var creature_id = id_number + 1
		if not Things.DATA_CREATURE.has(creature_id):
			var newName = creatures[id_number]
			var newSprite = get_sprite(newName, null)
			Things.DATA_CREATURE[creature_id] = [newName, newSprite, Things.TAB_CREATURE]


func load_trapdoor_data(path):
	var trapdoor_cfg = Utils.read_dkcfg_file(path)
	for section in trapdoor_cfg:
		var id = int(section)
		if id == 0: continue
		var trapOrDoor = -1
		if section.begins_with("door"):
			trapOrDoor = Things.TYPE.DOOR
		elif section.begins_with("trap"):
			trapOrDoor = Things.TYPE.TRAP
		else:
			continue
		
		var data = trapdoor_cfg[section]
		var newName = data.get("Name", null)
		var newSprite = get_sprite(newName, null)
		var crateName = data.get("Crate", null)
		
		if trapOrDoor == Things.TYPE.DOOR:
			Things.DATA_DOOR[id] = [newName, newSprite, Things.TAB_MISC]
		elif trapOrDoor == Things.TYPE.TRAP:
			Things.DATA_TRAP[id] = [newName, newSprite, Things.TAB_TRAP]
		Things.LIST_OF_BOXES[crateName] = [trapOrDoor, id]




func get_sprite(first_priority, second_priority):
	if Graphics.sprite_id.has(first_priority): return first_priority
	if Graphics.sprite_id.has(second_priority): return second_priority
	return null


func load_campaign_data(mapPath):
	var levelsDirPath = mapPath.get_base_dir().get_base_dir()
	var parentDirFolderName = levelsDirPath.get_file()
	if parentDirFolderName != "levels" and parentDirFolderName != "campgns":
		return {}
	var list_of_main_campaign_files = Utils.get_filetype_in_directory(levelsDirPath, "cfg")
	for campaignPath in list_of_main_campaign_files:
		var cfgDictionary = Utils.read_dkcfg_file(campaignPath)
		var levelsLocation = cfgDictionary.get("common", {}).get("LEVELS_LOCATION", null)
		if levelsLocation and oGame.GAME_DIRECTORY.plus_file(levelsLocation).to_lower() == mapPath.get_base_dir().to_lower():
			#print(oGame.GAME_DIRECTORY.plus_file(levelsLocation).to_lower())
			return cfgDictionary
	return {}
