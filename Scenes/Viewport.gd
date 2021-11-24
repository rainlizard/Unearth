extends Viewport

# Be very careful with project settings "expand" setting and maybe "2D", it can make the zoom imprecise.

var cameraInitialZoom

func _init():
	OS.window_borderless = false
	OS.set_window_position(Vector2(1000000000,1000000000)) # Put window off screen
	msaa = Viewport.MSAA_16X

func _ready():
	get_tree().get_root().connect("size_changed",self,"size_changed")
	
	var desktopResolution = OS.get_screen_size()
	var sameSize = desktopResolution.y * 0.9
	size = Vector2(sameSize, sameSize)
	
	var oldWindowSize = OS.get_screen_size()
	
	if Settings.cfg_has_setting("editor_window_size") == true:
		OS.window_size = Settings.read_cfg("editor_window_size")
	else:
		OS.window_size = Vector2(sameSize, sameSize)
	size_changed() # Needs to be called if starting the program up in fullscreen
	
	var newWindowSize = OS.get_screen_size()
	# Make the zoom level DIFFERENT depending on the monitor resolution. The 9085 is a magic number to try and fit the entire field onto the screen.
	# Camera2D refers to this value
	cameraInitialZoom = (oldWindowSize.y/newWindowSize.y) * (9085.0/newWindowSize.y)
	
#	for i in 2: #Wait for black screen
#		yield(get_tree(), "idle_frame")
	if Settings.cfg_has_setting("editor_window_position") == true:
		OS.window_position = Settings.read_cfg("editor_window_position")
	else:
		OS.center_window()
	
	if Settings.cfg_has_setting("editor_window_maximized_state") == true:
		OS.window_maximized = Settings.read_cfg("editor_window_maximized_state")
	else:
		OS.window_maximized = false
	
	if Settings.cfg_has_setting("editor_window_fullscreen_state") == true:
		OS.window_fullscreen = Settings.read_cfg("editor_window_fullscreen_state")
	else:
		OS.window_fullscreen = false
	
	var sceneMain = preload("res://Scenes/Main.tscn")
	
	var id = sceneMain.instance()
	add_child(id)

func size_changed():
	size = OS.window_size

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		Settings.write_cfg("editor_window_position", OS.window_position)
		Settings.write_cfg("editor_window_maximized_state", OS.window_maximized)
		Settings.write_cfg("editor_window_fullscreen_state", OS.window_fullscreen)
		Settings.write_cfg("editor_window_size", OS.window_size)
