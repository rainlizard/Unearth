extends Node
onready var oGame = Nodelist.list["oGame"]
onready var oWriteData = Nodelist.list["oWriteData"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptEditor = Nodelist.list["oScriptEditor"]
onready var oMenu = Nodelist.list["oMenu"]

var queueExit = false

func save_map(filePath): # auto opens other files
	var map = filePath.get_basename()
	
	var SAVETIME_START = OS.get_ticks_msec()
	
	# Delete the old files. Important for Linux otherwise duplicates can be created. (Lowercase files can be saved without replacing the uppercase files)
	if OS.get_name() == "X11":
		delete_existing_files(map)
	
	for EXT in Filetypes.FILE_TYPES:
		var saveToFilePath = map + '.' + EXT.to_lower()
		
		# Skip saving over existing script file unless it has been edited
		if EXT == "TXT":
#			print('hi')
			if File.new().file_exists(saveToFilePath) == true:
#				print('file exists')
				if oScriptEditor.scriptHasBeenEditedInUnearth == false:
#					print('script has NOT been edited in unearth')
#					print('skip saving')
					continue
			else:
#				print("file doesn't exist")
				pass
		
		Filetypes.write(saveToFilePath, EXT.to_upper())
		
		var getModifiedTime = File.new().get_modified_time(saveToFilePath)
		oCurrentMap.currentFilePaths[EXT] = [saveToFilePath, getModifiedTime]
	
	print('Total time to save: ' + str(OS.get_ticks_msec() - SAVETIME_START) + 'ms')
	if oDataScript.data == "":
		oMessage.big("Warning","Your map has no script! Use the Script Generator in Map Settings to give your map basic functionality.")
	oMessage.quick('Saved map')
	oCurrentMap.set_path_and_title(filePath)
	oEditor.mapHasBeenEdited = false
	oScriptEditor.set_script_as_edited(false)
	oMapSettingsWindow.visible = false
	
	# This goes last. Queued from when doing "save before quitting" and "save as" before quitting.
	if queueExit == true:
		get_tree().quit()

func delete_existing_files(map):
	
	var baseDirectory = map.get_base_dir()
	var MAP_NAME = map.get_basename().get_file().to_upper()
	var dir = Directory.new()
	if dir.open(baseDirectory) == OK:
		dir.list_dir_begin(true, false)
		var fileName = dir.get_next()
		while fileName != "":
			if MAP_NAME in fileName.to_upper():
				# Only delete the accompanying file types that I'm about to write
				if Filetypes.FILE_TYPES.has(fileName.get_extension().to_upper()):
					
					if dir.file_exists(fileName) == true: # Ensure any files being removed are definitely files and never directories
						print("Deleted: " + fileName)
						dir.remove(fileName)
			fileName = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func clicked_save_on_menu():
	save_map(oCurrentMap.path)

func _on_FileDialogSaveAs_file_selected(filePath):
	Settings.set_setting("save_path", filePath.get_base_dir())
	
	var map = filePath.get_basename()
	save_map(map)

#	if File.new().file_exists(path + ".slb") == true:
#		mapPathSave = path
#		oConfirmOverwrite.Utils.popup_centered(self)
#	else:
#		oSaveMap.save_map(path)
#		hide()
#
#var mapPathSave # set before popping up the overwrite confirmation box
#func _on_ConfirmOverwrite_confirmed():
#	oSaveMap.save_map(mapPathSave)
#	hide()
