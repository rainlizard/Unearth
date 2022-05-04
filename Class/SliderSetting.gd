extends HBoxContainer

export var label_setting:String setget set_label_setting, get_label_setting
export var min_value:float setget set_min_value, get_min_value
export var max_value:float setget set_max_value, get_max_value
export var step:float setget set_step, get_step
export var value:float setget set_value, get_value

signal sliderChanged

func _ready():
	$"VBoxContainer/LabelNumber".text = str($"VBoxContainer/HSlider".value)

func _on_HSlider_value_changed(val):
	$"VBoxContainer/LabelNumber".text = str(val)
	emit_signal("sliderChanged")

func set_label_setting(val):
	$LabelSetting.text = val
func get_label_setting():
	return $LabelSetting.text

func set_min_value(val):
	$"VBoxContainer/HSlider".min_value = float(val)
func get_min_value():
	return $"VBoxContainer/HSlider".min_value

func set_max_value(val):
	$"VBoxContainer/HSlider".max_value = float(val)
func get_max_value():
	return $"VBoxContainer/HSlider".max_value

func set_step(val):
	$"VBoxContainer/HSlider".step = float(val)
func get_step():
	return $"VBoxContainer/HSlider".step

func set_value(val):
	$"VBoxContainer/HSlider".value = float(val)
func get_value():
	return $"VBoxContainer/HSlider".value
