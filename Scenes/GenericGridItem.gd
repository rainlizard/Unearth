extends PanelContainer

signal pressed

var img_normal setget set_image_normal
var img_pressed
var img_hover
var img_margin = 0
var orig_backcol

func _ready():
	if img_normal:
		$TextureRect.texture = img_normal
	orig_backcol = get_stylebox("panel").bg_color
	
	
	get_stylebox("panel").content_margin_left = img_margin
	get_stylebox("panel").content_margin_right = img_margin
	get_stylebox("panel").content_margin_top = img_margin
	get_stylebox("panel").content_margin_bottom = img_margin

func _on_GenericGridItem_mouse_entered():
	if img_hover:
		$TextureRect.texture = img_hover
	
	get_stylebox("panel").bg_color = orig_backcol * 1.25

func _on_GenericGridItem_mouse_exited():
	if img_normal:
		$TextureRect.texture = img_normal
	
	get_stylebox("panel").bg_color = orig_backcol

func _on_GenericGridItem_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if img_pressed:
				$TextureRect.texture = img_pressed
			emit_signal("pressed")
		else:
			$TextureRect.texture = img_normal

func set_image_normal(setVal):
	$TextureRect.texture = setVal
	img_normal = setVal
