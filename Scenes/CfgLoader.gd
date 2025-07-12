extends Node
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oConfigFilesListWindow = Nodelist.list["oConfigFilesListWindow"]
onready var oCustomSlabSystem = Nodelist.list["oCustomSlabSystem"]
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]


# These are dictionaries containing dictionaries.
# objects_cfg["section_name"]["key"] will return the "value"
# If there's a space in the value string, then the value will be an array of strings or integers.

#var campaign_cfg : Dictionary
#var terrain_cfg : Dictionary
#var objects_cfg : Dictionary
#var creature_cfg : Dictionary
#var trapdoor_cfg : Dictionary

var file_exists_checker = File.new()

func start(mapPath):
	var CODETIME_LOADCFG_START = OS.get_ticks_msec()
	Things.clear_dynamic_lists()
	Things.reset_thing_data_to_default()
	Slabs.reset_slab_data_to_default()
	Slabset.clear_all_slabset_data()
	Columnset.clear_all_column_data()
	Cube.clear_all_cube_data()
	process_configuration_files(mapPath)
	print('Loaded all .cfg and .toml files: ' + str(OS.get_ticks_msec() - CODETIME_LOADCFG_START) + 'ms')
	if oConfigFilesListWindow.visible:
		Utils.popup_centered(oConfigFilesListWindow)
	oCustomSlabSystem.load_unearth_custom_slabs_file()


func process_configuration_files(mapPath):
	
	if oCurrentFormat.selected == Constants.ClassicFormat:
		# Use unearth defaults
		Cube.load_dk_original_cubes()
		Slabset.load_default_original_slabset()
		Columnset.load_default_original_columnset()
	
	oConfigFileManager.clear_paths()
	
	var config_dirs = get_config_directories(mapPath)
	var files_to_load = build_list_of_files_to_load(config_dirs, mapPath)
	for file_name_from_list in files_to_load:
		
		var combined_cfg_data = {}
		
		for load_cfg_type in [oConfigFileManager.LOAD_CFG_DATA, oConfigFileManager.LOAD_CFG_FXDATA, oConfigFileManager.LOAD_CFG_CAMPAIGN, oConfigFileManager.LOAD_CFG_CURRENT_MAP]:
			var check_path
			if load_cfg_type == oConfigFileManager.LOAD_CFG_CURRENT_MAP:
				check_path = config_dirs[load_cfg_type] + "." + file_name_from_list
			else:
				check_path = config_dirs[load_cfg_type].plus_file(file_name_from_list)
			
			var actual_filepath = ""
			if file_exists_checker.file_exists(check_path):
				actual_filepath = check_path
				oConfigFileManager.paths_loaded[load_cfg_type].append(actual_filepath)
			
			if actual_filepath != "":
				var ext = file_name_from_list.get_extension().to_lower()
				if ext == "toml":
					match file_name_from_list:
						"slabset.toml": Slabset.import_toml_slabset(actual_filepath)
						"columnset.toml": Columnset.import_toml_columnset(actual_filepath)
						"textureanim.toml": oTextureAnimation.generate_animation_database(actual_filepath)
						"effects.toml": load_effects_data(actual_filepath)
				elif ext == "cfg":
					var result = Utils.read_dkcfg_file(actual_filepath)
					combined_cfg_data = Utils.super_merge(combined_cfg_data, result["config"])
					
					if load_cfg_type == oConfigFileManager.LOAD_CFG_FXDATA and not result["comments"].empty():
						oConfigFileManager.FXDATA_COMMENTS[file_name_from_list] = result["comments"]
		# Load it
		if combined_cfg_data.empty() == false:
			match file_name_from_list:
				"objects.cfg": load_objects_data(combined_cfg_data)
				"creature.cfg": load_creatures_data(combined_cfg_data)
				"trapdoor.cfg": load_trapdoor_data(combined_cfg_data)
				"terrain.cfg": load_terrain_data(combined_cfg_data)
				"cubes.cfg": Cube.read_cubes_cfg(combined_cfg_data)
				"rules.cfg": load_rules_data(combined_cfg_data)


func get_config_directories(mapPath):
	var campaign_cfg_data = load_campaign_boss_file(mapPath)
	return {
		oConfigFileManager.LOAD_CFG_DATA: oGame.DK_DATA_DIRECTORY,
		oConfigFileManager.LOAD_CFG_FXDATA: oGame.DK_FXDATA_DIRECTORY,
		oConfigFileManager.LOAD_CFG_CAMPAIGN: oGame.GAME_DIRECTORY.plus_file(campaign_cfg_data.get("common", {}).get("CONFIGS_LOCATION", "")),
		oConfigFileManager.LOAD_CFG_CURRENT_MAP: mapPath.get_basename()
	}


