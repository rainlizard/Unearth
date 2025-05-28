extends Node
enum {
	SET = 0
	GET = 1
}
var haveInitializedAllSettings = false

var UI_SCALE = Vector2(1, 1)

var unearth_path = ""
var unearthdata = ""
var settings_file_path = ""

var config = ConfigFile.new()

var listOfSettings = [
	"REMEMBER_TMAPA_PATHS",
	"executable_path",
	"file_viewer_window_size",
	"file_viewer_window_position",
	"vsync",
	"framerate_limit",
	"always_decompress",
	"msaa",
	"dk_commands",
	"mouse_edge_panning",
	"pan_speed",
	"zoom_step",
	"smooth_pan_enabled",
	"smoothing_rate",
	"graphics_ownership_alpha",
	"symmetry_guidelines",
	"display_fps",
	"mouse_sensitivity",
	"fov",
	"display_3d_info",
	"ui_scale",
	"font_size_creature_level_scale",
	"font_size_creature_level_max",
	"script_icon_scale",
	"script_icon_max",
	"facing_arrow_scale",
	"facing_arrow_max",
	"slab_window_size",
	"slab_window_position",
	"slab_window_scale",
	"thing_window_size",
	"thing_window_position",
	"thing_window_scale",
	"script_editor_font_size",
	
#	"owner_window_size",
#	"owner_window_position",
#	"owner_window_scale",
	
	#"display_details_viewer",
	"details_viewer_window_position",
	"slab_style_window_size",
	"slab_style_window_position",
	"ownable_natural_terrain",
	"editable_borders",
	"bridges_only_on_liquid",
	"round_path_near_liquid",
	"round_earth_near_path",
	"round_earth_near_liquid",
	"round_rock_near_path",
	"round_rock_near_liquid",
	"round_gold_near_path",
	"round_gold_near_liquid",
	"round_water_near_lava",
	"place_things_anywhere",
	"wallauto_art",
	"wallauto_damaged",
	"recently_opened",
	"placing_tutorial",
	"chance_effect_water",
	"chance_effect_lava",
	"chance_path_stone",
	"auto_open_map_settings",
	"fortify",
	"automatic_torch_slabs",
	# These four are read inside Viewport script
#	"editor_window_position",
#	"editor_window_size",
#	"editor_window_maximized_state",
#	"editor_window_fullscreen_state",
]


func _init(): # Lots of stuff relies on "unearthdata" being set first.
	if OS.has_feature("standalone") == true:
		# Create settings.cfg next to unearth.exe
		unearth_path = OS.get_executable_path().get_base_dir()
	else:
		unearth_path = ""
	unearthdata = unearth_path.plus_file("unearthdata")


func initialize_settings():
	settings_file_path = unearth_path.plus_file("settings.cfg")
	var loadError = config.load(settings_file_path)
	if loadError != OK:
		var saveError = config.save(settings_file_path)
		
		if saveError != OK:
			var oMessage = Nodelist.list["oMessage"]
			oMessage.big("Error", "Cannot create settings.cfg: Error "+ str(saveError) + "\n" + "Please exit the editor and move the Unearth directory elsewhere.")
			return
	
	read_all()
	
	executable_stuff()
	
	haveInitializedAllSettings = true

func executable_stuff():
	var oGame = Nodelist.list["oGame"]
	
	# If previous executable_path is no longer valid (maybe it was deleted)
	if cfg_has_setting("executable_path") == true:
		if File.new().file_exists(oGame.EXECUTABLE_PATH) == false:
			cfg_remove_setting("executable_path")
	
	# Choose executable path upon first starting
	if cfg_has_setting("executable_path") == false:
		for i in 2:
			yield(get_tree(),'idle_frame')
		var oChooseDkExe = $'../Main/Ui/UiSystem/ChooseDkExe'
		Utils.popup_centered(oChooseDkExe)
	else:
		# Test whenever you restart, to always show the error if there's a problem
		if oGame.EXECUTABLE_PATH != "": # Don't provide an error when an executable hasn't even been set
			oGame.test_write_permissions()

func cfg_has_setting(setting):
	return config.has_section_key("settings", setting)

func cfg_remove_setting(setting):
	return config.erase_section_key("settings", setting)



