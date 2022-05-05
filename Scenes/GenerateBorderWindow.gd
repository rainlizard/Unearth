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

var noise = OpenSimplexNoise.new()

func _process(delta):
	if visible == false: return
	
	noise.octaves = oNoiseOctaves.value
	noise.period = oNoisePeriod.value
	noise.persistence = oNoisePersistence.value
	noise.lacunarity = oNoiseLacunarity.value

func _on_NoiseButtonApply_pressed():
	var CODETIME_START = OS.get_ticks_msec()
	
	# If a map is open, then clear it (remove objects and ownership and such)
	if oCurrentMap.path != "":
		oCurrentMap._on_ButtonNewMap_pressed()
	
	# If field is black (no map has been opened), then we need something to start with
	if oDataClm.cubes.empty() == true:
		oCurrentMap._on_ButtonNewMap_pressed()
	
	# Make fully rock and clear previous
	for x in range(1, 84):
		for y in range(1, 84):
			oDataSlab.set_cell(x,y, Slabs.ROCK)
	
	randomize()
	noise.seed = randi()
	
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
	
	var CODETIMEFLOODFILL = OS.get_ticks_msec()
	while coordsToCheck.size() > 0:
		var coord = coordsToCheck.pop_back()
		if floodFillTileMap.get_cellv(coord) == 1:
			floodFillTileMap.set_cellv(coord, 0)
			
			oDataSlab.set_cellv(coord, Slabs.EARTH)
			
			coordsToCheck.append(coord + Vector2(0,1))
			coordsToCheck.append(coord + Vector2(0,-1))
			coordsToCheck.append(coord + Vector2(1,0))
			coordsToCheck.append(coord + Vector2(-1,0))
	
	print('Floodfill time: ' + str(OS.get_ticks_msec() - CODETIMEFLOODFILL) + 'ms')
	
	oSlabPlacement.generate_slabs_based_on_id(Vector2(0,0), Vector2(84,84), false)
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func _on_ButtonBlankMap_pressed():
	oCurrentMap._on_ButtonNewMap_pressed()


func _on_NewMapCloseButton_pressed():
	visible = false
