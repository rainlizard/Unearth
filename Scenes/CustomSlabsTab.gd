extends PanelContainer
#onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
#
#var scnSlabStyleButton = preload("res://Scenes/SlabStyleButton.tscn")
#
#func add_grid_item(set_text):
#	var oGridContainer = current_grid_container()
#
#	var scene = load("res://Scenes/SlabDisplay.tscn")
#	var id = scene.instance()
#	var slabVariation
#
#
#	add_child_to_grid(Slabs.TAB_CUSTOM, id, set_text)
#
#	oGridContainer.add_child(btnId)
#
#
#
#func _on_CustomSlabButtonPressed(btnId):
#	print(btnId)
#
#func current_grid_container():
#	return $"ScrollContainer/GridContainer"
