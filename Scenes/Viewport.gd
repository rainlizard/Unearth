extends Viewport

var cameraInitialZoom


func _init():
	OS.window_borderless = false
	OS.set_window_position(Vector2(1000000000,1000000000)) # Put window off screen while it loads

func initialize_window_settings():
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
	# Make the zoom level different depending on the monitor resolution. The 9085 is a magic number to try and fit the entire field onto the screen.
	# Camera2D refers to this value
	cameraInitialZoom = (oldWindowSize.y/newWindowSize.y) * (9085.0/newWindowSize.y)
	var oCamera2D = Nodelist.list["oCamera2D"]
	oCamera2D.reset_camera()
	
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

func size_changed():
	size = OS.window_size
