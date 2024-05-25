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
	Slabs.reset_slab_data_to_default()
	
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
	print(Slabs.doorslab_data)

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

const keeperfx_edited_slabs = [Slabs.GEMS] # This is to help with backwards compatibility for previous keeperfx versions that don't have these edits.

func load_terrain_data(path):
	var terrain_cfg = Utils.read_dkcfg_file(path)
	for section in terrain_cfg:
		if section.begins_with("slab"):
			var id = int(section)
			if id >= 55 or id in keeperfx_edited_slabs:
				var slabSection = terrain_cfg[section]
				
				var setName = slabSection.get("Name", "UNKNOWN")
				
				var getBlockFlags = slabSection.get("BlockFlags", [])
				if getBlockFlags is String and getBlockFlags == "":
					getBlockFlags = []
				
				var setBlockType = Slabs.FLOOR_SLAB
				if "FILLED" in getBlockFlags or "DIGGABLE" in getBlockFlags or "VALUABLE" in getBlockFlags:
					setBlockType = Slabs.BLOCK_SLAB
				
				var setIsOwnable = Slabs.NOT_OWNABLE
				if slabSection.get("IsOwnable", 0) == 1:
					setIsOwnable = Slabs.OWNABLE
				
				
				var setBitmask = Slabs.BITMASK_GENERAL
				
				if slabSection.get("Animated", 0) == 1:
					setBitmask = Slabs.BITMASK_SIMPLE
					if "IS_DOOR" in getBlockFlags:
						if setName.ends_with("2"):
							setBitmask = Slabs.BITMASK_DOOR2
						else: setBitmask = Slabs.BITMASK_DOOR1
				else:
					match slabSection.get("Category", 0):
						0: # Unclaimed
							setBitmask = Slabs.BITMASK_GENERAL
						1: # Diggable dirt
							setBitmask = Slabs.BITMASK_GENERAL
						2: # Claimed path
							setBitmask = Slabs.BITMASK_CLAIMED
						3: # Fortified wall
							setBitmask = Slabs.BITMASK_REINFORCED
						4: # Room interior
							setBitmask = Slabs.BITMASK_GENERAL
						5: # Obstacle
							setBitmask = Slabs.BITMASK_SIMPLE
				
				Slabs.data[id] = [
					setName,
					setBlockType,
					setBitmask,
					Slabs.PANEL_TOP_VIEW, # Affects appearance in slab window
					0,  # Affects appearance in slab window
					Slabs.TAB_MAINSLAB, # Good
					slabSection.get("Wibble", 0),
					slabSection.get("WlbType", 0),
					setIsOwnable,
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
			
			var getSlabKind = data.get("SlabKind", null)
			if getSlabKind is Array and getSlabKind.size() == 2:
				Slabs.doorslab_data[getSlabKind[0]] = [id, Slabs.DOOR_ORIENT_EW]
				Slabs.doorslab_data[getSlabKind[1]] = [id, Slabs.DOOR_ORIENT_NS]
			
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
