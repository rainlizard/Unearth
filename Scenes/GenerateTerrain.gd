extends Node
onready var oVoxelGen = Nodelist.list["oVoxelGen"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oTerrainMesh = Nodelist.list["oTerrainMesh"]

var materialArray = []

func start():
	var CODETIME_START = OS.get_ticks_msec()
	var genArray = oVoxelGen.blankArray.duplicate(true)
	
	for x in 255:
		for z in 255:
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
			
			oVoxelGen.column_gen(genArray, x, z, clmIndex, surrClmIndex)
	
	oTerrainMesh.mesh = oVoxelGen.complete_mesh(genArray)
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func clear():
	pass

#	var CODETIME_TOTAL3D = OS.get_ticks_msec()
#	var CODETIME_FACES = OS.get_ticks_msec()
#	var CODETIME_START_ARRAY_INDEX = OS.get_ticks_msec()
#	print('Faces generated: ' + str(OS.get_ticks_msec() - CODETIME_FACES) + 'ms')
#	print('Calculated array index: ' + str(OS.get_ticks_msec() - CODETIME_START_ARRAY_INDEX) + 'ms')
#	print('Total 3D time: ' + str(OS.get_ticks_msec() - CODETIME_TOTAL3D) + 'ms')
