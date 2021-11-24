extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oSlabPalette = Nodelist.list["oSlabPalette"]

#enum {
#	COLUMN_FLOOR_MARKER = 0
#	COLUMN_WALL_MARKER = 1
#}

enum {
	RED = 0
	BLUE = 1
	GREEN = 2
	YELLOW = 3
	WHITE = 4
	NONE = 5
}
# Within each marker array, the cubes are arranged by owner
# Cube.ownedCube[Cube.FLOOR_MARKER][Cube.RED]
const ownedCube = [
	[192,193,194,195,199,198], # FLOOR_MARKER
	[67,68,69,70,71,4], # WALL_MARKER
	[382,422,423,424,426,425], # HEARTPORTAL_MARKER
	[393,427,428,429,431,430], # BARRACKS_FLAG
	[160,410,413,416,419,77], # BANNER_LEFT
	[161,411,414,417,420,77], # BANNER_MIDDLE
	[162,412,415,418,421,77], # BANNER_RIGHT
]
enum {
	FLOOR_MARKER = 0
	WALL_MARKER = 1
	HEARTPORTAL_MARKER = 2
	BARRACKS_FLAG = 3
	BANNER_LEFT = 4
	BANNER_MIDDLE = 5
	BANNER_RIGHT = 6
}

#var clmPal = []

#func make_owned_columns():
#
#	clmPal.resize(1)
#	clmPal[COLUMN_FLOOR_MARKER] = []
#	clmPal[COLUMN_FLOOR_MARKER].resize(6)
#
#	var slabVariation = 11 * 28
#	var subtile = 4
#
#	var clmIdx = oSlabPalette.assetDat[slabVariation][subtile]
#	var columnArray = oSlabPalette.assetClm[clmIdx]
#
#	for playerColour in 6:
#		var setCubeID = ownedCube[FLOOR_MARKER][playerColour]
#		var cubePosition = 0
#
#		# Construct
#		columnArray = columnArray.duplicate(true)
#		columnArray = oDataClm.construct_with_new_cube(columnArray, cubePosition, setCubeID)
#
#		# Index into oDataClm
#		var clmIndex = oDataClm.index_entry(columnArray)
#
#		# Put inside column palette
#		clmPal[COLUMN_FLOOR_MARKER][playerColour] = clmIndex
