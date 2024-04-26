extends AcceptDialog

func _ready():
	yield(get_tree(),'idle_frame')
	connect("visibility_changed",self,"_on_visibility_changed")

func _on_visibility_changed():
	if visible == false:
		queue_free()
