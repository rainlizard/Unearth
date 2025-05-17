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

var FONT_SIZE_CR_LVL_BASE := 1.00 setget set_FONT_SIZE_CR_LVL_BASE
var FONT_SIZE_CR_LVL_MAX := 8.00 setget set_FONT_SIZE_CR_LVL_MAX

const topMargin = 69

var optionButtonIsOpened = false
var mouseOnUi = false
var _is_handling_drag = false

var listOfWindowDialogs = []

func _ready():
	for mainCategories in get_children():
		for potentialWindow in mainCategories.get_children():
			if potentialWindow is WindowDialog:
				listOfWindowDialogs.append(potentialWindow)
	
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed") # Connect viewport resize handler

	for i in 10: # Important to wait here, so the viewport size/resolution doesn't affect window positions
		yield(get_tree(),'idle_frame')
	
	_on_viewport_size_changed()
	
	for windowNode in listOfWindowDialogs:
		windowNode.connect("item_rect_changed",self,"_on_any_window_was_dragged",[windowNode])

func _clamp_window_position(theWindow, currentViewSize):
	if theWindow.rect_position.x > currentViewSize.x - theWindow.rect_size.x:
		theWindow.rect_position.x = currentViewSize.x - theWindow.rect_size.x
	if theWindow.rect_position.y > currentViewSize.y - theWindow.rect_size.y:
		theWindow.rect_position.y = currentViewSize.y - theWindow.rect_size.y
	if theWindow.rect_position.x < 0:
		theWindow.rect_position.x = 0
	if theWindow.rect_position.y < topMargin:
		theWindow.rect_position.y = topMargin

func _on_any_window_was_dragged(callingNode):
	if _is_handling_drag:
		return
	_is_handling_drag = true
	
	var viewSize = get_viewport().size / Settings.UI_SCALE
	_clamp_window_position(callingNode, viewSize)
	
	_is_handling_drag = false

func _on_viewport_size_changed():
	var currentViewSize = get_viewport().size / Settings.UI_SCALE
	for windowNode in listOfWindowDialogs:
		windowNode.rect_size.x = clamp(windowNode.rect_size.x, 0, currentViewSize.x)
		windowNode.rect_size.y = clamp(windowNode.rect_size.y, 0, currentViewSize.y - topMargin)
		_clamp_window_position(windowNode, currentViewSize)

func _input(event):
	if event is InputEventMouseMotion:
		mouseOnUi = true # This line combined with the line in _unhandled_input can be used to determine whether the mouse is over UI.
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouseOnUi = false # Used in combination with the line in _input()
		# There's a Godot bug where if you open an optionbutton, it treats it as if the mouse is not on UI.
		if optionButtonIsOpened == true:
			mouseOnUi = true


func update_theme_colour(val):
	var col = Constants.windowTitleCol[val]
	if windowStyleBoxFlat.get('border_color') != col:
		windowStyleBoxFlat.set('border_color', col)

func HSV_8(h,s,v):
	return Color.from_hsv(h/359.0,s/100.0,v/100.0, 1.0)

#oUi2D.theme.set('WindowDialog/colors/title_color', col)

func set_FONT_SIZE_CR_LVL_BASE(setVal):
	FONT_SIZE_CR_LVL_BASE = setVal
	oCamera2D.emit_signal("zoom_level_changed", oCamera2D.zoom)

func set_FONT_SIZE_CR_LVL_MAX(setVal):
	FONT_SIZE_CR_LVL_MAX = setVal
	oCamera2D.emit_signal("zoom_level_changed", oCamera2D.zoom)




#func opened_2D_view():
#	if is_instance_valid(oPickThingWindow) == false: return
#	if oImageAsMapDialog.visible == true: return
#	oUi3D.visible = false
#	show_tools()

#func opened_3D_view():
#	if is_instance_valid(oPickThingWindow) == false: return
#	oUi3D.visible = true
	
	


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
		#oUi3D.visible = false
		# Don't show tools if opening a map from the map browser or oImageAsMapDialog
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
	
	# This code section below is temporary.
#	yield(get_tree(),'idle_frame')
#	if oGenerateTerrain.GENERATED_TYPE == oGenerateTerrain.GEN_CLM:
#		oPropertiesWindow.visible = true
#		oUi3D.visible = true
#
#		oPropertiesWindow.oPropertiesTabs.current_tab = 2


func set_ui_scale(setVal):
	Settings.UI_SCALE = Vector2(setVal,setVal)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(1024,576), setVal)
