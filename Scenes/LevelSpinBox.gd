extends SpinBox

func _ready():
	get_child(0).connect("text_changed", self, "text_changed")

func text_changed(newText):
	if Input.is_key_pressed(KEY_1) == true: get_child(0).text = "1"
	if Input.is_key_pressed(KEY_2) == true: get_child(0).text = "2"
	if Input.is_key_pressed(KEY_3) == true: get_child(0).text = "3"
	if Input.is_key_pressed(KEY_4) == true: get_child(0).text = "4"
	if Input.is_key_pressed(KEY_5) == true: get_child(0).text = "5"
	if Input.is_key_pressed(KEY_6) == true: get_child(0).text = "6"
	if Input.is_key_pressed(KEY_7) == true: get_child(0).text = "7"
	if Input.is_key_pressed(KEY_8) == true: get_child(0).text = "8"
	if Input.is_key_pressed(KEY_9) == true: get_child(0).text = "9"
	if Input.is_key_pressed(KEY_0) == true: get_child(0).text = "10"
	get_child(0).caret_position = get_child(0).text.length()

func get_level():
	return int(get_child(0).text)
