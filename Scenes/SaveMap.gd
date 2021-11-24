extends Node
onready var oGame = Nodelist.list["oGame"]
onready var oWriteData = Nodelist.list["oWriteData"]
onready var oQuickMessage = Nodelist.list["oQuickMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]

func save_map(filePath): # auto opens other files
	var map = filePath.get_basename()
	
	var SAVETIME_START = OS.get_ticks_msec()
	
	for i in Filetypes.FILE_TYPES:
		Filetypes.write(map + '.' + i.to_lower())
	
	print('Total time to save: ' + str(OS.get_ticks_msec() - SAVETIME_START) + 'ms')
	
	oQuickMessage.message('Saved map')
	oCurrentMap.set_path_and_title(filePath)
	oEditor.mapHasBeenEdited = false


func clicked_save_on_menu():
	save_map(oCurrentMap.path)

func _on_FileDialogSaveAs_file_selected(filePath):
	Settings.set_setting("save_path", filePath.get_base_dir().plus_file(''))
	
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
