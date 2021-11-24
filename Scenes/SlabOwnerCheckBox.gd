extends CheckBox

func _on_UseSlabOwnerCheckBox_toggled(button_pressed):
	if button_pressed == true and visible == true:
		$"../GridContainer".modulate = Color(1,1,1,0.25)
	else:
		$"../GridContainer".modulate = Color(1,1,1,1.00)


func _on_UseSlabOwnerCheckBox_visibility_changed():
	_on_UseSlabOwnerCheckBox_toggled(pressed)
