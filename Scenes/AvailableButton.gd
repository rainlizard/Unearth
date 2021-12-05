extends VBoxContainer

var availabilityState setget set_availability_state

enum {
	OPTION_START
	OPTION_RESEARCH
	OPTION_DISABLED
	ENABLED
	DISABLED
}

func _ready():
	connect("mouse_entered", self, "_on_available_button_mouse_entered")
	connect("mouse_exited", self, "_on_available_button_mouse_exited")

func _on_available_button_mouse_entered():
	$TextureRect/Highlight.color.a8 = 16
	$Label/Highlight.color.a8 = 16
	$LineEdit/Highlight.color.a8 = 16

func _on_available_button_mouse_exited():
	$TextureRect/Highlight.color.a8 = 0
	$Label/Highlight.color.a8 = 0
	$LineEdit/Highlight.color.a8 = 0

func _on_AvailableButton_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_on_button_pressed()

func _on_button_pressed():
	match availabilityState:
		OPTION_START: set_availability_state(OPTION_RESEARCH)
		OPTION_RESEARCH: set_availability_state(OPTION_DISABLED)
		OPTION_DISABLED: set_availability_state(OPTION_START)
		DISABLED: set_availability_state(ENABLED)
		ENABLED: set_availability_state(DISABLED)


func set_availability_state(setVal):
	availabilityState = setVal
	match availabilityState:
		OPTION_START:
			get_node("Label").text = "Start"
			modulate = Color(1,1,1,1)
			get_node("Label/ColorRect").color = Color("#46455c")
			get_node("TextureRect/ColorRect").color = Color("#383745")
		OPTION_RESEARCH:
			get_node("Label").text = "Research"
			modulate = Color(1,1,1,1)
			get_node("Label/ColorRect").color = Color("#5c3b5c")
			get_node("TextureRect/ColorRect").color = Color("#3f3745")
		OPTION_DISABLED:
			get_node("Label").text = "Disabled"
			modulate = Color(1,1,1,0.25)
			get_node("Label/ColorRect").color = Color("#000000")
			get_node("TextureRect/ColorRect").color = Color("#000000")
		ENABLED:
			get_node("Label").text = "Enabled"
			modulate = Color(1,1,1,1)
			get_node("Label/ColorRect").color = Color("#46455c")
			get_node("TextureRect/ColorRect").color = Color("#383745")
		DISABLED:
			get_node("Label").text = "Disabled"
			modulate = Color(1,1,1,0.25)
			get_node("Label/ColorRect").color = Color("#000000")
			get_node("TextureRect/ColorRect").color = Color("#000000")

func _on_LineEdit_text_changed(new_text):
	var integer = int(new_text)
	if integer > 0:
		modulate = Color(1,1,1,1)
		get_node("LineEdit/ColorRect").color = Color("#46455c")
		get_node("TextureRect/ColorRect").color = Color("#383745")
	else:
		modulate = Color(1,1,1,0.25)
		get_node("LineEdit/ColorRect").color = Color("#000000")
		get_node("TextureRect/ColorRect").color = Color("#000000")

func get_integer():
	return int($LineEdit.text)


func _on_LineEdit_focus_exited():
	$LineEdit.deselect()
