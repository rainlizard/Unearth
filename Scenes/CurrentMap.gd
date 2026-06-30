extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oGame = Nodelist.list["oGame"]
onready var oUiTools = Nodelist.list["oUiTools"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oMain = Nodelist.list["oMain"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptMarkers = Nodelist.list["oScriptMarkers"]
onready var oDataFakeSlab = Nodelist.list["oDataFakeSlab"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]
onready var oDataLua = Nodelist.list["oDataLua"]
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oUiSystem = Nodelist.list["oUiSystem"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oActionPointList = Nodelist.list["oActionPointList"]

var path = ""
var currentFilePaths = {} # [0] = pathString,  [1] = modified date
var loaded_from_backup = false
var DKScript_enabled = false
var LuaScript_enabled = false
var configFileModifiedTimes = {}
var missingMapFileModifiedTimes = {}
var lastExternalChangeWarningKey = ""

var existing_slabset_file = ""
var existing_rules_file = ""
var existing_columnset_file = ""
var existing_cubes_file = ""

enum {
	PATHSTRING
	MODIFIED_DATE
}

const CONFIG_FILE_NAMES = ["rules.cfg", "slabset.toml", "columnset.toml", "cubes.cfg"]
const SCRIPT_FILE_TYPES = ["TXT", "LUA"]


func _init():
	OS.set_window_title('Unearth v'+Version.full)

func _ready():
	oConfigFileManager.connect("config_file_status_changed", self, "_on_config_status_changed")

func _on_config_status_changed():
	update_config_paths(true)

func _on_ButtonNewMap_pressed():
	oOpenMap.open_map("") # This means "blank" map


func set_path_and_title(newpath):
	if newpath != "":
		OS.set_window_title(newpath + ' - Unearth v'+Version.full)
		if loaded_from_backup == false:
			oMenu.add_recent(newpath) # Add saved maps to the recent menu
	else:
		OS.set_window_title('Unearth v'+Version.full)
	path = newpath
	
	oGame.reconstruct_command_line() # Always update command line whenever the path changes

func clear_map(): # Remember, "Undo" calls this
	var CODETIME_START = OS.get_ticks_msec()
	
	oInstances.clear_all_instances()
	oActionPointList.update_if_visible()
	
	# "lif"
	oDataMapName.clear()
	# "wib"
	oDataSlx.clear_img()
	oOverheadOwnership.clear()
	# "inf"
	oDataLevelStyle.data = 0
	# 3D
	oGenerateTerrain.clear()
	
	oScriptMarkers.clear()
	
	# "LOF" # Do this last in case other functions rely on the old map size
	oDataLof.clear_all()
	
	print('Cleared map in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func _notification(what: int):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		if loaded_from_backup == true:
			return
		check_script_file_modifications()
		warn_if_external_files_changed()

func get_meaningful_file_path(fileName):
	for cfg_type in [oConfigFileManager.LOAD_CFG_CURRENT_MAP, oConfigFileManager.LOAD_CFG_CAMPAIGN]:
		if oConfigFileManager.paths_loaded.has(cfg_type):
			for loaded_path in oConfigFileManager.paths_loaded[cfg_type]:
				if loaded_path and loaded_path.to_lower().ends_with(fileName):
					return loaded_path
	return ""

func update_config_paths(refresh_modified_times = false):
	existing_slabset_file = get_meaningful_file_path("slabset.toml")
	existing_columnset_file = get_meaningful_file_path("columnset.toml") 
	existing_cubes_file = get_meaningful_file_path("cubes.cfg")
	existing_rules_file = get_meaningful_file_path("rules.cfg")
	if refresh_modified_times:
		store_config_file_modified_times()


func warn_if_external_files_changed():
	if path == "":
		return
	var changed_files = get_changed_external_files()
	if changed_files.empty():
		return
	var changed_file_paths = changed_files.keys()
	changed_file_paths.sort()
	if oEditor.mapHasBeenEdited == false:
		oOpenMap.open_map(path, false, false)
		var changed_file_names = []
		for file_path in changed_file_paths:
			changed_file_names.append(file_path.get_file())
		oMessage.quick("Map reloaded because file was edited externally: " + ", ".join(changed_file_names))
		return
	var warning_key = ""
	for file_path in changed_file_paths:
		warning_key += file_path + ":" + str(changed_files[file_path]) + "\n"
	if warning_key == lastExternalChangeWarningKey:
		return
	lastExternalChangeWarningKey = warning_key
	var message = "Some files for this map were edited outside Unearth:\n"
	message += "\n".join(changed_file_paths) + "\n\n"
	message += "Click Reload to discard your unsaved map editor changes and keep your external changes.\n"
	message += "Or click Save to discard your external changes and keep your unsaved map editor changes."
	show_external_changes_dialog(message)


func show_external_changes_dialog(message):
	var dialog = ConfirmationDialog.new()
	dialog.window_title = "External changes detected"
	dialog.dialog_text = message
	dialog.get_ok().text = "Reload map"
	dialog.get_cancel().text = "Save map"
	dialog.popup_exclusive = true
	dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	if dialog.has_method("get_close_button"):
		dialog.get_close_button().hide()
	oUiSystem.add_child(dialog)
	dialog.get_ok().connect("pressed", self, "_on_external_changes_reload_pressed", [dialog, path], CONNECT_ONESHOT)
	dialog.get_cancel().connect("pressed", self, "_on_external_changes_save_pressed", [dialog, path], CONNECT_ONESHOT)
	dialog.connect("popup_hide", get_tree(), "set", ["paused", false], CONNECT_ONESHOT)
	dialog.connect("popup_hide", self, "set", ["lastExternalChangeWarningKey", ""], CONNECT_ONESHOT)
	dialog.popup_centered()
	get_tree().paused = true
	dialog.connect("popup_hide", dialog, "queue_free", [], CONNECT_ONESHOT)
	dialog.get_ok().grab_focus()


func _on_external_changes_reload_pressed(dialog, map_path):
	get_tree().paused = false
	if is_instance_valid(dialog):
		dialog.hide()
	oOpenMap.open_map(map_path, true, false)


func _on_external_changes_save_pressed(dialog, map_path):
	get_tree().paused = false
	if is_instance_valid(dialog):
		dialog.hide()
	oSaveMap.save_map(map_path)


func get_changed_external_files():
	var changed_files = {}
	for file_type in currentFilePaths.keys():
		if SCRIPT_FILE_TYPES.has(file_type):
			continue
		var file_info = currentFilePaths[file_type]
		if typeof(file_info) == TYPE_ARRAY and file_info.size() > MODIFIED_DATE:
			add_if_modified(changed_files, file_info[PATHSTRING], file_info[MODIFIED_DATE])
	for file_path in configFileModifiedTimes.keys():
		add_if_modified(changed_files, file_path, configFileModifiedTimes.get(file_path))
	for file_path in missingMapFileModifiedTimes.keys():
		if SCRIPT_FILE_TYPES.has(file_path.get_extension().to_upper()):
			continue
		add_if_modified(changed_files, file_path, missingMapFileModifiedTimes.get(file_path))
	return changed_files


func script_file_auto_reloads(file_type):
	var enabled_script = (file_type == "TXT" and DKScript_enabled) or (file_type == "LUA" and LuaScript_enabled)
	if enabled_script == false:
		return false
	if currentFilePaths.has(file_type) == false:
		return false
	var file_info = currentFilePaths[file_type]
	if typeof(file_info) != TYPE_ARRAY or file_info.size() <= PATHSTRING:
		return false
	return File.new().file_exists(file_info[PATHSTRING])


func add_if_modified(changed_files, file_path, stored_modified_time = null):
	if file_path == "" or stored_modified_time == null:
		return
	var current_modified_time = get_file_modified_time(file_path)
	if current_modified_time != stored_modified_time:
		changed_files[file_path] = current_modified_time


func get_tracked_config_file_paths(map_path = ""):
	var paths = {}
	if map_path == "":
		map_path = path
	if oConfigFileManager.current_mappack_cfg_path != "":
		paths[oConfigFileManager.current_mappack_cfg_path] = true
	for load_cfg_type in oConfigFileManager.paths_loaded.keys():
		for file_path in oConfigFileManager.paths_loaded.get(load_cfg_type, []):
			if file_path == "":
				continue
			if load_cfg_type == oConfigFileManager.LOAD_CFG_CURRENT_MAP or load_cfg_type == oConfigFileManager.LOAD_CFG_CAMPAIGN:
				paths[file_path] = true
			if load_cfg_type != oConfigFileManager.LOAD_CFG_CURRENT_MAP and map_path != "" and (file_path.get_extension().to_lower() == "cfg" or file_path.get_extension().to_lower() == "toml"):
				paths[map_path.get_basename() + "." + file_path.get_file()] = true
	if map_path != "":
		for file_name in CONFIG_FILE_NAMES:
			paths[map_path.get_basename() + "." + file_name] = true
	return paths.keys()


func store_config_file_modified_times():
	configFileModifiedTimes.clear()
	for file_path in get_tracked_config_file_paths():
		configFileModifiedTimes[file_path] = get_file_modified_time(file_path)
	missingMapFileModifiedTimes.clear()
	if path != "":
		for file_type in oBuffers.FILE_TYPES:
			if SCRIPT_FILE_TYPES.has(file_type):
				continue
			if currentFilePaths.has(file_type) == false:
				var file_path = path.get_basename() + "." + file_type.to_lower()
				missingMapFileModifiedTimes[file_path] = get_file_modified_time(file_path)
	lastExternalChangeWarningKey = ""


func get_file_modified_time(file_path):
	var file = File.new()
	if file.file_exists(file_path):
		return file.get_modified_time(file_path)
	var precise_path = Utils.case_insensitive_file(file_path.get_base_dir(), file_path.get_file().get_basename(), file_path.get_extension())
	if precise_path != "":
		return file.get_modified_time(precise_path)
	return 0


func check_script_file_modifications():
	reload_script_file("TXT", oDataScript, "Script reloaded from file.", true)
	reload_script_file("LUA", oDataLua, "Lua script reloaded from file.", false)


func reload_script_file(file_type, data_node, message, update_editor):
	if script_file_auto_reloads(file_type) == false:
		return
	var file_info = currentFilePaths[file_type]
	var file_path = file_info[PATHSTRING]
	var current_modified_time = get_file_modified_time(file_path)
	if file_info[MODIFIED_DATE] == current_modified_time:
		return
	var file = File.new()
	if file.file_exists(file_path) == false:
		return
	file_info[MODIFIED_DATE] = current_modified_time
	if file.open(file_path, File.READ) == OK:
		data_node.data = file.get_as_text()
		file.close()
		oMessage.quick(message)
		if update_editor:
			oScriptEditor.update_texteditor()
			oScriptEditor.set_script_as_edited(false)
