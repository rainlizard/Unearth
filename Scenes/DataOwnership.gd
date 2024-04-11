extends Grid

func set_cellv_ownership(pos, value):
	var x = pos.x * 3
	var y = pos.y * 3
	var start_seek_pos = (y * width + x) * bytes_per_entry
	if start_seek_pos >= 0 and start_seek_pos < buffer_size:
		var seek_pos = start_seek_pos
		for _i in range(3):
			for _j in range(3):
				buffer.seek(seek_pos)
				buffer.put_u8(value)
				seek_pos += bytes_per_entry
			seek_pos += (width - 3) * bytes_per_entry


func get_cell_ownership(x, y):
	return get_cell(x*3, y*3)



func get_cellv_ownership(pos):
	return get_cell(pos.x*3, pos.y*3)
