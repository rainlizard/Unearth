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
	
	for section in objects_cfg:
		if section.begins_with("object"):
			var id = int(section)
			if id == 0: continue
			if id >= 136 or id in [100,101,102,103,104,105]: # Dummy Boxes should be overwritten
				var newName = objects_cfg[section]["Name"]
				
				var animID = objects_cfg[section]["AnimationID"]
				var newSprite = null
				if Graphics.sprite_id.has(animID):
					newSprite = animID
				elif Graphics.sprite_id.has(newName):
					newSprite = newName
				
				var newGenre = objects_cfg[section].get("Genre", null)
				var newEditorTab = Things.GENRE_TO_TAB[newGenre]
				
				Things.DATA_OBJECT[id] = [
					newName, # NAME
					newSprite, # SPRITE
					newEditorTab, # EDITOR_TAB
				]
	
	for id_number in creature_cfg["common"]["Creatures"].size():
		if Things.DATA_CREATURE.has(id_number+1) == false:
			
			var newName = creature_cfg["common"]["Creatures"][id_number]
			
			var newSprite = null
			if Graphics.sprite_id.has(newName):
				newSprite = newName
			
			var newPortrait = null
			if Graphics.sprite_id.has(str(newSprite) + "_PORTRAIT"):
				newPortrait = str(newSprite) + "_PORTRAIT"
			
			Things.DATA_CREATURE[id_number+1] = [
				newName, # NAME
				newSprite, # SPRITE
				Things.TAB_CREATURE, # EDITOR_TAB
			]
	
	for section in trapdoor_cfg:
		var id = int(section)
		if id == 0: continue
		if section.begins_with("door"):
			var newName = trapdoor_cfg[section]["Name"]
			var newSprite = null
			if Graphics.sprite_id.has(newName):
				newSprite = newName
			Things.DATA_DOOR[id] = [
				newName, # NAME
				newSprite, # SPRITE
				Things.TAB_MISC, # EDITOR_TAB
			]
		elif section.begins_with("trap"):
			var newName = trapdoor_cfg[section]["Name"]
			var newSprite = null
			if Graphics.sprite_id.has(newName):
				newSprite = newName
			Things.DATA_TRAP[id] = [
				newName, # NAME
				newSprite, # SPRITE
				Things.TAB_TRAP, # EDITOR_TAB
			]
	print('Loaded things from cfg files: ' + str(OS.get_ticks_msec() - CODETIME_LOADCFG_START) + 'ms')

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

#	print ("var sprite_id = {")
#	for key in objects_cfg.keys():
#		if "object" in key:
#			#print(key)
#			#print(objects_cfg[key]["Name"] + " ")
#			#print(objects_cfg[key]["AnimationID"] + " : " + "")
#			var b = '""'
#			if Things.DATA_OBJECT.has(int(key)):
#				var fsffsa = Things.DATA_OBJECT[int(key)][Things.TEXTURE]
#				if fsffsa != null:
#					b = 'preload("' +fsffsa.resource_path + '")'
#
#			var a = objects_cfg[key]["AnimationID"]
#			if a is String:
#				print('"' + a + '"' + " : " + b + ",")
#			else:
#				print(str(a) + " : " + str(b) + ",")
#	print("}")
	
