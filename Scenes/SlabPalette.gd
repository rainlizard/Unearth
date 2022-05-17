extends Node
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDkDat = Nodelist.list["oDkDat"]
onready var oDkClm = Nodelist.list["oDkClm"]
onready var oDkTng = Nodelist.list["oDkTng"]
onready var oMessage = Nodelist.list["oMessage"]

enum dir {
	s = 0
	w = 1
	n = 2
	e = 3
	sw = 4
	nw = 5
	ne = 6
	se = 7
	all = 8
	center = 27
}

# 0 1 2
# 3 4 5
# 6 7 8

var CODETIME_START

# Randomized columns
#enum {
#	RNG_CLM_GOLD
#	RNG_CLM_GOLD_NEARBY_LAVA
#	RNG_CLM_GOLD_NEARBY_WATER
#	RNG_CLM_LAVA
#	RNG_CLM_DIRTPATH
#	RNG_CLM_GEMS
#	RNG_CLM_CLAIMED_AREA
#	RNG_CLM_LIBRARY
#	RNG_CLM_EARTH
#	RNG_CLM_EARTH_NEARBY_WATER
#	RNG_CLM_WALL
#	RNG_CLM_WALL_NEARBY_LAVA
#	RNG_CLM_WALL_NEARBY_WATER
#}
#var rngColumnsCubes = []
#var rngColumnsFloor = []

func start():
	# Do this only once.
	if oDkDat.dat.empty() == true: oDkDat.dat_asset()
	if oDkClm.cubes.empty() == true: oDkClm.clm_asset()
	if oDkTng.tngIndex.empty() == true: oDkTng.slabtng_assets()
	
	# Use this to show all the hidden slabs inside of slabs.clm, content unused by the game.
#	for slabvar in 1304:
#		for subtile in 9:
#			var clmIndex = oDkDat.dat[slabvar][subtile]
#			oDkClm.delete_column(clmIndex)
	#initialize_rng_columns()

#func initialize_rng_columns():
#	rngColumnsCubes.resize(RNG_CLM_WALL_NEARBY_WATER+1)
#	rngColumnsFloor.resize(RNG_CLM_WALL_NEARBY_WATER+1)
#	for i in RNG_CLM_WALL_NEARBY_WATER+1:
#		rngColumnsCubes[i] = []
#		rngColumnsFloor[i] = []
#
#	rng_get_gold(RNG_CLM_GOLD)
#	rng_get_gold_nearby_lava(RNG_CLM_GOLD_NEARBY_LAVA)
#	rng_get_gold_nearby_water(RNG_CLM_GOLD_NEARBY_WATER)
#	rng_get_lava(RNG_CLM_LAVA)
#	rng_get_dirtpath(RNG_CLM_DIRTPATH)
#	rng_get_gems(RNG_CLM_GEMS)
#	rng_get_claimed_area(RNG_CLM_CLAIMED_AREA)
#	rng_get_library(RNG_CLM_LIBRARY)
#	rng_get_earth(RNG_CLM_EARTH)
#	rng_get_earth_nearby_water(RNG_CLM_EARTH_NEARBY_WATER)
#	rng_get_wall(RNG_CLM_WALL)
#	rng_get_wall_nearby_lava(RNG_CLM_WALL_NEARBY_LAVA)
#	rng_get_wall_nearby_water(RNG_CLM_WALL_NEARBY_WATER)


