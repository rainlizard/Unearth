extends Node
class_name Grid

enum {
	U8, # (8-bit unsigned integer)
	U16 # (16-bit unsigned integer)
}
var buffer = StreamPeerBuffer.new()
var data_type = U8
var width = 0
var height = 0

func initialize(w, h, fillValue, dtype):
	width = w
	height = h
	#buffer.resize(width * height * get_data_size())
	buffer.resize(width * height)
	buffer.clear()
	data_type = dtype


func set_cell(x, y, value):
	if name == "DataOwnership":
		x*=3
		y*=3
	elif name == "DataClmPos":
		value = 65536-value
	
	if is_valid_coordinate(x, y):
		if data_type == U8:
			buffer.seek((y*width+x))
			buffer.put_u8(value)
		elif data_type == U16:
			buffer.seek((y*width+x) * 2)
			buffer.put_u16(value)

func get_cell(x, y):
	if name == "DataOwnership":
		x*=3
		y*=3
	
	if is_valid_coordinate(x, y):
		var value
		
		if data_type == U8:
			buffer.seek((y*width+x))
			value = buffer.get_u8()
		elif data_type == U16:
			buffer.seek((y*width+x) * 2)
			value = buffer.get_u16()
		return value
	
	return -1


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


func is_valid_coordinate(x, y):
	return x >= 0 and x < width and y >= 0 and y < height

func set_cellv(pos, value):
	set_cell(pos.x, pos.y, value)

func get_cellv(pos):
	return get_cell(pos.x, pos.y)
#
#func get_data_size():
#	if data_type == U8:
#		return 1
#	elif data_type == U16:
#		return 2
#	return 1
