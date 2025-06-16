extends Node

onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oNoiseOctaves = Nodelist.list["oNoiseOctaves"]
onready var oNoisePeriod = Nodelist.list["oNoisePeriod"]
onready var oNoisePersistence = Nodelist.list["oNoisePersistence"]
onready var oNoiseLacunarity = Nodelist.list["oNoiseLacunarity"]
onready var oXSizeLine = Nodelist.list["oXSizeLine"]
onready var oYSizeLine = Nodelist.list["oYSizeLine"]
onready var oNoiseDistance = Nodelist.list["oNoiseDistance"]
onready var oRandomPlayers = Nodelist.list["oRandomPlayers"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]

var noise = OpenSimplexNoise.new()
var algorithmType = 1

const earthColour = Color(36.0/255.0, 24.0/255.0, 0.0/255.0, 1.0)
const impenetrableColour = Color(0.0, 0.0, 0.0, 1.0)


func _ready():
	randomize()
	noise.seed = randi()


func fill_entire_map_with_earth():
	for y in range(1, M.ySize-1):
		for x in range(1, M.xSize-1):
			oDataSlab.set_cell(x, y, Slabs.EARTH)


func convert_pixels_to_slabs(imageData):
	imageData.lock()
	
	for y in range(1, M.ySize-1):
		for x in range(1, M.xSize-1):
			var pixelColor = imageData.get_pixel(x,y)
			var isPlayerColor = false
			
			for i in range(Constants.ownerRoomCol.size()):
					if pixelColor == Constants.ownerRoomCol[i]:
						# ownerRoomCol pixels represent dungeon hearts
						oDataSlab.set_cell(x, y, Slabs.DUNGEON_HEART)
						oDataOwnership.set_cellv_ownership(Vector2(x, y), i)
						isPlayerColor = true
						break
					elif pixelColor == Constants.ownerFloorCol[i]:
						# ownerFloorCol pixels represent claimed ground
						oDataSlab.set_cell(x, y, Slabs.CLAIMED_GROUND)
						oDataOwnership.set_cellv_ownership(Vector2(x, y), i)
						isPlayerColor = true
						break
			
			if isPlayerColor == false:
				match pixelColor:
					impenetrableColour: oDataSlab.set_cell(x, y, Slabs.ROCK)
					earthColour: oDataSlab.set_cell(x, y, Slabs.EARTH)
	imageData.unlock()


func update_border_image_with_noise(imageData, textureData):
	var NOISECODETIME = OS.get_ticks_msec()
	var borderDist = oNoiseDistance.value
	noise.period = (oNoisePeriod.max_value - oNoisePeriod.value) + (0.01)
	noise.persistence = (oNoisePersistence.max_value - oNoisePersistence.value)
	noise.lacunarity = oNoiseLacunarity.value
	noise.octaves = oNoiseOctaves.value
	
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
	
	print('Border image time: ' + str(OS.get_ticks_msec() - NOISECODETIME) + 'ms')


func update_border_image_with_blank(imageData, textureData):
	imageData.fill(earthColour)
	imageData.lock()
	
	var fullMapSize = Vector2(oXSizeLine.text.to_int(), oYSizeLine.text.to_int())
	
	for x in fullMapSize.x:
		for y in fullMapSize.y:
			if x == 0 or x == fullMapSize.x-1 or y == 0 or y == fullMapSize.y-1:
				imageData.set_pixel(x,y, impenetrableColour)
	imageData.unlock()


func remove_isolated_earth_slabs(imageData):
	var w = imageData.get_width()
	var h = imageData.get_height()
	var centerX = w * 0.5
	var centerY = h * 0.5
	var tempColor = Color(1, 0, 0, 1)
	var potentialPlayerColour = Color(1.0, 0.0, 1.0, 1.0)
	var coordsToCheck = []
	var magentaPositions = []
	imageData.lock()
	for y in range(h):
		for x in range(w):
			if imageData.get_pixel(x, y) == potentialPlayerColour:
				magentaPositions.append(Vector2(x, y))
				imageData.set_pixel(x, y, earthColour)
	var centerPixels = [
		Vector2(int(centerX), int(centerY)),
		Vector2(int(centerX), int(centerY) + 1),
		Vector2(int(centerX), int(centerY) - 1),
		Vector2(int(centerX) + 1, int(centerY)),
		Vector2(int(centerX) - 1, int(centerY))
	]
	for centerPixel in centerPixels:
		if centerPixel.x >= 0 and centerPixel.x < w and centerPixel.y >= 0 and centerPixel.y < h:
			if imageData.get_pixel(centerPixel.x, centerPixel.y) == earthColour:
				coordsToCheck.append(centerPixel)
	while coordsToCheck.size() > 0:
		var coord = coordsToCheck.pop_back()
		if coord.x < 0 or coord.x >= w or coord.y < 0 or coord.y >= h:
			continue
		if imageData.get_pixel(coord.x, coord.y) != earthColour:
			continue
		imageData.set_pixel(coord.x, coord.y, tempColor)
		coordsToCheck.append(coord + Vector2(0, 1))
		coordsToCheck.append(coord + Vector2(0, -1))
		coordsToCheck.append(coord + Vector2(1, 0))
		coordsToCheck.append(coord + Vector2(-1, 0))
	for y in range(h):
		for x in range(w):
			if imageData.get_pixel(x, y) == earthColour:
				imageData.set_pixel(x, y, impenetrableColour)
			elif imageData.get_pixel(x, y) == tempColor:
				imageData.set_pixel(x, y, earthColour)
	for magentaPos in magentaPositions:
		imageData.set_pixel(magentaPos.x, magentaPos.y, potentialPlayerColour)
	imageData.unlock()


 
