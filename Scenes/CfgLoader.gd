extends Node
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oConfigFilesListWindow = Nodelist.list["oConfigFilesListWindow"]
onready var oCustomSlabSystem = Nodelist.list["oCustomSlabSystem"]
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oReadCfg = Nodelist.list["oReadCfg"]

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
	
	if oCurrentFormat.selected == Constants.ClassicFormat or oGame.keeperfx_is_installed() == false:
		Cube.load_dk_original_cubes()
		Slabset.load_default_original_slabset()
		Columnset.load_default_original_columnset()
		load_classic_tmap_files()
		Things.LIST_OF_SPELLBOOKS = [11,12,13,14,15,16,17,18,19,20,21,22,23,45,46,47,48,134,135]
		Things.LIST_OF_HEROGATES = [49]
	
	var campaign_cfg = load_cfgs(mapPath)
	load_creature_stats_data(mapPath, campaign_cfg)
	
	print('Loaded all .cfg and .toml files: ' + str(OS.get_ticks_msec() - CODETIME_LOADCFG_START) + 'ms')
	if oConfigFilesListWindow.visible:
		Utils.popup_centered(oConfigFilesListWindow)
	oCustomSlabSystem.load_unearth_custom_slabs_file()


func load_cfgs(mapPath):
	# Load configuration for KeeperFX format
	# Processes .cfg and .toml files from multiple directories
	oConfigFileManager.clear_paths()
	
	var campaign_cfg = load_campaign_boss_file(mapPath)
	var config_dirs = get_config_directories(mapPath, campaign_cfg)
	var sprite_zip_paths = []
	var campaign_zip_dir = config_dirs[oConfigFileManager.LOAD_CFG_CAMPAIGN] if campaign_cfg.get("common", {}).get("CONFIGS_LOCATION", "") != "" else ""
	for zip_dir in [config_dirs[oConfigFileManager.LOAD_CFG_FXDATA], campaign_zip_dir]:
		if zip_dir == "":
			continue
		var zip_paths = Utils.get_filetype_in_directory(zip_dir, "zip")
		zip_paths.sort()
		for zip_path in zip_paths:
			if sprite_zip_paths.has(zip_path) == false:
				sprite_zip_paths.append(zip_path)
	if mapPath != "":
		var map_zip_path = mapPath.get_basename() + ".zip"
		if file_exists_checker.file_exists(map_zip_path) and sprite_zip_paths.has(map_zip_path) == false:
			sprite_zip_paths.append(map_zip_path)
	Graphics.load_custom_sprite_zips(sprite_zip_paths)
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
					var result = oReadCfg.read_dkcfg_file(actual_filepath)
					combined_cfg_data = super_merge_dictionaries(combined_cfg_data, result["config"])
					
					if load_cfg_type == oConfigFileManager.LOAD_CFG_FXDATA:
						if not result["config"].empty():
							oConfigFileManager.default_data[file_name_from_list] = result["config"].duplicate(true)
						if not result["comments"].empty():
							oConfigFileManager.FXDATA_COMMENTS[file_name_from_list] = result["comments"]
		# Load it
		if combined_cfg_data.empty() == false:
			match file_name_from_list:
				"objects.cfg": load_objects_data(combined_cfg_data)
				"creature.cfg": load_creatures_data(combined_cfg_data)
				"trapdoor.cfg": load_trapdoor_data(combined_cfg_data)
				"terrain.cfg": 
					load_terrain_data(combined_cfg_data)
					load_room_data_from_terrain(combined_cfg_data)
				"cubes.cfg": Cube.read_cubes_cfg(combined_cfg_data)
				"rules.cfg": load_rules_data(combined_cfg_data)
				"magic.cfg": load_magic_data(combined_cfg_data)
	Slabset.store_loaded_data()
	Columnset.store_loaded_data()
	return campaign_cfg

func super_merge_dictionaries(dict1:Dictionary, dict2:Dictionary):
	var merged = {}
	for key in dict1:
		merged[key] = dict1[key]
	for key in dict2:
		if key in merged and typeof(merged[key]) == TYPE_DICTIONARY and typeof(dict2[key]) == TYPE_DICTIONARY:
			merged[key] = super_merge_dictionaries(merged[key], dict2[key])
		else:
			merged[key] = dict2[key]
	return merged

