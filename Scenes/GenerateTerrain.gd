extends Node
onready var oVoxelGen = Nodelist.list["oVoxelGen"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oTerrainMesh = Nodelist.list["oTerrainMesh"]
onready var oLoadingBar = Nodelist.list["oLoadingBar"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataClm = Nodelist.list["oDataClm"]


func start():
	var CODETIME_START = OS.get_ticks_msec()
	
	var arrayOfArrays = initialize_array_of_arrays()
	
	loading_bar_start()
	var updateLoad = 0
	
	for ySlab in 85:
		for xSlab in 85:
			var slabStyleValue = oDataSlx.get_tileset_value(xSlab,ySlab)
			
			# Loading bar
			if ySlab >= updateLoad:
				updateLoad += (85*0.10)
				oLoadingBar.value += 10
				yield(get_tree(),"idle_frame")
			
			for ySubtile in 3:
				for xSubtile in 3:
					var x = (xSlab*3) + xSubtile
					var z = (ySlab*3) + ySubtile
					
					var clmIndex = oDataClmPos.get_cell(x,z)
					
					var surrClmIndex = [
						oDataClmPos.get_cell(x,z-1),
						oDataClmPos.get_cell(x+1,z),
						oDataClmPos.get_cell(x,z+1),
						oDataClmPos.get_cell(x-1,z),
					]
					# Fix the edges
					if x+1 >= 255: surrClmIndex[1] = TileMap.INVALID_CELL
					if z+1 >= 255: surrClmIndex[2] = TileMap.INVALID_CELL
					
					oVoxelGen.column_gen(arrayOfArrays[slabStyleValue], x, z, clmIndex, surrClmIndex, false, oDataClm)
	
	loading_bar_end()
	
	oTerrainMesh.mesh = oVoxelGen.complete_slx_mesh(arrayOfArrays)
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func loading_bar_start():
	oLoadingBar.visible = true
	oLoadingBar.value = 0

func loading_bar_end():
	oLoadingBar.visible = false
	oLoadingBar.value = 0

func initialize_array_of_arrays():
	var arrayOfArrays = []
	var numberOfSlabStyles = oTextureCache.cachedTextures.size()+1
	for i in numberOfSlabStyles:
		arrayOfArrays.append(oVoxelGen.blankArray.duplicate(true))
	return arrayOfArrays

func clear():
	pass

#	var CODETIME_TOTAL3D = OS.get_ticks_msec()
#	var CODETIME_FACES = OS.get_ticks_msec()
#	var CODETIME_START_ARRAY_INDEX = OS.get_ticks_msec()
#	print('Faces generated: ' + str(OS.get_ticks_msec() - CODETIME_FACES) + 'ms')
#	print('Calculated array index: ' + str(OS.get_ticks_msec() - CODETIME_START_ARRAY_INDEX) + 'ms')
#	print('Total 3D time: ' + str(OS.get_ticks_msec() - CODETIME_TOTAL3D) + 'ms')
