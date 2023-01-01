extends VBoxContainer
onready var oScriptGenerator = Nodelist.list["oScriptGenerator"]

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
	$'%IconHighlight'.color.a8 = 16
	$'%TextHighlight'.color.a8 = 16


func _on_available_button_mouse_exited():
	$'%IconHighlight'.color.a8 = 0
	$'%TextHighlight'.color.a8 = 0


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
	
	# Adjust estimated times when things become researchable or unresearchable
	oScriptGenerator.adjust_estimated_time()

func set_availability_state(setVal):
	availabilityState = setVal
	
	match availabilityState:
		OPTION_START:
			$'%TextEditableLabel'.text = "Start"
			$'%TextColorRect'.modulate = Color(1,1,1,1)
			$'%IconColorRect'.modulate = Color(1,1,1,1)
			$'%TextColorRect'.color = Color("#46455c")
			$'%IconColorRect'.color = Color("#383745")
		OPTION_RESEARCH:
			$'%TextEditableLabel'.text = "Research"
			$'%TextColorRect'.modulate = Color(1,1,1,1)
			$'%IconColorRect'.modulate = Color(1,1,1,1)
			$'%TextColorRect'.color = Color("#5c3b5c")
			$'%IconColorRect'.color = Color("#3f3745")
		OPTION_DISABLED:
			$'%TextEditableLabel'.text = "Disabled"
			$'%TextColorRect'.modulate = Color(1,1,1,0.25)
			$'%IconColorRect'.modulate = Color(1,1,1,0.25)
			$'%TextColorRect'.color = Color("#000000")
			$'%IconColorRect'.color = Color("#000000")
		ENABLED:
			$'%IconColorRect'.modulate = Color(1,1,1,1)
			$'%TextColorRect'.modulate = Color(1,1,1,1)
			$'%TextColorRect'.color = Color("#46455c")
			$'%IconColorRect'.color = Color("#383745")
			if $'%TextEditableLabel'.editable == false:
				$'%TextEditableLabel'.text = "Enabled"
		DISABLED:
			$'%IconColorRect'.modulate = Color(1,1,1,0.25)
			$'%TextColorRect'.modulate = Color(1,1,1,0.25)
			$'%TextColorRect'.color = Color("#000000")
			$'%IconColorRect'.color = Color("#000000")
			if $'%TextEditableLabel'.editable == false:
				$'%TextEditableLabel'.text = "Disabled"


func get_integer():
	return int($'%TextEditableLabel'.text)


func _on_EditableLabel_focus_exited():
	$'%TextEditableLabel'.text = str(int($'%TextEditableLabel'.text))
