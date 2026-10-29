extends PanelContainer
onready var oSaveMap = Nodelist.list["oSaveMap"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oGame = Nodelist.list["oGame"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oPreferencesWindow = Nodelist.list["oPreferencesWindow"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]
onready var oMenuButtonFile = Nodelist.list["oMenuButtonFile"]
onready var oMenuButtonEdit = Nodelist.list["oMenuButtonEdit"]
onready var oMenuButtonMap = Nodelist.list["oMenuButtonMap"]
onready var oMenuButtonScript = Nodelist.list["oMenuButtonScript"]
onready var oMenuButtonView = Nodelist.list["oMenuButtonView"]
onready var oMenuPlayButton = Nodelist.list["oMenuPlayButton"]
onready var oFileDialogSaveAs = Nodelist.list["oFileDialogSaveAs"]
onready var oFileDialogOpen = Nodelist.list["oFileDialogOpen"]
onready var oUpdateAllSlabsWindow = Nodelist.list["oUpdateAllSlabsWindow"]
onready var oMenuButtonHelp = Nodelist.list["oMenuButtonHelp"]
onready var oAboutWindow = Nodelist.list["oAboutWindow"]
onready var oControlsWindow = Nodelist.list["oControlsWindow"]
onready var oImageAsMapDialog = Nodelist.list["oImageAsMapDialog"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
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
onready var oInstanceListWindow = Nodelist.list["oInstanceListWindow"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oSortCreatureStats = Nodelist.list["oSortCreatureStats"]
onready var oConfigFilesListWindow = Nodelist.list["oConfigFilesListWindow"]
onready var oChangelogWindow = Nodelist.list["oChangelogWindow"]
onready var oCfgEditor = Nodelist.list["oCfgEditor"]
onready var oMapBackups = Nodelist.list["oMapBackups"]
onready var oScriptGenerator = Nodelist.list["oScriptGenerator"]
onready var oConfirmCreateScript = Nodelist.list["oConfirmCreateScript"]
onready var oDataLua = Nodelist.list["oDataLua"]
onready var oBuffers = Nodelist.list["oBuffers"]

var recentlyOpened = []
var recentlyOpenedPopupMenu = PopupMenu.new()
var fixMenuExpansion
var playButtonLocked = false
var scriptToCreate = "TXT"

const MENU_TOOLTIPS = {
	"Reload map": "Load the map from disk again, dropping unsaved changes.",
	"Backups": "Load a backup. Each time you save over a map, its old files are backed up first.",
	"Image to map": "Build the map from an image by giving each colour a slab.",
	"Export preview": "Save a rendered picture of the map as a .png.",
	"Update all slabs": "Place every slab again to rebuild its look, objects or data. You choose what to reset.",
	"Rules": "Edit the map's rules.cfg: gameplay values, research order and sacrifices.",
	"Slabset": "Edit how slabs look: slabset, columns, cubes and textures.",
	"Config files": "List the config files that apply to this map, from the game, campaign and map folders.",
	"Open DKScript file": "Open the map's .txt script in your default text editor, or create one.",
	"Open Lua file": "Open the map's .lua script in your default text editor, or create one.",
	"Open log": "Open KEEPERFX.LOG from the game folder.",
	"Instance list": "List the map's action points, hero gates, creatures and objects.",
	"Grid data": "Show the raw values of one of the map's files, such as .slb or .own, over the map.",
	"Creature stats": "Compare one stat across all creatures.",
	"Workshop": "Open the KeeperFX workshop website to find and share maps.",
}

func _ready():
	# Allow Play button to be hovered without the dropdown menu appearing
	oMenuPlayButton.get_popup().mouse_filter = Control.MOUSE_FILTER_IGNORE
	oMenuPlayButton.get_popup().modulate = Color(0,0,0,0)

	# Item IDs count up in display order, separators ("") are skipped
	add_menu_items(oMenuButtonFile, "_on_FileSubmenu_Pressed", ["New map", "Open map", "Browse maps", "Open recent", "", "Save map", "Save map as", "Reload map", "Backups", "", "Image to map", "Export preview", "", "Preferences", "", "Exit"])
	add_menu_items(oMenuButtonEdit, "_on_EditSubmenu_Pressed", ["Undo", "", "Update all slabs", "Resize map"])
	add_menu_items(oMenuButtonMap, "_on_MapSubmenu_Pressed", ["Map properties", "", "Rules", "Slabset", "Config files", "", "Open map folder"])
	add_menu_items(oMenuButtonScript, "_on_ScriptSubmenu_Pressed", ["DKScript editor", "", "Open DKScript file", "Open Lua file", "Open log", "", "Script command reference"])
	add_menu_items(oMenuButtonView, "_on_ViewSubmenu_Pressed", ["3D: 1st person", "", "Instance list", "Grid data", "Creature stats"])
	add_menu_items(oMenuButtonHelp, "_on_HelpSubmenu_Pressed", ["Controls", "", "Creating a new campaign", "File format reference", "Workshop", "", "Changelog", "Report bugs & submit suggestions", "About"])

	recentlyOpenedPopupMenu.set_name("recentlyOpened")
	var popup = oMenuButtonFile.get_popup()
	popup.add_child(recentlyOpenedPopupMenu)
	popup.set_item_submenu(popup.get_item_index(3), "recentlyOpened")

	recentlyOpenedPopupMenu.connect("id_pressed",self,"_on_RecentSubmenu_Pressed")

func _input(event):
	# Godot 3.6 swallows clicks on a MenuButton while its own popup is open, so close it manually
	if event is InputEventMouseButton and event.pressed == true and event.button_index == BUTTON_LEFT:
		for menuButton in [oMenuButtonFile, oMenuButtonEdit, oMenuButtonMap, oMenuButtonScript, oMenuButtonView, oMenuButtonHelp]:
			var popup = menuButton.get_popup()
			if popup.visible == true and menuButton.get_global_rect().has_point(menuButton.get_global_mouse_position()):
				popup.hide()
				get_tree().set_input_as_handled()

func add_menu_items(menuButton, method, items):
	var popup = menuButton.get_popup()
	popup.rect_min_size.x = 180
	var id = 0
	for item in items:
		if item == "":
			popup.add_separator()
		else:
			popup.add_item(item, id)
			popup.set_item_tooltip(popup.get_item_count() - 1, MENU_TOOLTIPS.get(item, ""))
			id += 1
	popup.connect("id_pressed", self, method)

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
	if oMapBackups.is_backup_path(filePath) == true: return
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
	for i in range(recentlyOpened.size() - 1, -1, -1):
		var mapPathKey = recentlyOpened[i]
		var actualSlbFile = Utils.case_insensitive_file(mapPathKey.get_base_dir(), mapPathKey.get_file(), ".slb")
		if actualSlbFile == "" or oMapBackups.is_backup_path(mapPathKey) == true:
			recentlyOpened.remove(i)
	for i in recentlyOpened.size():
		var mapPathKey = recentlyOpened[i]
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
				mapDisplayName = oDataMapName.get_special_lif_text(mapPathKey)
		var displayPath = mapPathKey
		var gameBaseDir = oGame.GAME_DIRECTORY.replace('\\','/')
		recentlyOpenedPopupMenu.add_item(mapDisplayName + ' - ' + displayPath.trim_prefix(gameBaseDir), i)
		recentlyOpenedPopupMenu.set_item_metadata(i, mapPathKey)

func _process(delta):
	constantly_monitor_play_button_state()

	var save_map_disabled = oCurrentMap.path == "" or oCurrentMap.loaded_from_backup == true
	oMenuButtonFile.get_popup().set_item_disabled(oMenuButtonFile.get_popup().get_item_index(4), save_map_disabled)
	if oCurrentMap.path == "": # Certain features hould only be available to maps that exist as files - maps that have already been "Saved as".
		oMenuPlayButton.disabled = true # Can only play a map that has been "Saved as"

	# Fix button being stretched
	if visible == true and fixMenuExpansion != oEditor.mapHasBeenEdited:
		fixMenuExpansion = oEditor.mapHasBeenEdited
		hide()
		show()

func constantly_monitor_play_button_state():
	if oCurrentMap.loaded_from_backup == true:
		oMenuPlayButton.disabled = true
		oMenuPlayButton.hint_tooltip = "Loaded backups must be saved as a map before playing."
		oMenuPlayButton.text = "Save & Play"
		return

	var mapPath = oCurrentMap.path.to_upper().replace('\\','/')

	var currentDirectory = mapPath.get_base_dir()

	var mapIsInCorrectDirectory = false
	if oGame.is_playable_dir(currentDirectory) == true:
		mapIsInCorrectDirectory = true

	if mapIsInCorrectDirectory == true: # Is playable path
		oMenuPlayButton.disabled = false
		oMenuPlayButton.hint_tooltip = "Right-click to packetload: replay the game last recorded with Packetsave."
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

func open_externally(pathToTryAndOpen, notFoundMessage):
	if pathToTryAndOpen == "":
		oMessage.quick(notFoundMessage)
	elif OS.shell_open(pathToTryAndOpen) != OK:
		oMessage.quick("Could not open: " + pathToTryAndOpen)

func _on_FileSubmenu_Pressed(pressedID):
	match pressedID:
		0: Utils.popup_centered(oNewMapWindow) # New map
		1: Utils.popup_centered(oFileDialogOpen) # Open map
		2: oMapBrowser._on_BrowseMapsMenu_pressed() # Browse maps
		#3: Open recent
		4: oSaveMap.clicked_save_on_menu() # Save map
		5: Utils.popup_centered(oFileDialogSaveAs) # Save map as
		6: oOpenMap.open_map(oCurrentMap.path) # Reload map
		7: oMapBackups.open_window() # Backups
		8: Utils.popup_centered(oImageAsMapDialog) # Image to map
		9: Utils.popup_centered(oExportPreview) # Export preview
		10: oPreferencesWindow._on_ButtonSettings_pressed() # Preferences
		11: oEditor.notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST) # Exit

func _on_EditSubmenu_Pressed(pressedID):
	match pressedID:
		0: oUndoStates.perform_undo() # Undo
		1: # Update all slabs
			if oDataSlab.get_cell(0,0) != TileMap.INVALID_CELL:
				Utils.popup_centered(oUpdateAllSlabsWindow)
		2: Utils.popup_centered(oResizeCurrentMapSize) # Resize map

func _on_MapSubmenu_Pressed(pressedID):
	match pressedID:
		0: # Map properties
			if Columnset.cubes.empty() == true:
				oMessage.quick("No currently opened map.")
			else:
				Utils.popup_centered(oMapSettingsWindow)
		1: Utils.popup_centered(oCfgEditor) # Rules
		2: oSlabsetWindow.popup_on_right_side() # Slabset
		3: Utils.popup_centered(oConfigFilesListWindow) # Config files
		4: open_externally(oCurrentMap.path.get_base_dir(), "No map path detected. Try saving first.") # Open map folder

func _on_ScriptSubmenu_Pressed(pressedID):
	match pressedID:
		0: oScriptGenerator.open() # DKScript editor
		1: open_script_file("TXT") # Open DKScript file
		2: open_script_file("LUA") # Open Lua file
		3: open_externally(Utils.case_insensitive_file(oGame.GAME_DIRECTORY, "KEEPERFX", ".log"), "Could not find KEEPERFX.LOG") # Open log
		4: # Script command reference
			if oGame.keeperfx_is_installed() == true:
				OS.shell_open("https://github.com/dkfans/keeperfx/wiki/Level-Script-commands")
			else:
				OS.shell_open("https://lubiki.keeperklan.com/dk1_docs/dk_scripting_ref.htm")

func open_script_file(EXT):
	if oCurrentMap.path == "":
		oMessage.quick("No map path detected. Try saving first.")
		return
	var scriptPath = Utils.case_insensitive_file(oCurrentMap.path.get_base_dir(), oCurrentMap.path.get_file(), EXT)
	if scriptPath != "":
		open_externally(scriptPath, "")
		return
	scriptToCreate = EXT
	oConfirmCreateScript.dialog_text = "This map has no %s file. Create one?" % ("DKScript" if EXT == "TXT" else "Lua")
	Utils.popup_centered(oConfirmCreateScript)

func _on_ConfirmCreateScript_confirmed():
	if scriptToCreate == "LUA":
		oDataLua.data = new_lua_script()
	var scriptPath = oCurrentMap.path + "." + scriptToCreate.to_lower()
	if oBuffers.write(scriptPath, scriptToCreate) != OK:
		oMessage.quick("Could not create: " + scriptPath)
		return
	# Saving the map keeps the file, and edits made outside Unearth are reloaded
	if scriptToCreate == "TXT":
		oCurrentMap.DKScript_enabled = true
	else:
		oCurrentMap.LuaScript_enabled = true
	oCurrentMap.currentFilePaths[scriptToCreate] = [scriptPath, File.new().get_modified_time(scriptPath)]
	oScriptGenerator.refresh() # Show the new file in the DKScript window's path link
	open_externally(scriptPath, "")

func new_lua_script():
	var mapName = oDataMapName.data if oDataMapName.data != "" else "--insert map name--"
	var authorName = oDataLof.AUTHOR if oDataLof.AUTHOR != "" else "--insert author--"
	return """-- ********************************************
--
--        %s
--        by %s
--
-- ********************************************


--will get called when the game starts
function OnGameStart()
	Setup()
	SetupTriggers()
end

--here we setup things
function Setup()

end

--here we setup the triggers, these can be found in fxdata/lua/triggers/Events.lua
function SetupTriggers()

end
""" % [mapName, authorName]

func _on_ViewSubmenu_Pressed(pressedID):
	match pressedID:
		0: # 3D: 1st person
			if oEditor.currentView == oEditor.VIEW_2D:
				oEditor.set_view_3d()
				oGenerateTerrain.start()
			oUi.switch_to_1st_person()
		1: Utils.popup_centered(oInstanceListWindow) # Instance list
		2: Utils.popup_centered(oGridDataWindow) # Grid data
		3: Utils.popup_centered(oSortCreatureStats) # Creature stats

func _on_HelpSubmenu_Pressed(pressedID):
	match pressedID:
		0: Utils.popup_centered(oControlsWindow) # Controls
		1: OS.shell_open("https://github.com/dkfans/keeperfx/wiki/Creating-a-new-campaign")
		2: OS.shell_open("https://github.com/dkfans/keeperfx/wiki/KeeperFx-Map-files-format-reference")
		3: OS.shell_open("https://keeperfx.net/workshop")
		4: Utils.popup_centered(oChangelogWindow) # Changelog
		5: OS.shell_open("https://github.com/rainlizard/Unearth/issues/new")
		6: Utils.popup_centered(oAboutWindow) # About


func _on_PlayButton_pressed(): # Use normal Button instead of MenuButton in combination with OS.execute otherwise a Godot bug occurs
	play_button_pressed(false)

func _on_PlayButton_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed == true:
		accept_event()
		play_button_pressed(true)

func play_button_pressed(packetLoad):
	if playButtonLocked == true:
		return
	if oCurrentFormat.selected == Constants.KfxFormat:
		if oGame.keeperfx_is_installed() == false:
			oMessage.big("Incompatible", "Your map format is set to KFX format, but your game executable is not set to keeperfx.exe")
			return
	if packetLoad == true and oGame.keeperfx_is_installed() == false:
		oMessage.big("Incompatible", "Packetload requires keeperfx.exe")
		return

	playButtonLocked = true
	if oGame.menu_play_clicked(packetLoad) == false:
		playButtonLocked = false
		return

	yield(get_tree().create_timer(2.5), "timeout")
	playButtonLocked = false
