extends WindowDialog
onready var oChooseMapImageFileDialog = Nodelist.list["oChooseMapImageFileDialog"]
onready var oMapImageTextureRect = Nodelist.list["oMapImageTextureRect"]
onready var oImgMapAspectRatioContainer = Nodelist.list["oImgMapAspectRatioContainer"]
onready var oImgMapInfoLabel = Nodelist.list["oImgMapInfoLabel"]
onready var oImgMapColourList = Nodelist.list["oImgMapColourList"]
onready var oImgMapSlabList = Nodelist.list["oImgMapSlabList"]
onready var oImgMapOwnerGrid = Nodelist.list["oImgMapOwnerGrid"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oUi = Nodelist.list["oUi"]
onready var oImageAsMapGuide = Nodelist.list["oImageAsMapGuide"]
onready var oNewMapWindow = Nodelist.list["oNewMapWindow"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]

const MAX_LISTED_COLOURS = 256
const NO_FLASH = Color(0.00001, 0.00002, 0.00003, 0.00004) # Matches the shader's default so nothing flashes
const TRANSPARENT = Color(0,0,0,0)

var imageData = Image.new()
var sourceImageData = Image.new()
var imageName = ""
var colourOrder = [] # Colours as listed, most common first
var colourPositions = {} # Colour -> map positions (excluding the border)
var assignments = {} # Colour -> [slabID, owner]. Kept between images, so a reworked image can be reapplied.
var selectedColour = null
var currentOwner = Constants.PLAYER_NEUTRAL

func _ready():
	oImgMapSlabList.add_item("Unassigned")
	for slabID in Slabs.slabOrder:
		# Don't put the junk slabs in
		if Slabs.data[slabID][Slabs.EDITOR_TAB] == Slabs.TAB_MAINSLAB:
			oImgMapSlabList.add_item(Slabs.fetch_name(slabID))
			oImgMapSlabList.set_item_metadata(oImgMapSlabList.get_item_count() - 1, slabID)
	update_guide()

func _on_ImgMapButtonSelectImage_pressed():
	Utils.popup_centered(oChooseMapImageFileDialog)

func _on_ImgMapButtonNewMap_pressed():
	Utils.popup_centered(oNewMapWindow)

func _on_ChooseMapImageFileDialog_file_selected(path):
	var err = sourceImageData.load(path)

	if err != OK:
		oMessage.quick("Error loading file.")
		return

	sourceImageData.convert(Image.FORMAT_RGBA8) # blit_rect requires matching formats, images without alpha load as RGB8
	imageName = path.get_file()
	selectedColour = null
	fit_image_to_current_map_size()

func fit_image_to_current_map_size():
	var mapSize = Vector2(M.xSize, M.ySize)
	var sourceSize = sourceImageData.get_size()
	var fittedImage = Image.new()
	fittedImage.copy_from(sourceImageData)

	var fitText = "centered on"
	if sourceSize.x > mapSize.x or sourceSize.y > mapSize.y:
		fitText = "downscaled to fit"
		var fittedSize = (sourceSize * min(mapSize.x / sourceSize.x, mapSize.y / sourceSize.y)).floor()
		fittedImage.resize(int(max(fittedSize.x, 1)), int(max(fittedSize.y, 1)), Image.INTERPOLATE_NEAREST)
	elif sourceSize == mapSize:
		fitText = "matches"

	imageData.create(int(mapSize.x), int(mapSize.y), false, Image.FORMAT_RGBA8)
	imageData.fill(TRANSPARENT)
	var destinationCoordinates = ((mapSize - fittedImage.get_size()) / 2).floor()
	imageData.blit_rect(fittedImage, Rect2(Vector2(), fittedImage.get_size()), destinationCoordinates)

	var textureData = ImageTexture.new()
	textureData.create_from_image(imageData, 0) # flags off
	oMapImageTextureRect.texture = textureData

	build_colour_list()
	oImgMapInfoLabel.text = "%s  |  %dx%d image %s %dx%d map  |  %d colours" % [imageName, sourceSize.x, sourceSize.y, fitText, mapSize.x, mapSize.y, colourOrder.size()]

func update_image_if_map_size_changed():
	var mapSize = Vector2(M.xSize, M.ySize)
	oImgMapAspectRatioContainer.ratio = mapSize.x / mapSize.y
	if sourceImageData.is_empty():
		oImgMapInfoLabel.text = "Map size: %dx%d" % [mapSize.x, mapSize.y]
	elif imageData.get_size() != mapSize:
		fit_image_to_current_map_size()

func build_colour_list():
	colourPositions.clear()
	var imageSize = imageData.get_size()
	imageData.lock()
	for y in int(imageSize.y):
		for x in int(imageSize.x):
			var c = normalise(imageData.get_pixel(x, y))
			if colourPositions.has(c) == false:
				colourPositions[c] = []
			# Don't overwrite the borders
			if x > 0 and y > 0 and x < imageSize.x-1 and y < imageSize.y-1:
				colourPositions[c].append(Vector2(x, y))
	imageData.unlock()

	colourOrder = colourPositions.keys()
	colourOrder.sort_custom(self, "sort_by_most_common")
	if colourOrder.size() > MAX_LISTED_COLOURS:
		oMessage.quick("Image has " + str(colourOrder.size()) + " colours, only the " + str(MAX_LISTED_COLOURS) + " most common are listed. Use an image with fewer colours.")
		colourOrder.resize(MAX_LISTED_COLOURS)

	oImgMapColourList.clear()
	for i in colourOrder.size():
		var swatch = Image.new()
		swatch.create(16, 16, false, Image.FORMAT_RGBA8)
		swatch.fill(colourOrder[i])
		var swatchTexture = ImageTexture.new()
		swatchTexture.create_from_image(swatch, 0)
		oImgMapColourList.add_item("", swatchTexture)
		refresh_colour_item(i)

	select_colour(selectedColour if colourOrder.has(selectedColour) else null)

func sort_by_most_common(a, b):
	return colourPositions[a].size() > colourPositions[b].size()

func normalise(c):
	return TRANSPARENT if c.a == 0 else c # All fully transparent pixels count as one colour

func refresh_colour_item(i):
	var c = colourOrder[i]
	var text = "Unassigned"
	if assignments.has(c):
		var slabID = assignments[c][0]
		var ownerID = assignments[c][1]
		text = Slabs.fetch_name(slabID)
		if ownerID != Constants.PLAYER_NEUTRAL and oSlabPlacement.slabID_is_ownable(slabID):
			text += " (" + Constants.ownershipNames[ownerID] + ")"
	if c == TRANSPARENT:
		text = "Transparent: " + text
	oImgMapColourList.set_item_text(i, text)
	oImgMapColourList.set_item_custom_fg_color(i, Color(1,1,1,1) if assignments.has(c) else Color(1,1,1,0.5))
	oImgMapColourList.set_item_tooltip(i, "R:%d G:%d B:%d A:%d\n%d tiles" % [c.r8, c.g8, c.b8, c.a8, colourPositions[c].size()])

func select_colour(c):
	selectedColour = c
	oMapImageTextureRect.material.set_shader_param("flashSpecific", NO_FLASH if c == null else c)

	var slabIndex = 0
	if assignments.has(c):
		slabIndex = find_slab_index(assignments[c][0])
		currentOwner = assignments[c][1]
		press_owner_button()

	if c == null:
		oImgMapColourList.unselect_all()
		oImgMapSlabList.unselect_all()
	else:
		oImgMapColourList.select(colourOrder.find(c))
		oImgMapColourList.ensure_current_is_visible()
		oImgMapSlabList.select(slabIndex)
		oImgMapSlabList.ensure_current_is_visible()
	update_guide()

func find_slab_index(slabID):
	for i in oImgMapSlabList.get_item_count():
		if oImgMapSlabList.get_item_metadata(i) == slabID:
			return i
	return 0

func _on_MapImageTextureRect_gui_input(event):
	if oMapImageTextureRect.texture == null: return

	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		update_image_if_map_size_changed()
		var imageSize = imageData.get_size()
		var imagePos = (event.position / oMapImageTextureRect.rect_size * imageSize).floor()
		imagePos.x = clamp(imagePos.x, 0, imageSize.x - 1)
		imagePos.y = clamp(imagePos.y, 0, imageSize.y - 1)

		imageData.lock()
		var c = normalise(imageData.get_pixelv(imagePos))
		imageData.unlock()

		if colourOrder.has(c):
			select_colour(c)
		else:
			oMessage.quick("This colour isn't listed, the image has too many colours.")

func _on_ImgMapColourList_item_selected(index):
	select_colour(colourOrder[index])

func _on_ImgMapSlabList_item_selected(index):
	if selectedColour == null:
		oImgMapSlabList.unselect_all()
		oMessage.quick("First click a colour in the image or in the colour list.")
		return

	var slabID = oImgMapSlabList.get_item_metadata(index)
	if slabID == null:
		assignments.erase(selectedColour)
	else:
		assignments[selectedColour] = [slabID, currentOwner]
	refresh_colour_item(colourOrder.find(selectedColour))
	update_guide()

func build_owner_buttons():
	for child in oImgMapOwnerGrid.get_children():
		child.free()

	var ownerOrder = [0,1,2,3,4,6,7,8,5]
	if oCurrentFormat.selected == Constants.OldFormat:
		ownerOrder = [0,1,2,3,4,5]
	if ownerOrder.has(currentOwner) == false:
		currentOwner = Constants.PLAYER_NEUTRAL

	var ownerGroup = ButtonGroup.new()
	for ownerID in ownerOrder:
		var ownerButton = Button.new()
		ownerButton.toggle_mode = true
		ownerButton.group = ownerGroup
		ownerButton.icon = Constants.ownerIcons[ownerID]
		ownerButton.hint_tooltip = Constants.ownershipNames[ownerID]
		ownerButton.set_meta("ownerID", ownerID)
		ownerButton.connect("pressed", self, "_on_owner_button_pressed", [ownerID])
		oImgMapOwnerGrid.add_child(ownerButton)
	press_owner_button()

func press_owner_button():
	for ownerButton in oImgMapOwnerGrid.get_children():
		ownerButton.pressed = ownerButton.get_meta("ownerID") == currentOwner

func _on_owner_button_pressed(ownerID):
	currentOwner = ownerID
	if assignments.has(selectedColour):
		assignments[selectedColour][1] = ownerID
		refresh_colour_item(colourOrder.find(selectedColour))

func _on_ImgMapButtonApply_pressed():
	if oDataClm.cubes.size() == 0:
		oMessage.quick("Must first create a new map or load an existing map.")
		return
	if oSlabPlacement.block_while_generating():
		return
	update_image_if_map_size_changed()
	var appliedCount = 0
	var shapePositionArray = []
	for c in colourOrder:
		if assignments.has(c):
			oSlabPlacement.place_shape_of_slab_id(colourPositions[c], assignments[c][0], assignments[c][1])
			shapePositionArray.append_array(colourPositions[c])
			appliedCount += 1

	if appliedCount == 0:
		oMessage.quick("You haven't assigned slabs to any colours yet.")
		return
	oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, true)
	oMessage.quick("Applied " + str(appliedCount) + " colours to map.")

func update_guide():
	if sourceImageData.is_empty():
		oImageAsMapGuide.text = "Select an image to begin. Each pixel becomes one slab, so draw the image at the map size shown above."
	elif selectedColour == null:
		oImageAsMapGuide.text = "Click a colour in the image or in the colour list, then pick a slab for it."
	else:
		oImageAsMapGuide.text = "Pick a slab and owner for the flashing colour, then press Apply to place everything onto the map."

func _on_ImageAsMapDialog_visibility_changed():
	if is_instance_valid(oUi) == false: return
	if visible == true:
		oUi.hide_tools()
		rect_position.x = 0
		build_owner_buttons()
		update_image_if_map_size_changed()
	else:
		oUi.show_tools()
