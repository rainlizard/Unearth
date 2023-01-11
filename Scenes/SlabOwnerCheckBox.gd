extends CheckBox
onready var oOwnershipGridContainer = Nodelist.list["oOwnershipGridContainer"]

func _on_UseSlabOwnerCheckBox_toggled(button_pressed):
	if button_pressed == true and visible == true:
		oOwnershipGridContainer.modulate = Color(1,1,1,0.25)
	else:
		oOwnershipGridContainer.modulate = Color(1,1,1,1.00)


func _on_UseSlabOwnerCheckBox_visibility_changed():
	yield(get_tree(),'idle_frame')
	_on_UseSlabOwnerCheckBox_toggled(pressed)
