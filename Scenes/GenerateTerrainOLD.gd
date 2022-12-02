extends Node
onready var oMeshData = Nodelist.list["oMeshData"]
onready var oTerrainMesh = Nodelist.list["oTerrainMesh"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oExtra3DInfo = Nodelist.list["oExtra3DInfo"]
onready var oSelector3D = Nodelist.list["oSelector3D"]
onready var oFloor = Nodelist.list["oFloor"]
onready var oLoadingBar = Nodelist.list["oLoadingBar"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataSlx = Nodelist.list["oDataSlx"]

var TERRAIN_SIZE_X
var TERRAIN_SIZE_Z
var TERRAIN_SIZE_Y
var blockMap = []
var meshInfo = []
#var tempMeshInfo = []
var tempArrays = []
var materialArray = []
var faceCount = []
var numberOfSlabStyles

enum {ARRAY_BLOCK_POSITION = 0, ARRAY_SIDE_COUNT = 1}
const EMPTY = 0

var CODETIME_START
var TOTALTIME_CODETIME_START

enum {
	GEN_MAP = 0
	GEN_CLM = 1
}
var GENERATED_TYPE = GEN_MAP

func start(genType):
	return #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	# The "+1" is to include the "Default" style.
	numberOfSlabStyles = oTextureCache.cachedTextures.size()+1
	
	
	match genType:
		"MAP":
			match GENERATED_TYPE:
				GEN_MAP: clear() #if blockMap.size() != 0: return # Disabling this for now to prevent misleading visuals
				GEN_CLM: clear()
			GENERATED_TYPE = GEN_MAP
			TERRAIN_SIZE_X = (M.xSize*3) # might need to swap xSize and ySize here
			TERRAIN_SIZE_Z = (M.ySize*3)
			TERRAIN_SIZE_Y = 8
			oFloor.visible = false
		"CLM":
			match GENERATED_TYPE:
				GEN_MAP: clear()
				GEN_CLM: clear() #if blockMap.size() != 0: return # Disabling this for now to prevent misleading visuals
			GENERATED_TYPE = GEN_CLM
			TERRAIN_SIZE_X = 32*2 # Width
			TERRAIN_SIZE_Z = 64*2 # Height
			TERRAIN_SIZE_Y = 8
			oFloor.visible = true

			
	oFloor.resize(TERRAIN_SIZE_X, TERRAIN_SIZE_Z)
	
	if oDataClm.cubes.size() == 0:
		print("!!!!! Cannot generate 3D view because oDataClm.data.size() == 0 !!!!!")
		return
	
	TOTALTIME_CODETIME_START = OS.get_ticks_msec()
	
	CODETIME_START = OS.get_ticks_msec()
	if GENERATED_TYPE == GEN_MAP: set_cube_id_with_column_position_data()
	elif GENERATED_TYPE == GEN_CLM: set_cube_id_to_clm_index()
	
	print('Set cubeID in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	faceCount.resize(numberOfSlabStyles)
	for i in faceCount.size():
		faceCount[i] = 0
	
	generation()

func generation():
	# Level 1000 won't display correctly when using an optimization technique.
	
	CODETIME_START = OS.get_ticks_msec()
	
#	tempMeshInfo.resize(2)
#	tempMeshInfo[ARRAY_BLOCK_POSITION] = []
#	tempMeshInfo[ARRAY_SIDE_COUNT] = []
	
	tempArrays.resize(numberOfSlabStyles)
	for i in tempArrays.size():
		tempArrays[i] = []
		tempArrays[i].resize(Mesh.ARRAY_MAX)
		tempArrays[i][Mesh.ARRAY_INDEX] = []
		tempArrays[i][Mesh.ARRAY_VERTEX] = []
		tempArrays[i][Mesh.ARRAY_TEX_UV] = []
		tempArrays[i][Mesh.ARRAY_TEX_UV2] = []
		tempArrays[i][Mesh.ARRAY_NORMAL] = []
	
	var slabStyleValue
	var updateLoad = 0
	oLoadingBar.visible = true
	oLoadingBar.value = 0
	
	for ySlab in TERRAIN_SIZE_Z/3: # I could write "85" but the columns viewer has a different size.
		
		if ySlab/float(TERRAIN_SIZE_Z/3) > updateLoad:
			updateLoad += 0.1
			oLoadingBar.value = updateLoad*100
			yield(get_tree(),"idle_frame")
		
		for xSlab in TERRAIN_SIZE_X/3: # I could write "85" but the columns viewer has a different size.
			if GENERATED_TYPE == GEN_MAP:
				slabStyleValue = oDataSlx.get_tileset_value(xSlab,ySlab)
			else:
				slabStyleValue = 0 # Use Default Dungeon Style for CLM view
			
			for ySubtile in 3:
				for xSubtile in 3:
					var x = (xSlab*3) + xSubtile
					var z = (ySlab*3) + ySubtile
					
					
					for y in TERRAIN_SIZE_Y:
						var cubeID = blockMap[x][z][y]
						if cubeID != EMPTY:
							faceCount[slabStyleValue] += face_loop(Vector3(x,y,z),cubeID, slabStyleValue)
						else:
							if y == 0: # Floor
								var pos = Vector3(x,y-1,z)
								var clmIndex
								if GENERATED_TYPE == GEN_MAP:
									clmIndex = oDataClmPos.get_cell(x,z)
								elif GENERATED_TYPE == GEN_CLM:
									if x/2 != x/2.0 or z/2 != z/2.0: continue #skips current loop
									clmIndex = ((z/2) * (TERRAIN_SIZE_X/2)) + (x/2)
									if clmIndex >= 2048: clmIndex = 0
								
								var floorID = oDataClm.floorTexture[clmIndex]
								add_face(pos, 4, cubeID, floorID, faceCount[slabStyleValue], slabStyleValue)
								
								faceCount[slabStyleValue] += 1

	print('Set Mesh Faces in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	CODETIME_START = OS.get_ticks_msec()
	
	if oTextureCache.cachedTextures.size() > 0:
		create_surface_materials()
	
	var generatedMesh = ArrayMesh.new()
	
	for i in tempArrays.size():
		var newMeshArray = []
		newMeshArray.resize(Mesh.ARRAY_MAX)
		newMeshArray[Mesh.ARRAY_INDEX] = PoolIntArray(tempArrays[i][Mesh.ARRAY_INDEX])
		newMeshArray[Mesh.ARRAY_VERTEX] = PoolVector3Array(tempArrays[i][Mesh.ARRAY_VERTEX])
		newMeshArray[Mesh.ARRAY_TEX_UV] = PoolVector2Array(tempArrays[i][Mesh.ARRAY_TEX_UV])
		newMeshArray[Mesh.ARRAY_TEX_UV2] = PoolVector2Array(tempArrays[i][Mesh.ARRAY_TEX_UV2])
		newMeshArray[Mesh.ARRAY_NORMAL] = PoolVector3Array(tempArrays[i][Mesh.ARRAY_NORMAL])
		if tempArrays[i][Mesh.ARRAY_INDEX].size() > 0:
			#print(tempArrays[2])
			generatedMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, newMeshArray)
			generatedMesh.surface_set_material(generatedMesh.get_surface_count()-1, materialArray[i])
	
	oTextureCache.set_current_texture_pack()
	
	oTerrainMesh.mesh = generatedMesh
	
	print('Finalized Mesh in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	print('Total time to generate terrain: '+str(OS.get_ticks_msec()-TOTALTIME_CODETIME_START)+'ms')
	
	oLoadingBar.visible = false


func set_cube_id_with_column_position_data():
	# clmIndex is a position inside the 2048 column collection
	# clmData is the 24 byte array.
	# Get the cubeIDs from that array
	
	blockMap.resize(TERRAIN_SIZE_X)
	for x in TERRAIN_SIZE_X:
		blockMap[x] = []
		blockMap[x].resize(TERRAIN_SIZE_Z)
		for z in TERRAIN_SIZE_Z:
			blockMap[x][z] = []
			blockMap[x][z].resize(TERRAIN_SIZE_Y)
			
			var clmIndex = oDataClmPos.get_cell(x,z)
			blockMap[x][z] = oDataClm.cubes[clmIndex] # Warning: this is probably a reference. But it probably doesn't matter.

func set_cube_id_to_clm_index():
	# clmIndex is a position inside the 2048 column collection
	# clmData is the 24 byte array.
	# "continue" skips current loop
	
	blockMap.resize(TERRAIN_SIZE_X)
	for x in TERRAIN_SIZE_X:
		blockMap[x] = []
		blockMap[x].resize(TERRAIN_SIZE_Z)
		for z in TERRAIN_SIZE_Z:
			blockMap[x][z] = []
			blockMap[x][z].resize(TERRAIN_SIZE_Y)
			
			for y in TERRAIN_SIZE_Y:
				blockMap[x][z][y] = EMPTY
			
			if x/2 != x/2.0 or z/2 != z/2.0: continue
			var clmIndex = ((z/2) * (TERRAIN_SIZE_X/2)) + (x/2)
			if clmIndex >= 2048: clmIndex = 0
			
			blockMap[x][z] = oDataClm.cubes[clmIndex] # Warning: this is probably a reference. But it probably doesn't matter.

func get_clm_index(x, z): # Used by ColumnDetails in clm view
	if int(x/2) != x/2.0 or int(z/2) != z/2.0: return null #skips current loop
	if x >= TERRAIN_SIZE_X: return null
	if z >= TERRAIN_SIZE_Z: return null
	var clmIndex = ((z/2) * (TERRAIN_SIZE_X/2)) + (x/2)
	if clmIndex >= 2048: clmIndex = 0
	return clmIndex


func create_surface_materials():
	materialArray.clear()
	# Slab styles
	for i in numberOfSlabStyles:
		var map = i-1
		if map == -1:
			map = oDataLevelStyle.data
		
		var mat = ShaderMaterial.new()
		mat.shader = preload("res://Shaders/display_texture_3d.shader")
		mat.set_shader_param("dkTextureMap_Split_A", oTextureCache.cachedTextures[map][0])
		mat.set_shader_param("dkTextureMap_Split_B", oTextureCache.cachedTextures[map][1])
		mat.set_shader_param("animationDatabase", preload("res://Shaders/textureanimationdatabase.png"))
		
		materialArray.append(mat)

func face_loop(pos, cubeID, slabStyleValue):
	var x = pos.x
	var y = pos.y
	var z = pos.z
	var countSides = 0
	
	if z == 0:
		add_face(pos, 0, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	elif blockMap[x][z-1][y] == EMPTY:
		add_face(pos, 0, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	
	if x == TERRAIN_SIZE_X-1:
		add_face(pos, 1, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	elif blockMap[x+1][z][y] == EMPTY:
		add_face(pos, 1, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	
	if z == TERRAIN_SIZE_Z-1:
		add_face(pos, 2, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	elif blockMap[x][z+1][y] == EMPTY:
		add_face(pos, 2, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	
	if x == 0:
		add_face(pos, 3, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	elif blockMap[x-1][z][y] == EMPTY:
		add_face(pos, 3, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	
	if y == TERRAIN_SIZE_Y-1:
		add_face(pos, 4, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	elif blockMap[x][z][y+1] == EMPTY:
		add_face(pos, 4, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	
	if y == 0:
		pass # Skip rendering bottom, for speed
#		add_face(pos, 5, cubeID, null, faceCount[slabStyleValue]+countSides)
#		countSides += 1
	elif blockMap[x][z][y-1] == EMPTY:
		add_face(pos, 5, cubeID, null, faceCount[slabStyleValue]+countSides, slabStyleValue)
		countSides += 1
	
	return countSides




#func getLocalBlockNorth(x,y,z):
#	if z < 0: return EMPTY
#	return blockMap[x][y][z]

#func getLocalBlockEast(x,y,z):
#	if x > TERRAIN_SIZE_X-1: return EMPTY
#	return blockMap[x][y][z]

#func getLocalBlockSouth(x,y,z):
#	if z > TERRAIN_SIZE_Z-1: return EMPTY
#	return blockMap[x][y][z]

#func getLocalBlockWest(x,y,z):
#	if x < 0: return EMPTY
#	return blockMap[x][y][z]

#func getLocalBlockTop(x,y,z):
#	if y > TERRAIN_SIZE_Y-1: return EMPTY
#	return blockMap[x][y][z]

#func getLocalBlockBottom(x,y,z):
#	if y < 0: return EMPTY
#	return blockMap[x][y][z]

func add_face(pos,side,cubeID,texOverride, faceNumber, slabStyleValue):
	
	var idx = faceNumber * 4
	tempArrays[slabStyleValue][Mesh.ARRAY_INDEX].append_array([
		0+idx, 1+idx, 3+idx,
		3+idx, 1+idx, 2+idx,
	])
	
	var sideArray = oMeshData.vertex[side]
	tempArrays[slabStyleValue][Mesh.ARRAY_VERTEX].append_array([
		pos + sideArray[0],
		pos + sideArray[1],
		pos + sideArray[2],
		pos + sideArray[3],
	])

	
	tempArrays[slabStyleValue][Mesh.ARRAY_TEX_UV].append_array(oMeshData.uv[side])
	
	var texArrayIndex
	if texOverride == null:
		texArrayIndex = Cube.tex[cubeID][side]
	else:
		texArrayIndex = texOverride
	tempArrays[slabStyleValue][Mesh.ARRAY_TEX_UV2].append_array([
		Vector2(texArrayIndex, texArrayIndex),
		Vector2(texArrayIndex, texArrayIndex),
		Vector2(texArrayIndex, texArrayIndex),
		Vector2(texArrayIndex, texArrayIndex),
	])
	
	tempArrays[slabStyleValue][Mesh.ARRAY_NORMAL].append_array(oMeshData.normal[side])
#	tempArrays[slabStyleValue][Mesh.ARRAY_NORMAL][faceCount[slabStyleValue]*4] = oMeshData.normal[side][0]
#	tempArrays[slabStyleValue][Mesh.ARRAY_NORMAL][(faceCount[slabStyleValue]*4)+1] = oMeshData.normal[side][1]
#	tempArrays[slabStyleValue][Mesh.ARRAY_NORMAL][(faceCount[slabStyleValue]*4)+2] = oMeshData.normal[side][2]
#	tempArrays[slabStyleValue][Mesh.ARRAY_NORMAL][(faceCount[slabStyleValue]*4)+3] = oMeshData.normal[side][3]

func clear():
	blockMap.clear()
	meshInfo.clear()
	#tempMeshInfo.clear()
	tempArrays.clear()
	faceCount.clear()

func get_block(pos):
	if pos.x < 0: return EMPTY
	if pos.x >= TERRAIN_SIZE_X: return EMPTY
	if pos.y < 0: return EMPTY
	if pos.y >= TERRAIN_SIZE_Y: return EMPTY
	if pos.z < 0: return EMPTY
	if pos.z >= TERRAIN_SIZE_Z: return EMPTY
	
	return blockMap[pos.x][pos.z][pos.y]
