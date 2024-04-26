extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oTerrainMesh = Nodelist.list["oTerrainMesh"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oGame3D = Nodelist.list["oGame3D"]

var blankArray = initalize_blank_array()

func column_gen(genArray, x, z, clmIndex, surrClmIndex, generateBottomFace, sourceDataClm):
	
	var cubeArray = sourceDataClm.cubes[clmIndex]
	for y in 8:
		var cubeID = cubeArray[y]
		if cubeID >= Cube.tex.size():
			break
		
		if cubeID != 0:
			var pos = Vector3(x,y,z)
			
			for side in 4:
				var sideIdx = surrClmIndex[side]
				if oDataClm.cubes[sideIdx][y] == 0 or sideIdx == TileMap.INVALID_CELL:
					var textureID = Cube.tex[cubeID][side]
					add_face(genArray, pos, side, textureID)
			
			# Top face
			if y == 7 or cubeArray[y+1] == 0:
				var textureID = Cube.tex[cubeID][4]
				add_face(genArray, pos, 4, textureID)
			
			# Bottom face
			if (y >= 1 and cubeArray[y-1] == 0) or (y == 0 and generateBottomFace == true):
				var textureID = Cube.tex[cubeID][5]
				add_face(genArray, pos, 5, textureID)
		else:
			if y == 0:
				# Place floor as a "top side" on cube position 0 minus 1
				var pos = Vector3(x,y-1,z)
				var textureID = sourceDataClm.floorTexture[clmIndex]
				add_face(genArray, pos, 4, textureID)

func complete_mesh(genArray):
	var generatedMesh = ArrayMesh.new()
	
	if genArray[Mesh.ARRAY_VERTEX].size() > 0:
		calculate_array_index(genArray)
		var newMeshArray = temparray_to_mesharray(genArray)
		generatedMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, newMeshArray)
		
		var mat = oGame3D.create_material(oDataLevelStyle.data)
		generatedMesh.surface_set_material(0, mat)
	
	return generatedMesh

func complete_slx_mesh(arrayOfArrays):
	var generatedMesh = ArrayMesh.new()
	
	oGame3D.create_material_array(arrayOfArrays.size())
	
	for i in arrayOfArrays.size():
		var genArray = arrayOfArrays[i]
		if genArray[Mesh.ARRAY_VERTEX].size() > 0:
			calculate_array_index(genArray)
			var newMeshArray = temparray_to_mesharray(genArray)
			generatedMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, newMeshArray)
			
			generatedMesh.surface_set_material(generatedMesh.get_surface_count()-1, oGame3D.materialArray[i])
	
	return generatedMesh


static func add_face(array, pos, side, textureID):
	var sideArray = vertex[side]
	array[Mesh.ARRAY_VERTEX].append_array([
		sideArray[0] + pos,
		sideArray[1] + pos,
		sideArray[2] + pos,
		sideArray[3] + pos,
	])
	
	array[Mesh.ARRAY_TEX_UV].append_array(uv[side])
	
	var appendData = Vector2(float((textureID >> 16) & 65535), float(textureID & 65535))
	array[Mesh.ARRAY_TEX_UV2].append_array([
		appendData,
		appendData,
		appendData,
		appendData,
	])
	
	array[Mesh.ARRAY_NORMAL].append_array(normal[side])

static func calculate_array_index(array): # Calculate ARRAY_INDEX using the size of ARRAY_VERTEX/4
	var numberOfFaces = array[Mesh.ARRAY_VERTEX].size() / 4
	
	var meshArrayIndex = []
	meshArrayIndex.resize(numberOfFaces*6)
	
	var overallFaceIndex = 0
	for i in numberOfFaces:
		var offset = (i*6)
		meshArrayIndex[0+offset] = 0+overallFaceIndex
		meshArrayIndex[1+offset] = 1+overallFaceIndex
		meshArrayIndex[2+offset] = 3+overallFaceIndex
		meshArrayIndex[3+offset] = 3+overallFaceIndex
		meshArrayIndex[4+offset] = 1+overallFaceIndex
		meshArrayIndex[5+offset] = 2+overallFaceIndex
		overallFaceIndex += 4

	array[Mesh.ARRAY_INDEX] = meshArrayIndex

static func initalize_blank_array():
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_INDEX] = []
	array[Mesh.ARRAY_VERTEX] = []
	array[Mesh.ARRAY_TEX_UV] = []
	array[Mesh.ARRAY_TEX_UV2] = []
	array[Mesh.ARRAY_NORMAL] = []
	return array

static func temparray_to_mesharray(tempArrays):
	var newMeshArray = []
	newMeshArray.resize(Mesh.ARRAY_MAX)
	newMeshArray[Mesh.ARRAY_INDEX] = PoolIntArray(tempArrays[Mesh.ARRAY_INDEX])
	newMeshArray[Mesh.ARRAY_VERTEX] = PoolVector3Array(tempArrays[Mesh.ARRAY_VERTEX])
	newMeshArray[Mesh.ARRAY_TEX_UV] = PoolVector2Array(tempArrays[Mesh.ARRAY_TEX_UV])
	newMeshArray[Mesh.ARRAY_TEX_UV2] = PoolVector2Array(tempArrays[Mesh.ARRAY_TEX_UV2])
	newMeshArray[Mesh.ARRAY_NORMAL] = PoolVector3Array(tempArrays[Mesh.ARRAY_NORMAL])
	return newMeshArray

const uv = [
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)], # North
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)], # East
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)], # South
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)], # West
	[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)], # Top
	[Vector2(1, 1), Vector2(0, 1), Vector2(0, 0), Vector2(1, 0)], # Bottom
]
const vertex = [
	[Vector3(1, 1, 0), Vector3(0, 1, 0), Vector3(0, 0, 0), Vector3(1, 0, 0)], # North
	[Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(1, 0, 0), Vector3(1, 0, 1)], # East
	[Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 0, 1), Vector3(0, 0, 1)], # South
	[Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(0, 0, 1), Vector3(0, 0, 0)], # West
	[Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 1)], # Top
	[Vector3(1, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(1, 0, 1)], # Bottom
]
const normal = [
	[Vector3(0, 0, -1), Vector3(0, 0, -1), Vector3(0, 0, -1), Vector3(0, 0, -1)], #North
	[Vector3(1, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 0)], # East
	[Vector3(0, 0, 1), Vector3(0, 0, 1), Vector3(0, 0, 1), Vector3(0, 0, 1)], # South
	[Vector3(-1, 0, 0), Vector3(-1, 0, 0), Vector3(-1, 0, 0), Vector3(-1, 0, 0)], # West
	[Vector3(0, 1, 0), Vector3(0, 1, 0), Vector3(0, 1, 0), Vector3(0, 1, 0)], # Top
	[Vector3(0, -1, 0), Vector3(0, -1, 0), Vector3(0, -1, 0), Vector3(0, -1, 0)], # Bottom
]
