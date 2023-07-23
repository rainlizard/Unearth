extends VBoxContainer
onready var oToolPencil = Nodelist.list["oToolPencil"]
onready var oBrushSizeContainer = Nodelist.list["oBrushSizeContainer"]
onready var oBrushPreview = Nodelist.list["oBrushPreview"]
onready var oFillUseDisplay = Nodelist.list["oFillUseDisplay"]
onready var oFortifyCheckBox = Nodelist.list["oFortifyCheckBox"]

var BRUSH_SIZE = 1

enum {
	BRUSH
	PENCIL
	RECTANGLE
	PAINTBUCKET
}

var TOOL_SELECTED = PENCIL

func _on_ToolBrush_toggled(button_pressed):
	TOOL_SELECTED = BRUSH
	oBrushSizeContainer.visible = true
	oBrushSizeContainer.get_node("Label").text = "Brush size"
	oBrushPreview.update_img()
	oFillUseDisplay.visible = false

func _on_ToolPencil_toggled(button_pressed):
	TOOL_SELECTED = PENCIL
	oBrushSizeContainer.visible = true
	oBrushSizeContainer.get_node("Label").text = "Pencil size"
	oBrushPreview.update_img()
	oFillUseDisplay.visible = false

func _on_ToolRectangle_toggled(button_pressed):
	TOOL_SELECTED = RECTANGLE
	oBrushSizeContainer.visible = false
	oBrushPreview.update_img()
	oFillUseDisplay.visible = false

func _on_ToolPaintBucket_toggled(button_pressed):
	TOOL_SELECTED = PAINTBUCKET
	oBrushSizeContainer.visible = false
	oBrushPreview.update_img()
	oFillUseDisplay.visible = true

func switched_to_slab_mode():
	visible = true
	
	if is_instance_valid(oFortifyCheckBox):
		oFortifyCheckBox.visible = true

func switched_to_thing_mode():
	oToolPencil.pressed = true
	visible = false
	oFillUseDisplay.visible = false
	oFortifyCheckBox.visible = false

func _on_EditBrushSizeValue_value_changed(value):
	BRUSH_SIZE = value
	yield(get_tree(),'idle_frame')
	oBrushPreview.update_img()