#func get_random_column_array(RNG_CLM):
#	if randomColumns[RNG_CLM].empty() == true: # Only needs to do once!
#		match RNG_CLM:
#			RNG_CLM_GOLD:               randomColumns[RNG_CLM_GOLD] = rng_get_gold()
#			RNG_CLM_GOLD_NEARBY_LAVA:   randomColumns[RNG_CLM_GOLD_NEARBY_LAVA] = rng_get_gold_nearby_lava()
#			RNG_CLM_GOLD_NEARBY_WATER:  randomColumns[RNG_CLM_GOLD_NEARBY_WATER] = rng_get_gold_nearby_water()
#			RNG_CLM_LAVA:               randomColumns[RNG_CLM_LAVA] = rng_get_lava()
#			RNG_CLM_DIRTPATH:           randomColumns[RNG_CLM_DIRTPATH] = rng_get_dirtpath()
#			RNG_CLM_GEMS:               randomColumns[RNG_CLM_GEMS] = rng_get_gems()
#			RNG_CLM_CLAIMED_AREA:       randomColumns[RNG_CLM_CLAIMED_AREA] = rng_get_claimed_area()
#			RNG_CLM_LIBRARY:            randomColumns[RNG_CLM_LIBRARY] = rng_get_library()
#			RNG_CLM_EARTH:              randomColumns[RNG_CLM_EARTH] = rng_get_earth()
#			RNG_CLM_EARTH_NEARBY_WATER: randomColumns[RNG_CLM_EARTH_NEARBY_WATER] = rng_get_earth_nearby_water()
#			RNG_CLM_WALL:               randomColumns[RNG_CLM_WALL] = rng_get_wall()
#			RNG_CLM_WALL_NEARBY_LAVA:   randomColumns[RNG_CLM_WALL_NEARBY_LAVA] = rng_get_wall_nearby_lava()
#			RNG_CLM_WALL_NEARBY_WATER:  randomColumns[RNG_CLM_WALL_NEARBY_WATER] = rng_get_wall_nearby_water()
#
#	return randomColumns[RNG_CLM]

func test_write_to_file(data):
	print('WRITING TO CLM.TXT')
	var file = File.new()
	file.open("clm.txt", File.WRITE)
	for i in data:
		file.store_line(str(i))
	file.close()

