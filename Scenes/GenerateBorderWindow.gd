extends WindowDialog
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oNoiseOctaves = Nodelist.list["oNoiseOctaves"]
onready var oNoisePeriod = Nodelist.list["oNoisePeriod"]
onready var oNoisePersistence = Nodelist.list["oNoisePersistence"]
onready var oNoiseLacunarity = Nodelist.list["oNoiseLacunarity"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oQuickNoisePreview = Nodelist.list["oQuickNoisePreview"]
onready var oNoiseUpdateTimer = Nodelist.list["oNoiseUpdateTimer"]
onready var oNewMapNoiseOptions = Nodelist.list["oNewMapNoiseOptions"]
onready var oXSizeLine = Nodelist.list["oXSizeLine"]
onready var oYSizeLine = Nodelist.list["oYSizeLine"]
onready var oGame = Nodelist.list["oGame"]
onready var oSetNewFormat = Nodelist.list["oSetNewFormat"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCheckBoxNewMapBorder = Nodelist.list["oCheckBoxNewMapBorder"]
onready var oNewMapSymmetricalBorder = Nodelist.list["oNewMapSymmetricalBorder"]
onready var oNoiseDistance = Nodelist.list["oNoiseDistance"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oCheckBoxNewMapAutoOpensMapSettings = Nodelist.list["oCheckBoxNewMapAutoOpensMapSettings"]
onready var oDkDat = Nodelist.list["oDkDat"]

var noise = OpenSimplexNoise.new()
var imageData = Image.new()
var textureData = ImageTexture.new()

const earthColour = Color8(255,255,255,255)#Color8(36,24,0,255)
const impenetrableColour = Color8(0,0,0,255)

var algorithmType = 0

func _ready():
	randomize()
	noise.seed = randi()

func _on_NewMapWindow_visibility_changed():
	if visible == false: return
	
	
	var kfxOutOfDate = false
	if oGame.KEEPERFX_VERSION_INT != 0 and oGame.KEEPERFX_VERSION_INT < oGame.KEEPERFX_VERSION_REQUIRED_INT:
		kfxOutOfDate = true
	
	# Default to KFX format
	
	if oGame.running_keeperfx() == false or kfxOutOfDate == true:
		oSetNewFormat.selected = 0 # Set default format to Classic format, for newbies who don't know what KeeperFX is
		_on_NewMapFormat_item_selected(0)
	else:
		oSetNewFormat.selected = 1 # Set default format to KFX format
		_on_NewMapFormat_item_selected(1)
	
	reinit_noise_preview()
	
	_on_CheckBoxNewMapBorder_pressed()


func reinit_noise_preview():
	var sizeX = oXSizeLine.text.to_int()
	var sizeY = oYSizeLine.text.to_int()
	imageData.create(sizeX, sizeY, false, Image.FORMAT_RGB8)
	textureData.create_from_image(imageData, 0)
	oQuickNoisePreview.texture = textureData
	
	
	var pixelSize = 4
	var maxSize = Vector2(85*pixelSize,85*pixelSize)
	
	oQuickNoisePreview.rect_min_size = Vector2(min(sizeX*pixelSize, maxSize.x), min(sizeY*pixelSize, maxSize.y))
	
	if sizeX > 85 or sizeY > 85:
		if sizeX < sizeY:
			var aspectRatio = float(max(1.0,sizeX)) / float(max(1.0,sizeY))
			oQuickNoisePreview.rect_min_size.x *= aspectRatio
		else:
			var aspectRatio = float(max(1.0,sizeY)) / float(max(1.0,sizeX))
			oQuickNoisePreview.rect_min_size.y *= aspectRatio
	
	#oQuickNoisePreview.rect_size = oQuickNoisePreview.rect_min_size



func _on_ButtonNewMapOK_pressed():
	if oGame.EXECUTABLE_PATH == "":
		oMessage.quick("Error: Game executable is not set. Set in File -> Preferences")
		return
	
	oCurrentMap._on_ButtonNewMap_pressed()
	
	if oDkDat.dat.empty() == true:
		oMessage.quick("Failed loading slabset, game executable might not be correct. Set in File -> Preferences")
		return
	
	var rectStart = Vector2(0, 0)
	var rectEnd = Vector2(M.xSize-1, M.ySize-1)
	var shapePositionArray = []
	for y in range(rectStart.y, rectEnd.y+1):
		for x in range(rectStart.x, rectEnd.x+1):
			shapePositionArray.append(Vector2(x,y))
	var slabID = Slabs.ROCK
	var useOwner = 5
	oSlabPlacement.place_shape_of_slab_id(shapePositionArray, slabID, useOwner)
	
	if oNewMapNoiseOptions.visible == true:
		# Border
		overwrite_map_with_border_values()
	else:
		# Blank
		overwrite_map_with_blank_values()
	
	#Vector2(0,0), Vector2(M.xSize-1,M.ySize-1)
	oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, false)
	
	visible = false # Close New Map window after pressing OK button
	
	if oCheckBoxNewMapAutoOpensMapSettings.pressed == true:
		Utils.popup_centered(oMapSettingsWindow)

func overwrite_map_with_blank_values():
	for y in range(1, M.ySize-1):
		for x in range(1, M.xSize-1):
			oDataSlab.set_cell(x, y, Slabs.EARTH)

func overwrite_map_with_border_values():
	imageData.lock()
	for y in range(1, M.ySize-1):
		for x in range(1, M.xSize-1):
			match imageData.get_pixel(x,y):
				impenetrableColour: oDataSlab.set_cell(x, y, Slabs.ROCK)
				earthColour: oDataSlab.set_cell(x, y, Slabs.EARTH)
	imageData.unlock()
	

func _on_NoisePersistence_sliderChanged():
	# Constantly reset the timer to max time while dragging the slider
	# When timer ends, update the visual
	oNoiseUpdateTimer.start(0.01)
func _on_NoisePeriod_sliderChanged():
	oNoiseUpdateTimer.start(0.01)
func _on_NoiseLacunarity_sliderChanged():
	oNoiseUpdateTimer.start(0.01)
func _on_NoiseOctaves_sliderChanged():
	oNoiseUpdateTimer.start(0.01)
func _on_NoiseDistance_sliderChanged():
	oNoiseUpdateTimer.start(0.01)

func _on_NoiseAlgTypeCheckBox_toggled(button_pressed):
	if button_pressed == true:
		algorithmType = 0
	else:
		algorithmType = 1
	oNoiseUpdateTimer.start(0.01)

func _on_YSizeLine_focus_exited():
	if oCheckBoxNewMapBorder.pressed == false: return
	if oYSizeLine.text.to_int() > 170:
		oYSizeLine.text = "170"
	reinit_noise_preview()
	update_border_image_with_noise()
func _on_XSizeLine_focus_exited():
	if oCheckBoxNewMapBorder.pressed == false: return
	if oXSizeLine.text.to_int() > 170:
		oXSizeLine.text = "170"
	reinit_noise_preview()
	update_border_image_with_noise()


func _on_NoiseUpdateTimer_timeout():
	update_border_image_with_noise()

func update_border_image_with_noise():
	if oCheckBoxNewMapBorder.pressed == false: return
	
	var NOISECODETIME = OS.get_ticks_msec()
	noise.octaves = oNoiseOctaves.value
	noise.period = oNoisePeriod.value
	noise.persistence = oNoisePersistence.value
	noise.lacunarity = oNoiseLacunarity.value
	var borderDist = oNoiseDistance.value
	
	var fullMapSize = Vector2(oXSizeLine.text.to_int()-1, oYSizeLine.text.to_int()-1)
	var halfMapSize = Vector2(fullMapSize.x * 0.5, fullMapSize.y * 0.5)
	
	var floodFillTileMap = TileMap.new()
	
	var aspectRatio = Vector2()
	if fullMapSize.x < fullMapSize.y:
		aspectRatio.x = max(fullMapSize.x,1.0) / max(fullMapSize.y,1.0)
		aspectRatio.y = 1.0
	else:
		aspectRatio.x = 1.0
		aspectRatio.y = max(fullMapSize.y,1.0) / max(fullMapSize.x,1.0)
	
	
	
	var edgeDist = Vector2()
	match algorithmType:
		0:
			for x in range(1, fullMapSize.x):
				for y in range(1, fullMapSize.y):
					edgeDist.x = (abs(x-halfMapSize.x) / halfMapSize.x) * borderDist
					edgeDist.y = (abs(y-halfMapSize.y) / halfMapSize.y) * borderDist
					var n = 1.0-abs(noise.get_noise_2d( (x/fullMapSize.x)*aspectRatio.x, (y/fullMapSize.y)*aspectRatio.y ))
					if n > edgeDist.x and n > edgeDist.y:
						floodFillTileMap.set_cell(x,y,1)
		1:
			for x in range(1, fullMapSize.x):
				for y in range(1, fullMapSize.y):
					edgeDist.x = (abs(x-halfMapSize.x) / halfMapSize.x) * borderDist
					edgeDist.y = (abs(y-halfMapSize.y) / halfMapSize.y) * borderDist
					var n = 1.0-noise.get_noise_2d( (x/fullMapSize.x)*aspectRatio.x, (y/fullMapSize.y)*aspectRatio.y )
					if n > edgeDist.x and n > edgeDist.y:
						floodFillTileMap.set_cell(x,y,1)
	
	var coordsToCheck = [Vector2(halfMapSize.x,halfMapSize.y)]
	
	imageData.fill(impenetrableColour)
	imageData.lock()
	
	while coordsToCheck.size() > 0:
		var coord = coordsToCheck.pop_back()
		if floodFillTileMap.get_cellv(coord) == 1:
			floodFillTileMap.set_cellv(coord, 0)
			
			imageData.set_pixelv(coord, earthColour)
			
			coordsToCheck.append(coord + Vector2(0,1))
			coordsToCheck.append(coord + Vector2(0,-1))
			coordsToCheck.append(coord + Vector2(1,0))
			coordsToCheck.append(coord + Vector2(-1,0))
	
	imageData.unlock()
	
	apply_symmetry()
	textureData.set_data(imageData)
	
	print('Border image time: ' + str(OS.get_ticks_msec() - NOISECODETIME) + 'ms')

func update_border_image_with_blank():
	imageData.fill(earthColour)
	imageData.lock()
	
	var fullMapSize = Vector2(oXSizeLine.text.to_int(), oYSizeLine.text.to_int())
	
	for x in fullMapSize.x:
		for y in fullMapSize.y:
			if x == 0 or x == fullMapSize.x-1 or y == 0 or y == fullMapSize.y-1:
				imageData.set_pixel(x,y, impenetrableColour)
	imageData.unlock()
	textureData.set_data(imageData)


func _on_CheckBoxNewMapBorder_pressed():
	if oCheckBoxNewMapBorder.pressed == true:
		oNewMapNoiseOptions.visible = true
		update_border_image_with_noise()
	else:
		oNewMapNoiseOptions.visible = false
		update_border_image_with_blank()

func _on_NewMapFormat_item_selected(index):
	if index == 0:
		oXSizeLine.editable = false
		oYSizeLine.editable = false
		oXSizeLine.text = "85"
		oYSizeLine.text = "85"
		_on_XSizeLine_focus_exited()
		_on_YSizeLine_focus_exited()
		oXSizeLine.hint_tooltip = "" #"Map size can only be changed if KFX format is used."
		oYSizeLine.hint_tooltip = "" #"Map size can only be changed if KFX format is used."
	elif index == 1:
		oXSizeLine.editable = false#true
		oYSizeLine.editable = false#true
		oXSizeLine.hint_tooltip = ""
		oYSizeLine.hint_tooltip = ""
	


func _on_QuickNoisePreview_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			noise.seed = randi()
			update_border_image_with_noise()



func _on_NewMapSymmetricalBorder_item_selected(index):
	update_border_image_with_noise()

func apply_symmetry():
	if oNewMapSymmetricalBorder.selected == 0: return
	
	var w = imageData.get_width()
	var h = imageData.get_height()
	# Based on whether the map's size is even or odd, adjust the placement slightly.
	var half_w = floor(w*0.5)
	var half_h = floor(h*0.5)
	var half_w_ceil = ceil(w*0.5)
	var half_h_ceil = ceil(h*0.5)
	
	# Note: center pixel won't be mirrored on an odd sized map.
	
	match oNewMapSymmetricalBorder.selected:
		1: # Vertical symmetry
			var imageTopHalf = imageData.get_rect(Rect2(0, 0, w, half_h))
			
			imageData.fill(Color(1,0,0,1))
			imageData.blit_rect(imageTopHalf, Rect2(0, 0, w, half_h), Vector2(0, 0))
			
			imageTopHalf.flip_y()
			imageData.blit_rect(imageTopHalf, Rect2(0, 0, w, half_h), Vector2(0, half_h_ceil))
		2: # Vertical symmetry flipped
			var imageTopHalf = imageData.get_rect(Rect2(0, 0, w, half_h))
			imageData.fill(Color(1,0,0,1))
			imageData.blit_rect(imageTopHalf, Rect2(0, 0, w, half_h), Vector2(0, 0))
			
			imageTopHalf.flip_y()
			imageTopHalf.flip_x()
			imageData.blit_rect(imageTopHalf, Rect2(0, 0, w, half_h), Vector2(0, half_h_ceil))
		3: # Horizontal symmetry
			var imageLeftHalf = imageData.get_rect(Rect2(0, 0, half_w, h))
			imageData.fill(Color(1,0,0,1))
			imageData.blit_rect(imageLeftHalf, Rect2(0, 0, half_w, h), Vector2(0, 0))
			
			imageLeftHalf.flip_x()
			imageData.blit_rect(imageLeftHalf, Rect2(0, 0, half_w, h), Vector2(half_w_ceil, 0))
		4: # Horizontal symmetry flipped
			var imageLeftHalf = imageData.get_rect(Rect2(0, 0, half_w, h))
			
			imageData.fill(Color(1,0,0,1))
			imageData.blit_rect(imageLeftHalf, Rect2(0, 0, half_w, h), Vector2(0, 0))
			
			imageLeftHalf.flip_x()
			imageLeftHalf.flip_y()
			imageData.blit_rect(imageLeftHalf, Rect2(0, 0, half_w, h), Vector2(half_w_ceil, 0))
		5: # 4-way symmetry
			var imageTopLeft = imageData.get_rect(Rect2(0, 0, half_w, half_h))
			imageData.fill(Color(1,0,0,1))
			
			imageData.blit_rect(imageTopLeft, Rect2(0, 0, half_w, half_h), Vector2(0, 0))
			
			imageTopLeft.flip_x()
			imageData.blit_rect(imageTopLeft, Rect2(0, 0, half_w, half_h), Vector2(half_w_ceil, 0))
			
			imageTopLeft.flip_x() # Flips back so it's normal again
			imageTopLeft.flip_y()
			imageData.blit_rect(imageTopLeft, Rect2(0, 0, half_w, half_h), Vector2(0, half_h_ceil))
			
			imageTopLeft.flip_x()
			imageData.blit_rect(imageTopLeft, Rect2(0, 0, half_w, half_h), Vector2(half_w_ceil, half_h_ceil))
			
			if half_w != half_w_ceil or half_h != half_h_ceil:
				imageData.lock()
				imageData.set_pixel(half_w, half_h, Color(1,1,1,1))
				imageData.unlock()
	
	
	imageData.lock()
	
	for y in range(0, h):
		for x in range(0, w):
			if imageData.get_pixel(x,y) == Color(1,0,0,1):
				
				if imageData.get_pixel(x, max(y-1,0)) == Color(1,1,1,1) and imageData.get_pixel(x, min(y+1,h-1)) == Color(1,1,1,1):
					imageData.set_pixel(x, y, Color(1,1,1,1))
					continue
				if imageData.get_pixel(max(x-1,0), y) == Color(1,1,1,1) and imageData.get_pixel(min(x+1,w-1), y) == Color(1,1,1,1):
					imageData.set_pixel(x, y, Color(1,1,1,1))
					continue
				
				imageData.set_pixel(x, y, Color(0,0,0,1))
	
	imageData.unlock()



# This is for dev purposes
func _on_XSizeLine_gui_input(event):
	event_on_map_size_fields(event)
func _on_YSizeLine_gui_input(event):
	event_on_map_size_fields(event)
func event_on_map_size_fields(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_MIDDLE:
			oXSizeLine.editable = true
			oYSizeLine.editable = true
		if event.button_index == BUTTON_LEFT:
			if oXSizeLine.editable == false or oYSizeLine.editable == false:
				oMessage.big("Disabled", "Big maps are disabled until a game-breaking pathfinding bug is fixed. If you think you can help solve this bug, head on over to KeeperFX's github or the discord.")
