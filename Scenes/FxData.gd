extends Node
onready var oGame = Nodelist.list["oGame"]

# These are dictionaries containing dictionaries.
# objects_cfg["section_name"]["key"] will return the "value"
# If there's a space in the value string, then the value will be an array of strings or integers.

var terrain_cfg : Dictionary
var objects_cfg : Dictionary
var creature_cfg : Dictionary
var trapdoor_cfg : Dictionary


#func _ready():
#	var directory = Directory.new()
#	var image_directory = "res://Art/"
#
#	if directory.open(image_directory) == OK:
#		directory.list_dir_begin()
#		var file_name = directory.get_next()
#		while file_name != "":
#			if file_name.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
#				var image_path = image_directory + file_name
#				print("Loaded image: ", image_path)
#
#			file_name = directory.get_next()
#	else:
#		print("Failed to open the directory.")

#				var newName
#				var checkName = objects_cfg[section]["Name"]
#				if Things.convert_name.has(checkName):
#					newName = Things.convert_name[checkName]
#				else:
#					newName = checkName.capitalize()

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
	
	var id = 0
	while true:
		id += 1
		if id >= 136 or id in [100,101,102,103,104,105]: # Dummy Boxes should be overwritten
			var section = "object"+str(id)
			if objects_cfg.has(section):
				var newName = objects_cfg[section]["Name"]
				var newGenre = objects_cfg[section]["Genre"]
				var newEditorTab = Things.GENRE_TO_TAB[newGenre]
				
				var newTexture = null
				match newGenre:
					"SPECIALBOX": newTexture = preload("res://dk_images/trapdoor_64/bonus_box_std.png")
					"SPELLBOOK": newTexture = preload("res://edited_images/icon_book.png")
					"WORKSHOPBOX": newTexture = preload("res://dk_images/traps_doors/anim0116/AnimBox.tres")
				
				Things.DATA_OBJECT[id] = [
					newName, # NAME
					null, # ANIMATION_ID
					newTexture, # TEXTURE
					null, # PORTRAIT
					newEditorTab, # EDITOR_TAB
				]
			else:
				break
	print('Loaded objects.cfg: ' + str(OS.get_ticks_msec() - CODETIME_LOADCFG_START) + 'ms')

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
