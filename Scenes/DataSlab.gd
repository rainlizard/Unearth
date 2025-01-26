extends Node

const U8 = 1
const U16 = 2

var buffer = StreamPeerBuffer.new()
var bytes_per_entry = 1
var width = 0
var height = 0
var buffer_size = 0

var idImgData = Image.new()
var idTexData = ImageTexture.new()

#func _input(event):
#	if event is InputEventKey and event.pressed and event.scancode == KEY_F11:
#		var filename = "a.png"
#		var err = idImgData.save_png(filename)
#		if err == OK:
#			print("Saved slab ID debug image to: ", filename)
#		else:
#			print("Failed to save slab ID debug image, error: ", err)

func initialize(w, h, fillValue, setPerEntryBytes):
	# Initialize the grid
	width = w
	height = h
	bytes_per_entry = setPerEntryBytes
	buffer_size = width * height * bytes_per_entry
	
	# Clearing a buffer is troublesome, in order to do so I need to set the buffer to an equal-sized blank PoolByteArray. (this takes 0ms)
	var blankByteArray = PoolByteArray([])
	blankByteArray.resize(buffer_size)
	blankByteArray.fill(fillValue)
	buffer.data_array = blankByteArray

func initialize_img():
	# Initialize the image
	idImgData.create(width, height, false, idImgData.FORMAT_RGB8)
	idImgData.lock()
	
	# Load buffer data into image
	for y in range(height):
		for x in range(width):
			var value = get_cell(x, y)
			idImgData.set_pixel(x, y, Color8(value, value, value))
	
	idImgData.unlock()
	idTexData.create_from_image(idImgData)

func set_cellv(pos, value):
	set_cell(pos.x, pos.y, value)

func set_cell(x, y, value):
	# Update grid
	var seek_pos = (y * width + x) * bytes_per_entry
	if seek_pos >= 0 and seek_pos < buffer_size:
		buffer.seek(seek_pos)
		if bytes_per_entry == U8:
			buffer.put_u8(value)
		elif bytes_per_entry == U16:
			buffer.put_u16(value)
	
	# Update idImgData
	if x >= 0 and x < width and y >= 0 and y < height:
		idImgData.lock()
		idImgData.set_pixel(x, y, Color8(value, value, value))
		idImgData.unlock()
		idTexData.create_from_image(idImgData)

func get_cell(x, y):
	var seek_pos = (y * width + x) * bytes_per_entry
	if seek_pos >= 0 and seek_pos < buffer_size:
		buffer.seek(seek_pos)
		if bytes_per_entry == U8:
			return buffer.get_u8()
		elif bytes_per_entry == U16:
			return buffer.get_u16()
	return -1

func get_cellv(pos):
	return get_cell(pos.x, pos.y)


func resize(new_width, new_height, fillValue):
	# Resize grid
	var new_buffer_size = new_width * new_height * bytes_per_entry
	var new_buffer = StreamPeerBuffer.new()
	var new_data_array = PoolByteArray([])
	new_data_array.resize(new_buffer_size)
	new_data_array.fill(fillValue)
	new_buffer.data_array = new_data_array
	
	var copy_width = min(width, new_width)
	var copy_height = min(height, new_height)
	
	# This is necessary for the strangely sized data structures that are like: Vector2((width*3)+1,(height*3)+1)
	match name:
		"DataOwnership", "DataClmPos", "DataWibble":
			copy_width -= 1
			copy_height -= 1
	
	for y in range(copy_height):
		for x in range(copy_width):
			var old_value = get_cell(x, y)
			var new_seek_pos = (y * new_width + x) * bytes_per_entry
			new_buffer.seek(new_seek_pos)
			if bytes_per_entry == U8:
				new_buffer.put_u8(old_value)
			elif bytes_per_entry == U16:
				new_buffer.put_u16(old_value)

	width = new_width
	height = new_height
	buffer_size = new_buffer_size
	buffer = new_buffer
	
	# Resize image
	var new_image = Image.new()
	new_image.create(new_width, new_height, false, idImgData.FORMAT_RGB8)
	new_image.fill(Color8(fillValue, fillValue, fillValue))
	
	# Copy old image data
	new_image.lock()
	idImgData.lock()
	var copy_widthi = min(width, new_width)
	var copy_heighti = min(height, new_height)
	for y in range(copy_heighti):
		for x in range(copy_widthi):
			new_image.set_pixel(x, y, idImgData.get_pixel(x, y))
	idImgData.unlock()
	new_image.unlock()
	
	idImgData = new_image
	idTexData.create_from_image(idImgData)
