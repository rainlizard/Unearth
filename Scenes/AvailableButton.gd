extends VBoxContainer
onready var oScriptGenerator = Nodelist.list["oScriptGenerator"]

var availabilityState setget set_availability_state

enum {
	START
	RESEARCH
	ENABLED
	DISABLED
	MIXED # Shown on the All players tab when keepers differ
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


# Left click cycles forward, right click cycles back
func _on_AvailableButton_gui_input(event):
	if event is InputEventMouseButton and event.pressed and (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT):
		for id in get_tree().get_nodes_in_group("EditableLabel"):
			id.release_focus()
		oScriptGenerator.apply(oScriptGenerator.availability_result(self, next_state(1 if event.button_index == BUTTON_LEFT else -1)))
		oScriptGenerator._on_setting_mouse_entered(self) # Still hovered, so preview the next click once this one removed the line


func next_state(step):
	var cycle = get_meta("cycle")
	return cycle[(cycle.find(availabilityState) + step) % cycle.size()]


func set_availability_state(setVal):
	availabilityState = setVal
	var disabled = availabilityState == DISABLED
	var tint = {RESEARCH: ["#5c3b5c", "#3f3745"], MIXED: ["#5c533b", "#403d37"]}.get(availabilityState, ["#46455c", "#383745"])
	$'%TextEditableLabel'.self_modulate.a = 0.55 if disabled else 1.0
	$'%TextColorRect'.color = Color(0, 0, 0, 0.25) if disabled else Color(tint[0])
	$'%IconColorRect'.color = Color(0, 0, 0, 0.25) if disabled else Color(tint[1])
	$'%TextEditableLabel'.text = ["Start", "Research", "Enabled", "Disabled", "Mixed"][availabilityState] # Creatures that aren't disabled show their portal pool instead


func get_integer():
	return int($'%TextEditableLabel'.text)


func _on_EditableLabel_focus_exited():
	oScriptGenerator._on_available_quantity_changed(self)