#func rng_get_wall_nearby_lava(RNG_ENUM): # slabs.dat doesn't include these randomized columns, but the official editor does randomize them.
#	for variant1 in range(72, 74+1):
#		for variant2 in range(72, 74+1):
#			for variant3 in range(72, 74+1):
#				rngColumnsCubes[RNG_ENUM].append([
#					117,
#					variant1,
#					variant2,
#					variant3,
#					77,
#					0,
#					0,
#					0,
#				])
#				rngColumnsFloor[RNG_ENUM].append(27)
#
#func rng_get_wall_nearby_water(RNG_ENUM): # slabs.dat doesn't include these randomized columns, but the official editor does randomize them.
#	for variant1 in range(72, 74+1):
#		for variant2 in range(72, 74+1):
#			for variant3 in range(72, 74+1):
#				rngColumnsCubes[RNG_ENUM].append([
#					118,
#					variant1,
#					variant2,
#					variant3,
#					77,
#					0,
#					0,
#					0,
#				])
#				rngColumnsFloor[RNG_ENUM].append(27)
#
#func rng_get_wall(RNG_ENUM): # slabs.dat doesn't include these randomized columns, but the official editor does randomize them.
#	for variant1 in range(25, 29+1):
#		#print(25+variant1)
#		for variant2 in range(72, 74+1):
#			for variant3 in range(72, 74+1):
#				rngColumnsCubes[RNG_ENUM].append([
#					variant1, # This is the dirt path cube, but we should add it anyway because when updating a column it checks if the column is inside this array.
#					82,
#					variant2,
#					variant3,
#					77,
#					0,
#					0,
#					0,
#				])
#				rngColumnsFloor[RNG_ENUM].append(27)
#
#
#func rng_get_earth(RNG_ENUM): # slabs.dat doesn't include these randomized columns, but the official editor does randomize them.
#	for variant1 in range(25, 29+1):
#		for variant2 in range(1, 3+1):
#			for variant3 in range(1, 3+1):
#				rngColumnsCubes[RNG_ENUM].append([
#					variant1,
#					10,
#					variant2,
#					variant3,
#					5,
#					0,
#					0,
#					0,
#				])
#				rngColumnsFloor[RNG_ENUM].append(27)
#
#func rng_get_earth_nearby_water(RNG_ENUM): # slabs.dat doesn't include these randomized columns, but the official editor does randomize them.
#	for variant1 in range(1, 3+1):
#		for variant2 in range(1, 3+1):
#			for variant3 in range(1, 3+1):
#				rngColumnsCubes[RNG_ENUM].append([
#					38,
#					variant1,
#					variant2,
#					variant3,
#					5,
#					0,
#					0,
#					0,
#				])
#				rngColumnsFloor[RNG_ENUM].append(27)
#
#func rng_get_lava(RNG_ENUM): # slabs.dat doesn't include these randomized columns, but the official editor does randomize them.
#	rngColumnsCubes[RNG_ENUM].append([0,0,0,0, 0,0,0,0])
#	rngColumnsFloor[RNG_ENUM].append(546)
#	rngColumnsCubes[RNG_ENUM].append([0,0,0,0, 0,0,0,0])
#	rngColumnsFloor[RNG_ENUM].append(547)
#
#func rng_get_dirtpath(RNG_ENUM):
#	var slabVariation = 28 * Slabs.PATH
#	var pal = oDkDat.dat[slabVariation + dir.sw]
#
#	var selection = [1,2,4, 6,7]
#	for i in selection:
#		var dkClmIndex = pal[i]
#		var addCubes = oDkClm.cubes[dkClmIndex]
#		var addFloor = oDkClm.floorTexture[dkClmIndex]
#		if rngColumnsCubes[RNG_ENUM].has(addCubes) == false:
#			rngColumnsCubes[RNG_ENUM].append(addCubes)
#			rngColumnsFloor[RNG_ENUM].append(addFloor)
#
#func rng_get_claimed_area(RNG_ENUM):
#	var slabVariation = 28 * Slabs.CLAIMED_GROUND
#	var pal = oDkDat.dat[slabVariation + dir.s]
#	var selection = [0,1,2]
#	for i in selection:
#		var dkClmIndex = pal[i]
#		var addCubes = oDkClm.cubes[dkClmIndex]
#		var addFloor = oDkClm.floorTexture[dkClmIndex]
#		if rngColumnsCubes[RNG_ENUM].has(addCubes) == false:
#			rngColumnsCubes[RNG_ENUM].append(addCubes)
#			rngColumnsFloor[RNG_ENUM].append(addFloor)
#
#func rng_get_library(RNG_ENUM):
#	var slabVariation = 28 * Slabs.LIBRARY
#	var pal = oDkDat.dat[slabVariation + dir.s]
#	var selection = [0,1]
#	for i in selection:
#		var dkClmIndex = pal[i]
#		var addCubes = oDkClm.cubes[dkClmIndex]
#		var addFloor = oDkClm.floorTexture[dkClmIndex]
#		if rngColumnsCubes[RNG_ENUM].has(addCubes) == false:
#			rngColumnsCubes[RNG_ENUM].append(addCubes)
#			rngColumnsFloor[RNG_ENUM].append(addFloor)
#
#func rng_get_gems(RNG_ENUM):
#	var simpleVar = Slabs.GEMS - 42
#	var slabVariation = (42 * 28) + (8 * simpleVar)
#
#	var pal = oDkDat.dat[slabVariation + dir.s]
#	var selection = [0,1,2,3,4,5,6,7,8]
#	for i in selection:
#		var dkClmIndex = pal[i]
#		var addCubes = oDkClm.cubes[dkClmIndex]
#		var addFloor = oDkClm.floorTexture[dkClmIndex]
#		if rngColumnsCubes[RNG_ENUM].has(addCubes) == false:
#			rngColumnsCubes[RNG_ENUM].append(addCubes)
#			rngColumnsFloor[RNG_ENUM].append(addFloor)
#
#func rng_get_gold(RNG_ENUM):
#	var slabVariation = 28 * Slabs.GOLD
#	for pick in 13:
#		var pal
#		var selection
#		match pick:
#			0:
#				pal = oDkDat.dat[slabVariation + dir.s]
#				selection = [0,1,2,3,4,5,6,7,8]
#			1:
#				pal = oDkDat.dat[slabVariation + dir.w]
#				selection = [0,1,2,3,4,5,6,7,8]
#			2:
#				pal = oDkDat.dat[slabVariation + dir.n]
#				selection = [0,1,2,3,4,5,6,7,8]
#			3:
#				pal = oDkDat.dat[slabVariation + dir.e]
#				selection = [0,1,2,3,4,5,6,7,8]
#			4:
#				pal = oDkDat.dat[slabVariation + dir.sw]
#				selection = [0,1,2,4,5,8]
#			5:
#				pal = oDkDat.dat[slabVariation + dir.nw]
#				selection = [2,4,5,6,7,8]
#			6:
#				pal = oDkDat.dat[slabVariation + dir.ne]
#				selection = [0,3,4,6,7,8]
#			7:
#				pal = oDkDat.dat[slabVariation + dir.se]
#				selection = [0,1,2,3,4,6]
#			8:
#				pal = oDkDat.dat[slabVariation + dir.all]
#				selection = [1,3,4,5,7]
#			9:
#				pal = oDkDat.dat[slabVariation + dir.s + 9]
#				selection = [0,1,2,3,4,5]
#			10:
#				pal = oDkDat.dat[slabVariation + dir.w + 9]
#				selection = [1,2,4,5,7,8]
#			11:
#				pal = oDkDat.dat[slabVariation + dir.n + 9]
#				selection = [3,4,5,6,7,8]
#			12:
#				pal = oDkDat.dat[slabVariation + dir.e + 9]
#				selection = [0,1,3,4,6,7]
#		for i in selection:
#			var dkClmIndex = pal[i]
#			var addCubes = oDkClm.cubes[dkClmIndex]
#			var addFloor = oDkClm.floorTexture[dkClmIndex]
#			if rngColumnsCubes[RNG_ENUM].has(addCubes) == false:
#				rngColumnsCubes[RNG_ENUM].append(addCubes)
#				rngColumnsFloor[RNG_ENUM].append(addFloor)
#
#func rng_get_gold_nearby_water(RNG_ENUM):
#	var slabVariation = 28 * Slabs.GOLD
#	for pick in 9:
#		var pal
#		var selection
#		match pick:
#			0:
#				pal = oDkDat.dat[slabVariation + dir.s + 18]
#				selection = [6,7,8]
#			1:
#				pal = oDkDat.dat[slabVariation + dir.w + 18]
#				selection = [0,3,6]
#			2:
#				pal = oDkDat.dat[slabVariation + dir.n + 18]
#				selection = [0,1,2]
#			3:
#				pal = oDkDat.dat[slabVariation + dir.e + 18]
#				selection = [2,5,8]
#			4:
#				pal = oDkDat.dat[slabVariation + dir.sw + 18]
#				selection = [0,3,4,7,8]
#			5:
#				pal = oDkDat.dat[slabVariation + dir.nw + 18]
#				selection = [1,2,3,4,6]
#			6:
#				pal = oDkDat.dat[slabVariation + dir.ne + 18]
#				selection = [0,1,4,5,8]
#			7:
#				pal = oDkDat.dat[slabVariation + dir.se + 18]
#				selection = [2,4,5,6,7]
#			8:
#				pal = oDkDat.dat[slabVariation + dir.all + 18]
#				selection = [0,1,2,3,5,6,7,8]
#		for i in selection:
#			var dkClmIndex = pal[i]
#			var addCubes = oDkClm.cubes[dkClmIndex]
#			var addFloor = oDkClm.floorTexture[dkClmIndex]
#			if rngColumnsCubes[RNG_ENUM].has(addCubes) == false:
#				rngColumnsCubes[RNG_ENUM].append(addCubes)
#				rngColumnsFloor[RNG_ENUM].append(addFloor)
#
#
#func rng_get_gold_nearby_lava(RNG_ENUM):
#	var slabVariation = 28 * Slabs.GOLD
#	for pick in 9:
#		var pal
#		var selection
#		match pick:
#			0:
#				pal = oDkDat.dat[slabVariation + dir.s + 9]
#				selection = [6,7,8]
#			1:
#				pal = oDkDat.dat[slabVariation + dir.w + 9]
#				selection = [0,3,6]
#			2:
#				pal = oDkDat.dat[slabVariation + dir.n + 9]
#				selection = [0,1,2]
#			3:
#				pal = oDkDat.dat[slabVariation + dir.e + 9]
#				selection = [2,5,8]
#			4:
#				pal = oDkDat.dat[slabVariation + dir.sw + 9]
#				selection = [0,3,4,7,8]
#			5:
#				pal = oDkDat.dat[slabVariation + dir.nw + 9]
#				selection = [1,2,3,4,6]
#			6:
#				pal = oDkDat.dat[slabVariation + dir.ne + 9]
#				selection = [0,1,4,5,8]
#			7:
#				pal = oDkDat.dat[slabVariation + dir.se + 9]
#				selection = [2,4,5,6,7]
#			8:
#				pal = oDkDat.dat[slabVariation + dir.all + 9]
#				selection = [0,1,2,3,5,6,7,8]
#		for i in selection:
#			var dkClmIndex = pal[i]
#			var addCubes = oDkClm.cubes[dkClmIndex]
#			var addFloor = oDkClm.floorTexture[dkClmIndex]
#			if rngColumnsCubes[RNG_ENUM].has(addCubes) == false:
#				rngColumnsCubes[RNG_ENUM].append(addCubes)
#				rngColumnsFloor[RNG_ENUM].append(addFloor)

