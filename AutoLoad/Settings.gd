extends Node
enum {
	SET = 0
	GET = 1
}
var haveInitializedAllSettings = false

var unearth_path = ""
var unearthdata = ""
var settings_file_path = ""

var config = ConfigFile.new()

var listOfSettings = [
	"REMEMBER_TMAPA_PATHS",
	"custom_objects",
	"executable_path",
	"save_path",
	"file_viewer_window_size",
	"file_viewer_window_position",
	"vsync",
	"always_decompress",
	"msaa",
	"play_command_line",
	"mouse_edge_panning",
	"pan_speed",
	"zoom_step",
	"smooth_pan_enabled",
	"smoothing_rate",
	"graphics_ownership_alpha",
	"display_fps",
	"mouse_sensitivity",
	"fov",
	"display_3d_info",
	
	"font_size",
	"font_size_creature_level_scale",
	"font_size_creature_level_max",
	"slab_window_size",
	"slab_window_position",
	"slab_window_scale",
	"thing_window_size",
	"thing_window_position",
	"thing_window_scale",
	
#	"owner_window_size",
#	"owner_window_position",
#	"owner_window_scale",
	
	#"display_details_viewer",
	"details_viewer_window_position",
	"slab_style_window_size",
	"slab_style_window_position",
	"hide_unknown_data",
	"ownable_natural_terrain",
	"editable_borders",
	"bridges_only_on_liquid",
	"wallauto_art",
	"wallauto_damaged",
	
	# These four are read inside Viewport script
#	"editor_window_position",
#	"editor_window_size",
#	"editor_window_maximized_state",
#	"editor_window_fullscreen_state",
]

func _init():
	if OS.has_feature("standalone") == true:
		# Create settings.cfg next to unearth.exe
		unearth_path = OS.get_executable_path().get_base_dir()
	else:
		unearth_path = ""
		# Create settings.cfg in res:// directory
		#settings_file_path = "settings.cfg"
	unearthdata = unearth_path.plus_file("unearthdata/")
	settings_file_path = unearth_path.plus_file("settings.cfg")
	var err = config.load(settings_file_path)
	if err != OK: config.save(settings_file_path)

func initialize_settings():
	read_all()
	# Choose executable path upon first starting
	if cfg_has_setting("executable_path") == false:
		var oChooseDkExe = $'../ViewportContainer/Viewport/Main/Ui/UiSystem/ChooseDkExe'
		Utils.popup_centered(oChooseDkExe)
	haveInitializedAllSettings = true

