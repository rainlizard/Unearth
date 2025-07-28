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
onready var oMenuPlayButton = Nodelist.list["oMenuPlayButton"]
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
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oUi = Nodelist.list["oUi"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oNewMapWindow = Nodelist.list["oNewMapWindow"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oExportPreview = Nodelist.list["oExportPreview"]
onready var oResizeCurrentMapSize = Nodelist.list["oResizeCurrentMapSize"]
onready var oGridDataWindow = Nodelist.list["oGridDataWindow"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oActionPointListWindow = Nodelist.list["oActionPointListWindow"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oSortCreatureStats = Nodelist.list["oSortCreatureStats"]
onready var oConfigFilesListWindow = Nodelist.list["oConfigFilesListWindow"]
onready var oConfirmOpenWhichScript = Nodelist.list["oConfirmOpenWhichScript"]
onready var oChangelogWindow = Nodelist.list["oChangelogWindow"]
onready var oCfgEditor = Nodelist.list["oCfgEditor"]

var recentlyOpened = []
var recentlyOpenedPopupMenu = PopupMenu.new()
var fixMenuExpansion

func _ready():
	# Allow Settings and Play button to be hovered without the dropdown menu appearing
	oMenuButtonSettings.get_popup().mouse_filter = Control.MOUSE_FILTER_IGNORE
	oMenuButtonSettings.get_popup().modulate = Color(0,0,0,0)
	oMenuPlayButton.get_popup().mouse_filter = Control.MOUSE_FILTER_IGNORE
	oMenuPlayButton.get_popup().modulate = Color(0,0,0,0)
	
	for i in $HBoxContainer2.get_children():
		if i is MenuButton:
			i.get_popup().rect_min_size.x = 180
	
	add_file_menu_items()
	add_edit_menu_items()
	
	recentlyOpenedPopupMenu.set_name("recentlyOpened")
	var popup = oMenuButtonFile.get_popup()
	popup.add_child(recentlyOpenedPopupMenu)
	popup.set_item_submenu(3, "recentlyOpened")
	
	recentlyOpenedPopupMenu.connect("id_pressed",self,"_on_RecentSubmenu_Pressed")
	
	oMenuButtonFile.get_popup().connect("id_pressed",self,"_on_FileSubmenu_Pressed")
	oMenuButtonEdit.get_popup().connect("id_pressed",self,"_on_EditSubmenu_Pressed")
	oMenuButtonView.get_popup().connect("id_pressed",self,"_on_ViewSubmenu_Pressed")
	oMenuButtonHelp.get_popup().connect("id_pressed",self,"_on_HelpSubmenu_Pressed")

func add_file_menu_items():
	# Add menu items to oMenuButtonFile
	var file_popup = oMenuButtonFile.get_popup()
	
	file_popup.add_item("New map", 0)
	file_popup.add_item("Browse maps", 1)
	file_popup.add_item("Open map", 2)
	file_popup.add_item("Open recent", 3)
	file_popup.add_separator()
	file_popup.add_item("Save map", 4)
	file_popup.add_item("Save map as", 5)
	file_popup.add_separator()
	file_popup.add_item("Reload map", 6)
	file_popup.add_item("Image to map", 7)
	file_popup.add_item("Export preview", 8)
	file_popup.add_item("Workshop", 11)
	file_popup.add_separator()
	file_popup.add_item("Preferences", 9)
	file_popup.add_separator()
	file_popup.add_item("Exit", 10)


func add_edit_menu_items():
	# Add menu items to oMenuButtonEdit
	var edit_popup = oMenuButtonEdit.get_popup()
	
	edit_popup.add_item("Undo", 0)
	edit_popup.add_separator()
	#edit_popup.add_item("Custom objects", 2)
	edit_popup.add_item("Update all slabs", 4)
	edit_popup.add_item("Resize map", 3)
	edit_popup.add_separator()
	edit_popup.add_item("Rules", 7)
	edit_popup.add_item("Slabset", 6)
	edit_popup.add_item("Tileset", 5)

func update_undo_availability():
	if oUndoStates.undo_history.size() <= 1:
		oMenuButtonEdit.get_popup().set_item_disabled(0, true)
	else:
		oMenuButtonEdit.get_popup().set_item_disabled(0, false)


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

var tdir = Directory.new()

func find_cased_file_path(basePathString: String, fileExtensions: Array) -> String:
	var dirPath = basePathString.get_base_dir()
	var baseFileNameWithoutExt = basePathString.get_file()
	var d = Directory.new()
	if d.open(dirPath) != OK:
		return ""
	d.list_dir_begin()
	var entry = d.get_next()
	while entry != "":
		if d.current_is_dir() == false:
			for ext in fileExtensions:
				var targetFileNameWithExt = baseFileNameWithoutExt + ext
				if entry.to_lower() == targetFileNameWithExt.to_lower():
					d.list_dir_end()
					return dirPath.plus_file(entry)
		entry = d.get_next()
	d.list_dir_end()
	return ""

func populate_recently_opened():
	recentlyOpenedPopupMenu.clear()
	for i in range(recentlyOpened.size() - 1, -1, -1):
		var mapPathKey = recentlyOpened[i]
		var actualSlbFile = Utils.case_insensitive_file(mapPathKey.get_base_dir(), mapPathKey.get_file(), ".slb")
		if actualSlbFile == "":
			recentlyOpened.remove(i)
	for i in recentlyOpened.size():
		var mapPathKey = recentlyOpened[i]
		var mapFileName = mapPathKey.get_file()
		var mapDisplayName = ""
		var actualLofFile = Utils.case_insensitive_file(mapPathKey.get_base_dir(), mapPathKey.get_file(), ".lof")
		var actualLifFile = ""
		if actualLofFile != "":
			mapDisplayName = oDataLof.lof_name_text(actualLofFile)
		else:
			actualLifFile = Utils.case_insensitive_file(mapPathKey.get_base_dir(), mapPathKey.get_file(), ".lif")
			if actualLifFile != "":
				mapDisplayName = oDataMapName.lif_name_text(actualLifFile)
			else:
				mapDisplayName = oDataMapName.get_special_lif_text(mapFileName)
		var displayPath = mapPathKey
		var gameBaseDir = oGame.GAME_DIRECTORY.replace('\\','/')
		recentlyOpenedPopupMenu.add_item(mapDisplayName + ' - ' + displayPath.trim_prefix(gameBaseDir), i)
		recentlyOpenedPopupMenu.set_item_metadata(i, mapPathKey)

func _process(delta):
	constantly_monitor_play_button_state()
	
	if oCurrentMap.path == "": # Certain features hould only be available to maps that exist as files - maps that have already been "Saved as".
		oMenuButtonFile.get_popup().set_item_disabled(oMenuButtonFile.get_popup().get_item_index(4),true) # Disable "Save map"
		oMenuPlayButton.disabled = true # Can only play a map that has been "Saved as"
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
	if oGame.keeperfx_is_installed() == true:
		if parentDirectory.ends_with("/LEVELS") or parentDirectory.ends_with("/CAMPGNS"):
			mapIsInCorrectDirectory = true
	else:
		if currentDirectory.ends_with("/LEVELS"):
			mapIsInCorrectDirectory = true
	
	if mapIsInCorrectDirectory == true: # Is playable path
		oMenuPlayButton.disabled = false
		oMenuPlayButton.hint_tooltip = ""
	else: # Is not a playable path
		oMenuPlayButton.disabled = true
		oMenuPlayButton.hint_tooltip = "Map must be saved in the correct directory in order to play."
	
	if oCurrentMap.path == "":
		oMenuPlayButton.text = "Save & Play"
	elif oEditor.mapHasBeenEdited == true:
		oMenuPlayButton.text = "Save & Play"
	else:
		oMenuPlayButton.text = "Play"

func pressed_save_keyboard_shortcut():
	if oMenuButtonFile.get_popup().is_item_disabled(oMenuButtonFile.get_popup().get_item_index(4)) == true:
		_on_FileSubmenu_Pressed(5) # Save As
	else:
		_on_FileSubmenu_Pressed(4) # Save

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
		8: Utils.popup_centered(oExportPreview) # Export preview
		9: oPreferencesWindow._on_ButtonSettings_pressed()
		10: oEditor.notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
		11: OS.shell_open("https://keeperfx.net/workshop") # Workshop

func _on_EditSubmenu_Pressed(pressedID):
	match pressedID:
		0: # Undo
			oUndoStates.perform_undo()
		1: # Custom columns
			Utils.popup_centered(oTabClmEditor)
		2: # Custom objects
			#Utils.popup_centered(oAddCustomObjectWindow)
			pass
		3: # Resize and shift
			Utils.popup_centered(oResizeCurrentMapSize)
		4: # Update all slabs
			if oDataSlab.get_cell(0,0) != TileMap.INVALID_CELL:
				Utils.popup_centered(oConfirmAutoGen)
		5: # Texture editing
			Utils.popup_centered(oTextureEditingWindow)
		6: # Modify slabset
			oSlabsetWindow.popup_on_right_side()
		7: # Cfg editor
			Utils.popup_centered(oCfgEditor)

func _on_slab_style_window_close_button_clicked():
	oMenuButtonEdit.get_popup().set_item_checked(0, false)

func _on_MenuButtonHelp_about_to_show():
	if oGame.keeperfx_is_installed() == true:
		oMenuButtonHelp.get_popup().set_item_disabled(0, false) # New script commands
		oMenuButtonHelp.get_popup().set_item_disabled(1, true) # Old Script commands
	else:
		oMenuButtonHelp.get_popup().set_item_disabled(0, true) # New script commands
		oMenuButtonHelp.get_popup().set_item_disabled(1, false) # Old Script commands

func _on_HelpSubmenu_Pressed(pressedID):
	match pressedID:
		0:
			OS.shell_open("https://github.com/dkfans/keeperfx/wiki/Level-Script-commands")
		1:
			OS.shell_open("https://lubiki.keeperklan.com/dk1_docs/dk_scripting_ref.htm")
		2:
			OS.shell_open("https://github.com/dkfans/keeperfx/wiki/Creating-a-new-campaign")
		3:
			OS.shell_open("https://github.com/dkfans/keeperfx/wiki/KeeperFx-Map-files-format-reference")
		4:
			Utils.popup_centered(oControlsWindow)
		5:
			Utils.popup_centered(oChangelogWindow)
		6:
			OS.shell_open("https://github.com/rainlizard/Unearth/issues/new")
		7:
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
			if oCurrentMap.path == "":
				oMessage.quick("No map path detected. Try saving first.")
			else:
				var lua_enabled = oCurrentMap.LuaScript_enabled
				var dk_enabled = oCurrentMap.DKScript_enabled

				if lua_enabled and dk_enabled:
					Utils.popup_centered(oConfirmOpenWhichScript)
				elif lua_enabled:
					var scriptPathBasename = oCurrentMap.path.get_file()
					var scriptDir = oCurrentMap.path.get_base_dir()
					var pathToTryAndOpen = Utils.case_insensitive_file(scriptDir, scriptPathBasename, ".lua")
					if pathToTryAndOpen != "":
						var err = OS.shell_open(pathToTryAndOpen)
						if err != OK:
							oMessage.quick("Could not open: " + pathToTryAndOpen)
					else:
						oMessage.quick("Could not find script file: " + scriptPathBasename + ".lua")
				elif dk_enabled:
					var scriptPathBasename = oCurrentMap.path.get_file()
					var scriptDir = oCurrentMap.path.get_base_dir()
					var pathToTryAndOpen = Utils.case_insensitive_file(scriptDir, scriptPathBasename, ".txt")
					if pathToTryAndOpen != "":
						var err = OS.shell_open(pathToTryAndOpen)
						if err != OK:
							oMessage.quick("Could not open: " + pathToTryAndOpen)
					else:
						oMessage.quick("Could not find script file: " + scriptPathBasename + ".txt")
				else: 
					oMessage.quick("No script available for this map.")
		2: # Open log file
			var pathToTryAndOpen = Utils.case_insensitive_file(oGame.GAME_DIRECTORY, "KEEPERFX", ".log")
			if pathToTryAndOpen != "":
				var err = OS.shell_open(pathToTryAndOpen)
				if err != OK:
					oMessage.quick("Could not open: " + pathToTryAndOpen)
			else:
				oMessage.quick("Could not find KEEPERFX.LOG")
		3:
			if oEditor.currentView == oEditor.VIEW_2D:
				oEditor.set_view_3d()
				oGenerateTerrain.start()
			oUi.switch_to_1st_person()
		4:
			Utils.popup_centered(oActionPointListWindow)
		5:
			Utils.popup_centered(oGridDataWindow)
		6:
			Utils.popup_centered(oConfigFilesListWindow)
		7:
			Utils.popup_centered(oSortCreatureStats)
#		4:
#			if oEditor.currentView == oEditor.VIEW_2D:
#				oEditor.set_view_3d()
#				oGenerateTerrain.start()
#			oUi.switch_to_3D_overhead()
#		5:
#			if oEditor.currentView == oEditor.VIEW_3D:
#				oEditor.set_view_2d()

func _on_MenuButtonSettings_pressed():
	oMenuButtonSettings.get_popup().visible = false
	
	if Columnset.cubes.empty() == true:
		oMessage.quick("No currently opened map.")
	else:
		Utils.popup_centered(oMapSettingsWindow)


func _on_PlayButton_pressed(): # Use normal Button instead of MenuButton in combination with OS.execute otherwise a Godot bug occurs
	if oCurrentFormat.selected == Constants.KfxFormat:
		if oGame.keeperfx_is_installed() == false:
			oMessage.big("Incompatible", "Your map format is set to KFX format, but your game executable is not set to keeperfx.exe")
			return
	
	oGame.menu_play_clicked()
	
	oMenuPlayButton.disconnect("pressed",self,"_on_PlayButton_pressed")
	yield(get_tree().create_timer(2.5), "timeout")
	oMenuPlayButton.connect("pressed",self,"_on_PlayButton_pressed")

func _on_ConfirmDiscardChanges_confirmed():
	oOpenMap.open_map(oCurrentMap.path)