func get_config_directories(mapPath, campaign_cfg_data):
	return {
		oConfigFileManager.LOAD_CFG_DATA: oGame.DK_DATA_DIRECTORY,
		oConfigFileManager.LOAD_CFG_FXDATA: oGame.DK_FXDATA_DIRECTORY,
		oConfigFileManager.LOAD_CFG_CAMPAIGN: oGame.GAME_DIRECTORY.plus_file(campaign_cfg_data.get("common", {}).get("CONFIGS_LOCATION", "")),
		oConfigFileManager.LOAD_CFG_CURRENT_MAP: mapPath.get_basename()
	}


func build_list_of_files_to_load(config_dirs, mapPath):
	var files = {}
	for extension in ["cfg", "toml"]:
		for path in Utils.get_filetype_in_directory(config_dirs[oConfigFileManager.LOAD_CFG_FXDATA], extension):
			files[path.get_file()] = true
		add_map_file_suffixes(files, config_dirs[oConfigFileManager.LOAD_CFG_CURRENT_MAP], extension)
	for file_name in get_all_texture_map_files(config_dirs, mapPath):
		files[file_name] = true
	var arr = files.keys()
	arr.sort()
	return arr

func add_map_file_suffixes(files, current_map_path, extension):
	if current_map_path == "":
		return
	var map_prefix = current_map_path.get_file() + "."
	var map_prefix_lower = map_prefix.to_lower()
	for path in Utils.get_filetype_in_directory(current_map_path.get_base_dir(), extension):
		var file_name = path.get_file()
		if file_name.to_lower().begins_with(map_prefix_lower):
			files[file_name.substr(map_prefix.length())] = true

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
			var old_data = Things.DATA_OBJECT.get(id, ["UNDEFINED_NAME", null, null])
			var newName = objSection.get("Name", old_data[Things.NAME_ID])
			var newSprite = get_sprite(newName, objSection.get("AnimationID"))
			if newSprite == null:
				newSprite = old_data[Things.SPRITE]
			var newGenre = objSection.get("Genre")
			if newGenre == "SPELLBOOK":
				Things.LIST_OF_SPELLBOOKS.append(id)
			if newGenre == "HEROGATE":
				Things.LIST_OF_HEROGATES.append(id)
			
			Things.DATA_OBJECT[id] = [newName, newSprite, newGenre]


func load_terrain_data(cfg): # 4ms
	for section in cfg:
		if section.begins_with("slab") == false:
			continue
		
		var id = int(section)
		var slabSection = cfg[section]
		var slabData = Slabs.data.get(id, [
			"UNKNOWN",
			Slabs.FLOOR_SLAB,
			Slabs.BITMASK_FLOOR,
			Slabs.TAB_MAINSLAB,
			0,
			0,
			Slabs.NOT_OWNABLE,
			0,
		]).duplicate()
		
		slabData[Slabs.NAME] = slabSection.get("Name", slabData[Slabs.NAME])
		if slabSection.has("IsOwnable"):
			slabData[Slabs.IS_OWNABLE] = Slabs.NOT_OWNABLE
			if slabSection.get("IsOwnable", 0) == 1:
				slabData[Slabs.IS_OWNABLE] = Slabs.OWNABLE
		
		var getBlockFlags = slabSection.get("BlockFlags", [])
		if getBlockFlags is String and getBlockFlags == "":
			getBlockFlags = []
		
		if slabSection.has("BlockFlags"):
			slabData[Slabs.IS_SOLID] = Slabs.FLOOR_SLAB
			if "FILLED" in getBlockFlags or "DIGGABLE" in getBlockFlags or "VALUABLE" in getBlockFlags:
				slabData[Slabs.IS_SOLID] = Slabs.BLOCK_SLAB
		
		if slabSection.has("Animated") or slabSection.has("Category") or slabSection.has("BlockFlags"):
			slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_BLOCK
			if slabSection.get("Animated", 0) == 1:
				slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_SIMPLE
				if "IS_DOOR" in getBlockFlags:
					if slabData[Slabs.NAME].ends_with("2"):
						slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_DOOR2
					else: slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_DOOR1
			else:
				match slabSection.get("Category", 0):
					0: # Unclaimed
						if slabData[Slabs.IS_SOLID] == Slabs.BLOCK_SLAB:
							slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_BLOCK
						elif slabData[Slabs.IS_SOLID] == Slabs.FLOOR_SLAB:
							slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_FLOOR
					1: # Diggable dirt
						slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_BLOCK
					2: # Claimed path
						slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_CLAIMED
					3: # Fortified wall
						slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_REINFORCED
					4: # Room
						slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_FLOOR
					5: # Obstacle
						slabData[Slabs.BITMASK_TYPE] = Slabs.BITMASK_SIMPLE
		
		slabData[Slabs.WIBBLE_TYPE] = slabSection.get("Wibble", slabData[Slabs.WIBBLE_TYPE])
		slabData[Slabs.LIQUID_TYPE] = slabSection.get("WlbType", slabData[Slabs.LIQUID_TYPE])
		slabData[Slabs.EDGE_BLEND_GROUP] = slabSection.get("SlbID", slabData[Slabs.EDGE_BLEND_GROUP])
		
		Slabs.data[id] = slabData


