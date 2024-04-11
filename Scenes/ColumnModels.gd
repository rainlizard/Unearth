extends Node
#onready var oDataClmPos = Nodelist.list["oDataClmPos"]
#onready var oDataClm = Nodelist.list["oDataClm"]
#onready var oMeshData = Nodelist.list["oMeshData"]
#onready var oGame3D = Nodelist.list["oGame3D"]
#

#var tempArrays = [] #tempvar
#var meshArrays = [] #tempvar
#var columnMeshArrays = []
#
#enum {NORTH, EAST, SOUTH, WEST, TOP, BOTTOM}
#
#func UNUSED_ready():
#	yield(get_tree(),'idle_frame')
#
#	var CODETIME_START = OS.get_ticks_msec()
#
#
#	#columnModels.resize(2048)
#	columnMeshArrays.resize(2048)
#
#	tempArrays.resize(Mesh.ARRAY_MAX)
#
#	for idx in 2048:
#		if oDataClm.solidMask[idx] > 0: # DON'T USE SOLID MASK LIKE THIS!!!!!!!!!!!!!!!!!!!!!!!!
#			var faceCountPerMesh = 0
#			tempArrays[Mesh.ARRAY_INDEX] = []
#			tempArrays[Mesh.ARRAY_VERTEX] = []
#			tempArrays[Mesh.ARRAY_TEX_UV] = []
#			tempArrays[Mesh.ARRAY_TEX_UV2] = []
#			tempArrays[Mesh.ARRAY_NORMAL] = []
#			var cubeList = oDataClm.cubes[idx]
#			for y in 8:
#				var cubeID = cubeList[y]
#				if cubeID != 0:
#					add_face(Vector3(0,y,0),NORTH,cubeID,null,faceCountPerMesh)
#					faceCountPerMesh += 1
#					add_face(Vector3(0,y,0),EAST,cubeID,null,faceCountPerMesh)
#					faceCountPerMesh += 1
#					add_face(Vector3(0,y,0),SOUTH,cubeID,null,faceCountPerMesh)
#					faceCountPerMesh += 1
#					add_face(Vector3(0,y,0),WEST,cubeID,null,faceCountPerMesh)
#					faceCountPerMesh += 1
#					if y == 7:
#						add_face(Vector3(0,y,0),TOP,cubeID,null,faceCountPerMesh)
#						faceCountPerMesh += 1
#					else:
#						if cubeList[y+1] == 0:
#							add_face(Vector3(0,y,0),TOP,cubeID,null,faceCountPerMesh)
#							faceCountPerMesh += 1
#					if y == 0:
#						pass
#					else:
#						if cubeList[y-1] == 0:
#							add_face(Vector3(0,y,0),BOTTOM,cubeID,null,faceCountPerMesh)
#							faceCountPerMesh += 1
#
#			columnMeshArrays[idx] = tempArrays.duplicate(true) # Do I need duplicate here?????????
#	print('Column models : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
#
#	CODETIME_START = OS.get_ticks_msec()
#	tempArrays.clear()
#	tempArrays.resize(Mesh.ARRAY_MAX)
#
#	tempArrays[Mesh.ARRAY_INDEX] = []
#	tempArrays[Mesh.ARRAY_VERTEX] = []
#	tempArrays[Mesh.ARRAY_TEX_UV] = []
#	tempArrays[Mesh.ARRAY_TEX_UV2] = []
#	tempArrays[Mesh.ARRAY_NORMAL] = []
#
#	for z in 255:
#		for x in 255:
#			var idx = oDataClmPos.get_cell_clmpos(z,x)
#			if oDataClm.solidMask[idx] > 0: # DON'T USE SOLID MASK LIKE THIS!!!!!!!!!!!!!!!!!!!!!!!!
#				tempArrays[Mesh.ARRAY_INDEX].append_array(columnMeshArrays[idx][Mesh.ARRAY_INDEX])
#				tempArrays[Mesh.ARRAY_VERTEX].append_array(columnMeshArrays[idx][Mesh.ARRAY_VERTEX])
#				tempArrays[Mesh.ARRAY_TEX_UV].append_array(columnMeshArrays[idx][Mesh.ARRAY_TEX_UV])
#				tempArrays[Mesh.ARRAY_TEX_UV2].append_array(columnMeshArrays[idx][Mesh.ARRAY_TEX_UV2])
#				tempArrays[Mesh.ARRAY_NORMAL].append_array(columnMeshArrays[idx][Mesh.ARRAY_NORMAL])
#	print('Test column placement : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
#
#	CODETIME_START = OS.get_ticks_msec()
#	var generatedMesh = ArrayMesh.new()
#	meshArrays.resize(Mesh.ARRAY_MAX)
#	meshArrays[Mesh.ARRAY_INDEX] = PoolIntArray(tempArrays[Mesh.ARRAY_INDEX])
#	meshArrays[Mesh.ARRAY_VERTEX] = PoolVector3Array(tempArrays[Mesh.ARRAY_VERTEX])
#	meshArrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array(tempArrays[Mesh.ARRAY_TEX_UV])
#	meshArrays[Mesh.ARRAY_TEX_UV2] = PoolVector2Array(tempArrays[Mesh.ARRAY_TEX_UV2])
#	meshArrays[Mesh.ARRAY_NORMAL] = PoolVector3Array(tempArrays[Mesh.ARRAY_NORMAL])
#	generatedMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshArrays)
#	print('Finalize mesh : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
#
#func add_face(pos,side,cubeID,texOverride,totalFaces):
#	var sideArray = oMeshData.vertex[side]
#	tempArrays[Mesh.ARRAY_VERTEX].append_array([
#		pos + sideArray[0],
#		pos + sideArray[1],
#		pos + sideArray[2],
#		pos + sideArray[3],
#	])
#	var idx = totalFaces*4
#	tempArrays[Mesh.ARRAY_INDEX].append_array([
#		0+idx, 1+idx, 3+idx,
#		3+idx, 1+idx, 2+idx,
#	])
#
#	tempArrays[Mesh.ARRAY_TEX_UV].append_array(oMeshData.uv[side])
#
#	var texArrayIndex
#	if texOverride == null:
#		texArrayIndex = Cube.tex[cubeID][side]
#	else:
#		texArrayIndex = texOverride
#	tempArrays[Mesh.ARRAY_TEX_UV2].append_array([
#		Vector2(texArrayIndex, texArrayIndex),
#		Vector2(texArrayIndex, texArrayIndex),
#		Vector2(texArrayIndex, texArrayIndex),
#		Vector2(texArrayIndex, texArrayIndex),
#	])
#
#	tempArrays[Mesh.ARRAY_NORMAL].append_array(oMeshData.normal[side])











