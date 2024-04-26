extends CheckBox
onready var oOwnerSelection = Nodelist.list["oOwnerSelection"]
onready var oOwnershipGridContainer = Nodelist.list["oOwnershipGridContainer"]

func _on_UseSlabOwnerCheckBox_toggled(button_pressed):
	oOwnerSelection.update_ownership_available()

func _on_UseSlabOwnerCheckBox_visibility_changed():
	yield(get_tree(),'idle_frame')
	oOwnerSelection.update_ownership_available()
