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

var noise = OpenSimplexNoise.new()
var imageData = Image.new()
var textureData = ImageTexture.new()

const earthColour = Color8(255,255,255,255)#Color8(36,24,0,255)
const impenetrableColour = Color8(0,0,0,255)

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
	
	oQuickNoisePreview.rect_size = oQuickNoisePreview.rect_min_size

func _on_NewMapWindow_visibility_changed():
	if visible == true:
		oXSizeLine.text = "85"
		oYSizeLine.text = "85"
		reinit_noise_preview()
		
		randomize()
		noise.seed = randi()
		update_border_image_with_noise()

func _on_ButtonNewMapOK_pressed():
	oCurrentMap._on_ButtonNewMap_pressed()
	
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
	
	oSlabPlacement.generate_slabs_based_on_id(Vector2(0,0), Vector2(M.xSize-1,M.ySize-1), false)
	
	visible = false # Close New Map window after pressing OK button

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
func _on_YSizeLine_text_changed(new_text):
	if new_text.to_int() > 500:
		oYSizeLine.text = "500"
	reinit_noise_preview()
	oNoiseUpdateTimer.start(0.01)
func _on_XSizeLine_text_changed(new_text):
	if new_text.to_int() > 500:
		oXSizeLine.text = "500"
	reinit_noise_preview()
	oNoiseUpdateTimer.start(0.01)


func _on_NoiseUpdateTimer_timeout():
	update_border_image_with_noise()

func update_border_image_with_noise():
	var NOISECODETIME = OS.get_ticks_msec()
	noise.octaves = oNoiseOctaves.value
	noise.period = oNoisePeriod.value
	noise.persistence = oNoisePersistence.value
	noise.lacunarity = oNoiseLacunarity.value
	
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
	for x in range(1, fullMapSize.x):
		for y in range(1, fullMapSize.y):
			edgeDist.x = 1.0 - (abs(x-halfMapSize.x) / halfMapSize.x)
			edgeDist.y = 1.0 - (abs(y-halfMapSize.y) / halfMapSize.y)
			
			var n = abs(noise.get_noise_2d( (x/fullMapSize.x)*aspectRatio.x, (y/fullMapSize.y)*aspectRatio.y ))
			
			if n < edgeDist.x and n < edgeDist.y:
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
	oNewMapNoiseOptions.visible = true
	update_border_image_with_noise()

func _on_CheckBoxNewMapBlank_pressed():
	oNewMapNoiseOptions.visible = false
	update_border_image_with_blank()
