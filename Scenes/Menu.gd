extends PanelContainer
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oGame = Nodelist.list["oGame"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oPreferencesWindow = Nodelist.list["oPreferencesWindow"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]
onready var oMenuButtonFile = Nodelist.list["oMenuButtonFile"]
onready var oMenuButtonEdit = Nodelist.list["oMenuButtonEdit"]
onready var oMenuButtonSettings = Nodelist.list["oMenuButtonSettings"]
onready var oMenuButtonView = Nodelist.list["oMenuButtonView"]
onready var oPlayButton = Nodelist.list["oPlayButton"]
onready var oFileDialogSaveAs = Nodelist.list["oFileDialogSaveAs"]
onready var oFileDialogOpen = Nodelist.list["oFileDialogOpen"]
onready var oConfirmAutoGen = Nodelist.list["oConfirmAutoGen"]
onready var oTabPlacements = Nodelist.list["oTabPlacements"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oMenuButtonHelp = Nodelist.list["oMenuButtonHelp"]
onready var oAboutWindow = Nodelist.list["oAboutWindow"]
onready var oControlsWindow = Nodelist.list["oControlsWindow"]
onready var oImageAsMapDialog = Nodelist.list["oImageAsMapDialog"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oTextureEditingWindow = Nodelist.list["oTextureEditingWindow"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oConfirmDiscardChanges = Nodelist.list["oConfirmDiscardChanges"]
onready var oColumnEditor = Nodelist.list["oColumnEditor"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oUi = Nodelist.list["oUi"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oNewMapWindow = Nodelist.list["oNewMapWindow"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oAddCustomObjectWindow = Nodelist.list["oAddCustomObjectWindow"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oDataLof = Nodelist.list["oDataLof"]

var recentlyOpened = []
var recentlyOpenedPopupMenu = PopupMenu.new()
var fixMenuExpansion

func _ready():
	for i in $HBoxContainer2.get_children():
		if i is MenuButton:
			i.get_popup().rect_min_size.x = 180
	
	recentlyOpenedPopupMenu.set_name("recentlyOpened")
	var popup = oMenuButtonFile.get_popup()
	popup.add_child(recentlyOpenedPopupMenu)
	popup.set_item_submenu(3, "recentlyOpened")
	
	recentlyOpenedPopupMenu.connect("id_pressed",self,"_on_RecentSubmenu_Pressed")
	
	oMenuButtonFile.get_popup().connect("id_pressed",self,"_on_FileSubmenu_Pressed")
	oMenuButtonEdit.get_popup().connect("id_pressed",self,"_on_EditSubmenu_Pressed")
	oMenuButtonView.get_popup().connect("id_pressed",self,"_on_ViewSubmenu_Pressed")
	oMenuButtonHelp.get_popup().connect("id_pressed",self,"_on_HelpSubmenu_Pressed")


func _on_RecentSubmenu_Pressed(pressedID):
	var recentString = recentlyOpenedPopupMenu.get_item_metadata(pressedID)
	oOpenMap.open_map(recentString)


func add_recent(filePath):
	if filePath == "": return
	var recentString = filePath
	
	var findExisting = recentlyOpened.find(recentString)
	if findExisting == -1:
		recentlyOpened.push_front(recentString)
		if recentlyOpened.size() > 10:
			recentlyOpened.pop_back()
	else:
		recentlyOpened.push_front(recentlyOpened.pop_at(findExisting))
	
	populate_recently_opened()
	
	Settings.write_cfg("recently_opened", recentlyOpened)


func initialize_recently_opened(value):
	recentlyOpened = value
	populate_recently_opened()


func populate_recently_opened():
	recentlyOpenedPopupMenu.clear()
	
	for i in range(recentlyOpened.size() - 1, -1, -1): # iterate in reverse
		var filePath = recentlyOpened[i]
		
		if Directory.new().file_exists(filePath.get_basename()+".slb") == false and Directory.new().file_exists(filePath.get_basename()+".SLB") == false:
			recentlyOpened.remove(i)
	
	for i in recentlyOpened.size():
		var filePath = recentlyOpened[i]
		
		filePath = filePath.replace("\\", "/")
		var mapName = ""
		
		if mapName == "": mapName = oDataLof.lof_name_text(filePath + ".lof")
		if mapName == "": mapName = oDataLof.lof_name_text(filePath + ".LOF")
		if mapName == "": mapName = oDataMapName.lif_name_text(filePath + '.lif')
		if mapName == "": mapName = oDataMapName.lif_name_text(filePath + '.LIF')
		if mapName == "": mapName = oDataMapName.get_special_lif_text(filePath)
		if mapName == "": mapName = oDataMapName.get_special_lif_text(filePath)
		
		# Trim game directory from path to make it look nicer
		var baseDir = oGame.GAME_DIRECTORY.replace('\\','/')
		
		recentlyOpenedPopupMenu.add_item(mapName + ' - ' + filePath.trim_prefix(baseDir), i)
		recentlyOpenedPopupMenu.set_item_metadata(i, filePath)

func _process(delta):
	constantly_monitor_play_button_state()
	
	if oCurrentMap.path == "": # Certain features hould only be available to maps that exist as files - maps that have already been "Saved as".
		oMenuButtonFile.get_popup().set_item_disabled(oMenuButtonFile.get_popup().get_item_index(4),true) # Disable "Save map"
		oPlayButton.disabled = true # Can only play a map that has been "Saved as"
	else:
		oMenuButtonFile.get_popup().set_item_disabled(oMenuButtonFile.get_popup().get_item_index(4),false) # Enable "Save map"
	
	# Fix button being stretched
	if visible == true and fixMenuExpansion != oEditor.mapHasBeenEdited:
		fixMenuExpansion = oEditor.mapHasBeenEdited
		hide()
		show()

func constantly_monitor_play_button_state():
	var mapPath = oCurrentMap.path.to_upper().replace('\\','/')
	
	var currentDirectory = mapPath.get_base_dir()
	var parentDirectory = currentDirectory.get_base_dir()
	
	var mapIsInCorrectDirectory = false
	if oGame.running_keeperfx() == true:
		if parentDirectory.ends_with("/LEVELS") or parentDirectory.ends_with("/CAMPGNS"):
			mapIsInCorrectDirectory = true
	else:
		if currentDirectory.ends_with("/LEVELS"):
			mapIsInCorrectDirectory = true
	
	if mapIsInCorrectDirectory == true: # Is playable path
		oPlayButton.disabled = false
		oPlayButton.hint_tooltip = ""
	else: # Is not a playable path
		oPlayButton.disabled = true
		oPlayButton.hint_tooltip = "Map must be saved in the correct directory in order to play."
	
	if oEditor.mapHasBeenEdited == true:
		oPlayButton.text = "Save & Play"
	else:
		oPlayButton.text = "Play"

func _on_FileSubmenu_Pressed(pressedID):
	match pressedID:
		0: Utils.popup_centered(oNewMapWindow)#oCurrentMap._on_ButtonNewMap_pressed() # New
		1: oMapBrowser._on_BrowseMapsMenu_pressed() # Browse maps
		2: Utils.popup_centered(oFileDialogOpen) # Open
		#3: Open recent
		4: oSaveMap.clicked_save_on_menu() # Save
		5: Utils.popup_centered(oFileDialogSaveAs) # Save as
		6: Utils.popup_centered(oConfirmDiscardChanges) # Reload map
		7: Utils.popup_centered(oImageAsMapDialog) # Load image as map
		8: oPreferencesWindow._on_ButtonSettings_pressed()
		9: oEditor.notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

func _on_EditSubmenu_Pressed(pressedID):
	match pressedID:
		0: # Custom columns
			Utils.popup_centered(oColumnEditor)
		1: # Custom objects
			Utils.popup_centered(oAddCustomObjectWindow)
		2: # Update all slabs
			if oDataSlab.get_cell(0,0) != TileMap.INVALID_CELL:
				Utils.popup_centered(oConfirmAutoGen)
		3: # Texture editing
			Utils.popup_centered(oTextureEditingWindow)
		4: # Modify dynamic slabs
			Utils.popup_centered(oSlabsetWindow)

func _on_slab_style_window_close_button_clicked():
	oMenuButtonEdit.get_popup().set_item_checked(0, false)

func _on_MenuButtonHelp_about_to_show():
	if oGame.running_keeperfx() == true:
		oMenuButtonHelp.get_popup().set_item_disabled(0, false)
		oMenuButtonHelp.get_popup().set_item_disabled(1, false)
		oMenuButtonHelp.get_popup().set_item_disabled(2, true)
	else:
		oMenuButtonHelp.get_popup().set_item_disabled(0, true)
		oMenuButtonHelp.get_popup().set_item_disabled(1, true)
		oMenuButtonHelp.get_popup().set_item_disabled(2, false)

func _on_HelpSubmenu_Pressed(pressedID):
	match pressedID:
		0:
			OS.shell_open("https://github.com/dkfans/keeperfx/wiki/New-and-Modified-Level-Script-Commands")
		1:
			OS.shell_open("https://github.com/dkfans/keeperfx/wiki/Creating-a-new-campaign")
		2:
			OS.shell_open("https://lubiki.keeperklan.com/dk1_docs/dk_scripting_ref.htm")
		3:
			Utils.popup_centered(oControlsWindow)
		4:
			Utils.popup_centered(oAboutWindow)

func _on_ViewSubmenu_Pressed(pressedID):
	match pressedID:
		0: # Open map folder
			if oCurrentMap.path != "":
				var pathToTryAndOpen = oCurrentMap.path.get_base_dir()
				var err = OS.shell_open(pathToTryAndOpen)
				if err != OK:
					oMessage.quick("Could not open: " + pathToTryAndOpen)
			else:
				oMessage.quick("No map path detected. Try saving first.")
		1: # Open script file
			if oCurrentMap.path != "":
				var pathToTryAndOpen = oCurrentMap.path + '.txt'
				var err = OS.shell_open(pathToTryAndOpen)
				if err != OK:
					oMessage.quick("Could not open: " + pathToTryAndOpen)
			else:
				oMessage.quick("No map path detected. Try saving first.")
		2:
			if oEditor.currentView == oEditor.VIEW_2D:
				oEditor.set_view_3d()
				oGenerateTerrain.start()
			oUi.switch_to_1st_person()
		3:
			if oEditor.currentView == oEditor.VIEW_2D:
				oEditor.set_view_3d()
				oGenerateTerrain.start()
			oUi.switch_to_3D_overhead()
		4:
			if oEditor.currentView == oEditor.VIEW_3D:
				oEditor.set_view_2d()

func _on_MenuButtonSettings_pressed():
	oMenuButtonSettings.get_popup().visible = false
	Utils.popup_centered(oMapSettingsWindow)

func _on_PlayButton_pressed(): # Use normal Button instead of MenuButton in combination with OS.execute otherwise a Godot bug occurs
	if oCurrentFormat.selected == 0:
		if oGame.running_keeperfx() == false:
			oMessage.big("Incompatible", "Your map format is set to KFX format, but your game executable is not set to keeperfx.exe")
			return
	
	oGame.menu_play_clicked()
	
	oPlayButton.disconnect("pressed",self,"_on_PlayButton_pressed")
	yield(get_tree().create_timer(2.5), "timeout")
	oPlayButton.connect("pressed",self,"_on_PlayButton_pressed")

func _on_ConfirmDiscardChanges_confirmed():
	oOpenMap.open_map(oCurrentMap.path)
