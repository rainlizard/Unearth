extends Control

var offset = Vector2(0,-35)

func _process(delta):
	if get_text() != "":
		rect_global_position = get_global_mouse_position() + offset
		visible = true
	else:
		visible = false

func set_text(txt):
	$PanelContainer/Label.text = txt
	yield(get_tree(),'idle_frame')
	yield(get_tree(),'idle_frame')
	rect_size = Vector2(0,0)

func get_text():
	return $PanelContainer/Label.text
