extends Control
# Greys out REM lines in its parent TextEdit, whose color regions can't begin with a letter

func _ready():
	var oTextEdit = get_parent()
	oTextEdit.call_deferred("move_child", self, 0) # Beneath the scrollbars
	oTextEdit.connect("draw", self, "update")
	material = ShaderMaterial.new()
	material.shader = preload("res://Shaders/rem_line.shader")
	material.set_shader_param("background", oTextEdit.get_color("background_color"))


func _draw():
	var oTextEdit = get_parent()
	var lineHeight = oTextEdit.get_line_height()
	var stylebox = oTextEdit.get_stylebox("read_only" if oTextEdit.readonly else "normal")
	var top = int(stylebox.get_offset().y / 2) + oTextEdit.get_constant("line_spacing") / 2 - oTextEdit.scroll_vertical * lineHeight # Matches TextEdit's own line drawing
	var firstLine = int(oTextEdit.scroll_vertical)
	for line in range(firstLine, min(firstLine + int(rect_size.y / lineHeight) + 2, oTextEdit.get_line_count())):
		if Utils.is_rem_line(oTextEdit.get_line(line)):
			draw_rect(Rect2(0, top + line * lineHeight, rect_size.x, lineHeight).clip(Rect2(Vector2(), rect_size)), Color.white)