func create_keeperfx_cfg_columns(filePath): #"res://columns.cfg"
	var textFile = File.new()
	if textFile.open(filePath, File.WRITE) == OK:
	
		textFile.store_line('[common]')
		textFile.store_line('ColumnsCount = 2048')
		textFile.store_line('\r')
		
		for i in oDkClm.utilized.size():
			textFile.store_line('[column' + str(i) +']')
			textFile.store_line('Utilized = ' + str(oDkClm.utilized[i])) #(0-1)
			textFile.store_line('Permanent = ' + str(oDkClm.permanent[i])) #(2)
			textFile.store_line('Lintel = ' + str(oDkClm.lintel[i])) #(2)
			textFile.store_line('Height = ' + str(oDkClm.height[i])) #(2)
			textFile.store_line('SolidMask = ' + str(oDkClm.solidMask[i])) #(3-4)
			textFile.store_line('FloorTexture = ' + str(oDkClm.floorTexture[i])) #(5-6)
			textFile.store_line('Orientation = ' + str(oDkClm.orientation[i])) #(7)
			textFile.store_line('Cubes = ' + str(oDkClm.cubes[i])) #(8-23)
			textFile.store_line('\r')
		oMessage.quick("Saved: " + filePath)
	else:
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")

func create_keeperfx_cfg_slab_autotile_data(filePath): #"res://slab_autotile_data.cfg"
	var textFile = File.new()
	if textFile.open(filePath, File.WRITE) == OK:
		var slabSection = 0
		
		for slabID in 58:
			#textFile.store_line('[[slab' + str(slabSection) + '.columns]]')
			
			var variationStart = (slabID * 28)
			if slabID >= 42:
				variationStart = (42 * 28) + (8 * (slabID - 42))
			
			var variationCount = 28
			if slabID >= 42:
				variationCount = 8
			
			for variationNumber in variationCount:
				if variationStart + variationNumber < oDkDat.dat.size():
					#var beginLine = get_dir_text(variationNumber) + ' = '
					textFile.store_line('[slab' + str(slabSection) + '.' + get_dir_text(variationNumber) + ']')
					textFile.store_line('columns = ' + String(oDkDat.dat[variationStart + variationNumber])) #.replace(',','').replace('[','').replace(']','')
				
				var hasObjects = false
				for i in oDkTng.tngObject.size():
					if oDkTng.tngObject[i][1] == variationStart + variationNumber: #VariationIndex
						textFile.store_line("\r")
						hasObjects = true
						textFile.store_line('[[slab' + str(slabSection) + '.' + get_dir_text(variationNumber) + '.objects]]')
						for z in 9:
							var val = oDkTng.tngObject[i][z]
							var beginLine = ''
							match z:
								0: beginLine = 'IsLight'
								1: beginLine = 'VariationIndex'
								2: beginLine = 'Subtile'
								3: beginLine = 'RelativeX'
								4: beginLine = 'RelativeY'
								5: beginLine = 'RelativeZ'
								6: beginLine = 'ThingType'
								7: beginLine = 'ThingSubtype'
								8: beginLine = 'EffectRange'
							if z == 1: continue # skip "VariationIndex"
							
							beginLine += ' = '
							
							textFile.store_line(beginLine + String(val))
				
				if hasObjects == false:
					textFile.store_line('objects = []')
				
				textFile.store_line("\r")
				
			textFile.store_line("\r")
			
			slabSection += 1
		
		textFile.close()
		oMessage.quick("Saved: " + filePath)
	else:
		oMessage.big("Error", "Couldn't save file, maybe try saving to another directory.")

