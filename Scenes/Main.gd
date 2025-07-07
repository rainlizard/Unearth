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
	
	# Auto switch to 3D while devving
#	for i in 2:
#		yield(get_tree(),'idle_frame')
#	$Editor._on_ButtonViewType_pressed()

func initialize_window_settings():
	if Settings.cfg_has_setting("ui_scale") == false:
		var desktopResolution = OS.get_screen_size()
		var scaleValue = desktopResolution.x / 1920.0
		scaleValue = round(scaleValue * 100.0) / 100.0
		oUi.set_ui_scale(scaleValue)

	#var vp = get_viewport()
	
	OS.window_borderless = false
	
	if Settings.cfg_has_setting("editor_window_size") == true:
		OS.window_size = Settings.read_cfg("editor_window_size")
	else:
		var sameSize = OS.get_screen_size().y * 0.9
		OS.window_size = Vector2(sameSize, sameSize)
	if Settings.cfg_has_setting("editor_window_position") == true:
		var newPos = Settings.read_cfg("editor_window_position")
		var desktopRes = OS.get_screen_size(-1)
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


#func get_mipmap(img, level): # Doesn't need to care about formats, but can't handle the smallest MIP level
#	if img.has_mipmaps() == false: return
#
#	if img.is_compressed():
#		img.decompress()
#
#	var mip_offset = img.get_mipmap_offset(level)
#	var next_offset = img.get_mipmap_offset(level + 1)
#	assert (mip_offset >= 0 and next_offset > 0)
#
#	var buffer = img.get_data().subarray(mip_offset, next_offset - 1)
#
#	var size = img.get_size()
#	var new_width = int(size.x / pow(2, level))
#	var new_height = int(size.y / pow(2, level))
#
#	var mipmapImage = Image.new()
#	mipmapImage.create_from_data(new_width, new_height, false, img.get_format(), buffer)
#	assert (mipmapImage.get_size() == Vector2(new_width, new_height))
#	return mipmapImage

