extends VBoxContainer
var text
var align
signal position_editor_focus_exited
signal position_editor_text_entered
onready var oLineEditX = $"HBoxContainer1/LineEditX"
onready var oLineEditY = $"HBoxContainer1/LineEditY"
onready var oLineEditZ = $"HBoxContainer2/LineEditZ"

func set_txt(array):
	if array.size() >= 1: $"HBoxContainer1/LineEditX".text = str(array[0])
	if array.size() >= 2: $"HBoxContainer1/LineEditY".text = str(array[1])
	if array.size() >= 3: $"HBoxContainer2/LineEditZ".text = str(array[2])

#$LinEditX.hint_tooltip =


func _on_LineEditX_focus_exited():
	emit_signal("position_editor_focus_exited")
func _on_LineEditY_focus_exited():
	emit_signal("position_editor_focus_exited")
func _on_LineEditZ_focus_exited():
	emit_signal("position_editor_focus_exited")
func _on_LineEditX_text_entered(new_text):
	emit_signal("position_editor_text_entered")
func _on_LineEditY_text_entered(new_text):
	emit_signal("position_editor_text_entered")
func _on_LineEditZ_text_entered(new_text):
	emit_signal("position_editor_text_entered")