func cfg_has_setting(setting):
	return config.has_section_key("settings", setting)

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
			var oTextureCache = $'../ViewportContainer/Viewport/Main/TextureCache'
			if doWhat == SET: oTextureCache.LOAD_TMAPA_PATHS_FROM_SETTINGS(value)
			if doWhat == GET: return oTextureCache.REMEMBER_TMAPA_PATHS
		"custom_objects":
			var oCustomData = $'../ViewportContainer/Viewport/Main/CustomData'
			if doWhat == SET: oCustomData.load_custom_objects(value)
			if doWhat == GET: return oCustomData.CUSTOM_OBJECTS
		"executable_path":
			var oGame = $'../ViewportContainer/Viewport/Main/Game'
			if doWhat == SET: oGame.set_paths(value)
			if doWhat == GET: return oGame.EXECUTABLE_PATH
		"save_path":
			var oGame = $'../ViewportContainer/Viewport/Main/Game'
			if doWhat == SET: oGame.set_SAVE_AS_DIRECTORY(value)
			if doWhat == GET: return oGame.SAVE_AS_DIRECTORY
		"file_viewer_window_size":
			var oMapBrowser = $'../ViewportContainer/Viewport/Main/Ui/UiSystem/MapBrowser'
			if doWhat == SET: oMapBrowser.rect_size = value
			if doWhat == GET: return oMapBrowser.rect_size
		"file_viewer_window_position":
			var oMapBrowser = $'../ViewportContainer/Viewport/Main/Ui/UiSystem/MapBrowser'
			if doWhat == SET: oMapBrowser.rect_position = value
			if doWhat == GET: return oMapBrowser.rect_position
		"vsync":
			if doWhat == SET: OS.vsync_enabled = value
			if doWhat == GET: return OS.vsync_enabled
		"always_decompress":
			var oOpenMap = $'../ViewportContainer/Viewport/Main/OpenMap'
			if doWhat == SET: oOpenMap.ALWAYS_DECOMPRESS = value
			if doWhat == GET: return oOpenMap.ALWAYS_DECOMPRESS
		"msaa":
			if doWhat == SET: get_viewport().msaa = value
			if doWhat == GET: return get_viewport().msaa
		"play_command_line":
			var oGame = $'../ViewportContainer/Viewport/Main/Game'
			if doWhat == SET: oGame.COMMAND_LINE = value
			if doWhat == GET: return oGame.COMMAND_LINE
		"mouse_edge_panning":
			var oCamera2D = $'../ViewportContainer/Viewport/Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.MOUSE_EDGE_PANNING = value
			if doWhat == GET: return oCamera2D.MOUSE_EDGE_PANNING
		"pan_speed":
			var oCamera2D = $'../ViewportContainer/Viewport/Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.DIRECTIONAL_PAN_SPEED = value
			if doWhat == GET: return oCamera2D.DIRECTIONAL_PAN_SPEED
		"zoom_step":
			var oCamera2D = $'../ViewportContainer/Viewport/Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.ZOOM_STEP = value
			if doWhat == GET: return oCamera2D.ZOOM_STEP
		"smooth_pan_enabled":
			var oCamera2D = $'../ViewportContainer/Viewport/Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.SMOOTH_PAN_ENABLED = value
			if doWhat == GET: return oCamera2D.SMOOTH_PAN_ENABLED
		"smoothing_rate":
			var oCamera2D = $'../ViewportContainer/Viewport/Main/Game2D/Camera2D'
			if doWhat == SET: oCamera2D.SMOOTHING_RATE = value
			if doWhat == GET: return oCamera2D.SMOOTHING_RATE
		"graphics_ownership_alpha":
			var oOverheadOwnership = $'../ViewportContainer/Viewport/Main/Game2D/OverheadOwnership'
			if doWhat == SET: oOverheadOwnership.OWNERSHIP_ALPHA = value
			if doWhat == GET: return oOverheadOwnership.OWNERSHIP_ALPHA
		"display_fps":
			var oFPScounter = $'../ViewportContainer/Viewport/Main/Ui/UiMessages/FPScounter'
			if doWhat == SET: oFPScounter.visible = value
			if doWhat == GET: return oFPScounter.visible
		"mouse_sensitivity":
			var oPlayer = $'../ViewportContainer/Viewport/Main/Game3D/Player'
			if doWhat == SET: oPlayer.mouseSensitivity = value
			if doWhat == GET: return oPlayer.mouseSensitivity
		"fov":
			var oCamera3D = $'../ViewportContainer/Viewport/Main/Game3D/Player/Head/Camera3D'
			if doWhat == SET: oCamera3D.fov = value
			if doWhat == GET: return oCamera3D.fov
		"display_3d_info":
			var oExtra3DInfo = $'../ViewportContainer/Viewport/Main/Ui/Ui3D/Extra3DInfo'
			if doWhat == SET: oExtra3DInfo.visible = value
			if doWhat == GET: return oExtra3DInfo.visible
		"font_size":
			var oUi = $'../ViewportContainer/Viewport/Main/Ui'
			if doWhat == SET: oUi.FONT_SIZE = value
			if doWhat == GET: return oUi.FONT_SIZE
		"font_size_creature_level_scale":
			var oUi = $'../ViewportContainer/Viewport/Main/Ui'
			if doWhat == SET: oUi.FONT_SIZE_CR_LVL_BASE = value
			if doWhat == GET: return oUi.FONT_SIZE_CR_LVL_BASE
		"font_size_creature_level_max":
			var oUi = $'../ViewportContainer/Viewport/Main/Ui'
			if doWhat == SET: oUi.FONT_SIZE_CR_LVL_MAX = value
			if doWhat == GET: return oUi.FONT_SIZE_CR_LVL_MAX
		"slab_window_size":
			var oPickSlabWindow = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PickSlabWindow'
			if doWhat == SET: oPickSlabWindow.rect_size = value
			if doWhat == GET: return oPickSlabWindow.rect_size
		"slab_window_position":
			var oPickSlabWindow = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PickSlabWindow'
			if doWhat == SET: oPickSlabWindow.rect_position = value
			if doWhat == GET: return oPickSlabWindow.rect_position
		"slab_window_scale":
			var oPickSlabWindow = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PickSlabWindow'
			if doWhat == SET: oPickSlabWindow.grid_window_scale = value
			if doWhat == GET: return oPickSlabWindow.grid_window_scale
		"thing_window_size":
			var oPickThingWindow = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PickThingWindow'
			if doWhat == SET: oPickThingWindow.rect_size = value
			if doWhat == GET: return oPickThingWindow.rect_size
		"thing_window_position":
			var oPickThingWindow = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PickThingWindow'
			if doWhat == SET: oPickThingWindow.rect_position = value
			if doWhat == GET: return oPickThingWindow.rect_position
		"thing_window_scale":
			var oPickThingWindow = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PickThingWindow'
			if doWhat == SET: oPickThingWindow.grid_window_scale = value
			if doWhat == GET: return oPickThingWindow.grid_window_scale
