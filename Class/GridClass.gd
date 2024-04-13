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
	buffer.resize(width * height * get_data_size())
	buffer.clear()
	data_type = dtype

func set_cell(x, y, value):
	if is_valid_coordinate(x, y):
		if data_type == U8:
			print("---")
			print("x: ", x*3)
			print("y: ", y*3)
			print("width: ", width)
			print("height: ", height)
			print("size: ", width*height)
			print("seek: ", y*width+x)
			
			buffer.seek((y*width+x))
			buffer.put_u8(value)
		elif data_type == U16:
			buffer.seek((y*width+x) * 2)
			buffer.put_u16(value)

func get_cell(x, y):
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

func is_valid_coordinate(x, y):
	return x >= 0 and x < width and y >= 0 and y < height

func set_cellv(pos, value):
	set_cell(pos.x, pos.y, value)

func get_cellv(pos):
	return get_cell(pos.x, pos.y)

func get_data_size():
	if data_type == U8:
		return 1
	elif data_type == U16:
		return 2
	return 1
