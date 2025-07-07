extends CanvasLayer
onready var oUiTools = Nodelist.list["oUiTools"]
onready var windowStyleBoxFlat = oUiTools.theme.get('WindowDialog/styles/panel')
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oImageAsMapDialog = Nodelist.list["oImageAsMapDialog"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oPropertiesWindow = Nodelist.list["oPropertiesWindow"]
onready var oEditingMode = Nodelist.list["oEditingMode"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oUi3D = Nodelist.list["oUi3D"]
onready var oModeSwitchButton = Nodelist.list["oModeSwitchButton"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]
onready var oCamera3D = Nodelist.list["oCamera3D"]
onready var oPlayer = Nodelist.list["oPlayer"]
onready var o3DCameraInfo = Nodelist.list["o3DCameraInfo"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oSelector = Nodelist.list["oSelector"]

var tabKeyInputEvent = InputEventKey.new()

var FONT_SIZE_CR_LVL_BASE := 1.00 setget set_FONT_SIZE_CR_LVL_BASE
var FONT_SIZE_CR_LVL_MAX := 8.00 setget set_FONT_SIZE_CR_LVL_MAX
var FACING_ARROW_SIZE_MAX := 1.00 setget set_FACING_ARROW_SIZE_MAX
var FACING_ARROW_SIZE_BASE := 1.00 setget set_FACING_ARROW_SIZE_BASE

var subwindows_status = {}

const topMargin = 69

var optionButtonIsOpened = false
var mouseOnUi = false
var _is_handling_drag = false
var _is_user_dragging = false
var listOfWindowDialogs = []

func get_desired_window_position(windowName):
	if subwindows_status.has(windowName) and subwindows_status[windowName].has("desired_position"):
		return subwindows_status[windowName]["desired_position"]
	return Vector2.ZERO

func get_desired_window_size(windowName):
	if subwindows_status.has(windowName) and subwindows_status[windowName].has("desired_size"):
		return subwindows_status[windowName]["desired_size"]
	return Vector2.ZERO

func set_desired_window_position(windowName, position):
	if not subwindows_status.has(windowName):
		subwindows_status[windowName] = {}
	subwindows_status[windowName]["desired_position"] = position
	Settings.set_setting("subwindows_status", subwindows_status)

func set_desired_window_size(windowName, size):
	if not subwindows_status.has(windowName):
		subwindows_status[windowName] = {}
	subwindows_status[windowName]["desired_size"] = size
	Settings.set_setting("subwindows_status", subwindows_status)

func initialize_window_desired_values():
	for window in listOfWindowDialogs:
		var windowName = window.name
		if not subwindows_status.has(windowName):
			subwindows_status[windowName] = {}
		if not subwindows_status[windowName].has("desired_position"):
			subwindows_status[windowName]["desired_position"] = window.rect_position
		if not subwindows_status[windowName].has("desired_size"):
			subwindows_status[windowName]["desired_size"] = window.rect_size
		
		window.rect_position = subwindows_status[windowName]["desired_position"]
		window.rect_size = subwindows_status[windowName]["desired_size"]
	on_startup_put_windows_in_correct_positions()

func on_startup_put_windows_in_correct_positions():
	yield(get_tree(), 'idle_frame')
	yield(get_tree(), 'idle_frame')
	_on_viewport_size_changed()

func _ready():
	tabKeyInputEvent.scancode = KEY_TAB
	setup_focus_key()
	find_window_dialogs()
	wait_until_windows_are_positioned()
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")

func wait_until_windows_are_positioned():
	for i in 10:
		yield(get_tree(),'idle_frame')
	for window in listOfWindowDialogs:
		window.connect("item_rect_changed",self,"_on_any_window_was_modified",[window])
		window.connect("visibility_changed", self, "_on_window_dialog_became_visible", [window])
		window.connect("resized", self, "_on_window_dialog_became_visible", [window])
		window.connect("gui_input", self, "_on_window_gui_input", [window])
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

func setup_focus_key():
	InputMap.action_add_event("ui_focus_next", tabKeyInputEvent)

func find_window_dialogs():
	for mainCategories in get_children():
		for potentialWindow in mainCategories.get_children():
			if potentialWindow is WindowDialog:
				listOfWindowDialogs.append(potentialWindow)

func _on_window_gui_input(event, callingNode):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_is_user_dragging = true
			else:
				_is_user_dragging = false


func _on_any_window_was_modified(callingNode):
	if Settings.haveInitializedAllSettings == false: return
	if _is_handling_drag:
		return
	
	if _is_user_dragging:
		_is_handling_drag = true
		var viewSize = get_viewport().size / Settings.UI_SCALE
		
		set_desired_window_position(callingNode.name, callingNode.rect_position)
		set_desired_window_size(callingNode.name, callingNode.rect_size)
		
		_clamp_window_position(callingNode, viewSize)
		_is_handling_drag = false

func _on_viewport_size_changed():
	var currentViewSize = get_viewport().size / Settings.UI_SCALE
	for windowNode in listOfWindowDialogs:
		if windowNode.visible == false:
			continue
		
		_is_handling_drag = true
		
		var desiredPosition = get_desired_window_position(windowNode.name)
		var desiredSize = get_desired_window_size(windowNode.name)
		
		if desiredPosition != Vector2.ZERO:
			windowNode.rect_position = desiredPosition
		if desiredSize != Vector2.ZERO:
			windowNode.rect_size = desiredSize
		
		_adjust_window_size_to_viewport(windowNode, currentViewSize)
		_is_handling_drag = false

func _on_window_dialog_became_visible(dialogNode):
	if dialogNode.visible == true:
		var currentViewSize = get_viewport().size / Settings.UI_SCALE
		_adjust_window_size_to_viewport(dialogNode, currentViewSize)

func _adjust_window_size_to_viewport(windowNode, currentViewSize):
	windowNode.rect_size.x = clamp(windowNode.rect_size.x, 0, currentViewSize.x)
	windowNode.rect_size.y = clamp(windowNode.rect_size.y, 0, currentViewSize.y - topMargin)
	_clamp_window_position(windowNode, currentViewSize)

func _clamp_window_position(theWindow, currentViewSize):
	if theWindow.rect_position.x > currentViewSize.x - theWindow.rect_size.x:
		theWindow.rect_position.x = currentViewSize.x - theWindow.rect_size.x
	if theWindow.rect_position.y > currentViewSize.y - theWindow.rect_size.y:
		theWindow.rect_position.y = currentViewSize.y - theWindow.rect_size.y
	if theWindow.rect_position.x < 0:
		theWindow.rect_position.x = 0
	if theWindow.rect_position.y < topMargin:
		theWindow.rect_position.y = topMargin

func _input(event):
	if event is InputEventMouseMotion:
		mouseOnUi = true

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouseOnUi = false
		if optionButtonIsOpened == true:
			mouseOnUi = true

func update_theme_colour(val):
	var col = Constants.windowTitleCol[val]
	if windowStyleBoxFlat.get('border_color') != col:
		windowStyleBoxFlat.set('border_color', col)

func HSV_8(h,s,v):
	return Color.from_hsv(h/359.0,s/100.0,v/100.0, 1.0)

func set_FONT_SIZE_CR_LVL_BASE(setVal):
	FONT_SIZE_CR_LVL_BASE = setVal
	oCamera2D.emit_signal("zoom_level_changed", oCamera2D.zoom)

func set_FONT_SIZE_CR_LVL_MAX(setVal):
	FONT_SIZE_CR_LVL_MAX = setVal
	oCamera2D.emit_signal("zoom_level_changed", oCamera2D.zoom)

func set_FACING_ARROW_SIZE_MAX(setVal):
	FACING_ARROW_SIZE_MAX = setVal
	oCamera2D.emit_signal("zoom_level_changed", oCamera2D.zoom)

func set_FACING_ARROW_SIZE_BASE(setVal):
	FACING_ARROW_SIZE_BASE = setVal
	oCamera2D.emit_signal("zoom_level_changed", oCamera2D.zoom)


func show_tools():
	if oDataSlab.get_cell(0,0) == TileMap.INVALID_CELL:
		oMenu.visible = true
		return
	
	match oModeSwitchButton.text:
		"Slab":
			oPickSlabWindow.visible = true
			oPickThingWindow.visible = false
		"Thing":
			oPickSlabWindow.visible = false
			oPickThingWindow.visible = true
	
	oPropertiesWindow.visible = true
	oMenu.visible = true
	oEditingMode.visible = true

func hide_tools():
	oPickThingWindow.visible = false
	oPickSlabWindow.visible = false
	oPropertiesWindow.visible = false
	oMenu.visible = false
	oEditingMode.visible = false

func switch_to_2D():
	o3DCameraInfo.visible = false
	if oDataSlab.get_cell(0,0) != TileMap.INVALID_CELL:
		if oMapBrowser.visible == false and oImageAsMapDialog.visible == false:
			show_tools()
	else:
		oEditingMode.visible = false

func switch_to_3D_overhead():
	o3DCameraInfo.visible = false
	oPlayer.switch_camera_type(0)
	show_tools()

func switch_to_1st_person():
	o3DCameraInfo.visible = o3DCameraInfo.ENABLE_CAMERA_COORDS
	oPlayer.switch_camera_type(1)
	hide_tools()

func set_ui_scale(setVal):
	Settings.UI_SCALE = Vector2(setVal,setVal)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(1024,576), setVal)


func _on_gui_focus_changed(newlyFocusedControl):
	if is_instance_valid(oPropertiesWindow) == false:
		if InputMap.action_has_event("ui_focus_next", tabKeyInputEvent) == false:
			InputMap.action_add_event("ui_focus_next", tabKeyInputEvent)
		return

	var focusIsInsideProperties = false
	if newlyFocusedControl != null:
		if newlyFocusedControl == oPropertiesWindow or oPropertiesWindow.is_a_parent_of(newlyFocusedControl):
			focusIsInsideProperties = true
	
	if focusIsInsideProperties == true:
		if InputMap.action_has_event("ui_focus_next", tabKeyInputEvent):
			InputMap.action_erase_event("ui_focus_next", tabKeyInputEvent)
	else:
		if InputMap.action_has_event("ui_focus_next", tabKeyInputEvent) == false:
			InputMap.action_add_event("ui_focus_next", tabKeyInputEvent)
