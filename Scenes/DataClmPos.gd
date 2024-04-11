extends Grid


func get_cell_clmpos(x, y):
	if is_valid_coordinate(x, y) == false:
		return 0
	
	buffer.seek((y*width+x) * 2)
	return abs(buffer.get_16())

func get_cell_clmpos_fast(x, y):
	buffer.seek((y*width+x) * 2)
	return abs(buffer.get_16())

func set_cell_clmpos(x, y, value):
	value = value
	set_cell(x, y, value)

# Alternatively, use:
#var value = 65536 - buffer.get_u16()
#if value == 65536: value = 0
