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
	default_data = {}
	emit_signal("config_file_status_changed")


func store_default_data():
	if not DATA_RULES.empty():
		default_data = DATA_RULES.duplicate(true)


func is_item_different(section_name: String, key: String) -> bool:
	if not default_data.has(section_name) or not default_data[section_name].has(key):
		return false
	
	var current_value = DATA_RULES[section_name][key]
	var default_value = default_data[section_name][key]
	return current_value != default_value


func is_section_different(section_name: String) -> bool:
	if not DATA_RULES.has(section_name):
		return false
	
	for key in DATA_RULES[section_name].keys():
		if is_item_different(section_name, key):
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
