extends Node
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oConfigFilesListWindow = Nodelist.list["oConfigFilesListWindow"]
onready var oCustomSlabSystem = Nodelist.list["oCustomSlabSystem"]
onready var oTextureAnimation = Nodelist.list["oTextureAnimation"]

# These are dictionaries containing dictionaries.
# objects_cfg["section_name"]["key"] will return the "value"
# If there's a space in the value string, then the value will be an array of strings or integers.

#var campaign_cfg : Dictionary
#var terrain_cfg : Dictionary
#var objects_cfg : Dictionary
#var creature_cfg : Dictionary
#var trapdoor_cfg : Dictionary

var paths_loaded = {}
const files_to_load = ["objects.cfg", "creature.cfg", "trapdoor.cfg", "terrain.cfg", "cubes.cfg", "slabset.toml", "columnset.toml", "textureanim.toml", "effects.toml"]

enum {
	LOAD_CFG_FXDATA,
	LOAD_CFG_CAMPAIGN,
	LOAD_CFG_CURRENT_MAP,
}

func start(mapPath):
	var CODETIME_LOADCFG_START = OS.get_ticks_msec()
	
	Things.clear_dynamic_lists()
	Things.reset_thing_data_to_default()
	Slabs.reset_slab_data_to_default()
	Slabset.clear_all_slabset_data()
	Columnset.clear_all_column_data()
	Cube.clear_all_cube_data()
	
	var campaign_cfg = load_campaign_data(mapPath)
	paths_loaded = {
		LOAD_CFG_FXDATA: [],
		LOAD_CFG_CAMPAIGN: [],
		LOAD_CFG_CURRENT_MAP: []
	}
	var config_dirs = {
		LOAD_CFG_FXDATA: oGame.DK_FXDATA_DIRECTORY,
		LOAD_CFG_CAMPAIGN: oGame.GAME_DIRECTORY.plus_file(campaign_cfg.get("common", {}).get("CONFIGS_LOCATION", "")),
		LOAD_CFG_CURRENT_MAP: mapPath.get_basename()
	}
	
	var file_exists = File.new()
	
	for i in files_to_load.size():
		var file_name = files_to_load[i]
		
		var combined_cfg = {}
		
		for cfg_type in [LOAD_CFG_FXDATA, LOAD_CFG_CAMPAIGN, LOAD_CFG_CURRENT_MAP]:
			var cfg_dir = config_dirs[cfg_type]
			var file_path = cfg_dir.plus_file(file_name)
			if cfg_type == LOAD_CFG_CURRENT_MAP:
				file_path = cfg_dir + "." + file_name
			
			if file_exists.file_exists(file_path):
				
				# ALL OTHER FILES GET DEFAULTED TO BEING LOADED AS A DKCFG FILE
				match file_name:
					"slabset.toml": Slabset.import_toml_slabset(file_path) # .toml import gets run multiple times instead of combining
					"columnset.toml": Columnset.import_toml_columnset(file_path)
					"textureanim.toml": oTextureAnimation.generate_animation_database(file_path)
					"effects.toml": load_effects_data(file_path)
					_:
						var cfgData = Utils.read_dkcfg_file(file_path)
						combined_cfg = Utils.super_merge(combined_cfg, cfgData)
				
				paths_loaded[cfg_type].resize(files_to_load.size())
				paths_loaded[cfg_type][i] = file_path
			else:
				if cfg_type == LOAD_CFG_FXDATA:
					match file_name:
						"cubes.cfg": Cube.load_dk_original_cubes()
						"slabset.toml": Slabset.load_default_original_slabset()
						"columnset.toml": Columnset.load_default_original_columnset()
		
		#if file_name == "objects.cfg":
		#	print(combined_cfg)
		
		# Only load cfg after they've been combined (they're combined so they'll automatically have fallbacks)
		if combined_cfg.empty() == false: # It can be empty if the file wasn't found
			match file_name:
				"objects.cfg": load_objects_data(combined_cfg)
				"creature.cfg": load_creatures_data(combined_cfg)
				"trapdoor.cfg": load_trapdoor_data(combined_cfg)
				"terrain.cfg": load_terrain_data(combined_cfg)
				"cubes.cfg": Cube.read_cubes_cfg(combined_cfg)
	
	print('Loaded all .cfg and .toml files: ' + str(OS.get_ticks_msec() - CODETIME_LOADCFG_START) + 'ms')
	if oConfigFilesListWindow.visible == true:
		Utils.popup_centered(oConfigFilesListWindow)
	
	oCustomSlabSystem.load_unearth_custom_slabs_file()

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
					Slabs.TAB_MAINSLAB, # Good
					slabSection.get("Wibble", 0),
					slabSection.get("WlbType", 0),
					setIsOwnable,
				]


func load_creatures_data(cfg): # 3ms
	var creatures = cfg.get("common", {}).get("Creatures", [])
	for id_number in creatures.size():
		var creature_id = id_number + 1
		if not Things.DATA_CREATURE.has(creature_id):
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
	if int(animID) == 777: # 777 is the AnimationID for all spellbooks in objects.cfg, which unearth uses separate sprites for
		if Graphics.sprite_id.has(newName): return newName
	
	if Graphics.sprite_id.has(animID): return animID
	if Graphics.sprite_id.has(newName): return newName
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
