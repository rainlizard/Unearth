extends Node
class_name Grid

const U8 = 1
const U16 = 2

var buffer = StreamPeerBuffer.new()
var bytes_per_entry = 1
var width = 0
var height = 0
var buffer_size = 0

func initialize(w, h, fillValue, setPerEntryBytes):
	width = w
	height = h
	bytes_per_entry = setPerEntryBytes
	buffer_size = width * height * bytes_per_entry
	
	# Clearing a buffer is troublesome, in order to do so I need to set the buffer to an equal-sized blank PoolByteArray. (this takes 0ms)
	var blankByteArray = PoolByteArray([])
	blankByteArray.resize(buffer.get_size())
	blankByteArray.fill(fillValue)
	buffer.data_array = blankByteArray


func set_cell(x, y, value):
	var seek_pos = (y * width + x) * bytes_per_entry
	if seek_pos >= 0 and seek_pos < buffer_size:
		buffer.seek(seek_pos)
		if bytes_per_entry == U8:
			buffer.put_u8(value)
		elif bytes_per_entry == U16:
			buffer.put_u16(value)

func get_cell(x, y):
	var seek_pos = (y * width + x) * bytes_per_entry
	if seek_pos >= 0 and seek_pos < buffer_size:
		buffer.seek(seek_pos)
		if bytes_per_entry == U8:
			return buffer.get_u8()
		elif bytes_per_entry == U16:
			return buffer.get_u16()
	return -1

func set_cellv(pos, value):
	set_cell(pos.x, pos.y, value)

func get_cellv(pos):
	return get_cell(pos.x, pos.y)
