extends WindowDialog
onready var oGenerateSlabColumn = Nodelist.list["oGenerateSlabColumn"]
onready var oCELabelCurrentColumn = Nodelist.list["oCELabelCurrentColumn"]

var viewColumn = 1

func _on_SlabColumnEditor_about_to_show():
	yield(get_tree(),'idle_frame')
	var CODETIME_START = OS.get_ticks_msec()
	oGenerateSlabColumn.start(viewColumn)
	print('Column generated in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	update_ui()

func _ready():
	popup_centered()
	visible = false
	visible = true

func _unhandled_input(event):
	if visible == false: return
	
	if event.is_action("ui_left"):
		get_tree().set_input_as_handled()
		viewColumn -= 1
		update_ui()
		oGenerateSlabColumn.start(viewColumn)
		
	if event.is_action("ui_right"):
		get_tree().set_input_as_handled()
		viewColumn += 1
		update_ui()
		oGenerateSlabColumn.start(viewColumn)
		

func update_ui():
	oCELabelCurrentColumn.text = "Column index: " + str(viewColumn)
