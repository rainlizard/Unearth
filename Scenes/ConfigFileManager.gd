extends Node

onready var oCfgLoader = Nodelist.list["oCfgLoader"]

signal config_file_status_changed()

enum {
	LOAD_CFG_DATA,
	LOAD_CFG_FXDATA,
	LOAD_CFG_CAMPAIGN,
	LOAD_CFG_CURRENT_MAP,
}
var paths_loaded = {}

var DATA_RULES = {}
var DATA_MAGIC = {}
var DATA_ROOMS = {}
var FXDATA_COMMENTS = {}
var default_data = {}


func _ready():
	clear_paths()


func clear_paths():
	paths_loaded = {
		LOAD_CFG_DATA: [],
		LOAD_CFG_FXDATA: [],
		LOAD_CFG_CAMPAIGN: [],
		LOAD_CFG_CURRENT_MAP: []
	}
	DATA_RULES = {}
	DATA_MAGIC = {}
	DATA_ROOMS = {}
	FXDATA_COMMENTS = {}
	default_data = {}
	emit_signal("config_file_status_changed")


func store_default_data():
	if not DATA_RULES.empty():
		default_data["rules.cfg"] = DATA_RULES.duplicate(true)


func get_comments_for_key(filename: String, section_name: String, key: String) -> Array:
	if FXDATA_COMMENTS.has(filename) and FXDATA_COMMENTS[filename].has(section_name) and FXDATA_COMMENTS[filename][section_name].has(key):
		return FXDATA_COMMENTS[filename][section_name][key]
	return []


func is_item_different(section_name: String, key: String) -> bool:
	if not default_data.has("rules.cfg") or not default_data["rules.cfg"].has(section_name) or not default_data["rules.cfg"][section_name].has(key):
		return false
	
	if not DATA_RULES.has(section_name) or not DATA_RULES[section_name].has(key):
		return false
	
	var current_value = DATA_RULES[section_name][key]
	var default_value = default_data["rules.cfg"][section_name][key]
	return current_value != default_value


func is_section_different(section_name: String) -> bool:
	if not DATA_RULES.has(section_name):
		return false
	
	var current_section = DATA_RULES[section_name]
	
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
			for key in default_data["rules.cfg"][section_name].keys():
				if not current_section.has(key):
					return true
		
		if section_name == "sacrifices":
			if not default_data.has("rules.cfg") or not default_data["rules.cfg"].has(section_name):
				return true
			var current_keys = current_section.keys()
			var default_keys = default_data["rules.cfg"][section_name].keys()
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
