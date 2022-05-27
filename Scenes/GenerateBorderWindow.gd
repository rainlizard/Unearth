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

var noise = OpenSimplexNoise.new()
var imageData = Image.new()
var textureData = ImageTexture.new()

const earthColour = Color8(255,255,255,255)#Color8(36,24,0,255)
const impenetrableColour = Color8(0,0,0,255)

func _ready():
	imageData.create(85, 85, false, Image.FORMAT_RGB8)
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
	for x in range(1, 84):
		for y in range(1, 84):
			match imageData.get_pixel(x,y):
				impenetrableColour: oDataSlab.set_cell(x, y, Slabs.ROCK)
				earthColour: oDataSlab.set_cell(x, y, Slabs.EARTH)
	imageData.unlock()
	oSlabPlacement.generate_slabs_based_on_id(Vector2(0,0), Vector2(84,84), false)

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

func _on_NoiseUpdateTimer_timeout():
	update_border_image_with_noise()

func update_border_image_with_noise():
	var NOISECODETIME = OS.get_ticks_msec()
	noise.octaves = oNoiseOctaves.value
	noise.period = oNoisePeriod.value
	noise.persistence = oNoisePersistence.value
	noise.lacunarity = oNoiseLacunarity.value
	
	var fullMapSize = 84.0 #84.0
	var halfMapSize = fullMapSize * 0.5
	var mapCenter = Vector2(halfMapSize,halfMapSize)
	
	#var positionsArray = []
	
	var floodFillTileMap = TileMap.new()
	
	for x in range(1, 84):
		for y in range(1, 84):
			var edgeDistPercent = 1.0 - (max(abs(x-mapCenter.x), abs(y-mapCenter.y)) / halfMapSize)
			if abs(noise.get_noise_2d(x/fullMapSize, y/fullMapSize)) < edgeDistPercent:
				floodFillTileMap.set_cell(x,y,1)
	
	var coordsToCheck = [Vector2(42,42)]
	
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
	for x in 85:
		for y in 85:
			if x == 0 or x == 84 or y == 0 or y == 84:
				imageData.set_pixel(x,y, impenetrableColour)
	imageData.unlock()
	textureData.set_data(imageData)


func _on_CheckBoxNewMapBorder_pressed():
	oNewMapBorderOptions.visible = true
	update_border_image_with_noise()

func _on_CheckBoxNewMapBlank_pressed():
	oNewMapBorderOptions.visible = false
	update_border_image_with_blank()
