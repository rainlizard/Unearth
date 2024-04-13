extends Grid

func get_cell_clmpos(x, y):
	var seek_pos = (y * width + x) * bytes_per_entry
	if seek_pos >= 0 and seek_pos < buffer_size:
		buffer.seek(seek_pos)
		return abs(buffer.get_16())
	return 0

func get_cell_clmpos_fast(x, y):
	var seek_pos = (y * width + x) * bytes_per_entry
	buffer.seek(seek_pos)
	return abs(buffer.get_16())

func set_cell_clmpos(x, y, value):
	value = 65536-value
	set_cell(x, y, value)

# Alternatively, use:
#var value = 65536 - buffer.get_u16()
#if value == 65536: value = 0
