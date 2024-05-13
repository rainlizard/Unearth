extends Node
onready var oGame = Nodelist.list["oGame"]

# These are dictionaries containing dictionaries.
# objects_cfg["section_name"]["key"] will return the "value"
# If there's a space in the value string, then the value will be an array of strings or integers.

var terrain_cfg : Dictionary
var objects_cfg : Dictionary
var creature_cfg : Dictionary
var trapdoor_cfg : Dictionary

func start():
	if Cube.tex.empty() == true:
		Cube.read_cubes_cfg()
	var CODETIME_START = OS.get_ticks_msec()
	terrain_cfg = read_dkcfg_file(oGame.DK_FXDATA_DIRECTORY.plus_file("terrain.cfg"))
	objects_cfg = read_dkcfg_file(oGame.DK_FXDATA_DIRECTORY.plus_file("objects.cfg"))
	creature_cfg = read_dkcfg_file(oGame.DK_FXDATA_DIRECTORY.plus_file("creature.cfg"))
	trapdoor_cfg = read_dkcfg_file(oGame.DK_FXDATA_DIRECTORY.plus_file("trapdoor.cfg"))
	print('Parsed all dkcfg files: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	var CODETIME_LOADCFG_START = OS.get_ticks_msec()
	# Step 1: set object data to default
	Things.reset_thing_data_to_default()
	# Step 2: load data from /fxdata/ config files
	load_objects_data()
	load_creatures_data()
	load_trapdoor_data()
	# Step 3: load data from local config files (map00001.objects.cfg)
	print('Loaded things from cfg files: ' + str(OS.get_ticks_msec() - CODETIME_LOADCFG_START) + 'ms')

func load_objects_data():
	for section in objects_cfg:
		if section.begins_with("object"):
			var id = int(section)
			if id == 0: continue
			if id >= 136 or id in [100, 101, 102, 103, 104, 105]: # Dummy Boxes should be overwritten
				var data = objects_cfg[section]
				var newName = data["Name"]
				var animID = data["AnimationID"]
				var newSprite = get_sprite(animID, newName)
				var newGenre = data.get("Genre", null)
				var newEditorTab = Things.GENRE_TO_TAB[newGenre]
				Things.DATA_OBJECT[id] = [newName, newSprite, newEditorTab]


func load_creatures_data():
	for id_number in creature_cfg["common"]["Creatures"].size():
		if Things.DATA_CREATURE.has(id_number+1) == false:
			var newName = creature_cfg["common"]["Creatures"][id_number]
			var newSprite = get_sprite(newName, null)
			Things.DATA_CREATURE[id_number + 1] = [newName, newSprite, Things.TAB_CREATURE]


func load_trapdoor_data():
	for section in trapdoor_cfg:
		var id = int(section)
		var trapOrDoor = -1
		if section.begins_with("door"): trapOrDoor = Things.TYPE.DOOR
		if section.begins_with("trap"): trapOrDoor = Things.TYPE.TRAP
		if id == 0 or trapOrDoor == -1: continue
		
		var data = trapdoor_cfg[section]
		var newName = data.get("Name", null)
		var newSprite = get_sprite(newName, null)
		var crateName = data.get("Crate", null)
		if trapOrDoor == Things.TYPE.DOOR:
			Things.DATA_DOOR[id] = [newName, newSprite, Things.TAB_MISC]
		elif trapOrDoor == Things.TYPE.TRAP:
			Things.DATA_TRAP[id] = [newName, newSprite, Things.TAB_TRAP]
		
		var crate_id_number = Things.find_subtype_by_name(Things.TYPE.OBJECT, crateName)
		Things.LIST_OF_BOXES[crate_id_number] = [
			trapOrDoor,
			id,
		]
	#print(Things.LIST_OF_BOXES)


func get_sprite(first_priority, second_priority):
	if Graphics.sprite_id.has(first_priority): return first_priority
	if Graphics.sprite_id.has(second_priority): return second_priority
	return null


func read_dkcfg_file(file_path) -> Dictionary: # Optimized
	var config = {}
	var current_section = ""
	
	var file = File.new()
	if not file.file_exists(file_path):
		print("File not found: ", file_path)
		return config
	
	file.open(file_path, File.READ)
	var lines = file.get_as_text().split("\n")
	file.close()
	
	for line in lines:
		line = line.strip_edges()
		if line.begins_with(";") or line.empty():
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			config[current_section] = {}
		else:
			var delimiter_pos = line.find("=")
			if delimiter_pos != -1:
				var key = line.substr(0, delimiter_pos).strip_edges()
				var value = line.substr(delimiter_pos + 1).strip_edges()
				
				if " " in value:
					var construct_new_value_array = []
					for item in value.split(" "):
						if item.is_valid_integer():
							construct_new_value_array.append(int(item))
						else:
							construct_new_value_array.append(item)
					config[current_section][key] = construct_new_value_array
				else:
					if value.is_valid_integer():
						config[current_section][key] = int(value)
					else:
						config[current_section][key] = value
	
	return config
