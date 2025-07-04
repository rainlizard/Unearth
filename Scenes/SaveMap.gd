extends Node

onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oDataLua = Nodelist.list["oDataLua"]
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oMenuButtonFile = Nodelist.list["oMenuButtonFile"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]

var queueExit = false

func _input(event):
	if event.is_action_pressed("save"):
		oMenu.pressed_save_keyboard_shortcut()

func save_map(filePath):
	var map_basename_with_ext = filePath.get_file()
	var map_filename_no_ext = map_basename_with_ext.get_basename()
	var map_base_dir = filePath.get_base_dir()
	var SAVETIME_START = OS.get_ticks_msec()
	delete_existing_files(filePath)
	
	var script_definitions = [
		{"key": "TXT", "enabled": oCurrentMap.DKScript_enabled, "ext": ".txt", "display": "DKScript"},
		{"key": "LUA", "enabled": oCurrentMap.LuaScript_enabled, "ext": ".lua", "display": "LuaScript"}
	]
	for script_def in script_definitions:
		if not script_def.enabled:
			delete_script_file(map_filename_no_ext, map_base_dir, script_def.key, script_def.ext, script_def.display)

	oDataClm.update_all_utilized()
	var writeFailure = false
	for EXT in oBuffers.FILE_TYPES:
		var saveToFilePath = map_base_dir.plus_file(map_filename_no_ext + '.' + EXT.to_lower())
		var should_process = oBuffers.should_process_file_type(EXT)
		if should_process:
			if oBuffers.write(saveToFilePath, EXT.to_upper()) != OK:
				writeFailure = true
		
		if File.new().file_exists(saveToFilePath):
			var modTime = File.new().get_modified_time(saveToFilePath)
			var precise_path = Utils.case_insensitive_file(map_base_dir, saveToFilePath.get_file().get_basename(), saveToFilePath.get_extension())
			oCurrentMap.currentFilePaths[EXT] = [precise_path if precise_path else saveToFilePath, modTime]
		elif oCurrentMap.currentFilePaths.has(EXT):
			var path_info = oCurrentMap.currentFilePaths[EXT]
			var is_valid_path = typeof(path_info) == TYPE_ARRAY and path_info.size() > oCurrentMap.PATHSTRING and File.new().file_exists(path_info[oCurrentMap.PATHSTRING])
			if not should_process and not is_valid_path:
				oCurrentMap.currentFilePaths.erase(EXT)
			elif should_process:
				oCurrentMap.currentFilePaths.erase(EXT)

	if writeFailure:
		oMessage.big("Error", "Saving failed. Try saving to a different directory.")
		return

	# Handle slabset.toml and columnset.toml files
	save_slabset_toml(map_filename_no_ext, map_base_dir)
	save_columnset_toml(map_filename_no_ext, map_base_dir)

	print('Total time to save: ' + str(OS.get_ticks_msec() - SAVETIME_START) + 'ms')
	if oDataScript.data == "" and oDataLua.data == "":
		oMessage.big("Warning", "Your map has no script. In Map Settings, create a script then click 'Script Generator' to add basic functionality.")
	oMessage.quick('Saved map')
	oCurrentMap.set_path_and_title(filePath)
	oEditor.mapHasBeenEdited = false
	oScriptEditor.set_script_as_edited(false)
	oDataClm.store_default_data()
	oMapSettingsWindow.visible = false
	if queueExit:
		get_tree().quit()

func delete_script_file(map_filename_no_ext, map_base_dir, script_key, file_ext, display_name):
	var script_target_filename = map_filename_no_ext + file_ext
	var path_to_delete = ""
	if oCurrentMap.currentFilePaths.has(script_key):
		var path_info = oCurrentMap.currentFilePaths[script_key]
		if typeof(path_info) == TYPE_ARRAY and path_info.size() > oCurrentMap.PATHSTRING:
			path_to_delete = path_info[oCurrentMap.PATHSTRING]
	if path_to_delete == "" or not File.new().file_exists(path_to_delete):
		path_to_delete = Utils.case_insensitive_file(map_base_dir, script_target_filename.get_basename(), script_target_filename.get_extension())
	if path_to_delete == "" or not File.new().file_exists(path_to_delete):
		return

	var global_path = ProjectSettings.globalize_path(path_to_delete)
	var err_trash = OS.move_to_trash(global_path)
	if err_trash == OK:
		print("Moved disabled " + display_name + " file to trash: " + path_to_delete.get_file())
		if oCurrentMap.currentFilePaths.has(script_key):
			oCurrentMap.currentFilePaths.erase(script_key)
	else:
		var msg = "Error trashing " + display_name + " file: " + path_to_delete.get_file()
		oMessage.quick(msg)
		print(msg + " Code: " + str(err_trash))

func delete_existing_files(map_file_path):
	var fileTypesToDelete = []
	var baseDirectory = map_file_path.get_base_dir()
	var MAP_NAME_NO_EXT = map_file_path.get_file().get_basename().to_upper()

	if OS.get_name() == "X11":
		fileTypesToDelete = oBuffers.FILE_TYPES
	elif oCurrentFormat.selected == Constants.ClassicFormat:
		fileTypesToDelete = ["TNGFX", "APTFX", "LGTFX"]
	elif oCurrentFormat.selected == Constants.KfxFormat:
		fileTypesToDelete = ["LIF", "TNG", "APT", "LGT"]
	if fileTypesToDelete.empty():
		return

	var dir = Directory.new()
	if dir.open(baseDirectory) != OK:
		print("An error occurred when trying to access " + baseDirectory)
		return
	dir.list_dir_begin(true, false)
	var fileName = dir.get_next()
	while fileName != "":
		if MAP_NAME_NO_EXT in fileName.to_upper() and fileTypesToDelete.has(fileName.get_extension().to_upper()):
			if dir.file_exists(fileName):
				print("Deleted due to format conflict/OS: " + fileName)
				dir.remove(fileName)
		fileName = dir.get_next()


func clicked_save_on_menu():
	save_map(oCurrentMap.path)


func save_slabset_toml(map_filename_no_ext, map_base_dir):
	var slabset_file_path = map_base_dir.plus_file(map_filename_no_ext + ".slabset.toml")
	if Slabset.export_toml_slabset(slabset_file_path):
		oConfigFileManager.notify_file_created(slabset_file_path, "slabset.toml")
	else:
		delete_toml_file_if_exists(slabset_file_path, "slabset.toml")


func save_columnset_toml(map_filename_no_ext, map_base_dir):
	var columnset_file_path = map_base_dir.plus_file(map_filename_no_ext + ".columnset.toml")
	if Columnset.export_toml_columnset(columnset_file_path):
		oConfigFileManager.notify_file_created(columnset_file_path, "columnset.toml")
	else:
		delete_toml_file_if_exists(columnset_file_path, "columnset.toml")


func delete_toml_file_if_exists(file_path, file_type):
	if File.new().file_exists(file_path):
		var global_path = ProjectSettings.globalize_path(file_path)
		var err_trash = OS.move_to_trash(global_path)
		if err_trash == OK:
			print("Moved unmodified " + file_type + " file to trash: " + file_path.get_file())
			oConfigFileManager.notify_file_deleted(file_path, file_type)
		else:
			print("Error trashing " + file_type + " file: " + file_path.get_file() + " Code: " + str(err_trash))
