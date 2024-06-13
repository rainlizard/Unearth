extends VBoxContainer
var text
var align
signal position_editor_focus_exited
signal position_editor_text_entered
signal position_editor_text_changed
onready var oLineEditX = $"HBoxContainer1/LineEditX"
onready var oLineEditY = $"HBoxContainer1/LineEditY"
onready var oLineEditZ = $"HBoxContainer2/LineEditZ"

func set_txt(array):
	if array.size() >= 1:
		$"HBoxContainer1/LineEditX".text = str(array[0])
	if array.size() >= 2:
		$"HBoxContainer1/LineEditY".text = str(array[1])
	if array.size() >= 3:
		$"HBoxContainer2/LineEditZ".text = str(array[2])
	else:
		# For Action Point, don't display Z field.
		$"HBoxContainer2".visible = false
		$"HBoxContainer2/LineEditZ".visible = false #Visibility is checked for oLineEditZ later on, so visibility is set for it

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

func _on_LineEditX_text_changed(new_text):
	emit_signal("position_editor_text_changed", new_text)
func _on_LineEditY_text_changed(new_text):
	emit_signal("position_editor_text_changed", new_text)
func _on_LineEditZ_text_changed(new_text):
	emit_signal("position_editor_text_changed", new_text)
