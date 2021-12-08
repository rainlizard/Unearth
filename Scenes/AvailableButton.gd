extends VBoxContainer
onready var oIconTextureRect = $IconTextureRect
onready var oIconHighlight = $IconTextureRect/IconHighlight
onready var oIconColorRect = $IconTextureRect/IconColorRect
onready var oTextEditableLabel = $TextEditableLabel
onready var oTextHighlight = $TextEditableLabel/TextHighlight
onready var oTextColorRect = $TextEditableLabel/TextColorRect

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
	oIconHighlight.color.a8 = 16
	oTextHighlight.color.a8 = 16


func _on_available_button_mouse_exited():
	oIconHighlight.color.a8 = 0
	oTextHighlight.color.a8 = 0


func _on_AvailableButton_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_on_button_pressed()


func _on_button_pressed():
	for id in get_tree().get_nodes_in_group("EditableLabel"):
		id.release_focus()
	
	match availabilityState:
		OPTION_START: set_availability_state(OPTION_RESEARCH)
		OPTION_RESEARCH: set_availability_state(OPTION_DISABLED)
		OPTION_DISABLED: set_availability_state(OPTION_START)
		DISABLED: set_availability_state(ENABLED)
		ENABLED: set_availability_state(DISABLED)


func set_availability_state(setVal):
	availabilityState = setVal
	
	var oIconTextureRect = $IconTextureRect
	var oIconHighlight = $IconTextureRect/IconHighlight
	var oIconColorRect = $IconTextureRect/IconColorRect
	var oTextEditableLabel = $TextEditableLabel
	var oTextHighlight = $TextEditableLabel/TextHighlight
	var oTextColorRect = $TextEditableLabel/TextColorRect
	
	match availabilityState:
		OPTION_START:
			oTextEditableLabel.text = "Start"
			oTextColorRect.modulate = Color(1,1,1,1)
			oIconColorRect.modulate = Color(1,1,1,1)
			oTextColorRect.color = Color("#46455c")
			oIconColorRect.color = Color("#383745")
		OPTION_RESEARCH:
			oTextEditableLabel.text = "Research"
			oTextColorRect.modulate = Color(1,1,1,1)
			oIconColorRect.modulate = Color(1,1,1,1)
			oTextColorRect.color = Color("#5c3b5c")
			oIconColorRect.color = Color("#3f3745")
		OPTION_DISABLED:
			oTextEditableLabel.text = "Disabled"
			oTextColorRect.modulate = Color(1,1,1,0.25)
			oIconColorRect.modulate = Color(1,1,1,0.25)
			oTextColorRect.color = Color("#000000")
			oIconColorRect.color = Color("#000000")
		ENABLED:
			oIconColorRect.modulate = Color(1,1,1,1)
			oTextColorRect.modulate = Color(1,1,1,1)
			oTextColorRect.color = Color("#46455c")
			oIconColorRect.color = Color("#383745")
			if oTextEditableLabel.editable == false:
				oTextEditableLabel.text = "Enabled"
		DISABLED:
			oIconColorRect.modulate = Color(1,1,1,0.25)
			oTextColorRect.modulate = Color(1,1,1,0.25)
			oTextColorRect.color = Color("#000000")
			oIconColorRect.color = Color("#000000")
			if oTextEditableLabel.editable == false:
				oTextEditableLabel.text = "Disabled"


func get_integer():
	return int(oTextEditableLabel.text)


func _on_EditableLabel_focus_exited():
	oTextEditableLabel.text = str(int(oTextEditableLabel.text))
