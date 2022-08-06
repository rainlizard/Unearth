extends HBoxContainer
tool # So that label text changes in editor
export var settingText = "SettingName" setget set_label
export var slider_step : float = 0.01
export var minimum_value : float = 0.0
export var maximum_value : float = 1.0
export var allow_manually_set_to_anything : bool = true
onready var lineEdit = $'%LineEdit'

func _enter_tree():
	$Slider.min_value = minimum_value
	$Slider.max_value = maximum_value
	$Slider.step = slider_step

func set_label(newLabel):
	settingText = newLabel
	$Label.text = newLabel

func update_value(newValue):
	var oSettingsWindow = Nodelist.list["oSettingsWindow"]
	oSettingsWindow.call("edited_"+name, lineEdit.text)

func update_appearance(value):
	$Slider.value = value
	lineEdit.text = str(value)
	if slider_step < 1:
		lineEdit.text = lineEdit.text.pad_decimals(2)

func _on_LineEdit_focus_exited():
	_on_LineEdit_text_entered(lineEdit.text)
func _on_LineEdit_text_entered(new_text):
	var new_value = float(new_text)
	if allow_manually_set_to_anything == false:
		if new_value < minimum_value:
			new_value = minimum_value
		if new_value > maximum_value:
			new_value = maximum_value
	
	update_appearance(new_value)
	update_value(new_value)

func _on_Slider_value_changed(value):
	update_appearance(value)

func _on_Slider_drag_ended(value_has_changed):
	var new_value = $Slider.value
	update_value(new_value)

#	if "." in line.text:
#		numberValue = float(line.text)
#	else:
#		numberValue = int(line.text)


