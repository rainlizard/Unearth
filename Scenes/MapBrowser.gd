extends WindowDialog
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oDeleteMap = Nodelist.list["oDeleteMap"]
onready var oGame = Nodelist.list["oGame"]
onready var oLineEditFilter = Nodelist.list["oLineEditFilter"]
onready var oButtonFilename = Nodelist.list["oButtonFilename"]
onready var oMapTree = Nodelist.list["oMapTree"]
onready var oSourceTree = Nodelist.list["oSourceTree"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDateSaved = Nodelist.list["oDateSaved"]
onready var oCannotDelete = Nodelist.list["oCannotDelete"]
onready var oConfirmDelete = Nodelist.list["oConfirmDelete"]
onready var oBrowserFilename = Nodelist.list["oBrowserFilename"]
onready var oUi = Nodelist.list["oUi"]

func _ready():
	oBrowserFilename.text = oGame.GAME_DIRECTORY
	oButtonFilename.visible = false

func _on_MapBrowser_about_to_show():
	oSourceTree.updateSourceTree()
	oDateSaved.text = ""
	
	yield(get_tree(), "idle_frame") #Needs to be here for grab focus to work
	oLineEditFilter.grab_focus()

func _on_MapTree_item_activated():
	var selectedTreeItem = oMapTree.get_selected()
	var path = selectedTreeItem.get_metadata(0)
	if selectedTreeItem.get_metadata(1) == "is_a_file":
		activate(path)

func _on_ButtonFilename_pressed():
	var path = oBrowserFilename.text
	activate(path)

func activate(path):
	path = path.get_basename()
	oOpenMap.open_map(path)

func _on_MapTree_item_selected():
	var selectedTreeItem = oMapTree.get_selected()
	var path = selectedTreeItem.get_metadata(0)
	# Set modified time, if it's a file
	if selectedTreeItem.get_metadata(1) == "is_a_file":
		oButtonFilename.visible = true
		var file = File.new()
		var modifiedTime = file.get_modified_time(path + '.slb') # This might cause case-sensitive issues but I don't care right now.
		oDateSaved.text = convertUnixTimeToReadable(modifiedTime)
		file.close()
		
		# Set filename field to selected item
		
	else:
		oButtonFilename.visible = false
		# "Directory" modified time is not shown
		oDateSaved.text = ""
		#oBrowserFilename.text = ""
	oBrowserFilename.text = path

func _on_LineEdit_text_changed(new_text):
	oMapTree.searchTree(new_text, false)

var mapPathDelete
#func _input(event):
#	if Input.is_action_just_pressed("ui_delete"):
#		var selectedTreeItem = oMapTree.get_selected()
#		if visible == true and selectedTreeItem != null:
#			mapPathDelete = selectedTreeItem.get_metadata(0)
#			if oCurrentMap.path == mapPathDelete:
#				Utils.popup_centered(oCannotDelete)
#			else:
#				Utils.popup_centered(oConfirmDelete)

func _on_ConfirmDelete_confirmed():
	oDeleteMap.delete_map(mapPathDelete)
	oLineEditFilter.text = ""
	oBrowserFilename.text = ""
	oSourceTree.updateSourceTree()

func convertUnixTimeToReadable(modifiedTime):
	var dict = OS.get_datetime_from_unix_time(modifiedTime)
	var dateAndTime = ""
	dateAndTime += str(dict["day"]) + "/"
	dateAndTime += str(dict["month"]) + "/"
	dateAndTime += str(dict["year"])
	dateAndTime += " "
	dateAndTime += str(dict["hour"]) + ":"
	dateAndTime += str(dict["minute"]) + ":"
	dateAndTime += str(dict["second"])

	return dateAndTime

func _on_TextureButton_pressed():
	
	var path = ""
	if oBrowserFilename.text != "":
		# Use the filename field
		path = oBrowserFilename.text
	else:
		# If the filename field is blank, then use the selected tree item instead
		var selectedTreeItem = oMapTree.get_selected()
		if selectedTreeItem != null:
			path = selectedTreeItem.get_metadata(0)
	
	if Directory.new().dir_exists(path) == true:
		# Open folder
		OS.shell_open(path)
	else:
		# Open containing folder
		OS.shell_open(path.get_base_dir())

func _on_ButtonOpenMap_pressed():
	match visible:
		true: hide()
		false: popup()

func _on_MapBrowser_item_rect_changed():
	if Settings.haveInitializedAllSettings == false: return # Necessary because otherwise this signal is firing too early. Settings haven't loaded the values from the cfg file yet.
	Settings.set_setting("file_viewer_window_size", rect_size)
	Settings.set_setting("file_viewer_window_position", rect_position)


func _on_MapBrowser_visibility_changed():
	if is_instance_valid(oUi) == false: return
	if visible == true:
		oUi.hide_tools()
	else:
		oUi.show_tools()