func get_dir_text(variationNumber):
	match variationNumber:
		00: return 'S'
		01: return 'W'
		02: return 'N'
		03: return 'E'
		04: return 'SW'
		05: return 'NW'
		06: return 'NE'
		07: return 'SE'
		08: return 'ALL' #SWNE
		09: return 'S_LAVA'
		10: return 'W_LAVA'
		11: return 'N_LAVA'
		12: return 'E_LAVA'
		13: return 'SW_LAVA'
		14: return 'NW_LAVA'
		15: return 'NE_LAVA'
		16: return 'SE_LAVA'
		17: return 'ALL_LAVA' #SWNE_LAVA
		18: return 'S_WATER'
		19: return 'W_WATER'
		20: return 'N_WATER'
		21: return 'E_WATER'
		22: return 'SW_WATER'
		23: return 'NW_WATER'
		24: return 'NE_WATER'
		25: return 'SE_WATER'
		26: return 'ALL_WATER' #SWNE_WATER
		27: return 'CENTER'


#func edit_impenetrable():
#	var slabVariation
#	slabVariation = 28 * Slabs.WATER
#	var waterColumn = oDkDat.dat[slabVariation + dir.s][0]
#	slabVariation = 28 * Slabs.LAVA
#	var lavaColumn = oDkDat.dat[slabVariation + dir.s][0]
#
#	slabVariation = 28 * Slabs.ROCK
#	oDkDat.dat[slabVariation + dir.sw + 9][6] = lavaColumn
#	oDkDat.dat[slabVariation + dir.nw + 9][0] = lavaColumn
#	oDkDat.dat[slabVariation + dir.ne + 9][2] = lavaColumn
#	oDkDat.dat[slabVariation + dir.se + 9][8] = lavaColumn
#	oDkDat.dat[slabVariation + dir.sw + 18][6] = waterColumn
#	oDkDat.dat[slabVariation + dir.nw + 18][0] = waterColumn
#	oDkDat.dat[slabVariation + dir.ne + 18][2] = waterColumn
#	oDkDat.dat[slabVariation + dir.se + 18][8] = waterColumn
#
#func edit_walltorch_sw_ne_shadow(): # it's using the wrong side shadow
#	var slabVariation
#	slabVariation = 28 * Slabs.WALL_WITH_TORCH
#
#	# Use the "wall with drape" except add a torch cube to it. This custom column will be used to fix the incorrect shadows on the wall torch slab.
#
#	var clmIndex = oDkDat.dat[(28 * Slabs.WALL_WITH_BANNER) + dir.sw][3]
#	var fixUsingColumn = oDataClm.index_entry_replace_one_cube(clmIndex, 3, 119) # 119 = torch cube
#
#	oDkDat.dat[slabVariation + dir.sw][3] = fixUsingColumn
#	oDkDat.dat[slabVariation + dir.ne][1] = fixUsingColumn

