extends CheckBox
onready var oOwnerSelection = Nodelist.list["oOwnerSelection"]
onready var oOwnershipGridContainer = Nodelist.list["oOwnershipGridContainer"]

func _on_UseSlabOwnerCheckBox_toggled(button_pressed):
	oOwnerSelection.update_ownership_options()
