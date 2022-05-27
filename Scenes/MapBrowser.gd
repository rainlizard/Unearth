extends WindowDialog
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oGame = Nodelist.list["oGame"]
onready var oLineEditFilter = Nodelist.list["oLineEditFilter"]
onready var oBrowseOpenButton = Nodelist.list["oBrowseOpenButton"]
#onready var oBrowsePlayButton = Nodelist.list["oBrowsePlayButton"]
onready var oDynamicMapTree = Nodelist.list["oDynamicMapTree"]
onready var oSourceMapTree = Nodelist.list["oSourceMapTree"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDateSaved = Nodelist.list["oDateSaved"]
onready var oCannotDelete = Nodelist.list["oCannotDelete"]
onready var oConfirmDelete = Nodelist.list["oConfirmDelete"]
onready var oBrowserFilename = Nodelist.list["oBrowserFilename"]
onready var oUi = Nodelist.list["oUi"]
onready var oQuickMapPreview = Nodelist.list["oQuickMapPreview"]
onready var oSelector = Nodelist.list["oSelector"]

func _ready():
	oBrowserFilename.text = oGame.GAME_DIRECTORY
	oBrowseOpenButton.visible = false
	#oBrowsePlayButton.visible = false

func _on_BrowseMapsMenu_pressed():
	match visible:
		true: hide()
		false: popup()

func _on_MapBrowser_about_to_show():
	oSourceMapTree.update_source_tree()
	
	oDynamicMapTree.update_dynamic_tree()
	oDateSaved.text = ""
	
	yield(get_tree(), "idle_frame") #Needs to be here for grab focus to work
	oLineEditFilter.grab_focus()

func _on_DynamicMapTree_item_activated():
	var selectedTreeItem = oDynamicMapTree.get_selected()
	var path = selectedTreeItem.get_metadata(0)
	if selectedTreeItem.get_metadata(1) == "is_a_file":
		activate(path)

func _on_BrowseOpenButton_pressed():
	var path = oBrowserFilename.text
	activate(path)
	hide() # Hide map browser which clicking Open button. But keep it open when double clicking on maps to open them

func activate(path):
	path = path.get_basename()
	oOpenMap.open_map(path)
	toggle_map_preview(false)

func _on_DynamicMapTree_item_selected():
	var selectedTreeItem = oDynamicMapTree.get_selected()
	var path = selectedTreeItem.get_metadata(0)
	# Set modified time, if it's a file
	if selectedTreeItem.get_metadata(1) == "is_a_file":
		oBrowseOpenButton.visible = true
		#oBrowsePlayButton.visible = true
#		var file = File.new()
#		var modifiedTime = file.get_modified_time(path + '.slb') # This might cause case-sensitive issues but I don't care right now.
#		oDateSaved.text = convert_unix_time_to_readable(modifiedTime) #'Last modified: '+
#		file.close()
		
		var successOrFailure = oQuickMapPreview.update_img(path)
		if successOrFailure == OK:
			toggle_map_preview(true)
		else:
			toggle_map_preview(false)
	else:
		toggle_map_preview(false)
		oBrowseOpenButton.visible = false
		#oBrowsePlayButton.visible = false
		# "Directory" modified time is not shown
		oDateSaved.text = ""
		#oBrowserFilename.text = ""
	oBrowserFilename.text = path.get_basename()

func _on_LineEdit_text_changed(new_text):
	oDynamicMapTree.search_tree(new_text, false)

#var mapPathDelete
#func _input(event):
#	if Input.is_action_just_pressed("ui_delete"):
#		var selectedTreeItem = oDynamicMapTree.get_selected()
#		if visible == true and selectedTreeItem != null:
#			mapPathDelete = selectedTreeItem.get_metadata(0)
#			if oCurrentMap.path == mapPathDelete:
#				Utils.popup_centered(oCannotDelete)
#			else:
#				Utils.popup_centered(oConfirmDelete)

#func _on_ConfirmDelete_confirmed():
#	oLineEditFilter.text = ""
#	oBrowserFilename.text = ""
#	oSourceMapTree.updateSourceMapTree()

func convert_unix_time_to_readable(modifiedTime):
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
		var selectedTreeItem = oDynamicMapTree.get_selected()
		if selectedTreeItem != null:
			path = selectedTreeItem.get_metadata(0)
	
	if Directory.new().dir_exists(path) == true:
		# Open folder
		OS.shell_open(path)
	else:
		# Open containing folder
		OS.shell_open(path.get_base_dir())


func _on_MapBrowser_item_rect_changed():
	if Settings.haveInitializedAllSettings == false: return # Necessary because otherwise this signal is firing too early. Settings haven't loaded the values from the cfg file yet.
	Settings.set_setting("file_viewer_window_size", rect_size)
	Settings.set_setting("file_viewer_window_position", rect_position)


func _on_MapBrowser_visibility_changed():
	if is_instance_valid(oUi) == false: return
	if visible == true:
		oUi.hide_tools()
		toggle_map_preview(true)
	else:
		oUi.show_tools()
		toggle_map_preview(false)


func _on_BrowsePlayButton_pressed():
	pass # Replace with function body.


func toggle_map_preview(togglePreview):
	oQuickMapPreview.visible = togglePreview
	
	# Toggle to false if currently selecting the opened map
	if oCurrentMap.currentFilePaths.has("SLB") == true:
		var currentSlbPath = oCurrentMap.currentFilePaths["SLB"][oCurrentMap.PATHSTRING]
		
		if currentSlbPath == oDynamicMapTree.get_selected().get_metadata(0):
			oQuickMapPreview.visible = false
