extends Camera2D
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oSettingsWindow = Nodelist.list["oSettingsWindow"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oUi = Nodelist.list["oUi"]
onready var oMain = Nodelist.list["oMain"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]

signal zoom_level_changed

var SMOOTHING_RATE = 10
var ZOOM_STEP = 0.5
var SMOOTH_PAN_ENABLED = false
var MOUSE_EDGE_PANNING = true
var DIRECTIONAL_PAN_SPEED = 2250

var desired_zoom = Vector2(0,0)
var desired_offset = Vector2(0,0)
var panDirectionKeyboard = Vector2(0,0)
var panDirectionMouse = Vector2(0,0)
var middleMousePanning = false
#var mouseIsMoving = false

var mouseInWindow = true

func _ready():
	reset_camera()

func reset_camera():
	offset = Vector2(85*96,85*96) * Vector2(0.5,0.5)
	desired_offset = offset
	var initialZoom = 9085.0 / OS.window_size.y * Settings.UI_SCALE.y
	zoom = Vector2(initialZoom,initialZoom)
	desired_zoom = zoom

func _process(delta):
	
	
	if OS.is_window_focused() == false: return
	if current == false: return #View is 3D
	
	if zoom != desired_zoom:
		zoom = lerp(zoom, desired_zoom, clamp(SMOOTHING_RATE * delta, 0.0, 1.0))
		emit_signal("zoom_level_changed", zoom)
	
	
	
	desired_offset += panDirectionMouse * DIRECTIONAL_PAN_SPEED * (zoom/Settings.UI_SCALE.x) * delta
	desired_offset += panDirectionKeyboard * DIRECTIONAL_PAN_SPEED * (zoom/Settings.UI_SCALE.x) * delta
	var fieldSize = Vector2(32*255,32*255)
	var halfViewSize = ((get_viewport().size/Settings.UI_SCALE) * 0.5) * desired_zoom
	# The point of this is just so you can't move the map COMPLETELY off the screen
	var allowLittleExtraVisible = halfViewSize * 0.10
	desired_offset.x = clamp(desired_offset.x, -(halfViewSize.x-allowLittleExtraVisible.x), fieldSize.x+(halfViewSize.x-allowLittleExtraVisible.x))
	desired_offset.y = clamp(desired_offset.y, -(halfViewSize.y-allowLittleExtraVisible.y), fieldSize.y+(halfViewSize.y-allowLittleExtraVisible.y))
	
	offset = lerp(offset, desired_offset, clamp(SMOOTHING_RATE * delta, 0.0, 1.0))
	
	
	if OS.is_window_focused() == true and mouseInWindow == true:
		if MOUSE_EDGE_PANNING == true and oUi.mouseOnUi == false and middleMousePanning == false: #and mouseIsMoving == true
			mouse_edge_pan()
			#mouseIsMoving = false
	else:
		#Do not allow mouse window edge panning if window is unfocused
		panDirectionMouse = Vector2(0,0)
	
	if oUi.mouseOnUi == false and oScriptTextEdit.has_focus() == false and oMapBrowser.visible == false:
		keyboard_pan()
	else:
		panDirectionKeyboard = Vector2(0,0)
	
	# Close enough
	if (offset-desired_offset).abs() < Vector2(0.0001,0.0001):
		offset = desired_offset
	if (zoom-desired_zoom).abs() < Vector2(0.0001,0.0001):
		zoom = desired_zoom
	
#	print('offset : ' + str((offset-desired_offset).abs()))
#	print('zoom : ' + str((zoom-desired_zoom).abs()))

func _unhandled_input(event):
	if oSettingsWindow.visible == true: return
	if current == false: return #View is 3D
	
	if event.is_action_released('zoom_in') or event.is_action_pressed('keyboard_zoom_in'):
		zoom_camera(-ZOOM_STEP, get_viewport().get_mouse_position())
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
#	if event is InputEventMouseMotion:
#		mouseIsMoving = true

func _input(event):
	panDirectionMouse = Vector2(0,0) # This is good for when the mouse hovers over a UI element, so it can stop moving.

func mouse_edge_pan():
	panDirectionMouse = Vector2(0,0)
	var zoomedViewSize = (get_viewport().size/Settings.UI_SCALE) * zoom
	var topLeftOfView = offset - (zoomedViewSize*0.5)
	
	# make panBorder the same for each side, by using the larger screen value for all calculations
	var panBorder = max(zoomedViewSize.x, zoomedViewSize.y) * 0.05 # 0.15 is percentage of screen, panBorder.x is 10% of screen width
	
	var mpos = get_global_mouse_position()
	if (mpos.y < topLeftOfView.y+panBorder):
		panDirectionMouse.y = -1
	if (mpos.y > topLeftOfView.y+zoomedViewSize.y-panBorder):
		panDirectionMouse.y = 1
	if (mpos.x < topLeftOfView.x+panBorder):
		panDirectionMouse.x = -1
	if (mpos.x > topLeftOfView.x+zoomedViewSize.x-panBorder):
		panDirectionMouse.x = 1
	panDirectionMouse = panDirectionMouse.normalized()

func keyboard_pan():
	if Input.is_action_pressed('keyboard_zoom_in'): return
	if Input.is_action_pressed('keyboard_zoom_out'): return
	
	panDirectionKeyboard = Vector2(0,0)
	if Input.is_action_pressed("pan_up"):
		panDirectionKeyboard.y = -1
	if Input.is_action_pressed("pan_down"):
		panDirectionKeyboard.y = 1
	if Input.is_action_pressed("pan_left"):
		panDirectionKeyboard.x = -1
	if Input.is_action_pressed("pan_right"):
		panDirectionKeyboard.x = 1
	panDirectionKeyboard = panDirectionKeyboard.normalized()


func zoom_camera(zoom_factor, mouse_position):
	
	var viewport_size = get_viewport().size/Settings.UI_SCALE
	var previous_zoom = desired_zoom
	
	desired_zoom += desired_zoom * zoom_factor
	desired_offset += ((viewport_size * 0.5) - mouse_position) * (desired_zoom-previous_zoom)

func _notification(blah):
	match blah:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouseInWindow = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouseInWindow = true
