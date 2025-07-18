extends Node2D
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oUi = Nodelist.list["oUi"]
onready var oOpenMap = Nodelist.list["oOpenMap"]


func _enter_tree():
	print("Unearth v"+Version.full)
	Nodelist.start(self)


func _ready():
	Nodelist.done()
	Settings.initialize_settings()
	initialize_window_settings()
	oUi.initialize_window_desired_values()
	Graphics.load_extra_images_from_harddrive()
	oOpenMap.start()


func initialize_window_settings():
	if Settings.cfg_has_setting("ui_scale") == false:
		var desktopResolution = OS.get_screen_size()
		var scaleValue = desktopResolution.x / 1920.0
		scaleValue = round(scaleValue * 100.0) / 100.0
		oUi.set_ui_scale(scaleValue)
	
	OS.window_borderless = false
	
	if Settings.cfg_has_setting("editor_window_size") == true:
		var getStoredWindowSize = Settings.read_cfg("editor_window_size")
		OS.window_size = Vector2(max(720, getStoredWindowSize.x), max(720, getStoredWindowSize.y))
	else:
		var sameSize = OS.get_screen_size().y * 0.9
		OS.window_size = Vector2(max(720, sameSize), max(720, sameSize))
	
	if Settings.cfg_has_setting("editor_window_position") == true:
		var newPos = Settings.read_cfg("editor_window_position")
		var desktopRes = OS.get_screen_size()
		newPos.x = clamp(newPos.x, 0, desktopRes.x-(desktopRes.x*0.05)) # 5% from the edge
		newPos.y = clamp(newPos.y, 0, desktopRes.y-(desktopRes.y*0.05))
		OS.window_position = newPos
	else:
		OS.center_window()
	
	if Settings.cfg_has_setting("editor_window_maximized_state") == true:
		OS.window_maximized = Settings.read_cfg("editor_window_maximized_state")
	else:
		OS.window_maximized = true
	
	if Settings.cfg_has_setting("editor_window_fullscreen_state") == true:
		OS.window_fullscreen = Settings.read_cfg("editor_window_fullscreen_state")
	else:
		OS.window_fullscreen = false