#func edit_damaged_wall():
#	var slabVariation = 28 * Slabs.WALL_DAMAGED
#
#	var dmgWall1 = oDataClm.index_entry([25,82,123,120,77,0,0,0], 27)
#	var dmgWall2 = oDataClm.index_entry([25,82,124,121,77,0,0,0], 27)
#	var dmgWall3 = oDataClm.index_entry([25,82,125,122,77,0,0,0], 27)
#	for pick in 9:
#		match pick:
#			0:
#				oDkDat.dat[slabVariation + dir.s][6] = dmgWall1
#				oDkDat.dat[slabVariation + dir.s][7] = dmgWall2
#				oDkDat.dat[slabVariation + dir.s][8] = dmgWall3
#			1:
#				oDkDat.dat[slabVariation + dir.w][0] = dmgWall1
#				oDkDat.dat[slabVariation + dir.w][3] = dmgWall2
#				oDkDat.dat[slabVariation + dir.w][6] = dmgWall3
#			2:
#				oDkDat.dat[slabVariation + dir.n][0] = dmgWall1
#				oDkDat.dat[slabVariation + dir.n][1] = dmgWall2
#				oDkDat.dat[slabVariation + dir.n][2] = dmgWall3
#			3:
#				oDkDat.dat[slabVariation + dir.e][2] = dmgWall1
#				oDkDat.dat[slabVariation + dir.e][5] = dmgWall2
#				oDkDat.dat[slabVariation + dir.e][8] = dmgWall3
#			4:
#				oDkDat.dat[slabVariation + dir.sw][0] = dmgWall1
#				oDkDat.dat[slabVariation + dir.sw][3] = dmgWall3
#				oDkDat.dat[slabVariation + dir.sw][7] = dmgWall1
#				oDkDat.dat[slabVariation + dir.sw][8] = dmgWall3
#			5:
#				oDkDat.dat[slabVariation + dir.nw][1] = dmgWall1
#				oDkDat.dat[slabVariation + dir.nw][2] = dmgWall3
#				oDkDat.dat[slabVariation + dir.nw][3] = dmgWall1
#				oDkDat.dat[slabVariation + dir.nw][6] = dmgWall3
#			6:
#				oDkDat.dat[slabVariation + dir.ne][0] = dmgWall1
#				oDkDat.dat[slabVariation + dir.ne][1] = dmgWall3
#				oDkDat.dat[slabVariation + dir.ne][5] = dmgWall1
#				oDkDat.dat[slabVariation + dir.ne][8] = dmgWall3
#			7:
#				oDkDat.dat[slabVariation + dir.se][2] = dmgWall1
#				oDkDat.dat[slabVariation + dir.se][5] = dmgWall3
#				oDkDat.dat[slabVariation + dir.se][6] = dmgWall1
#				oDkDat.dat[slabVariation + dir.se][7] = dmgWall3
#			8:
#				oDkDat.dat[slabVariation + dir.all][1] = dmgWall2
#				oDkDat.dat[slabVariation + dir.all][3] = dmgWall2
#				oDkDat.dat[slabVariation + dir.all][5] = dmgWall2
#				oDkDat.dat[slabVariation + dir.all][7] = dmgWall2
#
#	var dmgWallLava1 = oDataClm.index_entry([118,72,123,120,77,0,0,0], 27)
#	var dmgWallLava2 = oDataClm.index_entry([118,72,124,121,77,0,0,0], 27)
#	var dmgWallLava3 = oDataClm.index_entry([118,72,125,122,77,0,0,0], 27)
#	for pick in 9:
#		match pick:
#			0:
#				oDkDat.dat[slabVariation + dir.s + 9][6] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.s + 9][7] = dmgWallLava2
#				oDkDat.dat[slabVariation + dir.s + 9][8] = dmgWallLava3
#			1:
#				oDkDat.dat[slabVariation + dir.w + 9][0] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.w + 9][3] = dmgWallLava2
#				oDkDat.dat[slabVariation + dir.w + 9][6] = dmgWallLava3
#			2:
#				oDkDat.dat[slabVariation + dir.n + 9][0] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.n + 9][1] = dmgWallLava2
#				oDkDat.dat[slabVariation + dir.n + 9][2] = dmgWallLava3
#			3:
#				oDkDat.dat[slabVariation + dir.e + 9][2] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.e + 9][5] = dmgWallLava2
#				oDkDat.dat[slabVariation + dir.e + 9][8] = dmgWallLava3
#			4:
#				oDkDat.dat[slabVariation + dir.sw + 9][0] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.sw + 9][3] = dmgWallLava3
#				oDkDat.dat[slabVariation + dir.sw + 9][7] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.sw + 9][8] = dmgWallLava3
#			5:
#				oDkDat.dat[slabVariation + dir.nw + 9][1] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.nw + 9][2] = dmgWallLava3
#				oDkDat.dat[slabVariation + dir.nw + 9][3] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.nw + 9][6] = dmgWallLava3
#			6:
#				oDkDat.dat[slabVariation + dir.ne + 9][0] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.ne + 9][1] = dmgWallLava3
#				oDkDat.dat[slabVariation + dir.ne + 9][5] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.ne + 9][8] = dmgWallLava3
#			7:
#				oDkDat.dat[slabVariation + dir.se + 9][2] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.se + 9][5] = dmgWallLava3
#				oDkDat.dat[slabVariation + dir.se + 9][6] = dmgWallLava1
#				oDkDat.dat[slabVariation + dir.se + 9][7] = dmgWallLava3
#			8:
#				oDkDat.dat[slabVariation + dir.all + 9][1] = dmgWallLava2
#				oDkDat.dat[slabVariation + dir.all + 9][3] = dmgWallLava2
#				oDkDat.dat[slabVariation + dir.all + 9][5] = dmgWallLava2
#				oDkDat.dat[slabVariation + dir.all + 9][7] = dmgWallLava2


