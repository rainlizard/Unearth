extends Node
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]


var animation_database_texture = preload("res://Shaders/textureanimationdatabase.png")

func generate_animation_database(file_path):
	# Load TOML file
	var file = File.new()
	if file.open(file_path, File.READ) != OK:
		return
	
	# Create image for animation database
	var img = Image.new()
	# Width = 8 frames, Height = number of animations (456)
	img.create(8, 456, false, Image.FORMAT_RGB8)
	img.lock()
	
	# Parse file line by line
	var current_texture_index = -1
	
	while !file.eof_reached():
		var line = file.get_line().strip_edges()
		
		# Skip empty lines and comments
		if line.empty() or line.begins_with("#"):
			continue
			
		# Check for texture definition
		if line.begins_with("[texture"):
			var index_str = line.substr(8).trim_suffix("]")
			current_texture_index = int(index_str)
			continue
			
		# Check for frames definition
		if line.begins_with("frames = [") and current_texture_index >= 544:
			# Extract numbers from frames array
			var frames_str = line.substr(9).trim_suffix("]")
			var frames = frames_str.split(",")
			
			# Calculate animation index (0-based)
			var anim_index = current_texture_index - 544
			
			# Write each frame's data to the correct x,y position
			for frame in range(8):
				if frame < frames.size():
					var texture_index = int(frames[frame])
					# Convert texture_index to RGB components
					var r = (texture_index >> 16) & 255
					var g = (texture_index >> 8) & 255
					var b = texture_index & 255
					# Store the texture index across RGB channels
					img.set_pixel(frame, anim_index, Color8(r, g, b))
				else:
					# For unused frames, set to black (0)
					img.set_pixel(frame, anim_index, Color8(0, 0, 0))
	
	img.unlock()
	file.close()
	
	# Create ImageTexture from the image
	animation_database_texture = ImageTexture.new()
	animation_database_texture.create_from_image(img, 0)
	
	# Optionally save the image to disk
#	var err = img.save_png("res://animationDatabase.png")
#	if err != OK:
#		printerr("Failed to save animation database: ", err)
#		return
	
	print("Successfully generated animation database")