func get_setting(string):
	return Settings.game_setting(Settings.GET, string, null)

func set_setting(string, value):
	Settings.write_cfg(string, value)
	Settings.game_setting(Settings.SET, string, value)

func read_all():
	# Read all
	var CODETIME_START = OS.get_ticks_msec()
	
	for i in listOfSettings:
		if cfg_has_setting(i) == true:
			var value = config.get_value("settings", i)
			if value != null:
				game_setting(SET, i, value)
	
	print('Read all settings in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func game_setting(doWhat,string,value):
	match string:
		"REMEMBER_TMAPA_PATHS":
			var oTMapLoader = $'../Main/TMapLoader'
			if doWhat == SET: oTMapLoader.load_remembered_paths(value)
			if doWhat == GET: return oTMapLoader.REMEMBER_TMAPA_PATHS
		"executable_path":
			var oGame = $'../Main/Game'
			if doWhat == SET: oGame.set_paths(value)
			if doWhat == GET: return oGame.EXECUTABLE_PATH
		"file_viewer_window_size":
			var oMapBrowser = $'../Main/Ui/UiSystem/MapBrowser'
			if doWhat == SET: oMapBrowser.rect_size = value
			if doWhat == GET: return oMapBrowser.rect_size
		"file_viewer_window_position":
			var oMapBrowser = $'../Main/Ui/UiSystem/MapBrowser'
			if doWhat == SET: oMapBrowser.rect_position = value
			if doWhat == GET: return oMapBrowser.rect_position
		"vsync":
			if doWhat == SET: OS.vsync_enabled = value
			if doWhat == GET: return OS.vsync_enabled
		"framerate_limit":
			var oEditor = $'../Main/Editor'
			if doWhat == SET: oEditor.framerate_limit = value
			if doWhat == GET: return oEditor.framerate_limit
		"always_decompress":
			var oOpenMap = $'../Main/OpenMap'
			if doWhat == SET: oOpenMap.ALWAYS_DECOMPRESS = value
			if doWhat == GET: return oOpenMap.ALWAYS_DECOMPRESS
		"msaa":
			var oViewport = get_viewport()
			if doWhat == SET: oViewport.msaa = value
			if doWhat == GET: return oViewport.msaa
		"dk_commands":
			var oGame = $'../Main/Game'
			if doWhat == SET: oGame.DK_COMMANDS = value
			if doWhat == GET: return oGame.DK_COMMANDS
		"mouse_edge_panning":
			var oCamera2D = $'../Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.MOUSE_EDGE_PANNING = value
			if doWhat == GET: return oCamera2D.MOUSE_EDGE_PANNING
		"pan_speed":
			var oCamera2D = $'../Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.DIRECTIONAL_PAN_SPEED = value
			if doWhat == GET: return oCamera2D.DIRECTIONAL_PAN_SPEED
		"zoom_step":
			var oCamera2D = $'../Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.ZOOM_STEP = value
			if doWhat == GET: return oCamera2D.ZOOM_STEP
		"smooth_pan_enabled":
			var oCamera2D = $'../Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.SMOOTH_PAN_ENABLED = value
			if doWhat == GET: return oCamera2D.SMOOTH_PAN_ENABLED
		"smoothing_rate":
			var oCamera2D = $'../Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.SMOOTHING_RATE = value
			if doWhat == GET: return oCamera2D.SMOOTHING_RATE
		"graphics_ownership_alpha":
			var oOverheadOwnership = $'../Main/Game2D/OverheadOwnership'
			if doWhat == SET: oOverheadOwnership.OWNERSHIP_ALPHA = value
			if doWhat == GET: return oOverheadOwnership.OWNERSHIP_ALPHA
		"symmetry_guidelines":
			var oGuidelines = $'../Main/Game2D/Guidelines'
			if doWhat == SET: oGuidelines.LINE_ALPHA = value
			if doWhat == GET: return oGuidelines.LINE_ALPHA
		"display_fps":
			var oFPScounter = $'../Main/Ui/UiMessages/FPScounter'
			if doWhat == SET: oFPScounter.visible = value
			if doWhat == GET: return oFPScounter.visible
		"mouse_sensitivity":
			var oPlayer = $'../Main/Game3D/Player'
			if doWhat == SET: oPlayer.mouseSensitivity = value
			if doWhat == GET: return oPlayer.mouseSensitivity
		"fov":
			var oCamera3D = $'../Main/Game3D/Player/Head/Camera3D'
			if doWhat == SET: oCamera3D.fov = value
			if doWhat == GET: return oCamera3D.fov
		"display_3d_info":
			var o3DCameraInfo = $'../Main/Ui/Ui3D/3DCameraInfo'
			if doWhat == SET: o3DCameraInfo.ENABLE_CAMERA_COORDS = value
			if doWhat == GET: return o3DCameraInfo.ENABLE_CAMERA_COORDS
		"ui_scale":
			var oUi = $'../Main/Ui'
			if doWhat == SET: oUi.set_ui_scale(value)
			if doWhat == GET: return UI_SCALE.x
		"font_size_creature_level_scale":
			var oUi = $'../Main/Ui'
			if doWhat == SET: oUi.FONT_SIZE_CR_LVL_BASE = value
			if doWhat == GET: return oUi.FONT_SIZE_CR_LVL_BASE
		"font_size_creature_level_max":
			var oUi = $'../Main/Ui'
			if doWhat == SET: oUi.FONT_SIZE_CR_LVL_MAX = value
			if doWhat == GET: return oUi.FONT_SIZE_CR_LVL_MAX
		"script_icon_scale":
			var oScriptHelpers = $'../Main/Game2D/ScriptHelpers'
			if doWhat == SET: oScriptHelpers.SCRIPT_ICON_SIZE_BASE = value
			if doWhat == GET: return oScriptHelpers.SCRIPT_ICON_SIZE_BASE
		"script_icon_max":
			var oScriptHelpers = $'../Main/Game2D/ScriptHelpers'
			if doWhat == SET: oScriptHelpers.SCRIPT_ICON_SIZE_MAX = value
			if doWhat == GET: return oScriptHelpers.SCRIPT_ICON_SIZE_MAX
		"facing_arrow_scale":
			var oUi = $'../Main/Ui'
			if doWhat == SET: oUi.FACING_ARROW_SIZE_BASE = value
			if doWhat == GET: return oUi.FACING_ARROW_SIZE_BASE
		"facing_arrow_max":
			var oUi = $'../Main/Ui'
			if doWhat == SET: oUi.FACING_ARROW_SIZE_MAX = value
			if doWhat == GET: return oUi.FACING_ARROW_SIZE_MAX
		"slab_window_size":
			var oPickSlabWindow = $'../Main/Ui/UiTools/PickSlabWindow'
			if doWhat == SET: oPickSlabWindow.rect_size = value
			if doWhat == GET: return oPickSlabWindow.rect_size
		"slab_window_position":
			var oPickSlabWindow = $'../Main/Ui/UiTools/PickSlabWindow'
			if doWhat == SET: oPickSlabWindow.rect_position = value
			if doWhat == GET: return oPickSlabWindow.rect_position
		"slab_window_scale":
			var oPickSlabWindow = $'../Main/Ui/UiTools/PickSlabWindow'
			if doWhat == SET: oPickSlabWindow.grid_window_scale = value
			if doWhat == GET: return oPickSlabWindow.grid_window_scale
		"thing_window_size":
			var oPickThingWindow = $'../Main/Ui/UiTools/PickThingWindow'
			if doWhat == SET: oPickThingWindow.rect_size = value
			if doWhat == GET: return oPickThingWindow.rect_size
		"thing_window_position":
			var oPickThingWindow = $'../Main/Ui/UiTools/PickThingWindow'
			if doWhat == SET: oPickThingWindow.rect_position = value
			if doWhat == GET: return oPickThingWindow.rect_position
		"thing_window_scale":
			var oPickThingWindow = $'../Main/Ui/UiTools/PickThingWindow'
			if doWhat == SET: oPickThingWindow.grid_window_scale = value
			if doWhat == GET: return oPickThingWindow.grid_window_scale
#		"owner_window_size":
#			var oOwnerSelection = $'../Main/Ui/UiTools/OwnerSelection'
#			if doWhat == SET: oOwnerSelection.rect_size = value
#			if doWhat == GET: return oOwnerSelection.rect_size
#		"owner_window_position":
#			var oOwnerSelection = $'../Main/Ui/UiTools/OwnerSelection'
#			if doWhat == SET: oOwnerSelection.rect_position = value
#			if doWhat == GET: return oOwnerSelection.rect_position
#		"owner_window_scale":
#			var oOwnerSelection = $'../Main/Ui/UiTools/OwnerSelection'
#			if doWhat == SET: oOwnerSelection.grid_window_scale = value
#			if doWhat == GET: return oOwnerSelection.grid_window_scale
		
		"editor_window_position":
			if doWhat == SET: OS.window_position = value
			if doWhat == GET: return OS.window_position
		"editor_window_size":
			if doWhat == SET: OS.window_size = value
			if doWhat == GET: return OS.window_size
		"editor_window_maximized_state":
			if doWhat == SET: OS.window_maximized = value
			if doWhat == GET: return OS.window_maximized
		"editor_window_fullscreen_state":
			if doWhat == SET: OS.window_fullscreen = value
			if doWhat == GET: return OS.window_fullscreen
		"details_viewer_window_position":
			var oPropertiesWindow = $'../Main/Ui/UiTools/PropertiesWindow'
			if doWhat == SET: oPropertiesWindow.rect_position = value
			if doWhat == GET: return oPropertiesWindow.rect_position
#		"display_details_viewer":
#			var oPropertiesWindow = $'../Main/Ui/UiTools/PropertiesWindow'
#			if doWhat == SET: oPropertiesWindow.display_details = value
#			if doWhat == GET: return oPropertiesWindow.display_details
		"ownable_natural_terrain":
			var oOwnableNaturalTerrain = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/OwnableNaturalTerrain'
			if doWhat == SET: oOwnableNaturalTerrain.pressed = value
			if doWhat == GET: return oOwnableNaturalTerrain.pressed
		"editable_borders":
			var oEditableBordersCheckbox = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/EditableBordersCheckbox'
			if doWhat == SET: oEditableBordersCheckbox.pressed = value
			if doWhat == GET: return oEditableBordersCheckbox.pressed
		"bridges_only_on_liquid":
			var oBridgesOnlyOnLiquidCheckbox = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/BridgesOnlyOnLiquidCheckbox'
			if doWhat == SET: oBridgesOnlyOnLiquidCheckbox.pressed = value
			if doWhat == GET: return oBridgesOnlyOnLiquidCheckbox.pressed
		"round_path_near_liquid":
			var oRoundPathNearLiquid = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/RoundPathNearLiquid'
			if doWhat == SET: oRoundPathNearLiquid.pressed = value
			if doWhat == GET: return oRoundPathNearLiquid.pressed
		"round_earth_near_path":
			var oRoundEarthNearPath = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/RoundEarthNearPath'
			if doWhat == SET: oRoundEarthNearPath.pressed = value
			if doWhat == GET: return oRoundEarthNearPath.pressed
		"round_earth_near_liquid":
			var oRoundEarthNearLiquid = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/RoundEarthNearLiquid'
			if doWhat == SET: oRoundEarthNearLiquid.pressed = value
			if doWhat == GET: return oRoundEarthNearLiquid.pressed
		"round_rock_near_path":
			var oRoundRockNearPath = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/RoundRockNearPath'
			if doWhat == SET: oRoundRockNearPath.pressed = value
			if doWhat == GET: return oRoundRockNearPath.pressed
		"round_rock_near_liquid":
			var oRoundRockNearLiquid = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/RoundRockNearLiquid'
			if doWhat == SET: oRoundRockNearLiquid.pressed = value
			if doWhat == GET: return oRoundRockNearLiquid.pressed
		"round_gold_near_path":
			var oRoundGoldNearPath = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/RoundGoldNearPath'
			if doWhat == SET: oRoundGoldNearPath.pressed = value
			if doWhat == GET: return oRoundGoldNearPath.pressed
		"round_gold_near_liquid":
			var oRoundGoldNearLiquid = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/RoundGoldNearLiquid'
			if doWhat == SET: oRoundGoldNearLiquid.pressed = value
			if doWhat == GET: return oRoundGoldNearLiquid.pressed
		"round_water_near_lava":
			var oRoundWaterNearLava = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/RoundWaterNearLava'
			if doWhat == SET: oRoundWaterNearLava.pressed = value
			if doWhat == GET: return oRoundWaterNearLava.pressed
		"place_things_anywhere":
			var oPlaceThingsAnywhere = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/PlaceThingsAnywhere'
			if doWhat == SET: oPlaceThingsAnywhere.pressed = value
			if doWhat == GET: return oPlaceThingsAnywhere.pressed
		"automatic_torch_slabs":
			var oAutomaticTorchSlabsCheckbox = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/AutomaticTorchSlabsCheckbox'
			if doWhat == SET: oAutomaticTorchSlabsCheckbox.pressed = value
			if doWhat == GET: return oAutomaticTorchSlabsCheckbox.pressed
		"wallauto_art":
			var oAutoWallArtButton = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/GridContainer/AutoWallArtButton'
			if doWhat == SET: oAutoWallArtButton.text = value
			if doWhat == GET: return oAutoWallArtButton.text
		"wallauto_damaged":
			var oDamagedWallLineEdit = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/GridContainer/DamagedWallLineEdit'
			if doWhat == SET: oDamagedWallLineEdit.text = value
			if doWhat == GET: return oDamagedWallLineEdit.text
		"recently_opened":
			var oMenu = $'../Main/Ui/UiTop/Menu'
			if doWhat == SET: oMenu.initialize_recently_opened(value)
			if doWhat == GET: return oMenu.recentlyOpened
		"placing_tutorial":
			var oPlacingTipsButton = $"../Main/Ui/UiTools/PropertiesWindow/VBoxContainer/PropertiesTabs/PlacingSettings/PlacingTipsButton"
			if doWhat == SET: oPlacingTipsButton.visible = value
			if doWhat == GET: return oPlacingTipsButton.visible
		"script_editor_font_size":
			var oScriptEditor = $'../Main/Ui/UiSystem/ScriptEditorWindow/MarginContainer/ScrollContainer/ScriptEditor'
			if doWhat == SET: oScriptEditor.set_SCRIPT_EDITOR_FONT_SIZE(value)
			if doWhat == GET: return oScriptEditor.get_SCRIPT_EDITOR_FONT_SIZE()
		"editor_font_size":
			var oUiSystem = $'../Main/Ui/UiSystem'
			if doWhat == SET: oUiSystem.theme.get_font("font","").size = value
			if doWhat == GET: return oUiSystem.theme.get_font("font","").size
		"chance_effect_water":
			var oWaterEffectPercent = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/HBoxContainer/WaterEffectPercent'
			if doWhat == SET: oWaterEffectPercent.value = value
			if doWhat == GET: return oWaterEffectPercent.value
		"chance_effect_lava":
			var oLavaEffectPercent = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/HBoxContainer2/LavaEffectPercent'
			if doWhat == SET: oLavaEffectPercent.value = value
			if doWhat == GET: return oLavaEffectPercent.value
		"chance_path_stone":
			var oPathStonePercent = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabPlacements/MarginContainer/VBoxContainer/HBoxContainer3/PathStonePercent'
			if doWhat == SET: oPathStonePercent.value = value
			if doWhat == GET: return oPathStonePercent.value
		"auto_open_map_settings":
			var oCheckBoxNewMapAutoOpensMapSettings = $'../Main/Ui/UiSystem/PreferencesWindow/VBoxContainer/TabSettings/TabUI/VBoxContainer/CheckBoxNewMapAutoOpensMapSettings'
			if doWhat == SET: oCheckBoxNewMapAutoOpensMapSettings.pressed = value
			if doWhat == GET: return oCheckBoxNewMapAutoOpensMapSettings.pressed
		"fortify":
			var oFortifyCheckBox = $"../Main/Ui/UiTools/PropertiesWindow/VBoxContainer/PropertiesTabs/PlacingSettings/FortifyCheckBox"
			if doWhat == SET: oFortifyCheckBox.pressed = value
			if doWhat == GET: return oFortifyCheckBox.pressed

func delete_settings():
	var dir = Directory.new()
	if dir.file_exists(settings_file_path) == true:
		dir.remove(settings_file_path)

func read_cfg(setting):
	return config.get_value("settings", setting)

func write_cfg(setting, value):
#	var err = config.load(settings_file_path)
#	if err == OK:
	config.set_value("settings", setting, value)
	config.save(settings_file_path)