#func blah():
#	viewoDkClm()
#	viewDKdat()
#
#func viewoDkClm():
#	var numberOfClmEntries = 2048
#	for entry in numberOfClmEntries:
#		var twentyFourByteArray = oAssets.clm[entry]
#		oDataClm.data.append(twentyFourByteArray)
#
#func viewDKdat():
#	var slabVariation = 0
#	for ySlab in 85:
#		for xSlab in 85:
#			slabVariation += 1
##			var slabID = oDataSlab.get_cell(xSlab,ySlab)
##			var slabVariation = slabID*28
#			if slabVariation >= 1304: slabVariation = 0
#			for subtile in 9:
#				var value = oDkClm.dat[slabVariation][subtile] # slab variation - subtile of that variation				
#				var ySubtile = subtile/3
#				var xSubtile = subtile-(ySubtile*3)
#				oDataClmPos.set_cell( (xSlab*3)+xSubtile, (ySlab*3)+ySubtile, value)

#func update_slab_palette_for_map():
#	var dictionary = {}
#
#	slabPal.clear()
#
#	var numberOfSets = 1304
#	slabPal.resize(numberOfSets)
#	for i in slabPal.size():
#		oDkDat.dat[i] = []
#		oDkDat.dat[i].resize(9)
#
#		for subtile in 9:
#			# Get the column array from the assets
#			var assetClmIndex = oDkDat.dat[i][subtile]
#
#			var newClmIndex
#			if dictionary.has(assetClmIndex) == true: # Quicker subsequent lookups
#				# Reuse the same clmIndex that we've found before
#				newClmIndex = dictionary[assetClmIndex]
#			else:
#				# New column. Put that column inside our map's DataClm.
#				var cubeArray = oDkClm.cubes[assetClmIndex]
#				var floorID = oDkClm.floorTexture[assetClmIndex]
#
#				#newClmIndex = oDataClm.index_entry(cubeArray, floorID) #!!!!!!!!!!!!!!!!!!!!!!!!
#
#				dictionary[assetClmIndex] = newClmIndex # Store for subsequent lookups to instantly find any duplicates
#
#			# Put that column index inside the slabPal.
#			oDkDat.dat[i][subtile] = newClmIndex
#
#	# Add extra sets here for custom slabs