func build_list_of_files_to_load(config_dirs, mapPath):
	var arr = []
	var fxdata_cfg_files = Utils.get_filetype_in_directory(config_dirs[oConfigFileManager.LOAD_CFG_FXDATA], "cfg")
	var fxdata_toml_files = Utils.get_filetype_in_directory(config_dirs[oConfigFileManager.LOAD_CFG_FXDATA], "toml")
	for i in fxdata_cfg_files:
		arr.append(i.get_file())
	for i in fxdata_toml_files:
		arr.append(i.get_file())
	arr.sort()
	arr += get_all_texture_map_files(config_dirs, mapPath)
	return arr

func get_all_texture_map_files(config_dirs, mapPath):
	var merged_files = {} # Use a dictionary so duplicate filenames will be merged
	var look_for_tmaps = Utils.get_filetype_in_directory(config_dirs[oConfigFileManager.LOAD_CFG_DATA], "dat")
	look_for_tmaps += Utils.get_filetype_in_directory(config_dirs[oConfigFileManager.LOAD_CFG_CAMPAIGN], "dat")
	for fullPath in look_for_tmaps:
		if "tmap" in fullPath.to_lower():
			merged_files[fullPath.get_file()] = true
	
	var look_for_tmaps2 = Utils.get_filetype_in_directory(config_dirs[oConfigFileManager.LOAD_CFG_CURRENT_MAP].get_base_dir(), "dat")
	for fullPath in look_for_tmaps2:
		if "tmap" in fullPath.to_lower():
			var tmap_ending_filename_part = fullPath.get_file().substr(fullPath.get_file().find(".") + 1)
			merged_files[tmap_ending_filename_part] = true
	merged_files = merged_files.keys()
	
	return merged_files


func load_objects_data(cfg): # 10ms
	for section in cfg:
		if section.begins_with("object"):
			var id = int(section)
			if id == 0: continue
			var objSection = cfg[section]
			var newName
			var animID
			var newSprite
			var newGenre
			if Things.DATA_OBJECT.has(id) == true:
				newName = objSection.get("Name", Things.DATA_OBJECT[id][Things.NAME_ID])
				animID = objSection.get("AnimationID")
				newSprite = get_sprite(newName, animID)
				if newSprite == null:
					newSprite = Things.DATA_OBJECT[id][Things.SPRITE]
				newGenre = objSection.get("Genre")
				if newGenre == "SPELLBOOK":
					Things.LIST_OF_SPELLBOOKS.append(id)
				if newGenre == "HEROGATE":
					Things.LIST_OF_HEROGATES.append(id)
			else:
				newName = objSection.get("Name", "UNDEFINED_NAME")
				animID = objSection.get("AnimationID")
				newSprite = get_sprite(newName, animID)
				
				newGenre = objSection.get("Genre")
			
			Things.DATA_OBJECT[id] = [newName, newSprite, newGenre]


var keeperfx_edited_slabs = [Slabs.GEMS] # This is to help with backwards compatibility for previous keeperfx versions that don't have these edits.
func load_terrain_data(cfg): # 4ms
	for section in cfg:
		if section.begins_with("slab"):
			var id = int(section)
			if id >= 55 or id in keeperfx_edited_slabs:
				var slabSection = cfg[section]
				var setName = slabSection.get("Name", "UNKNOWN")
				
				var setIsOwnable = Slabs.NOT_OWNABLE
				if slabSection.get("IsOwnable", 0) == 1:
					setIsOwnable = Slabs.OWNABLE
				
				var getBlockFlags = slabSection.get("BlockFlags", [])
				if getBlockFlags is String and getBlockFlags == "":
					getBlockFlags = []
				
				var setBlockType = Slabs.FLOOR_SLAB
				if "FILLED" in getBlockFlags or "DIGGABLE" in getBlockFlags or "VALUABLE" in getBlockFlags:
					setBlockType = Slabs.BLOCK_SLAB
				
				var setBitmask = Slabs.BITMASK_BLOCK
				if slabSection.get("Animated", 0) == 1:
					setBitmask = Slabs.BITMASK_SIMPLE
					if "IS_DOOR" in getBlockFlags:
						if setName.ends_with("2"):
							setBitmask = Slabs.BITMASK_DOOR2
						else: setBitmask = Slabs.BITMASK_DOOR1
				else:
					match slabSection.get("Category", 0):
						0: # Unclaimed
							if setBlockType == Slabs.BLOCK_SLAB:
								setBitmask = Slabs.BITMASK_BLOCK
							elif setBlockType == Slabs.FLOOR_SLAB:
								setBitmask = Slabs.BITMASK_FLOOR
						1: # Diggable dirt
							setBitmask = Slabs.BITMASK_BLOCK
						2: # Claimed path
							setBitmask = Slabs.BITMASK_CLAIMED
						3: # Fortified wall
							setBitmask = Slabs.BITMASK_REINFORCED
						4: # Room
							setBitmask = Slabs.BITMASK_FLOOR
						5: # Obstacle
							setBitmask = Slabs.BITMASK_SIMPLE
				
				Slabs.data[id] = [
					setName,
					setBlockType,
					setBitmask,
					Slabs.TAB_MAINSLAB,
					slabSection.get("Wibble", 0),
					slabSection.get("WlbType", 0),
					setIsOwnable,
				]


