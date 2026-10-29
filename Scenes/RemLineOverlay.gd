extends Control
# Greys out REM lines in its parent TextEdit, whose color regions can't begin with a letter

func _ready():
	var oTextEdit = get_parent()
	call_deferred("place_beneath_scrollbars") # Deferred, so a duplicate of the TextEdit made during _ready doesn't copy the BackBufferCopy
	oTextEdit.connect("draw", self, "update")
	material = ShaderMaterial.new()
	material.shader = preload("res://Shaders/rem_line.shader")
	material.set_shader_param("background", oTextEdit.get_color("background_color"))


# Godot only copies the screen for the first SCREEN_TEXTURE reader each frame, so another TextEdit's overlay drawn earlier would leave this one a stale copy
func place_beneath_scrollbars():
	var oTextEdit = get_parent()
	var screenCopy = BackBufferCopy.new()
	screenCopy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	oTextEdit.add_child(screenCopy)
	oTextEdit.move_child(self, 0)
	oTextEdit.move_child(screenCopy, 0)


func _draw():
	var oTextEdit = get_parent()
	var lineHeight = oTextEdit.get_line_height()
	var stylebox = oTextEdit.get_stylebox("read_only" if oTextEdit.readonly else "normal")
	var top = int(stylebox.get_offset().y / 2) + oTextEdit.get_constant("line_spacing") / 2 - oTextEdit.scroll_vertical * lineHeight # Matches TextEdit's own line drawing
	var firstLine = int(oTextEdit.scroll_vertical)
	for line in range(firstLine, min(firstLine + int(rect_size.y / lineHeight) + 2, oTextEdit.get_line_count())):
		if Utils.is_rem_line(oTextEdit.get_line(line)):
			draw_rect(Rect2(0, top + line * lineHeight, rect_size.x, lineHeight).clip(Rect2(Vector2(), rect_size)), Color.white)