func load_creatures_data(cfg): # 3ms
	var creatures = cfg.get("common", {}).get("Creatures", [])
	for id_number in creatures.size():
		var creature_id = id_number + 1
		var old_data = Things.DATA_CREATURE.get(creature_id, ["UNDEFINED_NAME", null, "CREATURE"])
		var newName = creatures[id_number]
		var newSprite = get_sprite(newName, -1)
		if newSprite == null:
			newSprite = old_data[Things.SPRITE]
		Things.DATA_CREATURE[creature_id] = [newName, newSprite, "CREATURE"]

func load_creature_stats_data(mapPath, campaign_cfg):
	var data = {}
	load_creature_stats_dir(data, oGame.GAME_DIRECTORY.plus_file("creatrs"))
	var base_data = data.duplicate(true)
	var creature_location = campaign_cfg.get("common", {}).get("CREATURES_LOCATION", "")
	if creature_location != "":
		load_creature_stats_dir(data, oGame.GAME_DIRECTORY.plus_file(creature_location))
	if mapPath != "":
		var map_file_prefix = mapPath.get_basename().get_file() + "."
		var lower_map_file_prefix = map_file_prefix.to_lower()
		var map_cfgs = Utils.get_filetype_in_directory(mapPath.get_base_dir(), "CFG")
		map_cfgs.sort()
		for path in map_cfgs:
			var file = path.get_file()
			if file.to_lower().begins_with(lower_map_file_prefix):
				load_creature_stats_file(data, file.substr(map_file_prefix.length()), path, true)
	oConfigFileManager.current_data["creature_stats"] = data
	var hand_symbol_sprites = {}
	var query_symbol_sprites = {}
	for file in base_data:
		var sprites = base_data[file].get("sprites", {})
		var subtype = get_creature_subtype(file)
		if subtype == null or sprites.empty():
			continue
		var default_sprite = Things.DATA_CREATURE[subtype][Things.SPRITE]
		var symbol_key = get_creature_symbol_key(sprites.get("HandSymbol", null))
		if symbol_key != null and default_sprite != null:
			hand_symbol_sprites[symbol_key] = default_sprite
		var default_portrait = str(default_sprite) + "_PORTRAIT"
		symbol_key = get_creature_symbol_key(sprites.get("QuerySymbol", null))
		if symbol_key != null and Graphics.sprite_id.has(default_portrait):
			query_symbol_sprites[symbol_key] = default_portrait
	for file in data:
		var sprites = data[file].get("sprites", {})
		var subtype = get_creature_subtype(file)
		if subtype == null:
			continue
		if sprites.empty():
			continue
		var sprite_key = get_creature_image_key(sprites.get("HandSymbol", null), hand_symbol_sprites)
		if sprite_key == null:
			for key in [sprites.get("Stand", null), file.get_basename().to_upper()]:
				sprite_key = Graphics.get_sprite_key(key, false)
				if sprite_key != null:
					break
		var portrait_key = get_creature_image_key(sprites.get("QuerySymbol", null), query_symbol_sprites)
		if sprite_key == null:
			sprite_key = portrait_key
		if sprite_key == null:
			continue
		Things.DATA_CREATURE[subtype][Things.SPRITE] = sprite_key
		if portrait_key != null:
			Graphics.sprite_id[str(sprite_key) + "_PORTRAIT"] = Graphics.sprite_id[portrait_key]

