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


func _ready():
	clear_paths()


func clear_paths():
	paths_loaded = {
		LOAD_CFG_DATA: [],
		LOAD_CFG_FXDATA: [],
		LOAD_CFG_CAMPAIGN: [],
		LOAD_CFG_CURRENT_MAP: []
	}
	emit_signal("config_file_status_changed")


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