#		"owner_window_size":
#			var oOwnerSelection = $'../ViewportContainer/Viewport/Main/Ui/UiTools/OwnerSelection'
#			if doWhat == SET: oOwnerSelection.rect_size = value
#			if doWhat == GET: return oOwnerSelection.rect_size
#		"owner_window_position":
#			var oOwnerSelection = $'../ViewportContainer/Viewport/Main/Ui/UiTools/OwnerSelection'
#			if doWhat == SET: oOwnerSelection.rect_position = value
#			if doWhat == GET: return oOwnerSelection.rect_position
#		"owner_window_scale":
#			var oOwnerSelection = $'../ViewportContainer/Viewport/Main/Ui/UiTools/OwnerSelection'
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
			var oPropertiesWindow = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PropertiesWindow'
			if doWhat == SET: oPropertiesWindow.rect_position = value
			if doWhat == GET: return oPropertiesWindow.rect_position
#		"display_details_viewer":
#			var oPropertiesWindow = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PropertiesWindow'
#			if doWhat == SET: oPropertiesWindow.display_details = value
#			if doWhat == GET: return oPropertiesWindow.display_details
		"hide_unknown_data":
			var oThingDetails = $'../ViewportContainer/Viewport/Main/Ui/UiTools/PropertiesWindow/VBoxContainer/PropertiesTabs/ThingDetails'
			if doWhat == SET: oThingDetails.HIDE_UNKNOWN_DATA = value
			if doWhat == GET: return oThingDetails.HIDE_UNKNOWN_DATA
		"ownable_natural_terrain":
			var oOwnableNaturalTerrain = $'../ViewportContainer/Viewport/Main/Ui/UiSystem/SlabSettingsWindow/MarginContainer/VBoxContainer/OwnableNaturalTerrain'
			if doWhat == SET: oOwnableNaturalTerrain.pressed = value
			if doWhat == GET: return oOwnableNaturalTerrain.pressed
		"editable_borders":
			var oEditableBordersCheckbox = $'../ViewportContainer/Viewport/Main/Ui/UiSystem/SlabSettingsWindow/MarginContainer/VBoxContainer/EditableBordersCheckbox'
			if doWhat == SET: oEditableBordersCheckbox.pressed = value
			if doWhat == GET: return oEditableBordersCheckbox.pressed
		"bridges_only_on_liquid":
			var oBridgesOnlyOnLiquidCheckbox = $'../ViewportContainer/Viewport/Main/Ui/UiSystem/SlabSettingsWindow/MarginContainer/VBoxContainer/BridgesOnlyOnLiquidCheckbox'
			if doWhat == SET: oBridgesOnlyOnLiquidCheckbox.pressed = value
			if doWhat == GET: return oBridgesOnlyOnLiquidCheckbox.pressed
		"wallauto_art":
			var oAutoWallArtButton = $'../ViewportContainer/Viewport/Main/Ui/UiSystem/SlabSettingsWindow/MarginContainer/VBoxContainer/GridContainer/AutoWallArtButton'
			if doWhat == SET: oAutoWallArtButton.text = value
			if doWhat == GET: return oAutoWallArtButton.text
		"wallauto_damaged":
			var oDamagedWallLineEdit = $'../ViewportContainer/Viewport/Main/Ui/UiSystem/SlabSettingsWindow/MarginContainer/VBoxContainer/GridContainer/DamagedWallLineEdit'
			if doWhat == SET: oDamagedWallLineEdit.text = value
			if doWhat == GET: return oDamagedWallLineEdit.text

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
