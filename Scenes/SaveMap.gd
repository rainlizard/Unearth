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
	print("DEBUG save_map: About to save slabset.toml, map_filename_no_ext=" + map_filename_no_ext + ", map_base_dir=" + map_base_dir)
	print("DEBUG save_map: oCurrentlyOpenSlabset tooltip before save: '" + Nodelist.list["oCurrentlyOpenSlabset"].hint_tooltip + "'")
	save_toml_file("slabset.toml", "oCurrentlyOpenSlabset", map_filename_no_ext, map_base_dir)
	print("DEBUG save_map: oCurrentlyOpenSlabset tooltip after slabset save: '" + Nodelist.list["oCurrentlyOpenSlabset"].hint_tooltip + "'")
	
	print("DEBUG save_map: About to save columnset.toml")
	print("DEBUG save_map: oCurrentlyOpenColumnset tooltip before save: '" + Nodelist.list["oCurrentlyOpenColumnset"].hint_tooltip + "'")
	save_toml_file("columnset.toml", "oCurrentlyOpenColumnset", map_filename_no_ext, map_base_dir)
	print("DEBUG save_map: oCurrentlyOpenColumnset tooltip after columnset save: '" + Nodelist.list["oCurrentlyOpenColumnset"].hint_tooltip + "'")
	
	# Handle rules.cfg file
	save_rules_cfg_file("rules.cfg", "oCurrentlyOpenRules", map_filename_no_ext, map_base_dir)

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


func save_toml_file(file_type, ui_label_name, map_filename_no_ext, map_base_dir):
	print("DEBUG save_toml_file: Starting with file_type=" + file_type + ", ui_label_name=" + ui_label_name)
	print("DEBUG save_toml_file: map_filename_no_ext=" + map_filename_no_ext + ", map_base_dir=" + map_base_dir)
	
	var file_path
	var config_type = oConfigFileManager.LOAD_CFG_CURRENT_MAP
	print("DEBUG save_toml_file: Initial config_type=" + str(config_type))
	
	# Check if there's an existing file from the UI tooltip
	var ui_label = Nodelist.list[ui_label_name]
	print("DEBUG save_toml_file: Got ui_label for " + ui_label_name)
	var existing_file_path = ui_label.hint_tooltip
	print("DEBUG save_toml_file: existing_file_path from tooltip='" + existing_file_path + "'")
	
	if existing_file_path != "" and existing_file_path != "No saved file":
		print("DEBUG save_toml_file: Using existing file path")
		# Use the existing file path (campaign or local)
		file_path = existing_file_path
		print("DEBUG save_toml_file: Set file_path to existing path=" + file_path)
		print("DEBUG save_toml_file: existing_file_path.get_file()=" + existing_file_path.get_file() + ", file_type=" + file_type)
		if existing_file_path.get_file() == file_type:
			print("DEBUG save_toml_file: File matches type, setting config_type to CAMPAIGN")
			config_type = oConfigFileManager.LOAD_CFG_CAMPAIGN
		else:
			print("DEBUG save_toml_file: File does NOT match type, keeping config_type as CURRENT_MAP")
	else:
		print("DEBUG save_toml_file: No existing file, defaulting to local file")
		# Default to local file
		file_path = map_base_dir.plus_file(map_filename_no_ext + "." + file_type)
		print("DEBUG save_toml_file: Set file_path to local=" + file_path)
	
	print("DEBUG save_toml_file: Final file_path=" + file_path)
	print("DEBUG save_toml_file: Final config_type=" + str(config_type))
	
	var export_success = false
	match file_type:
		"slabset.toml":
			print("DEBUG save_toml_file: Calling Slabset.export_toml_slabset with path=" + file_path)
			export_success = Slabset.export_toml_slabset(file_path)
		"columnset.toml":
			print("DEBUG save_toml_file: Calling Columnset.export_toml_columnset with path=" + file_path)
			export_success = Columnset.export_toml_columnset(file_path)
	
	print("DEBUG save_toml_file: Export success=" + str(export_success))
	
	if export_success:
		print("DEBUG save_toml_file: Export successful, processing config type=" + str(config_type))
		if config_type == oConfigFileManager.LOAD_CFG_CAMPAIGN:
			print("DEBUG save_toml_file: Processing as CAMPAIGN file")
			if not oConfigFileManager.paths_loaded[config_type].has(file_path):
				print("DEBUG save_toml_file: Adding path to campaign paths_loaded")
				oConfigFileManager.paths_loaded[config_type].append(file_path)
			else:
				print("DEBUG save_toml_file: Path already in campaign paths_loaded")
			oConfigFileManager.emit_signal("config_file_status_changed")
		else:
			print("DEBUG save_toml_file: Processing as LOCAL/CURRENT_MAP file")
			oConfigFileManager.notify_file_created(file_path, file_type)
		print("Saved " + file_type.get_basename() + " to: " + file_path)
	else:
		print("DEBUG save_toml_file: Export failed, attempting to delete file")
		delete_toml_file_if_exists(file_path, file_type)



