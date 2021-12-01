extends Camera2D
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oSettingsWindow = Nodelist.list["oSettingsWindow"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oUi = Nodelist.list["oUi"]

signal zoom_level_changed

var SMOOTHING_RATE = 10
var ZOOM_STEP = 0.5
var SMOOTH_PAN_ENABLED = false
var MOUSE_EDGE_PANNING = true
var DIRECTIONAL_PAN_SPEED = 1500

var desired_zoom = Vector2()
var desired_offset = Vector2()
var directionalPan = Vector2()
var middleMousePanning = false
var mouseIsMoving = false

func reset_camera():
	offset = Vector2(85*96,85*96) * Vector2(0.5,0.5)
	desired_offset = offset
	
	var initialZoom = get_viewport().cameraInitialZoom
	zoom = Vector2(initialZoom,initialZoom)
	desired_zoom = zoom

func _process(delta):
	if current == false: return #View is 3D
	
	if zoom != desired_zoom:
		zoom = lerp(zoom, desired_zoom, clamp(SMOOTHING_RATE * delta, 0.0, 1.0))
		emit_signal("zoom_level_changed", zoom)
	
	desired_offset += directionalPan * DIRECTIONAL_PAN_SPEED * zoom * delta
	var fieldSize = Vector2(32*255,32*255)
	
	var halfViewSize = (get_viewport().size * 0.5) * desired_zoom
	
	# The point of this is just so you can't move the map COMPLETELY off the screen
	var allowLittleExtraVisible = halfViewSize * 0.10
	
	desired_offset.x = clamp(desired_offset.x, -(halfViewSize.x-allowLittleExtraVisible.x), fieldSize.x+(halfViewSize.x-allowLittleExtraVisible.x))
	desired_offset.y = clamp(desired_offset.y, -(halfViewSize.y-allowLittleExtraVisible.y), fieldSize.y+(halfViewSize.y-allowLittleExtraVisible.y))
	
	offset = lerp(offset, desired_offset, clamp(SMOOTHING_RATE * delta, 0.0, 1.0))
	
	if OS.is_window_focused() == true:
		if MOUSE_EDGE_PANNING == true and oUi.mouseOnUi == false and mouseIsMoving == true and middleMousePanning == false:
			mouse_edge_pan()
			mouseIsMoving = false
	else:
		#Do not allow mouse window edge panning if window is unfocused
		directionalPan = Vector2()

func _input(event):
	directionalPan = Vector2() # This is good for when the mouse hovers over a UI element, so it can stop moving.

func _unhandled_input(event):
	if oSettingsWindow.visible == true: return
	if current == false: return #View is 3D
	
	if event.is_action_released('zoom_in') or event.is_action_pressed('keyboard_zoom_in'):
		zoom_camera(-ZOOM_STEP, get_viewport().get_mouse_position()) #event.position)
	if event.is_action_released('zoom_out') or event.is_action_pressed('keyboard_zoom_out'):
		zoom_camera(ZOOM_STEP, get_viewport().get_mouse_position()) #event.position)
	
	# Middle mouse button pan
	if event.is_action_pressed("pan_with_mouse"):
		middleMousePanning = true
	elif event.is_action_released("pan_with_mouse"):
		middleMousePanning = false
	if middleMousePanning == true:
		if event is InputEventMouseMotion:
			desired_offset -= event.relative * zoom
		if SMOOTH_PAN_ENABLED == false:
			zoom = desired_zoom
			offset = desired_offset
	
	# Edge pan idle reset
	if event is InputEventMouseMotion:
		mouseIsMoving = true
	
	directional_pan()

func mouse_edge_pan():
	directionalPan = Vector2()
	var zoomedViewSize = get_viewport().size * zoom
	var topLeftOfView = offset - (zoomedViewSize*0.5)
	var panBorder = zoomedViewSize * 0.15 # 0.15 is percentage of screen, panBorder.x is 10% of screen width
	var mpos = get_global_mouse_position()
	if (mpos.y < topLeftOfView.y+panBorder.y):
		directionalPan.y = -1
	if (mpos.y > topLeftOfView.y+zoomedViewSize.y-panBorder.y):
		directionalPan.y = 1
	if (mpos.x < topLeftOfView.x+panBorder.x):
		directionalPan.x = -1
	if (mpos.x > topLeftOfView.x+zoomedViewSize.x-panBorder.x):
		directionalPan.x = 1
	directionalPan = directionalPan.normalized()

func directional_pan():
	if Input.is_action_pressed('keyboard_zoom_in'): return
	if Input.is_action_pressed('keyboard_zoom_out'): return
	
	directionalPan = Vector2()
	#var zoomedViewSize = get_viewport().size * zoom
	#var topLeftOfView = offset - (zoomedViewSize*0.5)
	#var panBorder = zoomedViewSize * 0.15 # 0.15 is percentage of screen, panBorder.x is 10% of screen width
	#var mpos = get_global_mouse_position()
	if Input.is_action_pressed("pan_up"):
		directionalPan.y = -1
	if Input.is_action_pressed("pan_down"):
		directionalPan.y = 1
	if Input.is_action_pressed("pan_left"):
		directionalPan.x = -1
	if Input.is_action_pressed("pan_right"):
		directionalPan.x = 1
	directionalPan = directionalPan.normalized()


func zoom_camera(zoom_factor, mouse_position):
	
	var viewport_size = get_viewport().size
	var previous_zoom = desired_zoom
	
	desired_zoom += desired_zoom * zoom_factor
	desired_offset += ((viewport_size * 0.5) - mouse_position) * (desired_zoom-previous_zoom)
