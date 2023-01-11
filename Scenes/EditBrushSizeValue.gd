extends SpinBoxPropertiesValue
onready var oInspector = Nodelist.list["oInspector"]

func _input(event):
	if visible == false: return
	if event is InputEventKey and event.pressed == true:
		yield(get_tree(),'idle_frame')
		match event.scancode:
			KEY_1, KEY_KP_1: value = 1
			KEY_2, KEY_KP_2: value = 2
			KEY_3, KEY_KP_3: value = 3
			KEY_4, KEY_KP_4: value = 4
			KEY_5, KEY_KP_5: value = 5
			KEY_6, KEY_KP_6: value = 6
			KEY_7, KEY_KP_7: value = 7
			KEY_8, KEY_KP_8: value = 8
			KEY_9, KEY_KP_9: value = 9
			KEY_0, KEY_KP_0:
				value = 10
				get_line_edit().text = "10"
