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
onready var oNewMapBorderOptions = Nodelist.list["oNewMapBorderOptions"]
onready var oXSizeLine = Nodelist.list["oXSizeLine"]
onready var oYSizeLine = Nodelist.list["oYSizeLine"]

var noise = OpenSimplexNoise.new()
var imageData = Image.new()
var textureData = ImageTexture.new()

const earthColour = Color8(255,255,255,255)#Color8(36,24,0,255)
const impenetrableColour = Color8(0,0,0,255)

func _ready():
	reinit_noise_preview()

func reinit_noise_preview():
	imageData.create(oXSizeLine.text.to_int(), oYSizeLine.text.to_int(), false, Image.FORMAT_RGB8)
	textureData.create_from_image(imageData, 0)
	oQuickNoisePreview.texture = textureData

func _on_NewMapWindow_visibility_changed():
	if visible == true:
		randomize()
		noise.seed = randi()
		update_border_image_with_noise()

func _on_ButtonNewMapOK_pressed():
	oCurrentMap._on_ButtonNewMap_pressed()
	
	if oNewMapBorderOptions.visible == true:
		update_border_image_with_noise()
		overwrite_map_with_border_values()
	
	visible = false # Close New Map window after pressing OK button

func overwrite_map_with_border_values():
	imageData.lock()
	for y in range(1, oYSizeLine.text.to_int()-1):
		for x in range(1, oXSizeLine.text.to_int()-1):
		
			match imageData.get_pixel(x,y):
				impenetrableColour: oDataSlab.set_cell(x, y, Slabs.ROCK)
				earthColour: oDataSlab.set_cell(x, y, Slabs.EARTH)
	imageData.unlock()
	oSlabPlacement.generate_slabs_based_on_id(Vector2(0,0), Vector2(M.xSize-1,M.ySize-1), false)

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
	
	#var positionsArray = []
	
	var floodFillTileMap = TileMap.new()
	
	for x in range(1, fullMapSize.x):
		for y in range(1, fullMapSize.y):
			var edgeDistPercent = 1.0 - (max(abs(x-halfMapSize.x), abs(y-halfMapSize.y)) / min(halfMapSize.x,halfMapSize.y))
			if abs(noise.get_noise_2d(x/fullMapSize.x, y/fullMapSize.y)) < edgeDistPercent:
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
	for x in M.xSize:
		for y in M.ySize:
			if x == 0 or x == M.xSize-1 or y == 0 or y == M.ySize-1:
				imageData.set_pixel(x,y, impenetrableColour)
	imageData.unlock()
	textureData.set_data(imageData)


func _on_CheckBoxNewMapBorder_pressed():
	oNewMapBorderOptions.visible = true
	update_border_image_with_noise()

func _on_CheckBoxNewMapBlank_pressed():
	oNewMapBorderOptions.visible = false
	update_border_image_with_blank()

