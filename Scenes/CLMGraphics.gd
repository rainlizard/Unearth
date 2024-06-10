extends TileMap
#
#onready var oDataClmPos = $'../../ReadData/GridColumnPositionData'
#onready var oColumn = $'../../ReadData/Column'
#const cubeTotal = 544
#
#func update_graphics():
#	var aaa = load("res://Cubes/TMAPA003.bmp")
#	#print(aaa.data)
#
#	print(aaa.data.layers[0])
#
#	#createTileSetInEditor() # EDITOR TOOL. ONLY RUN THIS ONCE TO CREATE THE TILESET.
#	var CODETIME_START = OS.get_ticks_msec()
#	tile_set = load("res://Cubes/CubeFaceTileSet.tres")
#	print('Loaded CubeFace TileSet in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
#
#	CODETIME_START = OS.get_ticks_msec()
#	for x in 255:
#		for y in 255:
#			var cubeFace
#
#			# clmIndex is a position inside the column_count column collection
#			var clmIndex = oDataClmPos.get_cell_clmpos(x,y)
#
#			# clmData is the 24 byte array.
#			var clmData = oDataClm.data[clmIndex]
#
#			#print(clmData)
#
#			# Get the cubeIDs from that array
#			var cubeID = oDataClm.getUppermostCube(clmData)
#			# Get the highest cubeID
#			if cubeID != 0:
#				# Get one of the 6 faces of the cube from the massive array of cube sides.
#				cubeFace = Cube.array[cubeID][Cube.SIDE_TOP]
#			else:
#				# Show floor texture because there were no cubes
#				cubeFace = oDataClm.getBase(clmData)
#
#			set_cell(x,y, cubeFace)
#
#			#set_cell(x,y,Random.randi_range(0,cubeTotal))
#
#	print('Set cells of CubeFace TileSet in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
#
#
#func createTileSetInEditor():
#	var texSheet = preload("res://Cubes/TMAPA003.bmp")
#	var sheetItemsX = 8
#	var sheetItemsY = 68
#
#	# For each cube, create a tile within the tileset
#	var ts = TileSet.new()
#	for i in cubeTotal:
#
#		# Convert index number to x y positions within sheet.
#		var y = i/sheetItemsX
#		var x = i-(y*sheetItemsX)
#
#		ts.create_tile(i)
#		ts.tile_set_texture(i,texSheet)
#		ts.tile_set_region(i, Rect2( x*32, y*32, 32, 32 ))
#		ts.tile_set_tile_mode(i,TileSet.ATLAS_TILE)
#
#	ResourceSaver.save("res://Cubes/CubeFaceTileSet.tres",ts)
