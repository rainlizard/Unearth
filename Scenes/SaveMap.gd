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
onready var oCfgLoader = Nodelist.list["oCfgLoader"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oMapBackups = Nodelist.list["oMapBackups"]

var queueExit = false

func _input(event):
	if event.is_action_pressed("save"):
		oMenu.pressed_save_keyboard_shortcut()

func save_map(filePath):
	var map_basename_with_ext = filePath.get_file()
	var map_filename_no_ext = map_basename_with_ext.get_basename()
	var map_base_dir = filePath.get_base_dir()
	var SAVETIME_START = OS.get_ticks_msec()

	if oMapBackups.backup_existing_map_files(filePath) == false:
		oMessage.big("Error", "Saving cancelled because the existing map files could not be backed up. Try moving Unearth to a writable directory.")
		queueExit = false
		return false
	
	var script_definitions = [
		{"key": "TXT", "enabled": oCurrentMap.DKScript_enabled, "ext": ".txt", "display": "DKScript"},
		{"key": "LUA", "enabled": oCurrentMap.LuaScript_enabled, "ext": ".lua", "display": "LuaScript"}
	]
	for script_def in script_definitions:
		if script_def.enabled == false:
			delete_script_file(map_filename_no_ext, map_base_dir, script_def, filePath)
	delete_existing_files(filePath)

	oDataClm.update_all_utilized()
	var writeFailure = false
	for EXT in oBuffers.FILE_TYPES:
		var saveToFilePath = get_save_path(map_base_dir, map_filename_no_ext, EXT)
		if OS.get_name() == "X11":
			delete_map_files(map_base_dir, map_filename_no_ext, EXT, saveToFilePath)
		var should_process = oBuffers.should_process_file_type(EXT)
		if should_process:
			if oBuffers.write(saveToFilePath, EXT.to_upper()) != OK:
				writeFailure = true
		
		var should_record_file = should_process or oCurrentMap.currentFilePaths.has(EXT)
		if File.new().file_exists(saveToFilePath) and should_record_file:
			var modTime = File.new().get_modified_time(saveToFilePath)
			var precise_path = Utils.case_insensitive_file(map_base_dir, saveToFilePath.get_file().get_basename(), saveToFilePath.get_extension())
			var path_to_record = saveToFilePath
			if precise_path != "":
				path_to_record = precise_path
			oCurrentMap.currentFilePaths[EXT] = [path_to_record, modTime]
		elif oCurrentMap.currentFilePaths.has(EXT):
			var path_info = oCurrentMap.currentFilePaths[EXT]
			var is_valid_path = typeof(path_info) == TYPE_ARRAY and path_info.size() > oCurrentMap.PATHSTRING and File.new().file_exists(path_info[oCurrentMap.PATHSTRING])
			if should_process == false and is_valid_path == false:
				oCurrentMap.currentFilePaths.erase(EXT)
			elif should_process:
				oCurrentMap.currentFilePaths.erase(EXT)

	if oCurrentFormat.selected == Constants.KfxFormat:
		var campaignFile = oCfgLoader.get_campaign_boss_file(filePath)
		if oDataLof.write_campaign_map_size(filePath, campaignFile) == false:
			writeFailure = true
		else:
			oCfgLoader.load_campaign_boss_file(filePath)

	if writeFailure:
		oMessage.big("Error", "Saving failed. Try saving to a different directory.")
		queueExit = false
		return false

	if oCurrentMap.loaded_from_backup == false and oConfigFileManager.copy_current_map_files(oCurrentMap.path, filePath) == false:
		oMessage.big("Error", "Saving failed while copying map config files. Try saving to a different directory.")
		queueExit = false
		return false
	oCurrentMap.update_config_paths(false)

	if save_config_files(map_filename_no_ext, map_base_dir) == false:
		oMessage.big("Error", "Saving failed while writing map config files. Try saving to a different directory.")
		queueExit = false
		return false

	print('Total time to save: ' + str(OS.get_ticks_msec() - SAVETIME_START) + 'ms')
	if oDataScript.data == "" and oDataLua.data == "":
		oMessage.big("Warning", "Your map has no script. In Map Settings, create a script then click 'Script Generator' to add basic functionality.")
	oMessage.quick('Saved map')
	oCurrentMap.set_path_and_title(filePath)
	oCurrentMap.loaded_from_backup = false
	oCurrentMap.update_config_paths(true)
	oEditor.mapHasBeenEdited = false
	oScriptEditor.set_script_as_edited(false)
	oDataClm.store_default_data()
	Slabset.store_loaded_data()
	Columnset.store_loaded_data()
	oMapSettingsWindow.visible = false
	if queueExit:
		get_tree().quit()
	return true


func get_save_path(map_base_dir, map_filename_no_ext, EXT):
	var save_to_file_path = map_base_dir.plus_file(map_filename_no_ext + "." + EXT.to_lower())
	var precise_path = Utils.case_insensitive_file(map_base_dir, map_filename_no_ext, EXT)
	if precise_path != "":
		return precise_path
	return save_to_file_path


func is_same_map(map_file_path):
	if oCurrentMap.path == "":
		return false
	if oCurrentMap.path.get_base_dir().to_upper() != map_file_path.get_base_dir().to_upper():
		return false
	return oCurrentMap.path.get_file().get_basename().to_upper() == map_file_path.get_file().get_basename().to_upper()


func get_script_path(map_filename_no_ext, map_base_dir, file_ext):
	var filename = map_filename_no_ext + file_ext
	var precise_path = Utils.case_insensitive_file(map_base_dir, filename.get_basename(), filename.get_extension())
	if precise_path != "":
		return precise_path
	return map_base_dir.plus_file(filename)


func delete_script_file(map_filename_no_ext, map_base_dir, script_def, map_file_path):
	var target_path = get_script_path(map_filename_no_ext, map_base_dir, script_def.ext)
	var tracked_path = ""
	if oCurrentMap.currentFilePaths.has(script_def.key) == true:
		var path_info = oCurrentMap.currentFilePaths[script_def.key]
		if typeof(path_info) == TYPE_ARRAY and path_info.size() > oCurrentMap.PATHSTRING:
			tracked_path = path_info[oCurrentMap.PATHSTRING]
	var should_delete = tracked_path != "" and tracked_path.to_upper() == target_path.to_upper()
	if should_delete == false:
		var has_tracked_script = oCurrentMap.currentFilePaths.has(script_def.key)
		if is_same_map(map_file_path) == false and has_tracked_script == true:
			oCurrentMap.currentFilePaths.erase(script_def.key)
		return
	if File.new().file_exists(target_path) == false:
		oCurrentMap.currentFilePaths.erase(script_def.key)
		return
	var err_trash = OS.move_to_trash(ProjectSettings.globalize_path(target_path))
	if err_trash == OK:
		print("Moved disabled " + script_def.display + " file to trash: " + target_path.get_file())
		oCurrentMap.currentFilePaths.erase(script_def.key)
	else:
		var msg = "Error trashing " + script_def.display + " file: " + target_path.get_file()
		oMessage.quick(msg)
		print(msg + " Code: " + str(err_trash))


func delete_existing_files(map_file_path):
	var file_types_to_delete = []
	var base_directory = map_file_path.get_base_dir()
	var map_name_no_ext = map_file_path.get_file().get_basename()
	if oCurrentFormat.selected == Constants.ClassicFormat:
		file_types_to_delete = ["TNGFX", "APTFX", "LGTFX"]
	elif oCurrentFormat.selected == Constants.KfxFormat:
		file_types_to_delete = ["LIF", "TNG", "APT", "LGT"]
	if file_types_to_delete.empty() == true:
		return
	for file_extension in file_types_to_delete:
		delete_map_files(base_directory, map_name_no_ext, file_extension)
		if oCurrentMap.currentFilePaths.has(file_extension) == true:
			oCurrentMap.currentFilePaths.erase(file_extension)


func delete_map_files(base_directory, map_name_no_ext, file_extension, kept_file_path = ""):
	var dir = Directory.new()
	if dir.open(base_directory) != OK:
		print("An error occurred when trying to access " + base_directory)
		return
	dir.list_dir_begin(true, false)
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() == false:
			var same_name = file_name.get_basename().to_upper() == map_name_no_ext.to_upper()
			var same_extension = file_name.get_extension().to_upper() == file_extension.to_upper()
			var same_path = base_directory.plus_file(file_name) == kept_file_path
			if same_name == true and same_extension == true and same_path == false:
				print("Deleted due to format conflict: " + file_name)
				dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()


func clicked_save_on_menu():
	return save_map(oCurrentMap.path)


func save_config_files(map_filename_no_ext, map_base_dir):
	for file_type in ["slabset.toml", "columnset.toml"]:
		if save_toml_file(file_type, map_filename_no_ext, map_base_dir) == false:
			return false
	return save_cubes_cfg_file("cubes.cfg", map_filename_no_ext, map_base_dir) and save_rules_cfg_file("rules.cfg", map_filename_no_ext, map_base_dir)


func save_toml_file(file_type, map_filename_no_ext, map_base_dir):
	var save_target = get_config_save_target(file_type, map_filename_no_ext, map_base_dir)
	var file_path = save_target[0]
	var config_type = save_target[1]
	
	var export_success = false
	match file_type:
		"slabset.toml":
			if Slabset.has_changes_since_load() == false:
				return true
			var list_of_modified_slabs = Slabset.get_all_modified_slabs()
			if list_of_modified_slabs.empty():
				return delete_config_file_if_exists(file_path, file_type)
			export_success = Slabset.export_toml_slabset(file_path, list_of_modified_slabs)
		"columnset.toml":
			if Columnset.has_changes_since_load() == false:
				return true
			var column_diffs = Columnset.find_all_different_columns()
			if column_diffs.empty():
				return delete_config_file_if_exists(file_path, file_type)
			export_success = Columnset.export_toml_columnset(file_path, column_diffs)
	
	if export_success:
		track_saved_config_file(file_path, file_type, config_type)
	return export_success


func save_rules_cfg_file(file_type, map_filename_no_ext, map_base_dir):
	var save_target = get_config_save_target(file_type, map_filename_no_ext, map_base_dir)
	var file_path = save_target[0]
	var config_type = save_target[1]
	
	var export_success = export_rules_cfg(file_path)

	if export_success == null:
		return false
	if export_success:
		track_saved_config_file(file_path, file_type, config_type)
	else:
		return delete_config_file_if_exists(file_path, file_type)
	return true


func save_cubes_cfg_file(file_type, map_filename_no_ext, map_base_dir):
	if Cube.modified_since_load == false:
		return true
	var file_path = get_local_cubes_save_path(file_type, map_filename_no_ext, map_base_dir)
	var export_success = Cube.export_cfg_cubes(file_path)
	if export_success:
		track_saved_config_file(file_path, file_type, oConfigFileManager.LOAD_CFG_CURRENT_MAP)
		Cube.modified_since_load = false
		return true
	if Cube.get_all_export_cube_ids().empty() and delete_config_file_if_exists(file_path, file_type):
		Cube.modified_since_load = false
		return true
	return false


func get_local_cubes_save_path(file_type, map_filename_no_ext, map_base_dir):
	if oCurrentMap.loaded_from_backup == false and oCurrentMap.existing_cubes_file != "" and oCurrentMap.existing_cubes_file.get_file() != file_type:
		return oCurrentMap.existing_cubes_file
	return map_base_dir.plus_file(map_filename_no_ext + "." + file_type)


func get_config_save_target(file_type, map_filename_no_ext, map_base_dir):
	var existing_file_path = ""
	if oCurrentMap.loaded_from_backup == false:
		match file_type:
			"slabset.toml": existing_file_path = oCurrentMap.existing_slabset_file
			"columnset.toml": existing_file_path = oCurrentMap.existing_columnset_file
			"rules.cfg": existing_file_path = oCurrentMap.existing_rules_file
			"cubes.cfg": existing_file_path = oCurrentMap.existing_cubes_file
	var config_type = oConfigFileManager.LOAD_CFG_CURRENT_MAP
	if existing_file_path != "":
		if existing_file_path.get_file() == file_type:
			config_type = oConfigFileManager.LOAD_CFG_CAMPAIGN
		return [existing_file_path, config_type]
	return [map_base_dir.plus_file(map_filename_no_ext + "." + file_type), config_type]


func track_saved_config_file(file_path, file_type, config_type):
	if config_type == oConfigFileManager.LOAD_CFG_CAMPAIGN:
		if not oConfigFileManager.paths_loaded[config_type].has(file_path):
			oConfigFileManager.paths_loaded[config_type].append(file_path)
		oConfigFileManager.emit_signal("config_file_status_changed")
	else:
		oConfigFileManager.notify_file_created(file_path, file_type)
	print("Saved " + file_type.get_basename() + " to: " + file_path)


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
		return null
	
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


func delete_config_file_if_exists(file_path, file_type):
	if File.new().file_exists(file_path) == false:
		return true
	var err_trash = OS.move_to_trash(ProjectSettings.globalize_path(file_path))
	if err_trash != OK:
		print("Error trashing " + file_type + " file: " + file_path.get_file() + " Code: " + str(err_trash))
		return false
	print("Moved unmodified " + file_type + " file to trash: " + file_path.get_file())
	oConfigFileManager.notify_file_deleted(file_path, file_type)
	return true
