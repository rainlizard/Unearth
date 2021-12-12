extends Node
onready var oMeshData = Nodelist.list["oMeshData"]
onready var oTerrainMesh = Nodelist.list["oTerrainMesh"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]

enum {
	GEN_MAP
	GEN_CLM
}

var GENERATED_TYPE = GEN_MAP
var materialArray = []

func start(genType):
	var CODETIME_TOTAL3D = OS.get_ticks_msec()
	
	var massiveArray = oMeshData.blankArray.duplicate(true)
	
	var CODETIME_FACES = OS.get_ticks_msec()
	for x in 255:
		for z in 255:
#			for dir in [Vector3(1,0,0), Vector3(0,0,1), Vector3(-1,0,0), Vector3(0,0,-1)]:
#				
#				if oDataClm.cubes[clmIndex] ==
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
			
			var cubeArray = oDataClm.cubes[clmIndex]
			for y in 8:
				var cubeID = cubeArray[y]
				if cubeID != 0:
					var pos = Vector3(x,y,z)
					
					for side in 4:
						var sideIdx = surrClmIndex[side]
						if oDataClm.cubes[sideIdx][y] == 0 or sideIdx == TileMap.INVALID_CELL:
							var textureID = Cube.tex[cubeID][side]
							add_face(massiveArray, pos, side, textureID)
					
					# Top face
					if y == 7 or cubeArray[y+1] == 0:
						var textureID = Cube.tex[cubeID][4]
						add_face(massiveArray, pos, 4, textureID)
					# Bottom face
					if y >= 1 and cubeArray[y-1] == 0:
						var textureID = Cube.tex[cubeID][5]
						add_face(massiveArray, pos, 5, textureID)
				else:
					if y == 0:
						# Place floor as a "top side" on cube position 0 minus 1
						var pos = Vector3(x,y-1,z)
						var textureID = oDataClm.floorTexture[clmIndex]
						add_face(massiveArray, pos, 4, textureID)
	
	print('Faces generated: ' + str(OS.get_ticks_msec() - CODETIME_FACES) + 'ms')
	
	# Calculate ARRAY_INDEX using the size of ARRAY_VERTEX/4
	var CODETIME_START_ARRAY_INDEX = OS.get_ticks_msec()
	calculate_array_index(massiveArray)
	print('Calculated array index: ' + str(OS.get_ticks_msec() - CODETIME_START_ARRAY_INDEX) + 'ms')
	
	var newMeshArray = temparray_to_mesharray(massiveArray)
	assign_generated_mesh(newMeshArray)
	
	print('Total 3D time: ' + str(OS.get_ticks_msec() - CODETIME_TOTAL3D) + 'ms')

func assign_generated_mesh(newMeshArray):
	var generatedMesh = ArrayMesh.new()
	generatedMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, newMeshArray)
	var mat = initialize_material()
	generatedMesh.surface_set_material(0, mat)
	oTerrainMesh.mesh = generatedMesh

func temparray_to_mesharray(tempArrays):
	var newMeshArray = []
	newMeshArray.resize(Mesh.ARRAY_MAX)
	newMeshArray[Mesh.ARRAY_INDEX] = PoolIntArray(tempArrays[Mesh.ARRAY_INDEX])
	newMeshArray[Mesh.ARRAY_VERTEX] = PoolVector3Array(tempArrays[Mesh.ARRAY_VERTEX])
	newMeshArray[Mesh.ARRAY_TEX_UV] = PoolVector2Array(tempArrays[Mesh.ARRAY_TEX_UV])
	newMeshArray[Mesh.ARRAY_TEX_UV2] = PoolVector2Array(tempArrays[Mesh.ARRAY_TEX_UV2])
	newMeshArray[Mesh.ARRAY_NORMAL] = PoolVector3Array(tempArrays[Mesh.ARRAY_NORMAL])
	return newMeshArray

func initialize_material():
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://Shaders/display_texture_3d.shader")
	mat.set_shader_param("dkTextureMap_Split_A", oTextureCache.cachedTextures[oDataLevelStyle.data][0])
	mat.set_shader_param("dkTextureMap_Split_B", oTextureCache.cachedTextures[oDataLevelStyle.data][1])
	mat.set_shader_param("animationDatabase", preload("res://Shaders/textureanimationdatabase.png"))
	return mat

func clear():
	pass

func add_face(array, pos, side, textureID):
	
	var sideArray = oMeshData.vertex[side]
	array[Mesh.ARRAY_VERTEX].append_array([
		pos + sideArray[0],
		pos + sideArray[1],
		pos + sideArray[2],
		pos + sideArray[3],
	])
	
	array[Mesh.ARRAY_TEX_UV].append_array(oMeshData.uv[side])
	
	var appendData = Vector2(textureID, textureID)
	array[Mesh.ARRAY_TEX_UV2].append_array([
		appendData,
		appendData,
		appendData,
		appendData,
	])
	
	array[Mesh.ARRAY_NORMAL].append_array(oMeshData.normal[side])

func calculate_array_index(massiveArray):
	var overallFaceIndex = 0
	var numberOfFaces = massiveArray[Mesh.ARRAY_VERTEX].size() / 4
	for i in numberOfFaces:
		massiveArray[Mesh.ARRAY_INDEX].append_array([
			0+overallFaceIndex, 1+overallFaceIndex, 3+overallFaceIndex,
			3+overallFaceIndex, 1+overallFaceIndex, 2+overallFaceIndex,
		])
		overallFaceIndex += 4
