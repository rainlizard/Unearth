extends WindowDialog
onready var oGenerateSlabColumn = Nodelist.list["oGenerateSlabColumn"]
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oCEColumnSpinBox = Nodelist.list["oCEColumnSpinBox"]

var viewColumn = 1

func _on_SlabColumnEditor_about_to_show():
	yield(get_tree(),'idle_frame')
	var CODETIME_START = OS.get_ticks_msec()
	oGenerateSlabColumn.start(viewColumn)
	print('Column generated in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	oPropertiesTabs.set_current_tab(2)

func _ready():
	popup_centered()
	visible = false
	visible = true

func _unhandled_input(event):
	if visible == false: return
	
	if (event.is_action("ui_left") or event.is_action("ui_down")) and event.is_pressed():
		get_tree().set_input_as_handled()
		set_clm_value(viewColumn-1)
		
	if (event.is_action("ui_right") or event.is_action("ui_up")) and event.is_pressed():
		get_tree().set_input_as_handled()
		set_clm_value(viewColumn+1)

func _on_CEColumnSpinBox_value_changed(value):
	set_clm_value(value)

func set_clm_value(newVal):
	oCEColumnSpinBox.value = newVal
	viewColumn = clamp(newVal,0,2047)
	oColumnDetails.update_details()
	oGenerateSlabColumn.start(viewColumn)
