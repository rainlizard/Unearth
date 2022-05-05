extends WindowDialog
onready var oChooseMapImageFileDialog = Nodelist.list["oChooseMapImageFileDialog"]
onready var oMapImageTextureRect = Nodelist.list["oMapImageTextureRect"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oUi = Nodelist.list["oUi"]

var imageData = Image.new()
var textureData = ImageTexture.new()
var btnGroup = ButtonGroup.new()
var highlightedColour
var offsetResultBy = Vector2()
var CODETIME_START

const transparencyColour = Color8(44,42,50,255) # When you click on the background

func _ready():
	for slabID in Slabs.slabOrder:
		# Don't put the junk slabs in
		if Slabs.data[slabID][Slabs.EDITOR_TAB] == Slabs.TAB_MAINSLAB:
			var buttonID = Button.new()
			buttonID.text = Slabs.data[slabID][Slabs.NAME]
			buttonID.toggle_mode = true
			buttonID.group = btnGroup
			buttonID.connect("pressed",self,"_on_slab_button_pressed",[buttonID])
			buttonID.set_meta("coloursAssigned", [])
			buttonID.set_meta("slabID", slabID)
			
			$HBoxContainer/VBoxContainer2/ScrollContainer/GridContainer.add_child(buttonID)

func _on_ImgMapButtonHelp_pressed():
	var helptxt = ""
	helptxt += "Load a .png file from your file system, images larger than 85x85 will be resized."
	helptxt += "\n"
	helptxt += "Click on a pixel within the image to highlight its colour, then click a slab button to instantly place slabs on the map. Repeat until all colours are assigned."
	oMessage.big("Help",helptxt)



func _on_ImgMapButtonSelectImage_pressed():
	Utils.popup_centered(oChooseMapImageFileDialog)

func _on_ChooseMapImageFileDialog_file_selected(path):
	
	var err = imageData.load(path)
	
	if err != OK:
		oMessage.quick("Error loading file.")
		return
	
	if imageData.get_size() > Vector2(85,85):
		imageData.resize(85,85,Image.INTERPOLATE_NEAREST) #Image.Interpolation.INTERPOLATE_NEAREST
	if imageData.get_size() < Vector2(85,85):
		#offsetResultBy = ( (Vector2(85,85) - imageData.get_size()) / 2 ).floor()
		
		var copyPaste = Image.new()
		copyPaste.copy_from(imageData)
		#print(copyPaste.get_size())
		
		
		# Center image if it's small
		imageData.crop(85,85)
		imageData.fill(Color(0,0,0,0))
		
		var destinationCoordinates = ( (Vector2(85,85) - copyPaste.get_size()) / 2 ).floor()
		
		imageData.blit_rect(copyPaste,copyPaste.get_used_rect(), destinationCoordinates)
	#offsetResultBy = Vector2(1,1) # # To take into consideration the border
	
	textureData = ImageTexture.new()
	textureData.create_from_image(imageData, 0) # flags off
	oMapImageTextureRect.texture = textureData

func _on_MapImageTextureRect_gui_input(event):
	if visible == false: return
	if oMapImageTextureRect.texture == null: return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		CODETIME_START = OS.get_ticks_msec()
		
		var mousePos = get_global_mouse_position() * Settings.UI_SCALE
		
		var screenshot = Image.new()
		screenshot = get_viewport().get_texture().get_data()
		
		screenshot.lock()
		screenshot.flip_y() # Must be used due to Godot
		var pixel = screenshot.get_pixelv(mousePos)
		highlightedColour = Color8(pixel.r8,pixel.g8,pixel.b8,pixel.a8)
		screenshot.unlock()
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

#CODETIME_START = OS.get_ticks_msec()
#print('Map to image time: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func _on_slab_button_pressed(buttonID):
	yield(get_tree(),'idle_frame')
	
	if highlightedColour == null:
		buttonID.pressed = false
		oMessage.quick("Click on a pixel within the image first.")
		return
	if oMapImageTextureRect.texture == null:
		oMessage.quick("Load an image first.")
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
	apply_colour_as_slabIDs_to_map(highlightedColour, slabID)
	yield(get_tree(),'idle_frame')
	
	finish_up()

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
	var shapePositionArray = []
	
	imageData.lock()
	# Only 83x83 is used within the image. Don't overwrite the borders.
	
	var rectStart = Vector2(1, 1)
	var rectEnd = Vector2(imageData.get_size().x-1, imageData.get_size().y-1)
	
	for y in range(rectStart.x, rectEnd.y):
		for x in range(rectStart.x, rectEnd.y):
			var c = imageData.get_pixel(x,y)
			
			if c == doColour:
				shapePositionArray.append(Vector2(x,y))
			elif c.a == 0 and doColour.a == 0: # If the alpha of both is 0, ignore the colour values
				shapePositionArray.append(Vector2(x,y))
	imageData.unlock()
	
	var useOwner = 5
	oSlabPlacement.place_shape_of_slab_id(shapePositionArray, slabID, useOwner)
	oSlabPlacement.generate_slabs_based_on_id(rectStart, rectEnd, true)

func finish_up():
	oMessage.quick("Applied slabs to map.")


func _on_ImgMapButtonNewMap_pressed():
	oCurrentMap._on_ButtonNewMap_pressed()


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