func load_creature_stats_dir(data, dir):
	var listOfCfgs = Utils.get_filetype_in_directory(dir, "CFG")
	listOfCfgs.sort()
	for path in listOfCfgs:
		load_creature_stats_file(data, path.get_file(), path)

func load_creature_stats_file(data, file, path, require_attributes = false):
	var cfg_data = oReadCfg.read_dkcfg_file(path)["config"]
	if cfg_data.empty() or (require_attributes and cfg_data.has("attributes") == false):
		return
	data[file] = super_merge_dictionaries(data.get(file, {}), cfg_data)

func get_creature_symbol_key(value):
	if value == null:
		return null
	if value is Array:
		return null if value.empty() else get_creature_symbol_key(value[0])
	var key = str(value)
	if key.is_valid_integer():
		return str(int(key))
	return key.to_upper()

func get_creature_subtype(file):
	return Things.find_subtype_by_name(Things.TYPE.CREATURE, file.get_basename().to_upper())

func get_creature_image_key(value, fallback_sprites):
	var sprite_key = Graphics.get_sprite_key(value, false)
	if sprite_key != null:
		return sprite_key
	return fallback_sprites.get(get_creature_symbol_key(value), null)

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
		return Graphics.get_sprite_key(newName)
	
	for key in [animID, newName]:
		var sprite_key = Graphics.get_sprite_key(key)
		if sprite_key != null:
			return sprite_key
	return null

func get_campaign_boss_file(mapPath):
	var levelsDirPath = mapPath.get_base_dir().get_base_dir()
	if oGame.is_map_root(levelsDirPath) == false:
		return {"path": "", "config": {}}
	var list_of_main_campaign_files = Utils.get_filetype_in_directory(levelsDirPath, "cfg")
	for campaignPath in list_of_main_campaign_files:
		var cfgDictionary = oReadCfg.read_dkcfg_file(campaignPath)["config"]
		var levelsLocation = cfgDictionary.get("common", {}).get("LEVELS_LOCATION", null)
		if levelsLocation and oGame.GAME_DIRECTORY.plus_file(levelsLocation).to_lower() == mapPath.get_base_dir().to_lower():
			return {"path": campaignPath, "config": cfgDictionary}
	return {"path": "", "config": {}}

func load_campaign_boss_file(mapPath):
	var campaignFile = get_campaign_boss_file(mapPath)
	oConfigFileManager.current_mappack_cfg_path = campaignFile["path"]
	oConfigFileManager.current_mappack_cfg_data = campaignFile["config"]
	oConfigFileManager.current_mappack_cfg_filename = campaignFile["path"].get_file()
	return campaignFile["config"]

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
	oConfigFileManager.current_data["rules.cfg"] = cfg

func load_magic_data(cfg):
	oConfigFileManager.current_data["magic.cfg"] = cfg

func load_room_data_from_terrain(cfg):
	var room_data = {}
	for section in cfg:
		if section.begins_with("room"):
			var id = int(section)
			if id == 0: continue
			room_data[id] = cfg[section]
	oConfigFileManager.current_data["terrain.cfg"] = room_data

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

func load_classic_tmap_files():
	oConfigFileManager.clear_paths()
	# Scan DATA directory for TMAP files
	var data_directory = oGame.DK_DATA_DIRECTORY
	var tmap_files = Utils.get_filetype_in_directory(data_directory, "dat")
	for fullPath in tmap_files:
		if "tmap" in fullPath.to_lower():
			oConfigFileManager.paths_loaded[oConfigFileManager.LOAD_CFG_DATA].append(fullPath)