##########################################################################











#			meshArrays[Mesh.ARRAY_INDEX] = PoolIntArray(tempArrays[Mesh.ARRAY_INDEX])
#			meshArrays[Mesh.ARRAY_VERTEX] = PoolVector3Array(tempArrays[Mesh.ARRAY_VERTEX])
#			meshArrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array(tempArrays[Mesh.ARRAY_TEX_UV])
#			meshArrays[Mesh.ARRAY_TEX_UV2] = PoolVector2Array(tempArrays[Mesh.ARRAY_TEX_UV2])
#			meshArrays[Mesh.ARRAY_NORMAL] = PoolVector3Array(tempArrays[Mesh.ARRAY_NORMAL])
			
#	var generatedMesh = ArrayMesh.new()
#	generatedMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshArrays)
	
			#TERRAIN_MAT.set_shader_param("animationDatabase", load("res://Shaders/textureanimationdatabase.png"))
			#generatedMesh.surface_set_material(0,TERRAIN_MAT)
			#columnModels[idx] = generatedMesh

#var columnModels = []
#var multiMeshes = []

	#print(columnModels[idx])
	
	#oDataClm.update_all_utilized()
	
	#CODETIME_START = OS.get_ticks_msec()
	
#	var mmInstance = MultiMeshInstance.new()
#	var mm = MultiMesh.new()
#	mm.mesh = columnModels[5]
#	mm.transform_format = MultiMesh.TRANSFORM_3D
#	mm.instance_count = 255 * 255 #oDataClm.utilized[idx]
#	mmInstance.multimesh = mm
#	oGame3D.add_child(mmInstance)
	
#	for idx in 2048:
#		if columnModels[idx] != null:
#			pass
	
	#print('multi mesh instances : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')


				
				#var instanceNumber = multiMeshes[idx].instance_count-1
				#multiMeshes[idx].set_instance_transform(instanceNumber, Transform(Basis(), Vector3(z,x,0)))
#				var a = MeshInstance.new()
#				a.mesh = columnModels[idx]
#				oGame3D.add_child(a)
