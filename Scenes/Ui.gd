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
onready var oPossess3DButton = Nodelist.list["oPossess3DButton"]

var FONT_SIZE = 16 setget set_FONT_SIZE
var FONT_SIZE_CR_LVL_BASE := 1.00 setget set_FONT_SIZE_CR_LVL_BASE
var FONT_SIZE_CR_LVL_MAX := 8.00 setget set_FONT_SIZE_CR_LVL_MAX

var optionButtonIsOpened = false
var mouseOnUi = false

var listOfWindowDialogs = []

func _ready():
	for mainCategories in get_children():
		for potentialWindow in mainCategories.get_children():
			if potentialWindow is WindowDialog:
				listOfWindowDialogs.append(potentialWindow)
	
	for i in 10: # Important to wait here, so the viewport size/resolution doesn't affect window positions
		yield(get_tree(),'idle_frame')
	for i in listOfWindowDialogs:
		i.connect("item_rect_changed",self,"_on_any_window_was_dragged",[i])
		_on_any_window_was_dragged(i)

func _on_any_window_was_dragged(callingNode):
	callingNode.disconnect("item_rect_changed",self,"_on_any_window_was_dragged") # Fixes a Stack Overflow under certain circumstances
	callingNode.rect_size.x = clamp(callingNode.rect_size.x, 0, get_viewport().size.x)
	callingNode.rect_size.y = clamp(callingNode.rect_size.y, 0, get_viewport().size.y-60)
	callingNode.rect_position.x = clamp(callingNode.rect_position.x, 0, get_viewport().size.x-callingNode.rect_size.x) #	Keep on screen
	callingNode.rect_position.y = clamp(callingNode.rect_position.y, 60, get_viewport().size.y-callingNode.rect_size.y)
	callingNode.connect("item_rect_changed",self,"_on_any_window_was_dragged", [callingNode])

func _input(event):
	mouseOnUi = true # This line combined with the line in _unhandled_input can be used to determine whether the mouse is over UI.
func _unhandled_input(event):
	mouseOnUi = false # Used in combination with the line in _input()
	
	# There's a Godot bug where if you open an optionbutton, it treats it as if the mouse is not on UI.
	if optionButtonIsOpened == true:
		mouseOnUi = true


#func _process(delta):
#	if 
#	var a = Control.new()
#	add_child(a)
#	print(a.get_focus_owner())



func update_theme_colour(val):
	var col
	match val:
		0: col = HSV_8(0,40,60)#Color8(132,44,0,255)
		1: col = HSV_8(279,30,66)#Color8(136,112,148,255)##
		2: col = HSV_8(88,34,50)#col = Color8(52,96,4,255)
		3: col = HSV_8(50,43,72)#col = Color8(188,156,0,255)
		4: col = HSV_8(0,0,72)#col = Color8(180,160,124,255)
		5: col = HSV_8(251,20,40)#col = Color8(64,62,72,255)
#	print(col.r8)
#	print(col.g8)
#	print(col.b8)
	
	windowStyleBoxFlat.set('border_color', col)

func HSV_8(h,s,v):
	return Color.from_hsv(h/359.0,s/100.0,v/100.0, 1.0)

#oUi2D.theme.set('WindowDialog/colors/title_color', col)


func set_FONT_SIZE(setVal):
	FONT_SIZE = setVal
	oUiTools.theme.default_font.size = FONT_SIZE

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
	if oDataSlab.get_cell(0,0) != TileMap.INVALID_CELL:
		oUi3D.visible = false
		# Don't show tools if opening a map from the map browser or oImageAsMapDialog
		if oMapBrowser.visible == false and oImageAsMapDialog.visible == false:
			show_tools()
	else:
		oEditingMode.visible = false

func switch_to_3D_overhead():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	oUi3D.visible = true
	oPossess3DButton.visible = true
	show_tools()

func switch_to_1st_person():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	oUi3D.visible = false
	oPossess3DButton.visible = false
	hide_tools()
	
	# This code section below is temporary.
	yield(get_tree(),'idle_frame')
	if oGenerateTerrain.GENERATED_TYPE == oGenerateTerrain.GEN_CLM:
		oPropertiesWindow.visible = true
		oUi3D.visible = true
		
		oPropertiesWindow.oPropertiesTabs.current_tab = 2


func _on_Possess3DButton_pressed():
	switch_to_1st_person()
