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

# Matches KeeperFX's make_solidmask(): one bit per filled cube
func calculate_solid_mask(cubeArray):
	var setSolidBitmask:int = 0
	for i in 8:
		if cubeArray[i] != 0:
			setSolidBitmask |= 1 << i
	return setSolidBitmask

# Matches KeeperFX's create_column(): 0 when nothing sits above the floor stack's gap,
# otherwise 7 minus the lowest filled index from 1 upwards (KeeperFX counts floor cubes above the bottom one too)
func calculate_lintel(cubeArray):
	if get_highest_cube_height(cubeArray) > get_height_from_bottom(cubeArray):
		for i in range(1, 8):
			if cubeArray[i] != 0:
				return 7 - i
	return 0

# KeeperFX's create_column() and init_columns() overwrite the stored height and lintel with values derived from the cubes
func update_height_and_lintel(index):
	self.height[index] = get_height_from_bottom(self.cubes[index])
	self.lintel[index] = calculate_lintel(self.cubes[index])

# For map columns, init_columns() also derives the solid mask, which find_cubearray_index() relies on
func update_derived_values(index):
	self.solidMask[index] = calculate_solid_mask(self.cubes[index])
	update_height_and_lintel(index)

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
	resize_column_arrays(0)

# Resizes every column array to column_count, blanking entries from keepCount onwards
func resize_column_arrays(keepCount):
	for array in [self.utilized, self.orientation, self.solidMask, self.permanent, self.lintel, self.height, self.floorTexture, self.cubes]:
		array.resize(self.column_count)
	for i in range(keepCount, self.column_count):
		delete_column(i) # Gives each entry its own cubes array, fill() would share one


# Matches KeeperFX's find_column(): cubes, floor texture (used for ceilings and abyss even under cubes), solid mask and orientation.
# Height and lintel aren't compared, KeeperFX derives them from the cubes.
func find_cubearray_index(cubeArray, floorID):
	var expectedSolidMask = calculate_solid_mask(cubeArray)
	var idx = self.cubes.find(cubeArray, 1) # Skip 1st entry which should remain 0
	while idx != -1 and not (self.floorTexture[idx] == floorID and self.solidMask[idx] == expectedSolidMask and self.orientation[idx] == 0):
		idx = self.cubes.find(cubeArray, idx+1)
	return idx

# A free slot for a new column: no cubes and no floor texture, other leftover values get overwritten
func find_empty_column():
	var idx = self.cubes.find([0,0,0,0, 0,0,0,0], 1)
	while idx != -1 and self.floorTexture[idx] != 0:
		idx = self.cubes.find([0,0,0,0, 0,0,0,0], idx+1)
	return idx

func get_top_cube_face(clmIndex):
	var cubeArray = self.cubes[clmIndex]
	for i in range(7, -1, -1):
		var cubeID = cubeArray[i]
		if cubeID != 0:
			return Cube.tex[cubeID][Cube.SIDE_TOP] if cubeID <= Cube.CUBES_COUNT else 1
	return self.floorTexture[clmIndex]


