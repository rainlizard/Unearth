extends WindowDialog
onready var oChooseMapImageFileDialog = Nodelist.list["oChooseMapImageFileDialog"]
onready var oMapImageTextureRect = Nodelist.list["oMapImageTextureRect"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oUi = Nodelist.list["oUi"]
onready var oImageAsMapGuide = Nodelist.list["oImageAsMapGuide"]
onready var oNewMapWindow = Nodelist.list["oNewMapWindow"]
onready var oDataClm = Nodelist.list["oDataClm"]

var imageData = Image.new()
var sourceImageData = Image.new()
var textureData = ImageTexture.new()
var btnGroup = ButtonGroup.new()
var highlightedColour
var offsetResultBy = Vector2()
var CODETIME_START

const transparencyColour = Color8(44,42,50,255) # When you click on the background

func _ready():
	oImageAsMapGuide.visible = false
	for slabID in Slabs.slabOrder:
		# Don't put the junk slabs in
		if Slabs.data[slabID][Slabs.EDITOR_TAB] == Slabs.TAB_MAINSLAB:
			var buttonID = Button.new()
			buttonID.text = Slabs.fetch_name(slabID)
			buttonID.toggle_mode = true
			buttonID.group = btnGroup
			buttonID.connect("pressed",self,"_on_slab_button_pressed",[buttonID])
			buttonID.set_meta("coloursAssigned", [])
			buttonID.set_meta("slabID", slabID)
			
			$HBoxContainer/VBoxContainer2/ScrollContainer/GridContainer.add_child(buttonID)

func _on_ImgMapButtonSelectImage_pressed():
	Utils.popup_centered(oChooseMapImageFileDialog)

func _on_ChooseMapImageFileDialog_file_selected(path):
	var err = sourceImageData.load(path)
	
	if err != OK:
		oMessage.quick("Error loading file.")
		return
	
	fit_image_to_current_map_size(true)

func fit_image_to_current_map_size(showMessage):
	if sourceImageData.is_empty():
		return

	var mapSize = Vector2(M.xSize, M.ySize)
	var sourceSize = sourceImageData.get_size()
	var fittedImage = Image.new()
	fittedImage.copy_from(sourceImageData)

	if sourceSize.x > mapSize.x or sourceSize.y > mapSize.y:
		if showMessage == true:
			oMessage.quick("Image has been downscaled to fit the current map size.")
		fittedImage.resize(int(mapSize.x), int(mapSize.y), Image.INTERPOLATE_NEAREST) #Image.Interpolation.INTERPOLATE_NEAREST
	elif sourceSize == mapSize:
		if showMessage == true:
			oMessage.quick("Image size perfectly matches the current map size.")
	elif sourceSize.x < mapSize.x or sourceSize.y < mapSize.y:
		if showMessage == true:
			oMessage.quick("Image has been centered to fit the current map size.")

	imageData.create(int(mapSize.x), int(mapSize.y), false, Image.FORMAT_RGBA8)
	imageData.fill(Color(0,0,0,0))
	var destinationCoordinates = ((mapSize - fittedImage.get_size()) / 2).floor()
	imageData.blit_rect(fittedImage, Rect2(Vector2(), fittedImage.get_size()), destinationCoordinates)
	
	textureData = ImageTexture.new()
	textureData.create_from_image(imageData, 0) # flags off
	oMapImageTextureRect.texture = textureData
	oImageAsMapGuide.visible = true

func update_image_if_map_size_changed():
	if sourceImageData.is_empty():
		return
	if imageData.get_size() != Vector2(M.xSize, M.ySize):
		fit_image_to_current_map_size(false)


func _on_MapImageTextureRect_gui_input(event):
	if visible == false: return
	if oMapImageTextureRect.texture == null: return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		CODETIME_START = OS.get_ticks_msec()
		update_image_if_map_size_changed()
		
		var imagePos = get_map_image_mouse_position()
		if imagePos == null:
			oMessage.quick("Click within the image.")
			return
		
		imageData.lock()
		var pixel = imageData.get_pixelv(imagePos)
		highlightedColour = Color8(pixel.r8, pixel.g8, pixel.b8, pixel.a8)
		imageData.unlock()
		#print(highlightedColour)
		if highlightedColour == transparencyColour:
			highlightedColour = Color(0,0,0,0)
		
		print('Get pixel time: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
		
		oMapImageTextureRect.material.set_shader_param("flashSpecific", highlightedColour)
		
		for i in btnGroup.get_buttons():
			if i.get_meta("coloursAssigned").has(highlightedColour) == true:
				i.pressed = true
				i.grab_focus() # Will scroll the ScrollContainer to show it
			else:
				i.pressed = false
				i.release_focus()
		
		#oMessage.quick("Highlighted colour: " + str(highlightedColour.r8) + "," + str(highlightedColour.g8) + "," + str(highlightedColour.b8))

func get_map_image_mouse_position():
	var imageSize = imageData.get_size()
	var previewSize = oMapImageTextureRect.rect_size
	if imageSize.x <= 0 or imageSize.y <= 0 or previewSize.x <= 0 or previewSize.y <= 0:
		return null

	var scale = min(previewSize.x / imageSize.x, previewSize.y / imageSize.y)
	if scale <= 0:
		return null

	var displayedSize = imageSize * scale
	var displayedStart = ((previewSize - displayedSize) / 2).floor()
	var mousePos = oMapImageTextureRect.get_local_mouse_position()
	if mousePos.x < displayedStart.x or mousePos.y < displayedStart.y:
		return null
	if mousePos.x >= displayedStart.x + displayedSize.x or mousePos.y >= displayedStart.y + displayedSize.y:
		return null

	var imagePos = ((mousePos - displayedStart) / scale).floor()
	imagePos.x = clamp(imagePos.x, 0, imageSize.x - 1)
	imagePos.y = clamp(imagePos.y, 0, imageSize.y - 1)
	return imagePos

#CODETIME_START = OS.get_ticks_msec()
#print('Map to image time: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func _on_slab_button_pressed(buttonID):
	yield(get_tree(),'idle_frame')
	buttonID.pressed = false
	
	if oDataClm.cubes.size() == 0:
		oMessage.quick("Must first create a new map or load an existing map.")
		return
	elif oMapImageTextureRect.texture == null:
		oMessage.quick("Must first load an image.")
		return
	elif highlightedColour == null:
		oMessage.quick("Must first click on a pixel within the image.")
		return
	
	var slabID = buttonID.get_meta("slabID")
	
	# Many colours can be assigned to one Button.
	# Many buttons CANNOT be assigned to one colour.
	
	# Remove the presence of this highlighted colour from every other button.
	for i in btnGroup.get_buttons():
		var colArr = i.get_meta("coloursAssigned")
		while colArr.has(highlightedColour) == true:
			colArr.erase(highlightedColour)
	# Assign it
	buttonID.get_meta("coloursAssigned").append(highlightedColour)
	
	
	yield(get_tree(),'idle_frame')
	var numberOfSlabsApplied = apply_colour_as_slabIDs_to_map(highlightedColour, slabID)
	yield(get_tree(),'idle_frame')
	
	if numberOfSlabsApplied > 0:
		finish_up()
	else:
		oMessage.quick("Must first click on a pixel within the image.")
	
	oImageAsMapGuide.visible = false

# The apply button is to make use of being able to remember old colour values, in case you want to make multiple maps
func _on_ImgMapButtonApply_pressed():
	var didSomething = false
	for i in btnGroup.get_buttons():
		var slabID = i.get_meta("slabID")
		for doColour in i.get_meta("coloursAssigned"):
			apply_colour_as_slabIDs_to_map(doColour, slabID)
			didSomething = true
	
	if didSomething == true:
		finish_up()
	else:
		oMessage.quick("You haven't even set any colours yet.")

func apply_colour_as_slabIDs_to_map(doColour, slabID):
	update_image_if_map_size_changed()
	var shapePositionArray = []
	
	imageData.lock()
	# Only 83x83 is used within the image. Don't overwrite the borders.
	
	var rectStart = Vector2(1, 1)
	var rectEnd = Vector2(imageData.get_size().x-1, imageData.get_size().y-1)
	
	for y in range(rectStart.y, rectEnd.y):
		for x in range(rectStart.x, rectEnd.x):
			var c = imageData.get_pixel(x,y)
			
			if c == doColour:
				shapePositionArray.append(Vector2(x,y))
			elif c.a == 0 and doColour.a == 0: # If the alpha of both is 0, ignore the colour values
				shapePositionArray.append(Vector2(x,y))
	imageData.unlock()
	
	var useOwner = 5
	oSlabPlacement.place_shape_of_slab_id(shapePositionArray, slabID, useOwner)
	oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, true)
	return shapePositionArray.size()

func finish_up():
	oMessage.quick("Applied slabs to map.")


func _on_ImgMapButtonNewMap_pressed():
	Utils.popup_centered(oNewMapWindow)


func _on_ImageAsMapDialog_visibility_changed():
	if is_instance_valid(oUi) == false: return
	if visible == true:
		oUi.hide_tools()
		rect_position.x = 0
	else:
		oUi.show_tools()


##
#		for getColour in slabColDict:
			
		
		#labelNode.set("custom_colors/font_color", col)
		
		# remove the colour from other buttons
#		for i in btnGroup.get_buttons():
#			if i.has_meta("colour"):
#				if i.get_meta("colour") == col:
#					i.remove_meta("colour")
#					i.get_meta("colourRectNode").hint_tooltip = ""
#					i.get_meta("colourRectNode").color = transparencyColour
#					i.get_meta("colourRectNode").get_child(0).border_color = Color(1, 1, 1, 0)
		
		#pressedButton.set_meta("colour", col)
		
#		var colourRectNode = pressedButton.get_meta("colourRectNode")
#
#		colourRectNode.color = col
#		colourRectNode.get_child(0).border_color = Color(1, 1, 1, 0.25)
#
#		if col == transparencyColour:
#			colourRectNode.hint_tooltip = "Transparent"
#		else:
#			colourRectNode.hint_tooltip = 'R:'+str(col.r8)+', G:'+str(col.g8)+', B:'+str(col.b8)+', A:'+str(col.a8)
		
		

#func add_colour_swatch(buttonID):
#
#	var colourRectNode = ColorRect.new()
#	colourRectNode.rect_min_size = Vector2(28,28)
#	colourRectNode.color = transparencyColour
#	colourRectNode.hint_tooltip = ""
#
#	$HBoxContainer/VBoxContainer2/ScrollContainer/GridContainer.add_child(colourRectNode)
#
#	var borderRect = ReferenceRect.new()
#	borderRect.border_color = Color(1, 1, 1, 0)
#	borderRect.border_width = 1.0
#	borderRect.editor_only = false
#	borderRect.anchor_right = 1.0
#	borderRect.anchor_bottom = 1.0
#	borderRect.rect_position.x += 1
#	borderRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
#	colourRectNode.add_child(borderRect)
#
#	buttonID.set_meta("colourRectNode", colourRectNode)
