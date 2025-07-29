extends ProgressBar
onready var oEditor = Nodelist.list["oEditor"]

func _init():
	visible = false


func _on_LoadingBar_visibility_changed():
	oEditor.input_requests_screen_update()
