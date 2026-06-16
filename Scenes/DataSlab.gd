extends Grid

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

func initialize_img():
	regenerate_image_from_buffer()
	idTexData.create_from_image(idImgData)

func update_texture():
	regenerate_image_from_buffer()
	idTexData.create_from_image(idImgData)


func regenerate_image_from_buffer():
	if width <= 0 or height <= 0:
		return
	
	var pixel_data = PoolByteArray()
	pixel_data.resize(width * height * 3) # RGB8 format = 3 bytes per pixel
	
	buffer.seek(0)
	for i in (width * height):
		var value
		if bytes_per_entry == U8:
			value = buffer.get_u8()
		elif bytes_per_entry == U16:
			value = buffer.get_u16() & 0xFF  # Take only lower 8 bits for display
		else:
			value = 0
		
		# RGB8: store same value in R, G, B channels
		var pixel_offset = i * 3
		pixel_data[pixel_offset] = value      # Red
		pixel_data[pixel_offset + 1] = value  # Green  
		pixel_data[pixel_offset + 2] = value  # Blue
	
	idImgData.create_from_data(width, height, false, Image.FORMAT_RGB8, pixel_data)


func resize(new_width, new_height, fillValue, offset_x = 0, offset_y = 0):
	.resize(new_width, new_height, fillValue, offset_x, offset_y)
	update_texture()
