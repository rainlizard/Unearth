extends Node
onready var oVoxelGen = Nodelist.list["oVoxelGen"]
onready var oMeshBlock = Nodelist.list["oMeshBlock"]

var materialArray = []

func start(clmIndex):
	var CODETIME_START = OS.get_ticks_msec()
	var genArray = oVoxelGen.blankArray.duplicate(true)
	
	var surrClmIndex = [-1,-1,-1,-1]
	oVoxelGen.column_gen(genArray, 0, 0, clmIndex, surrClmIndex)
	
	oMeshBlock.mesh = oVoxelGen.complete_mesh(genArray)
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
