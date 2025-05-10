extends PanelContainer

onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oGame = Nodelist.list["oGame"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oConfirmScriptDeletion = Nodelist.list["oConfirmScriptDeletion"]
onready var oScriptEditorWindow = Nodelist.list["oScriptEditorWindow"]
onready var header_vbox = get_node("%HeaderVBoxContainer")
onready var path_link_node = get_node("%PathLinkButton")
onready var path_separator_node = get_node("%PathHSeparator")
onready var hbox_create_node = get_node("%HBoxCreate")
onready var hbox_generate_node = get_node("%HBoxGenerate")
onready var hbox_delete_node = get_node("%HBoxDelete")
onready var header_label_node = get_node("%HeaderLabel")
onready var create_label_node = get_node("%CreateLabel")
onready var delete_label_node = get_node("%DeleteLabel")
onready var oScriptGeneratorWindow = Nodelist.list["oScriptGeneratorWindow"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oDataLof = Nodelist.list["oDataLof"]

var script_file_extension: String = ""

func _ready():
	self.script_file_extension = get_script_extension()
	var scriptTypeName = ""
	var fileExtensionDisplay = ""
	if self.script_file_extension == "txt":
		scriptTypeName = "DKScript"
		fileExtensionDisplay = "(.txt)"
	elif self.script_file_extension == "lua":
		scriptTypeName = "LuaScript"
		fileExtensionDisplay = "(.lua)"
	else:
		header_label_node.text = "Error: Unknown Script Section"
		return
	header_label_node.text = scriptTypeName + " file"
	create_label_node.text = scriptTypeName + " file " + fileExtensionDisplay
	delete_label_node.text = scriptTypeName + " file " + fileExtensionDisplay

func get_script_extension() -> String:
	var baseExtension = ""
	match name:
		"DKScriptFileSection": baseExtension = "txt"
		"LuaScriptFileSection": baseExtension = "lua"
		_:
			oMessage.quick("Unknown section name '" + name + "' for script extension.")
	return baseExtension

func get_map_directory() -> String:
	if is_instance_valid(oCurrentMap) == false or oCurrentMap.path == "":
		return ""
	return oCurrentMap.path.get_base_dir()

func get_map_basename() -> String:
	if is_instance_valid(oCurrentMap) == false or oCurrentMap.path == "":
		return ""
	return oCurrentMap.path.get_file().get_basename()

func build_script_path(mapDirectory: String, mapFilenameBasename: String, scriptBaseExtension: String) -> String:
	if mapFilenameBasename == "" or scriptBaseExtension == "":
		oMessage.quick("Invalid parameters for building script path (filename or extension missing).")
		return ""
	return mapDirectory.plus_file(mapFilenameBasename + "." + scriptBaseExtension)

func reset_user_display():
	header_vbox.visible = false
	path_link_node.visible = false
	path_separator_node.visible = false
	hbox_create_node.visible = true
	hbox_delete_node.visible = false
	hbox_generate_node.visible = false

func find_precise_path(baseDirectory: String, filename: String) -> String:
	if is_instance_valid(oGame) == false:
		oMessage.quick("Warning: oGame not available for precise path lookup of " + filename + " in " + baseDirectory)
		return ""
	return oGame.get_precise_filepath(baseDirectory, filename)

func resolve_script_path(keyExtensionUppercase: String) -> String:
	if map_state_valid() == false:
		return ""
	var scriptPath = resolve_map_data(keyExtensionUppercase)
	if scriptPath == "":
		scriptPath = discover_disk_script(keyExtensionUppercase)
	return scriptPath

func map_state_valid() -> bool:
	return is_instance_valid(oCurrentMap) and oCurrentMap.path != "" and oCurrentMap.currentFilePaths != null

func resolve_map_data(keyExtensionUppercase: String) -> String:
	if oCurrentMap.currentFilePaths.has(keyExtensionUppercase) == false:
		return ""
	var pathFromData = oCurrentMap.currentFilePaths[keyExtensionUppercase][oCurrentMap.PATHSTRING]
	if pathFromData == "":
		return ""
	var file = File.new()
	if file.file_exists(pathFromData):
		return pathFromData
	var dir = pathFromData.get_base_dir()
	var filename = pathFromData.get_file()
	var precisePath = find_precise_path(dir, filename)
	if precisePath != "":
		if precisePath != pathFromData:
			oMessage.quick("Corrected script path case: " + precisePath.get_file())
		record_script_entry(precisePath, keyExtensionUppercase, true)
		return precisePath
	oMessage.quick("File in map data not found on disk: " + pathFromData.get_file())
	record_script_entry(pathFromData, keyExtensionUppercase, false)
	return ""

func discover_disk_script(keyExtensionUppercase: String) -> String:
	var mapBaseDirectory = get_map_directory()
	var mapFilenameBasename = get_map_basename()
	if mapBaseDirectory == "" or mapFilenameBasename == "":
		return ""
	var scriptBaseExtensionForSection = keyExtensionUppercase.to_lower()
	if scriptBaseExtensionForSection != "":
		var expectedFilename = mapFilenameBasename + "." + scriptBaseExtensionForSection
		var precisePathOnDisk = find_precise_path(mapBaseDirectory, expectedFilename)
		if precisePathOnDisk != "":
			oMessage.quick("Discovered script file on disk: " + precisePathOnDisk.get_file())
			record_script_entry(precisePathOnDisk, keyExtensionUppercase, true)
			return precisePathOnDisk
	return ""

func show_script_interface(scriptPath: String, keyExtensionUppercase: String):
	if scriptPath == "":
		return
	header_vbox.visible = true
	path_link_node.text = scriptPath.get_file()
	path_link_node.hint_tooltip = scriptPath
	path_link_node.visible = true
	path_separator_node.visible = true
	hbox_create_node.visible = false
	hbox_delete_node.visible = true
	if keyExtensionUppercase == "TXT":
		hbox_generate_node.visible = true

func record_script_entry(operatedFilePath: String, fileKeyExtensionUppercase: String, intendedToExist: bool):
	if is_instance_valid(oCurrentMap) == false or oCurrentMap.currentFilePaths == null or fileKeyExtensionUppercase == "":
		oMessage.quick("record_script_entry - Invalid state (oCurrentMap, currentFilePaths, or ext_upper empty)")
		return
	var scriptIsActive = false
	var file = File.new()
	if intendedToExist and operatedFilePath != "" and file.file_exists(operatedFilePath):
		scriptIsActive = true
	if scriptIsActive:
		var modifiedTime = file.get_modified_time(operatedFilePath)
		oCurrentMap.currentFilePaths[fileKeyExtensionUppercase] = [operatedFilePath, modifiedTime]
	elif oCurrentMap.currentFilePaths.has(fileKeyExtensionUppercase):
		oCurrentMap.currentFilePaths.erase(fileKeyExtensionUppercase)
	set_script_flag(fileKeyExtensionUppercase, scriptIsActive)

func update_file_status():
	reset_user_display()
	var baseExtension = self.script_file_extension
	var finalAlpha = 0.25
	if baseExtension != "":
		var keyExtensionUppercase = baseExtension.to_upper()
		if get_script_flag(keyExtensionUppercase):
			var scriptPathValue = resolve_script_path(keyExtensionUppercase)
			if scriptPathValue != "" and get_script_flag(keyExtensionUppercase):
				show_script_interface(scriptPathValue, keyExtensionUppercase)
				finalAlpha = 1.0
	self_modulate.a = finalAlpha
	if is_instance_valid(create_label_node):
		create_label_node.self_modulate.a = finalAlpha

func select_script_path(baseDirectory: String, intendedPath: String) -> String:
	if is_instance_valid(oGame) == false:
		oMessage.quick("Warning: oGame not available for precise path check. Using intended: " + intendedPath.get_file())
		return intendedPath
	var precisePath = oGame.get_precise_filepath(baseDirectory, intendedPath.get_file())
	if precisePath != "" and precisePath != intendedPath:
		oMessage.quick("Using existing file with different case: " + precisePath.get_file())
		return precisePath
	return intendedPath

func write_file_content(targetPath: String, content: String) -> bool:
	var file = File.new()
	var err = file.open(targetPath, File.WRITE)
	if err == OK:
		file.store_string(content)
		file.close()
		return true
	else:
		oMessage.quick("Error writing file '" + targetPath.get_file() + "'. Code: " + str(err))
		return false

func can_start_task(isInvalidCondition: bool, specificIssueMessage: String, taskName: String) -> bool:
	if isInvalidCondition:
		oMessage.quick(specificIssueMessage + " Cannot " + taskName + " script.")
		update_file_status()
		return true
	return false

func start_file_task(taskFunction: FuncRef, taskName: String) -> void:
	if can_start_task(
		is_instance_valid(oCurrentMap) == false or oCurrentMap.is_inside_tree() == false or oCurrentMap.path == "",
		"Map not loaded or path not set.",
		taskName
	): return

	var baseExtension = self.script_file_extension
	if can_start_task(
		baseExtension == "",
		"Script extension not identified for this section.",
		taskName
	): return

	var mapBaseDirectory = get_map_directory()
	var mapFilenameBasename = get_map_basename()
	if can_start_task(
		mapBaseDirectory == "" or mapFilenameBasename == "",
		"Map path or filename is invalid.",
		taskName
	): return

	taskFunction.call_func(mapBaseDirectory, mapFilenameBasename, baseExtension)
	update_file_status()

func perform_write_action(mapBaseDirectory: String, mapFilenameBasename: String, baseExtension: String, content: String, successVerb: String) -> bool:
	var intendedTargetPath = build_script_path(mapBaseDirectory, mapFilenameBasename, baseExtension)
	if intendedTargetPath == "":
		return false
	var pathForOperation = select_script_path(mapBaseDirectory, intendedTargetPath)
	var keyExtensionForMapPaths = baseExtension.to_upper()
	var fileUtil = File.new()

	if fileUtil.file_exists(pathForOperation):
		if baseExtension == "lua":
			var existingFile = File.new()
			var existingContent = ""
			var err = existingFile.open(pathForOperation, File.READ)

			if err == OK:
				existingContent = existingFile.get_as_text()
				existingFile.close()

				if existingContent.strip_edges(true, true) == "":
					if write_file_content(pathForOperation, content):
						oMessage.quick(successVerb + " (populated blank) " + baseExtension.to_upper() + " script: " + pathForOperation.get_file())
						record_script_entry(pathForOperation, keyExtensionForMapPaths, true)
						return true
					else:
						record_script_entry(pathForOperation, keyExtensionForMapPaths, true) 
						return false 
				else:
					oMessage.quick("Using existing non-blank " + baseExtension.to_upper() + " script file: " + pathForOperation.get_file())
					record_script_entry(pathForOperation, keyExtensionForMapPaths, true)
					return true
			else:
				oMessage.quick("Could not read existing " + baseExtension.to_upper() + " file to check content: " + pathForOperation.get_file() + ". Code: " + str(err))
				record_script_entry(pathForOperation, keyExtensionForMapPaths, true) 
				return true 
		else:
			oMessage.quick("Using existing " + baseExtension.to_upper() + " script file: " + pathForOperation.get_file())
			record_script_entry(pathForOperation, keyExtensionForMapPaths, true)
			return true
	else:
		if write_file_content(pathForOperation, content):
			oMessage.quick(successVerb + " " + baseExtension.to_upper() + " script file: " + pathForOperation.get_file())
			record_script_entry(pathForOperation, keyExtensionForMapPaths, true)
			return true
		else:
			record_script_entry(pathForOperation, keyExtensionForMapPaths, false)
			return false

func make_empty_file(mapBaseDirectory: String, mapFilenameBasename: String, baseExtension: String) -> bool:
	var content = ""
	if baseExtension == "lua":
		var mapName = "--insert map name--"
		if is_instance_valid(oDataMapName) and oDataMapName.data != "":
			mapName = oDataMapName.data
		
		var authorName = "--insert author--"
		if is_instance_valid(oDataLof) and oDataLof.AUTHOR != "":
			authorName = oDataLof.AUTHOR
			
		content = """-- ********************************************
--
--        %s
--        by %s
--
-- ********************************************


--will get called when the game starts
function OnGameStart()
	Setup()
	Setup_triggers()
end

--here we setup things 
function Setup()

end

--here we setup the triggers, these can be found in fxdata/lua/triggers/Events.lua
function Register_triggers()

end
""" % [mapName, authorName]
	var successVerb = "Created"
	var success = perform_write_action(mapBaseDirectory, mapFilenameBasename, baseExtension, content, successVerb)
	if success and baseExtension == "lua":
		if is_instance_valid(Nodelist.list["oDataLua"]):
			Nodelist.list["oDataLua"].data = content
	return success

func _on_CreateButton_pressed():
	start_file_task(funcref(self, "make_empty_file"), "create")

func _on_DeleteButton_pressed():
	oConfirmScriptDeletion.set_meta("requesting_script_section_id", get_instance_id())
	Utils.popup_centered(oConfirmScriptDeletion)
	yield(oConfirmScriptDeletion, "confirmed")
	var hasRequestingMeta = oConfirmScriptDeletion.has_meta("requesting_script_section_id")
	var metaMatchesInstanceId = false
	if hasRequestingMeta:
		metaMatchesInstanceId = oConfirmScriptDeletion.get_meta("requesting_script_section_id") == get_instance_id()
	if (hasRequestingMeta and metaMatchesInstanceId) == false:
		return
	oConfirmScriptDeletion.remove_meta("requesting_script_section_id")
	var baseExtension = self.script_file_extension
	if baseExtension == "":
		oMessage.quick("Script extension not identified. Cannot disable script.")
		update_file_status()
		return
	var keyExtensionUppercase = baseExtension.to_upper()
	if mark_script_inactive(keyExtensionUppercase):
		if is_instance_valid(oEditor): oEditor.mapHasBeenEdited = true
		oMessage.quick(keyExtensionUppercase + " file will be removed on next save.")
	update_file_status()

func generate_script_boilerplate(filename: String) -> String:
	var content = "-- DKScript file (level script) generated by Unearth for " + filename + "\n"
	content += "-- This file (" + filename + ") is used by Dungeon Keeper.\n"
	return content

func make_templated_file(mapBaseDirectory: String, mapFilenameBasename: String, baseExtension: String) -> bool:
	if baseExtension != "txt":
		oMessage.quick("Script generation is only for DKScript (.txt) files.")
		return false
	Utils.popup_centered(oScriptGeneratorWindow)
	return true

func _on_GenerateButton_pressed():
	start_file_task(funcref(self, "make_templated_file"), "generate")

func _on_PathLinkButton_pressed():
	match name:
		"DKScriptFileSection":
			Utils.popup_centered(oScriptEditorWindow)
		"LuaScriptFileSection":
			if path_link_node.hint_tooltip == "":
				oMessage.quick("Cannot open script: path is not available.")
				return
			var err = OS.shell_open(path_link_node.hint_tooltip)
			if err != OK:
				oMessage.quick("Could not open: " + path_link_node.hint_tooltip)

func get_script_flag(keyExtensionUppercase: String) -> bool:
	if keyExtensionUppercase == "TXT":
		return oCurrentMap.DKScript_enabled
	elif keyExtensionUppercase == "LUA":
		return oCurrentMap.LuaScript_enabled
	return false

func set_script_flag(keyExtensionUppercase: String, isEnabled: bool):
	if keyExtensionUppercase == "TXT":
		oCurrentMap.DKScript_enabled = isEnabled
	elif keyExtensionUppercase == "LUA":
		oCurrentMap.LuaScript_enabled = isEnabled

func mark_script_inactive(keyExtensionUppercase: String) -> bool:
	set_script_flag(keyExtensionUppercase, false)
	if keyExtensionUppercase == "TXT" and is_instance_valid(oScriptEditorWindow):
		oScriptEditorWindow.hide()
	return true
