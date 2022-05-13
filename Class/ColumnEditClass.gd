extends Node

# Class is used by both DkClm and DataClm

func get_real_height(cubeArray):
	for cubeNumber in 8:
		if cubeArray[7-cubeNumber] != 0:
			return 8-cubeNumber
	return 0

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

func delete_column(index):
	self.utilized[index] = 0
	self.orientation[index] = 0
	self.solidMask[index] = 0
	self.permanent[index] = 0
	self.lintel[index] = 0
	self.height[index] = 0
	self.cubes[index] = [0,0,0,0, 0,0,0,0]
	self.floorTexture[index] = 0

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
