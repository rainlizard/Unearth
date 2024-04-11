extends Grid


func get_cell_clmpos(x, y):
	if is_valid_coordinate(x, y) == false:
		return 0
	buffer.seek((y*width+x) * 2)
	var value = 65536 - buffer.get_u16()
	if value == 65536: value = 0
	return value


func get_cell_clmpos_fast(x, y):
	buffer.seek((y*width+x) * 2)
	var value = 65536 - buffer.get_u16()
	if value == 65536: value = 0
	return value


func set_cell_clmpos(x, y, value):
	value = 65536-value
	if value == 65536: value = 0
	set_cell(x, y, value)