func delete_toml_file_if_exists(file_path, file_type):
	if File.new().file_exists(file_path):
		var global_path = ProjectSettings.globalize_path(file_path)
		var err_trash = OS.move_to_trash(global_path)
		if err_trash == OK:
			print("Moved unmodified " + file_type + " file to trash: " + file_path.get_file())
			oConfigFileManager.notify_file_deleted(file_path, file_type)
		else:
			print("Error trashing " + file_type + " file: " + file_path.get_file() + " Code: " + str(err_trash))


func save_rules_cfg_file(file_type, ui_label_name, map_filename_no_ext, map_base_dir):
	var file_path
	var config_type = oConfigFileManager.LOAD_CFG_CURRENT_MAP
	
	var ui_label = Nodelist.list[ui_label_name]
	var existing_file_path = ui_label.hint_tooltip
	
	if existing_file_path != "" and existing_file_path != "No saved file":
		file_path = existing_file_path
		if existing_file_path.get_file() == file_type:
			config_type = oConfigFileManager.LOAD_CFG_CAMPAIGN
	else:
		file_path = map_base_dir.plus_file(map_filename_no_ext + "." + file_type)
	
	var export_success = export_rules_cfg(file_path)
	
	if export_success:
		if config_type == oConfigFileManager.LOAD_CFG_CAMPAIGN:
			if not oConfigFileManager.paths_loaded[config_type].has(file_path):
				oConfigFileManager.paths_loaded[config_type].append(file_path)
			oConfigFileManager.emit_signal("config_file_status_changed")
		else:
			oConfigFileManager.notify_file_created(file_path, file_type)
		print("Saved " + file_type.get_basename() + " to: " + file_path)
	else:
		delete_rules_cfg_file_if_exists(file_path, file_type)


func export_rules_cfg(file_path):
	if not oConfigFileManager.current_data.has("rules.cfg") or oConfigFileManager.current_data["rules.cfg"].empty():
		return false
	
	var has_any_changes = false
	var sections_to_export = {}
	var rules_data = oConfigFileManager.current_data["rules.cfg"]
	
	for section_name in rules_data.keys():
		var section_data = rules_data[section_name]
		
		if section_name == "research" or section_name == "sacrifices":
			if oConfigFileManager.is_section_different(section_name):
				sections_to_export[section_name] = section_data
				has_any_changes = true
		else:
			var modified_keys = {}
			if section_data is Dictionary:
				for key in section_data.keys():
					if oConfigFileManager.is_item_different(section_name, key):
						modified_keys[key] = section_data[key]
						has_any_changes = true
			if not modified_keys.empty():
				sections_to_export[section_name] = modified_keys
	
	if not has_any_changes:
		return false
	
	var file = File.new()
	if file.open(file_path, File.WRITE) != OK:
		return false
	
	for section_name in sections_to_export.keys():
		file.store_line("[" + section_name + "]")
		var section_data = sections_to_export[section_name]
		
		if section_name == "research" and section_data is Array:
			for item in section_data:
				if item is Array and item.size() >= 3:
					var research_type = str(item[0])
					var research_item = str(item[1])
					var research_cost = str(item[2])
					file.store_line("Research = " + research_type + " " + research_item + " " + research_cost)
		elif section_name == "sacrifices" and section_data is Array:
			for item in section_data:
				if item is Array and item.size() >= 2:
					var command = str(item[0])
					var result = str(item[1])
					var ingredients = []
					for i in range(2, item.size()):
						ingredients.append(str(item[i]))
					if ingredients.size() > 0:
						var ingredients_text = " ".join(ingredients)
						file.store_line(command + " = " + result + " " + ingredients_text)
					else:
						file.store_line(command + " = " + result)
		elif section_data is Dictionary:
			for key in section_data.keys():
				var value = section_data[key]
				if value is Array:
					if value.empty():
						file.store_line(key + " = ")
					else:
						var str_values = []
						for v in value:
							str_values.append(str(v))
						file.store_line(key + " = " + " ".join(str_values))
				else:
					file.store_line(key + " = " + str(value))
		
		file.store_line("")
	
	file.close()
	return true


func delete_rules_cfg_file_if_exists(file_path, file_type):
	if File.new().file_exists(file_path):
		var global_path = ProjectSettings.globalize_path(file_path)
		var err_trash = OS.move_to_trash(global_path)
		if err_trash == OK:
			print("Moved unmodified " + file_type + " file to trash: " + file_path.get_file())
			oConfigFileManager.notify_file_deleted(file_path, file_type)
		else:
			print("Error trashing " + file_type + " file: " + file_path.get_file() + " Code: " + str(err_trash))


