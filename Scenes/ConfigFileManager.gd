extends Node

onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oMessage = Nodelist.list["oMessage"]

signal config_file_status_changed()

enum {
	LOAD_CFG_DATA,
	LOAD_CFG_FXDATA,
	LOAD_CFG_CAMPAIGN,
	LOAD_CFG_CURRENT_MAP,
}
var paths_loaded = {}

var current_data = {}
var default_data = {}
var FXDATA_COMMENTS = {}
var current_mappack_cfg_filename = ""
var current_mappack_cfg_path = ""
var current_mappack_cfg_data = {}

func _ready():
	clear_paths()


func clear_paths():
	paths_loaded = {
		LOAD_CFG_DATA: [],
		LOAD_CFG_FXDATA: [],
		LOAD_CFG_CAMPAIGN: [],
		LOAD_CFG_CURRENT_MAP: []
	}
	current_data = {}
	FXDATA_COMMENTS = {}
	default_data = {}
	current_mappack_cfg_filename = ""
	current_mappack_cfg_path = ""
	current_mappack_cfg_data = {}
	emit_signal("config_file_status_changed")


func copy_current_map_files(source_map_path, target_map_path):
	if source_map_path == "" or source_map_path.get_basename().to_upper() == target_map_path.get_basename().to_upper():
		return true
	var current_map_paths = paths_loaded.get(LOAD_CFG_CURRENT_MAP, [])
	var updated_map_paths = current_map_paths.duplicate()
	var source_prefix = source_map_path.get_file().get_basename() + "."
	var target_prefix = target_map_path.get_file().get_basename() + "."
	var dir = Directory.new()
	var copied_any = false
	var copy_failed = false
	for i in current_map_paths.size():
		var file_path = current_map_paths[i]
		var file_name = file_path.get_file()
		if file_name.to_upper().begins_with(source_prefix.to_upper()) == false:
			continue
		var target_path = target_map_path.get_base_dir().plus_file(target_prefix + file_name.substr(source_prefix.length()))
		var err = dir.copy(file_path, target_path)
		if err != OK:
			oMessage.quick("Error copying map file: " + file_name)
			print("Error copying map file: " + file_path + " Code: " + str(err))
			copy_failed = true
			continue
		updated_map_paths[i] = target_path
		copied_any = true
		print("Copied map file: " + target_path.get_file())
	if copy_failed == true:
		return false
	if copied_any == true:
		paths_loaded[LOAD_CFG_CURRENT_MAP] = updated_map_paths
		emit_signal("config_file_status_changed")
	return true


func store_default_data():
	if current_data.has("rules.cfg") and not current_data["rules.cfg"].empty():
		default_data["rules.cfg"] = current_data["rules.cfg"].duplicate(true)


func get_comments_for_key(filename: String, section_name: String, key: String) -> Array:
	if FXDATA_COMMENTS.has(filename) and FXDATA_COMMENTS[filename].has(section_name) and FXDATA_COMMENTS[filename][section_name].has(key):
		return FXDATA_COMMENTS[filename][section_name][key]
	return []


func is_item_different(section_name: String, key: String) -> bool:
	if not default_data.has("rules.cfg") or not default_data["rules.cfg"].has(section_name) or not default_data["rules.cfg"][section_name].has(key):
		return false
	
	if not current_data.has("rules.cfg") or not current_data["rules.cfg"].has(section_name) or not current_data["rules.cfg"][section_name].has(key):
		return false
	
	var current_value = current_data["rules.cfg"][section_name][key]
	var default_value = default_data["rules.cfg"][section_name][key]
	return current_value != default_value


func is_section_different(section_name: String) -> bool:
	if not current_data.has("rules.cfg") or not current_data["rules.cfg"].has(section_name):
		return false
	
	var current_section = current_data["rules.cfg"][section_name]
	
	# Handle array format (for research/sacrifices)
	if current_section is Array:
		# For arrays, we need to compare the entire array structure
		if not default_data.has("rules.cfg") or not default_data["rules.cfg"].has(section_name):
			return true
		
		var default_section = default_data["rules.cfg"][section_name]
		if not (default_section is Array):
			return true
		
		if current_section.size() != default_section.size():
			return true
		
		for i in range(current_section.size()):
			if current_section[i] != default_section[i]:
				return true
		
		return false
	else:
		# Handle dictionary format (for other sections)
		for key in current_section.keys():
			if is_item_different(section_name, key):
				return true
		
		if default_data.has("rules.cfg") and default_data["rules.cfg"].has(section_name):
			var default_section = default_data["rules.cfg"][section_name]
			if default_section is Dictionary:
				for key in default_section.keys():
					if not current_section.has(key):
						return true
		
		if section_name == "sacrifices":
			if not default_data.has("rules.cfg") or not default_data["rules.cfg"].has(section_name):
				return true
			if current_section is Dictionary:
				var current_keys = current_section.keys()
				var default_section = default_data["rules.cfg"][section_name]
				if default_section is Dictionary:
					var default_keys = default_section.keys()
					if current_keys.size() > default_keys.size():
						return true
	
	return false


func notify_file_created(file_path, file_type):
	if not paths_loaded[LOAD_CFG_CURRENT_MAP].has(file_path):
		paths_loaded[LOAD_CFG_CURRENT_MAP].append(file_path)
	emit_signal("config_file_status_changed")
	print("oConfigFileManager: Tracked new file - " + file_type + ": " + file_path)


func notify_file_deleted(file_path, file_type):
	if paths_loaded[LOAD_CFG_CURRENT_MAP].has(file_path):
		paths_loaded[LOAD_CFG_CURRENT_MAP].erase(file_path)
	emit_signal("config_file_status_changed")
	print("oConfigFileManager: Removed tracking for file - " + file_type + ": " + file_path) 
