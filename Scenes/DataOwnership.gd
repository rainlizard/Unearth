extends Grid

func set_cell_ownership(x, y, value):
	set_cell(x*3, y*3, value)

func set_cellv_ownership(pos, value):
	set_cell(pos.x*3, pos.y*3, value)

func get_cell_ownership(x, y):
	return get_cell(x*3, y*3)

func get_cellv_ownership(pos):
	return get_cell(pos.x*3, pos.y*3)
