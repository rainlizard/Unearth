extends Control
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oSelector = Nodelist.list["oSelector"]
onready var oPropertiesWindow = Nodelist.list["oPropertiesWindow"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oModeSwitchButton = Nodelist.list["oModeSwitchButton"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oBrushPreview = Nodelist.list["oBrushPreview"]

func _ready():
	get_viewport().connect("size_changed",self, "_on_viewport_size_changed")
	yield(get_tree(),'idle_frame')
	_on_viewport_size_changed()

func _on_viewport_size_changed():
	rect_position.x = get_viewport_rect().size.x/2
	rect_position.x = clamp(rect_position.x, 570, get_viewport_rect().size.x)

func _unhandled_input(event):
	if visible == false: return
	
	if Input.is_action_just_pressed("button_mode_switch"):
		_on_ModeSwitchButton_pressed()

func _on_ModeSwitchButton_pressed():
	if oModeSwitchButton.text == "Slab":
		oSelector.change_mode(oSelector.MODE_SUBTILE) # will also call switch_mode in here
	else:
		oSelector.change_mode(oSelector.MODE_TILE) # will also call switch_mode in here
	
	oPlacingSettings.editing_mode_was_switched(oModeSwitchButton.text)
	oBrushPreview.update_img()

func switch_mode(string): # Called from oSelection too
	if is_instance_valid(oPickSlabWindow) == false: return
	if visible == false: return
	match string:
		"Slab":
			oPickSlabWindow.visible = true
			oPickThingWindow.visible = false
			#oPropertiesWindow.oPropertiesTabs.current_tab = 2 # This one isn't super useful to auto-switch back to.
		"Thing":
			oPickSlabWindow.visible = false
			oPickThingWindow.visible = true
			#oPropertiesWindow.oPropertiesTabs.current_tab = 0
	oModeSwitchButton.text = string


func _on_ModeSwitch_pressed():
	pass # Replace with function body.
