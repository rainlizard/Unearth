extends AcceptDialog

func _ready():
	yield(get_tree(),'idle_frame') # Important otherwise it won't show because popup_hide gets called 1st frame
	connect("popup_hide",self,"_on_BigMessageInstance_popup_hide")
	get_ok().rect_position.y = get_ok().rect_position.y-20

func _on_BigMessageInstance_popup_hide():
	queue_free()
