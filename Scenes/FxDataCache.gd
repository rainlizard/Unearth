extends Node
onready var oGame = Nodelist.list["oGame"]

# These are dictionaries containing dictionaries.
# objects_cfg["section_name"]["key"] will return the "value"
# If there's a space in the value string, then the value will be an array of strings or integers.

var terrain_cfg:Dictionary
var objects_cfg:Dictionary
var creature_cfg:Dictionary
var trapdoor_cfg:Dictionary


func start():
	var CODETIME_START = OS.get_ticks_msec()
	terrain_cfg = read_dkcfg_file(oGame.DK_FXDATA_DIRECTORY.plus_file("terrain.cfg"))
	objects_cfg = read_dkcfg_file(oGame.DK_FXDATA_DIRECTORY.plus_file("objects.cfg"))
	creature_cfg = read_dkcfg_file(oGame.DK_FXDATA_DIRECTORY.plus_file("creature.cfg"))
	trapdoor_cfg = read_dkcfg_file(oGame.DK_FXDATA_DIRECTORY.plus_file("trapdoor.cfg"))
	print('Parsed all dkcfg files: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func read_dkcfg_file(file_path) -> Dictionary:
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