func load_creatures_data(cfg): # 3ms
	var creatures = cfg.get("common", {}).get("Creatures", [])
	for id_number in creatures.size():
		var creature_id = id_number + 1
		if Things.DATA_CREATURE.has(creature_id) == false:
			var newName = creatures[id_number]
			var newSprite = get_sprite(newName, -1)
			Things.DATA_CREATURE[creature_id] = [newName, newSprite, "CREATURE"]

func load_trapdoor_data(cfg): # 1ms
	for section in cfg:
		var id = int(section)
		if id == 0: continue
		var trapOrDoor = -1
		if section.begins_with("door"):
			trapOrDoor = Things.TYPE.DOOR
		elif section.begins_with("trap"):
			trapOrDoor = Things.TYPE.TRAP
		else:
			continue
		
		var data = cfg[section]
		var newName = data.get("Name", null)
		var newSprite = get_sprite(newName, -1)
		var crateName = data.get("Crate", null)
		
		if trapOrDoor == Things.TYPE.DOOR:
			Things.DATA_DOOR[id] = [newName, newSprite]
			
			var getSlabKind = data.get("SlabKind", null)
			if getSlabKind is Array and getSlabKind.size() == 2:
				Slabs.doorslab_data[getSlabKind[0]] = [id, Slabs.DOOR_ORIENT_EW]
				Slabs.doorslab_data[getSlabKind[1]] = [id, Slabs.DOOR_ORIENT_NS]
			
		elif trapOrDoor == Things.TYPE.TRAP:
			Things.DATA_TRAP[id] = [newName, newSprite]
		Things.LIST_OF_BOXES[crateName] = [trapOrDoor, id]

func get_sprite(newName, animID):
	if animID == null: return null
	if int(animID) == 777: # 777 is the AnimationID for all spellbooks in objects.cfg, which unearth uses separate sprites for
		if Graphics.sprite_id.has(newName): return newName
	
	if Graphics.sprite_id.has(animID): return animID
	if Graphics.sprite_id.has(newName): return newName
	return null

func load_campaign_boss_file(mapPath):
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

func load_effects_data(file_path):
	var cfg = ConfigFile.new()
	var err = cfg.load(file_path)
	if err != OK:
		return
	
	for section in cfg.get_sections():
		if section.begins_with("effectGenerator"):
			var id = int(section.trim_prefix("effectGenerator"))
			var effectName = cfg.get_value(section, "Name", "UNDEFINED_NAME")
			
			Things.DATA_EFFECTGEN[id] = [effectName, effectName, "EFFECTGEN"]


func load_rules_data(cfg):
	oConfigFileManager.DATA_RULES = cfg
	oConfigFileManager.store_default_data()

func update_paths_for_saved_files(file_path, file_type):
	if file_type == "slabset.toml" or file_type == "columnset.toml":
		if not oConfigFileManager.paths_loaded.has(oConfigFileManager.LOAD_CFG_CURRENT_MAP):
			oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP] = []
		if not oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP].has(file_path):
			oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_CURRENT_MAP].append(file_path)

func remove_path_from_loaded(file_path):
	for load_cfg_type in oConfigFileManager.paths_loaded.keys():
		if oConfigFileManager.paths_loaded[load_cfg_type].has(file_path):
			oConfigFileManager.paths_loaded[load_cfg_type].erase(file_path)
			break
