extends Node

# Class is used by both DkClm and DataClm

func get_highest_cube_height(cubeArray):
	for cubeNumber in 8:
		if cubeArray[7-cubeNumber] != 0:
			return 8-cubeNumber
	return 0

func get_height_from_bottom(cubeArray):
	for cubeNumber in 8:
		if cubeArray[cubeNumber] == 0:
			return cubeNumber
	return 8

func calculate_solid_mask(cubeArray):
	# For each cube value that isn't 0, add a bitmask value.
	# 0 = 1
	# 1 = 2
	# 2 = 4
	# 3 = 8
	# 4 = 16
	# 5 = 32
	# 6 = 64
	# 7 = 128
	var setSolidBitmask:int = 0
	for i in 8:
		if cubeArray[i] != 0:
			setSolidBitmask += int(pow(2, i))
	return setSolidBitmask

func calculate_lintel(cubeArray):
	var holeCount = 0
	# Scan from top to bottom (index 7 to 0)
	for cubeNumber in range(7, -1, -1):
		if cubeArray[cubeNumber] == 0:
			holeCount += 1
			if holeCount == 2:
				# Found the 2nd hole, return the position of the cube above it
				# The cube above this hole is at cubeNumber + 1
				var cubePosition = cubeNumber + 1
				var reversedCubePosition = 7 - cubePosition
				return reversedCubePosition
	# If we don't find a 2nd hole, return 0 as default
	return 0

func delete_column(index):
	self.utilized[index] = 0
	self.orientation[index] = 0
	self.solidMask[index] = 0
	self.permanent[index] = 0
	self.lintel[index] = 0
	self.height[index] = 0
	self.cubes[index] = [0,0,0,0, 0,0,0,0]
	self.floorTexture[index] = 0

func copy_column(indexSrc, indexDest):
	self.utilized[indexDest] = 0
	self.orientation[indexDest] = self.orientation[indexSrc]
	self.solidMask[indexDest] = self.solidMask[indexSrc]
	self.permanent[indexDest] = self.permanent[indexSrc]
	self.lintel[indexDest] = self.lintel[indexSrc]
	self.height[indexDest] = self.height[indexSrc]
	self.cubes[indexDest] = self.cubes[indexSrc].duplicate(true)
	self.floorTexture[indexDest] = self.floorTexture[indexSrc]

func clear_all_column_data():
	self.utilized.resize(self.column_count)
	self.utilized.fill(0)
	self.orientation.resize(self.column_count)
	self.orientation.fill(0)
	self.solidMask.resize(self.column_count)
	self.solidMask.fill(0)
	self.permanent.resize(self.column_count)
	self.permanent.fill(0)
	self.lintel.resize(self.column_count)
	self.lintel.fill(0)
	self.height.resize(self.column_count)
	self.height.fill(0)
	self.floorTexture.resize(self.column_count)
	self.floorTexture.fill(0)
	self.cubes.resize(self.column_count)
	for i in self.column_count:
		self.cubes[i] = [0,0,0,0, 0,0,0,0] # Don't use fill(), that doesn't work
	

func find_cubearray_index(cubeArray, floorID):
	var compareFloorTexture = false
	# If the lowest cube is missing that means the floor is visible, therefore the floor should be compared too
	if cubeArray[0] == 0:
		compareFloorTexture = true
	
	var searchFrom = 1 # Skip 1st entry which should remain 0
	while true:
		var idx = self.cubes.find(cubeArray, searchFrom)
		if idx != -1:
			# Matching cubes were found, should the floor texture be compared now?
			if compareFloorTexture == true:
				if self.floorTexture[idx] == floorID:
					# Found matching cubes and matching floor
					return idx
				else:
					# Did not find matching floor with matching cubes, so search again starting from the next entry
					searchFrom = idx+1
			else:
				# Found matching cubes, floor is irrelevant
				return idx
		else:
			# Found no matching cubes
			break
	return -1

func get_top_cube_face(clmIndex):
	var cubeArray = self.cubes[clmIndex]
	for i in range(7, -1, -1):
		var cubeID = cubeArray[i]
		if cubeID != 0:
			return Cube.tex[cubeID][Cube.SIDE_TOP] if cubeID <= Cube.CUBES_COUNT else 1
	return self.floorTexture[clmIndex]


