extends Node
onready var oReadData = Nodelist.list["oReadData"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oSlabPalette = Nodelist.list["oSlabPalette"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oPlaceThingWithSlab = Nodelist.list["oPlaceThingWithSlab"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oDamagedWallLineEdit = Nodelist.list["oDamagedWallLineEdit"]
onready var oAutoWallArtButton = Nodelist.list["oAutoWallArtButton"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oOwnableNaturalTerrain = Nodelist.list["oOwnableNaturalTerrain"]
onready var oBridgesOnlyOnLiquidCheckbox = Nodelist.list["oBridgesOnlyOnLiquidCheckbox"]
onready var oCustomSlabSystem = Nodelist.list["oCustomSlabSystem"]
onready var oDataCustomSlab = Nodelist.list["oDataCustomSlab"]
onready var oDkDat = Nodelist.list["oDkDat"]
onready var oDkClm = Nodelist.list["oDkClm"]
onready var oFrailSoloSlabsCheckbox = Nodelist.list["oFrailSoloSlabsCheckbox"]
onready var oFrailImpenetrableCheckbox = Nodelist.list["oFrailImpenetrableCheckbox"]

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

enum {
	OWNERSHIP_GRAPHIC_FLOOR
	OWNERSHIP_GRAPHIC_PORTAL
	OWNERSHIP_GRAPHIC_HEART
	OWNERSHIP_GRAPHIC_WALL
	OWNERSHIP_GRAPHIC_DOOR_1
	OWNERSHIP_GRAPHIC_DOOR_2
}

func place_shape_of_slab_id(shapePositionArray, slabID, ownership):
	var removeFromShape = []
	
	var CODETIME_START = OS.get_ticks_msec()
	for pos in shapePositionArray:
		
		if slabID < 1000:
			oDataCustomSlab.set_cellv(pos, 0)
		else:
			oDataCustomSlab.set_cellv(pos, slabID)
		
		match slabID:
			Slabs.BRIDGE:
				if oBridgesOnlyOnLiquidCheckbox.pressed == true:
					if oDataSlab.get_cellv(pos) != Slabs.WATER and oDataSlab.get_cellv(pos) != Slabs.LAVA:
						removeFromShape.append(pos) # This prevents ownership from changing if placing a bridge on something that's not liquid
				if removeFromShape.has(pos) == false:
					oDataSlab.set_cellv(pos, slabID)
			Slabs.EARTH:
				var autoEarthID = auto_torch_earth(pos.x, pos.y)
				oDataSlab.set_cellv(pos, autoEarthID)
			Slabs.WALL_AUTOMATIC:
				var autoWallID = auto_wall(pos.x, pos.y)
				oDataSlab.set_cellv(pos, autoWallID)
			_:
				oDataSlab.set_cellv(pos, slabID)
	
	for i in removeFromShape:
		shapePositionArray.erase(i)
	
	oOverheadOwnership.ownership_update_shape(shapePositionArray, ownership)
	print('Slab IDs set in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

func generate_slabs_based_on_id(rectStart, rectEnd, updateNearby):
	oEditor.mapHasBeenEdited = true
	if updateNearby == true:
		# Include surrounding
		rectStart -= Vector2(1,1)
		rectEnd += Vector2(1,1)
	rectStart = Vector2(clamp(rectStart.x, 0, 84), clamp(rectStart.y, 0, 84))
	rectEnd = Vector2(clamp(rectEnd.x, 0, 84), clamp(rectEnd.y, 0, 84))
	
	var CODETIME_START = OS.get_ticks_msec()
	for ySlab in range(rectStart.y, rectEnd.y+1):
		for xSlab in range(rectStart.x, rectEnd.x+1):
			var slabID = oDataSlab.get_cell(xSlab, ySlab)
			var ownership = oDataOwnership.get_cell(xSlab, ySlab)
			do_slab(xSlab, ySlab, slabID, ownership)
			
			oInstances.manage_things_on_slab(xSlab, ySlab, slabID, ownership)
	
	print('Generated slabs in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	
	
	oOverheadGraphics.overhead2d_update_rect(rectStart, rectEnd)


func do_slab(xSlab, ySlab, slabID, ownership):
	if slabID == Slabs.WALL_AUTOMATIC:
		slabID = auto_wall(xSlab, ySlab) # Set slabID to a real one
	elif slabID == Slabs.EARTH:
		slabID = auto_torch_earth(xSlab, ySlab) # Potentially change slab ID to Torch Earth
	
	var surrID = get_surrounding_slabIDs(xSlab, ySlab)
	var surrOwner = get_surrounding_ownership(xSlab, ySlab)
	
	if slabID >= 1000: # Custom Slab IDs
		if oCustomSlabSystem.data.has(slabID):
			slab_place_custom(xSlab, ySlab, slabID, ownership, surrID)
		return
	
	# Do not update custom slabs
	if oDataCustomSlab.get_cell(xSlab, ySlab) != 0:
		return
	
	# WIB (wibble)
	update_wibble(xSlab, ySlab, slabID, false)
	# WLB (Water Lava Block)
	if slabID != Slabs.BRIDGE:
		oDataLiquid.set_cell(xSlab, ySlab, Slabs.data[slabID][Slabs.REMEMBER_TYPE])
	
	var bitmaskType = Slabs.data[slabID][Slabs.BITMASK_TYPE]
	match bitmaskType:
		Slabs.BITMASK_WALL:
			place_fortified_wall(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType)
		Slabs.BITMASK_OTHER:
			place_other(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType)
		_:
			place_general(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType)


func slab_place_custom(xSlab, ySlab, slabID, ownership, surrID):
	var recognizedAsID = oCustomSlabSystem.data[slabID][oCustomSlabSystem.RECOGNIZED_AS]
	
	var wibbleEdges = oCustomSlabSystem.data[slabID][oCustomSlabSystem.WIBBLE_EDGES]
	
	# WIB (wibble)
	update_wibble(xSlab, ySlab, slabID, wibbleEdges)
	
	# WLB (Water Lava Block)
	if recognizedAsID != Slabs.BRIDGE:
		var liquidValue = Slabs.data[slabID][Slabs.REMEMBER_TYPE]
		oDataLiquid.set_cell(xSlab, ySlab, liquidValue)
	
	var slabCubes = oCustomSlabSystem.data[slabID][oCustomSlabSystem.CUBE_DATA]
	var slabFloor = oCustomSlabSystem.data[slabID][oCustomSlabSystem.FLOOR_DATA]
	
	set_columns(xSlab, ySlab, slabCubes, slabFloor)
	
	oDataSlab.set_cell(xSlab, ySlab, recognizedAsID)


func _on_ConfirmAutoGen_confirmed():
	oMessage.quick("Auto-generated all slabs")
	var updateNearby = true
	generate_slabs_based_on_id(Vector2(0,0), Vector2(84,84), updateNearby)


func auto_torch_earth(xSlab, ySlab):
	var newSlabID = Slabs.EARTH
	var calcTorchSide = calculate_torch_side(xSlab,ySlab)
	match calcTorchSide:
		1,3: # West, East
			if oDataSlab.get_cell(xSlab+1, ySlab) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab-1, ySlab) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.EARTH_WITH_TORCH
		0,2: # South, North
			if oDataSlab.get_cell(xSlab, ySlab+1) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab, ySlab-1) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.EARTH_WITH_TORCH
	
	oDataSlab.set_cell(xSlab, ySlab, newSlabID)
	return newSlabID

func auto_wall(xSlab, ySlab):
	var newSlabID = Slabs.ROCK
	
	match oAutoWallArtButton.text:
		"Grouped":
			if int(xSlab) % 15 < 15 or int(ySlab) % 15 < 15: newSlabID = Slabs.WALL_WITH_PAIR
			if int(xSlab) % 15 < 10 or int(ySlab) % 15 < 10: newSlabID = Slabs.WALL_WITH_WOMAN
			if int(xSlab) % 15 < 5 or int(ySlab) % 15 < 5: newSlabID = Slabs.WALL_WITH_TWINS
		"Random":
			newSlabID = Random.choose([Slabs.WALL_WITH_TWINS, Slabs.WALL_WITH_WOMAN, Slabs.WALL_WITH_PAIR])
	
	if Random.chance_int(int(oDamagedWallLineEdit.text)) == true:
		newSlabID = Slabs.WALL_DAMAGED
	
	# Checkerboard
	if (int(xSlab) % 2 == 0 and int(ySlab) % 2 == 0) or (int(xSlab) % 2 == 1 and int(ySlab) % 2 == 1):
		
		for dir in [Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,0)]:
			if oDataSlab.get_cell(xSlab+dir.x, ySlab+dir.y) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.WALL_WITH_BANNER
	
	# Torch wall takes priority
	var calcTorchSide = calculate_torch_side(xSlab,ySlab)
	match calcTorchSide:
		1,3: # West, East
			if oDataSlab.get_cell(xSlab+1, ySlab) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab-1, ySlab) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.WALL_WITH_TORCH
		0,2: # South, North
			if oDataSlab.get_cell(xSlab, ySlab+1) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab, ySlab-1) == Slabs.CLAIMED_GROUND:
				newSlabID = Slabs.WALL_WITH_TORCH
	
	oDataSlab.set_cell(xSlab, ySlab, newSlabID)
	
	return newSlabID

func calculate_torch_side(xSlab, ySlab):
	var calcTorchSide = -1
	var sideNS = -1
	var sideEW = -1
	
	if int(xSlab) % 5 == 0:
		if int(xSlab) % 10 == 0: # Every 10th row is reversed
			if int(ySlab) % 2 == 0: # Every 2nd tile flips the other way
				sideNS = dir.s
			else:
				sideNS = dir.n
		else:
			if int(ySlab) % 2 == 0: # Every 2nd tile flips the other way
				sideNS = dir.n
			else:
				sideNS = dir.s
	
	if int(ySlab) % 5 == 0:
		if int(ySlab) % 10 == 0: # Every 10th row is reversed
			if int(xSlab) % 2 == 0: # Every 2nd tile flips the other way
				sideEW = dir.e
			else:
				sideEW = dir.w
		else:
			if int(xSlab) % 2 == 0: # Every 2nd tile flips the other way
				sideEW = dir.w
			else:
				sideEW = dir.e
	
	if sideNS != -1 and sideEW != -1:
		# Some torch postions (every 5x5 point) are dynamically chosen
		if oDataSlab.get_cell(xSlab+1, ySlab) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab-1, ySlab) == Slabs.CLAIMED_GROUND:
			calcTorchSide = sideEW
		if oDataSlab.get_cell(xSlab, ySlab+1) == Slabs.CLAIMED_GROUND or oDataSlab.get_cell(xSlab, ySlab-1) == Slabs.CLAIMED_GROUND:
			calcTorchSide = sideNS
	else:
		if sideEW != -1: calcTorchSide = sideEW
		if sideNS != -1: calcTorchSide = sideNS
	
	return calcTorchSide



func place_general(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType):
	var slabVariation = slabID*28
	
	var bitmask
	match bitmaskType:
		Slabs.BITMASK_GENERAL: bitmask = get_general_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_CLAIMED: bitmask = get_claimed_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_TALL: bitmask = get_tall_bitmask(surrID)
	
	var asset3x3group = make_slab(slabID*28, bitmask)
	asset3x3group = modify_for_liquid(asset3x3group, surrID, slabID)
	asset3x3group = corner_filler_and_solo_slab(asset3x3group, surrID, bitmask, slabID)
	
	var fullSlabData = dkdat_position_to_column_data(asset3x3group)
	fullSlabData = randomize_columns(fullSlabData, slabID, bitmaskType)
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	match slabID:
		Slabs.ROCK:
			fullSlabData = make_impenetrable_frail(fullSlabData, surrID)
		Slabs.EARTH_WITH_TORCH:
			slabCubes = adjust_torch_cubes(slabCubes, calculate_torch_side(xSlab, ySlab))
		Slabs.CLAIMED_GROUND:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_FLOOR, bitmask, slabID)
		Slabs.DUNGEON_HEART:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_HEART, bitmask, slabID)
		Slabs.PORTAL:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_PORTAL, bitmask, slabID)
		
	
	set_columns(xSlab, ySlab, slabCubes, slabFloor)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab, slabID, ownership, slabVariation, bitmask, surrID, surrOwner)

func place_fortified_wall(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType):
	var slabVariation = slabID * 28
	
	var bitmask = get_wall_bitmask(xSlab, ySlab, surrID, ownership)
	var asset3x3group = make_slab(slabID*28, bitmask)
	
	# Wall corners
	# 0 1 2
	# 3 4 5
	# 6 7 8
	var wallS = Slabs.data[ surrID[dir.s] ][Slabs.BITMASK_TYPE]
	var wallW = Slabs.data[ surrID[dir.w] ][Slabs.BITMASK_TYPE]
	var wallN = Slabs.data[ surrID[dir.n] ][Slabs.BITMASK_TYPE]
	var wallE = Slabs.data[ surrID[dir.e] ][Slabs.BITMASK_TYPE]
	if wallN == bitmaskType and wallE == bitmaskType and Slabs.data[ surrID[dir.ne] ][Slabs.IS_SOLID] == false:
		asset3x3group[2] = ((slabVariation + dir.all) * 9) + 2
	if wallN == bitmaskType and wallW == bitmaskType and Slabs.data[ surrID[dir.nw] ][Slabs.IS_SOLID] == false:
		asset3x3group[0] = ((slabVariation + dir.all) * 9) + 0
	if wallS == bitmaskType and wallE == bitmaskType and Slabs.data[ surrID[dir.se] ][Slabs.IS_SOLID] == false:
		asset3x3group[8] = ((slabVariation + dir.all) * 9) + 8
	if wallS == bitmaskType and wallW == bitmaskType and Slabs.data[ surrID[dir.sw] ][Slabs.IS_SOLID] == false:
		asset3x3group[6] = ((slabVariation + dir.all) * 9) + 6
	
	asset3x3group = modify_wall_based_on_nearby_room_and_liquid(asset3x3group, surrID, slabID)
	asset3x3group = corner_filler_and_solo_slab(asset3x3group, surrID, bitmask, slabID)
	
	var fullSlabData = dkdat_position_to_column_data(asset3x3group)
	fullSlabData = randomize_columns(fullSlabData, slabID, bitmaskType)
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	
	
	if slabID == Slabs.WALL_WITH_TORCH:
		slabCubes = adjust_torch_cubes(slabCubes, calculate_torch_side(xSlab, ySlab))
	
	slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_WALL, bitmask, slabID)
	
	set_columns(xSlab, ySlab, slabCubes, slabFloor)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab,slabID, ownership, slabVariation, bitmask, surrID, surrOwner)


func place_other(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType): # These slabs only have 8 variations each, compared to the others which have 28 each.
	# Make sure door is facing the correct direction by changing its Slab based on surrounding slabs.
	if slabID in [Slabs.WOODEN_DOOR_1, Slabs.WOODEN_DOOR_2, Slabs.BRACED_DOOR_1, Slabs.BRACED_DOOR_2, Slabs.IRON_DOOR_1, Slabs.IRON_DOOR_2, Slabs.MAGIC_DOOR_1, Slabs.MAGIC_DOOR_2]:
		if Slabs.data[ surrID[dir.e] ][Slabs.IS_SOLID] == true and Slabs.data[ surrID[dir.w] ][Slabs.IS_SOLID] == true:
			match slabID:
				Slabs.WOODEN_DOOR_1: slabID = Slabs.WOODEN_DOOR_2
				Slabs.BRACED_DOOR_1: slabID = Slabs.BRACED_DOOR_2
				Slabs.IRON_DOOR_1: slabID = Slabs.IRON_DOOR_2
				Slabs.MAGIC_DOOR_1: slabID = Slabs.MAGIC_DOOR_2
			oDataSlab.set_cell(xSlab, ySlab, slabID)
		elif Slabs.data[ surrID[dir.n] ][Slabs.IS_SOLID] == true and Slabs.data[ surrID[dir.s] ][Slabs.IS_SOLID] == true:
			match slabID:
				Slabs.WOODEN_DOOR_2: slabID = Slabs.WOODEN_DOOR_1
				Slabs.BRACED_DOOR_2: slabID = Slabs.BRACED_DOOR_1
				Slabs.IRON_DOOR_2: slabID = Slabs.IRON_DOOR_1
				Slabs.MAGIC_DOOR_2: slabID = Slabs.MAGIC_DOOR_1
			oDataSlab.set_cell(xSlab, ySlab, slabID)
	
	var slabVariation = (42 * 28) + (8 * (slabID - 42))
	var bitmask = 1
	var asset3x3group = make_slab(slabVariation, bitmask)
	asset3x3group = corner_filler_and_solo_slab(asset3x3group, surrID, bitmask, slabID)
	
	var fullSlabData = dkdat_position_to_column_data(asset3x3group)
	fullSlabData = randomize_columns(fullSlabData, slabID, bitmaskType)
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	match slabID:
		Slabs.WOODEN_DOOR_1, Slabs.BRACED_DOOR_1, Slabs.IRON_DOOR_1, Slabs.MAGIC_DOOR_1:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_DOOR_1, 0, slabID)
		Slabs.WOODEN_DOOR_2, Slabs.BRACED_DOOR_2, Slabs.IRON_DOOR_2, Slabs.MAGIC_DOOR_2:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_DOOR_2, 0, slabID)
	
	set_columns(xSlab, ySlab, slabCubes, slabFloor)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab, slabID, ownership, slabVariation, bitmask, null, null)

#var localRandom = RandomNumberGenerator.new()
const rngEarthPathUnderneath = [25,26,27,28,29]
const rngEarth = [1,2,3]
const rngClaimedGround = [126,127,128]
const rngGold = [49,50,51]
const rngGoldNearLava = [52,53,54]
const rngPathClean = [25,26,27]
const rngPathWithStones = [28,29]
const rngLibrary = [174,175]
const rngGems = [441,442,443,444]
const rngWall = [72,73,74]
const rngLava = [546,547] # This one is a FloorTexture

func randomize_columns(fullSlabData, slabID, bitmaskType):
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	if bitmaskType == Slabs.BITMASK_WALL:
		for i in 9:
			if slabCubes[i][0] in rngEarthPathUnderneath:
				slabCubes[i][0] = 25 # No need to randomize the path cube, it's not visible and the game overwrites it anyway.
			if slabCubes[i][1] in rngWall:
				slabCubes[i][1] = Random.choose(rngWall)
			if slabCubes[i][2] in rngWall:
				slabCubes[i][2] = Random.choose(rngWall)
			if slabCubes[i][3] in rngWall:
				slabCubes[i][3] = Random.choose(rngWall)
	else:
		match slabID:
			Slabs.PATH:
				var stoneRatio = 0.15
				for i in 9:
					if slabCubes[i][0] in rngPathClean or slabCubes[i][0] in rngPathWithStones:
						if stoneRatio < randf():
							slabCubes[i][0] = Random.choose(rngPathClean)
						else:
							slabCubes[i][0] = Random.choose(rngPathWithStones)
			Slabs.EARTH:
				for i in 9:
					if slabCubes[i][0] in rngEarthPathUnderneath:
						slabCubes[i][0] = 25 # No need to randomize the path cube, it's not visible and the game overwrites it anyway.
					if slabCubes[i][1] in rngEarth: # This one applies when near water
						slabCubes[i][1] = Random.choose(rngEarth)
					if slabCubes[i][2] in rngEarth:
						slabCubes[i][2] = Random.choose(rngEarth)
					if slabCubes[i][3] in rngEarth:
						slabCubes[i][3] = Random.choose(rngEarth)
					
			Slabs.CLAIMED_GROUND:
				for i in 9:
					if slabCubes[i][0] in rngClaimedGround:
						slabCubes[i][0] = Random.choose(rngClaimedGround)
			Slabs.GOLD:
				for i in 9:
					if slabCubes[i][1] in rngGold: # This one applies when near water
						slabCubes[i][1] = Random.choose(rngGold)
					if slabCubes[i][2] in rngGold:
						slabCubes[i][2] = Random.choose(rngGold)
					if slabCubes[i][3] in rngGold:
						slabCubes[i][3] = Random.choose(rngGold)
					if slabCubes[i][4] in rngGold:
						slabCubes[i][4] = Random.choose(rngGold)
					
					if slabCubes[i][1] in rngGoldNearLava:
						slabCubes[i][1] = Random.choose(rngGoldNearLava)
					if slabCubes[i][2] in rngGoldNearLava:
						slabCubes[i][2] = Random.choose(rngGoldNearLava)
					if slabCubes[i][3] in rngGoldNearLava:
						slabCubes[i][3] = Random.choose(rngGoldNearLava)
					if slabCubes[i][4] in rngGoldNearLava:
						slabCubes[i][4] = Random.choose(rngGoldNearLava)
			Slabs.LAVA:
				for i in 9:
					if slabFloor[i] in rngLava:
						slabFloor[i] = Random.choose(rngLava)
			Slabs.LIBRARY:
				for i in 9:
					if slabCubes[i][0] in rngLibrary:
						slabCubes[i][0] = Random.choose(rngLibrary)
			Slabs.GEMS:
				for i in 9:
					if slabCubes[i][2] in rngGems:
						slabCubes[i][2] = Random.choose(rngGems)
					if slabCubes[i][3] in rngGems:
						slabCubes[i][3] = Random.choose(rngGems)
					if slabCubes[i][4] in rngGems:
						slabCubes[i][4] = Random.choose(rngGems)
	return fullSlabData


func set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_TYPE, bitmask, slabID):
	if ownership == 0: return slabCubes # It's already red
	
	match OWNERSHIP_GRAPHIC_TYPE:
		OWNERSHIP_GRAPHIC_FLOOR:
			slabCubes[4][0] = Cube.ownedCube[Cube.FLOOR_MARKER][ownership]
		OWNERSHIP_GRAPHIC_PORTAL:
			if bitmask == 0:
				slabCubes[4][6] = Cube.ownedCube[Cube.PORTAL_MARKER][ownership]
		OWNERSHIP_GRAPHIC_HEART:
			match bitmask:
				03: # sw bitmask
					slabCubes[2][7] = Cube.ownedCube[Cube.HEART_MARKER][ownership]
				06: # nw bitmask
					slabCubes[8][7] = Cube.ownedCube[Cube.HEART_MARKER][ownership]
				12: # ne bitmask
					slabCubes[6][7] = Cube.ownedCube[Cube.HEART_MARKER][ownership]
				09: # se bitmask
					slabCubes[0][7] = Cube.ownedCube[Cube.HEART_MARKER][ownership]
		OWNERSHIP_GRAPHIC_WALL:
			for i in 9:
				# 0 1 2
				# 3 4 5
				# 6 7 8
				# Red Banner Left: 0, 2, 6
				# Red Banner Middle: 1, 3, 5, 7
				# Red Banner Right: 2, 6, 8
				# Barracks: 1, 3, 5, 7
				match i:
					4: # Wall marker
						slabCubes[i][4] = Cube.ownedCube[Cube.WALL_MARKER][ownership]
					1, 3, 5, 7: # Barracks, Red Banner Middle
						if slabCubes[i][4] == 161: # Red Banner Middle
							slabCubes[i][4] = Cube.ownedCube[Cube.BANNER_MIDDLE][ownership]
						elif slabCubes[i][3] == 393: # Barracks flag
							slabCubes[i][3] = Cube.ownedCube[Cube.BARRACKS_FLAG][ownership]
					0, 2, 6, 8: # Red Banner Left, Red Banner Right
						var cube4 = slabCubes[i][4]
						if cube4 == 160: # Red Banner Left
							slabCubes[i][4] = Cube.ownedCube[Cube.BANNER_LEFT][ownership]
						elif cube4 == 162: # Red Banner Right
							slabCubes[i][4] = Cube.ownedCube[Cube.BANNER_RIGHT][ownership]
		OWNERSHIP_GRAPHIC_DOOR_1:
			# Floor marker
			slabCubes[4][0] = Cube.ownedCube[Cube.FLOOR_MARKER][ownership]
			# Red Banner Left, Red Banner Middle, Red Banner Right
			slabCubes[1][4] = Cube.ownedCube[Cube.BANNER_LEFT][ownership]
			slabCubes[4][4] = Cube.ownedCube[Cube.BANNER_MIDDLE][ownership]
			slabCubes[7][4] = Cube.ownedCube[Cube.BANNER_RIGHT][ownership]
		OWNERSHIP_GRAPHIC_DOOR_2:
			# Floor marker
			slabCubes[4][0] = Cube.ownedCube[Cube.FLOOR_MARKER][ownership]
			# Red Banner Left, Red Banner Middle, Red Banner Right
			slabCubes[3][4] = Cube.ownedCube[Cube.BANNER_LEFT][ownership]
			slabCubes[4][4] = Cube.ownedCube[Cube.BANNER_MIDDLE][ownership]
			slabCubes[5][4] = Cube.ownedCube[Cube.BANNER_RIGHT][ownership]
	return slabCubes

func dkdat_position_to_column_data(asset3x3group):
	var slabCubes = []
	var slabFloor = []
	for i in 9:
		# Convert asset3x3group's index to slabvar and subtile then read it from oDkDat
		var slabvar = asset3x3group[i] / 9
		var subtile = asset3x3group[i] - (slabvar*9)
		var dkClmIndex = oDkDat.dat[slabvar][subtile]
		
		# Get the cube data from oDkClm
		slabCubes.append(oDkClm.cubes[dkClmIndex])
		slabFloor.append(oDkClm.floorTexture[dkClmIndex])
	return [slabCubes.duplicate(true), slabFloor.duplicate(true)] # So they're no longer references


#	var clmIndexArray = [0,0,0, 0,0,0, 0,0,0]
#	for i in 9:
#		var slabVariation = asset3x3group[i] / 9
#		var newSubtile = asset3x3group[i] - (slabVariation*9)
#
#		# Prevent crash if I do something dumb, just show a purple tile
#		if slabVariation >= oSlabPalette.slabPal.size():
#			clmIndexArray[i] = oSlabPalette.slabPal[1303][0] # Show purple
#			continue
#
#		clmIndexArray[i] = oSlabPalette.slabPal[slabVariation][newSubtile] # slab variation - subtile of that variation
#	return clmIndexArray

#var positionsArray3x3 = [
#	Vector2(0,0),
#	Vector2(1,0),
#	Vector2(2,0),
#	Vector2(0,1),
#	Vector2(1,1),
#	Vector2(2,1),
#	Vector2(0,2),
#	Vector2(1,2),
#	Vector2(2,2),
#]
#
#func set_columns(xSlab, ySlab, array):
#
#	for i in 9:
#		var ySubtile = positionsArray3x3[i].y#i/3
#		var xSubtile = positionsArray3x3[i].x#i - (ySubtile*3)
#		oDataClmPos.set_cell((xSlab*3)+xSubtile, (ySlab*3)+ySubtile, array[i])

func set_columns(xSlab, ySlab, slabCubes, slabFloor):
	for i in 9:
		var clmIndex = oDataClm.index_entry(slabCubes[i], slabFloor[i])
		
		var ySubtile = i/3
		var xSubtile = i - (ySubtile*3)
		oDataClmPos.set_cell((xSlab*3)+xSubtile, (ySlab*3)+ySubtile, clmIndex)

func get_tall_bitmask(surrID):
	var bitmask = 0
	if Slabs.data[ surrID[dir.s] ][Slabs.IS_SOLID] == false: bitmask += 1
	if Slabs.data[ surrID[dir.w] ][Slabs.IS_SOLID] == false: bitmask += 2
	if Slabs.data[ surrID[dir.n] ][Slabs.IS_SOLID] == false: bitmask += 4
	if Slabs.data[ surrID[dir.e] ][Slabs.IS_SOLID] == false: bitmask += 8
	return bitmask

func get_wall_bitmask(xSlab, ySlab, surrID, ownership):
	var ownerS = oDataOwnership.get_cell(xSlab, ySlab+1)
	var ownerW = oDataOwnership.get_cell(xSlab-1, ySlab)
	var ownerN = oDataOwnership.get_cell(xSlab, ySlab-1)
	var ownerE = oDataOwnership.get_cell(xSlab+1, ySlab)
	if ownerS == 5: ownerS = ownership # If next to a Player 5 wall, treat it as earth, don't put up a wall against it.
	if ownerW == 5: ownerW = ownership
	if ownerN == 5: ownerN = ownership
	if ownerE == 5: ownerE = ownership
	var bitmask = 0
	if Slabs.data[ surrID[dir.s] ][Slabs.IS_SOLID] == false or ownerS != ownership: bitmask += 1
	if Slabs.data[ surrID[dir.w] ][Slabs.IS_SOLID] == false or ownerW != ownership: bitmask += 2
	if Slabs.data[ surrID[dir.n] ][Slabs.IS_SOLID] == false or ownerN != ownership: bitmask += 4
	if Slabs.data[ surrID[dir.e] ][Slabs.IS_SOLID] == false or ownerE != ownership: bitmask += 8
	return bitmask

func get_claimed_bitmask(slabID, ownership, surrID, surrOwner):
	var bitmask = 0
	if (slabID != surrID[dir.s] and Slabs.doors.has(surrID[dir.s]) == false) or ownership != surrOwner[dir.s]: bitmask += 1
	if (slabID != surrID[dir.w] and Slabs.doors.has(surrID[dir.w]) == false) or ownership != surrOwner[dir.w]: bitmask += 2
	if (slabID != surrID[dir.n] and Slabs.doors.has(surrID[dir.n]) == false) or ownership != surrOwner[dir.n]: bitmask += 4
	if (slabID != surrID[dir.e] and Slabs.doors.has(surrID[dir.e]) == false) or ownership != surrOwner[dir.e]: bitmask += 8
	return bitmask

func get_general_bitmask(slabID, ownership, surrID, surrOwner):
	var bitmask = 0
	if slabID != surrID[dir.s] or ownership != surrOwner[dir.s]: bitmask += 1
	if slabID != surrID[dir.w] or ownership != surrOwner[dir.w]: bitmask += 2
	if slabID != surrID[dir.n] or ownership != surrOwner[dir.n]: bitmask += 4
	if slabID != surrID[dir.e] or ownership != surrOwner[dir.e]: bitmask += 8
	
	# Middle slab
	if bitmask == 0:
		if Slabs.rooms_with_middle_slab.has(slabID):
			if slabID != surrID[dir.se] or slabID != surrID[dir.sw] or slabID != surrID[dir.ne] or slabID != surrID[dir.nw] or ownership != surrOwner[dir.se] or ownership != surrOwner[dir.sw] or ownership != surrOwner[dir.ne] or ownership != surrOwner[dir.nw]:
				bitmask = 15
				if slabID == Slabs.TEMPLE: # Temple is just odd
					bitmask = 1000
	return bitmask


func get_surrounding_slabIDs(xSlab, ySlab):
	var surrID = []
	surrID.resize(8)
	surrID[dir.n] = oDataSlab.get_cell(xSlab, ySlab-1)
	surrID[dir.s] = oDataSlab.get_cell(xSlab, ySlab+1)
	surrID[dir.e] = oDataSlab.get_cell(xSlab+1, ySlab)
	surrID[dir.w] = oDataSlab.get_cell(xSlab-1, ySlab)
	surrID[dir.ne] = oDataSlab.get_cell(xSlab+1, ySlab-1)
	surrID[dir.nw] = oDataSlab.get_cell(xSlab-1, ySlab-1)
	surrID[dir.se] = oDataSlab.get_cell(xSlab+1, ySlab+1)
	surrID[dir.sw] = oDataSlab.get_cell(xSlab-1, ySlab+1)
	return surrID

func get_surrounding_ownership(xSlab, ySlab):
	var surrOwner = []
	surrOwner.resize(8)
	surrOwner[dir.n] = oDataOwnership.get_cell(xSlab, ySlab-1)
	surrOwner[dir.s] = oDataOwnership.get_cell(xSlab, ySlab+1)
	surrOwner[dir.e] = oDataOwnership.get_cell(xSlab+1, ySlab)
	surrOwner[dir.w] = oDataOwnership.get_cell(xSlab-1, ySlab)
	surrOwner[dir.ne] = oDataOwnership.get_cell(xSlab+1, ySlab-1)
	surrOwner[dir.nw] = oDataOwnership.get_cell(xSlab-1, ySlab-1)
	surrOwner[dir.se] = oDataOwnership.get_cell(xSlab+1, ySlab+1)
	surrOwner[dir.sw] = oDataOwnership.get_cell(xSlab-1, ySlab+1)
	return surrOwner

func adjust_torch_cubes(slabCubes, torchSideToKeep):
	var side = 0
	for i in [7,3,1,5]: # S W N E
		if torchSideToKeep != side:
			# Wall Torch Cube: 119
			# Earth Torch Cube: 24
			if slabCubes[i][3] == 119 or slabCubes[i][3] == 24:
				# Paint with "normal wall" cube.
				var replaceUsingCubeBelowIt = slabCubes[i][2]
				slabCubes[i][3] = replaceUsingCubeBelowIt
		side += 1
	return slabCubes

func modify_wall_based_on_nearby_room_and_liquid(asset3x3group, surrID, slabID):
	# Combined modify_room_face() and modify_for_liquid() so that there won't be a conflict.
	# This function should opnly be used by Walls.
	
	var modify0 = 0; var modify1 = 0; var modify2 = 0; var modify3 = 0; var modify4 = 0; var modify5 = 0; var modify6 = 0; var modify7 = 0; var modify8 = 0
	
	if Slabs.rooms.has(surrID[dir.s]):
		var roomFace = surrID[dir.s] + 1
		var offset = ((roomFace-slabID)*28)*9
		if surrID[dir.se] == surrID[dir.s] and surrID[dir.sw] == surrID[dir.s]:
			offset += 9*9
		modify6 = offset
		modify7 = offset
		modify8 = offset
	
	if Slabs.rooms.has(surrID[dir.w]):
		var roomFace = surrID[dir.w] + 1
		var offset = ((roomFace-slabID)*28)*9
		if surrID[dir.sw] == surrID[dir.w] and surrID[dir.nw] == surrID[dir.w]:
			offset += 9*9
		modify0 = offset
		modify3 = offset
		modify6 = offset
	if Slabs.rooms.has(surrID[dir.n]):
		var roomFace = surrID[dir.n] + 1
		var offset = ((roomFace-slabID)*28)*9
		if surrID[dir.ne] == surrID[dir.n] and surrID[dir.nw] == surrID[dir.n]:
			offset += 9*9
		modify0 = offset
		modify1 = offset
		modify2 = offset
	if Slabs.rooms.has(surrID[dir.e]):
		var roomFace = surrID[dir.e] + 1
		var offset = ((roomFace-slabID)*28)*9
		if surrID[dir.se] == surrID[dir.e] and surrID[dir.ne] == surrID[dir.e]:
			offset += 9*9
		modify2 = offset
		modify5 = offset
		modify8 = offset
	
	if surrID[dir.s] == Slabs.LAVA:
		modify6 = 9*9
		modify7 = 9*9
		modify8 = 9*9
	elif surrID[dir.s] == Slabs.WATER:
		modify6 = 18*9
		modify7 = 18*9
		modify8 = 18*9
	
	if surrID[dir.w] == Slabs.LAVA:
		modify0 = 9*9
		modify3 = 9*9
		modify6 = 9*9
	elif surrID[dir.w] == Slabs.WATER:
		modify0 = 18*9
		modify3 = 18*9
		modify6 = 18*9
	
	if surrID[dir.n] == Slabs.LAVA:
		modify0 = 9*9
		modify1 = 9*9
		modify2 = 9*9
	elif surrID[dir.n] == Slabs.WATER:
		modify0 = 18*9
		modify1 = 18*9
		modify2 = 18*9
	
	if surrID[dir.e] == Slabs.LAVA:
		modify2 = 9*9
		modify5 = 9*9
		modify8 = 9*9
	elif surrID[dir.e] == Slabs.WATER:
		modify2 = 18*9
		modify5 = 18*9
		modify8 = 18*9
	
	asset3x3group[0] += modify0
	asset3x3group[1] += modify1
	asset3x3group[2] += modify2
	asset3x3group[3] += modify3
	asset3x3group[4] += modify4
	asset3x3group[5] += modify5
	asset3x3group[6] += modify6
	asset3x3group[7] += modify7
	asset3x3group[8] += modify8
	
	return asset3x3group

func modify_for_liquid(asset3x3group, surrID, slabID):
	
	# Don't modify slab if slab is liquid
	if slabID == Slabs.WATER or slabID == Slabs.LAVA:
		return asset3x3group
	
	var modify0 = 0; var modify1 = 0; var modify2 = 0; var modify3 = 0; var modify4 = 0; var modify5 = 0; var modify6 = 0; var modify7 = 0; var modify8 = 0
	if surrID[dir.s] == Slabs.LAVA:
		modify6 = 9*9
		modify7 = 9*9
		modify8 = 9*9
	elif surrID[dir.s] == Slabs.WATER:
		modify6 = 18*9
		modify7 = 18*9
		modify8 = 18*9
	
	if surrID[dir.w] == Slabs.LAVA:
		modify0 = 9*9
		modify3 = 9*9
		modify6 = 9*9
	elif surrID[dir.w] == Slabs.WATER:
		modify0 = 18*9
		modify3 = 18*9
		modify6 = 18*9
	
	if surrID[dir.n] == Slabs.LAVA:
		modify0 = 9*9
		modify1 = 9*9
		modify2 = 9*9
	elif surrID[dir.n] == Slabs.WATER:
		modify0 = 18*9
		modify1 = 18*9
		modify2 = 18*9
	
	if surrID[dir.e] == Slabs.LAVA:
		modify2 = 9*9
		modify5 = 9*9
		modify8 = 9*9
	elif surrID[dir.e] == Slabs.WATER:
		modify2 = 18*9
		modify5 = 18*9
		modify8 = 18*9
	
	asset3x3group[0] += modify0
	asset3x3group[1] += modify1
	asset3x3group[2] += modify2
	asset3x3group[3] += modify3
	asset3x3group[4] += modify4
	asset3x3group[5] += modify5
	asset3x3group[6] += modify6
	asset3x3group[7] += modify7
	asset3x3group[8] += modify8
	
	return asset3x3group

func make_slab(slabVariation, bitmask):
	var constructedSlab = bitmaskToSlab[bitmask].duplicate()
	for subtile in 9:
		constructedSlab[subtile] = ((slabVariation+constructedSlab[subtile]) * 9) + subtile
	return constructedSlab

var bitmaskToSlab = {
	00:slab_center,
	01:slab_s,
	02:slab_w,
	04:slab_n,
	08:slab_e,
	03:slab_sw,
	06:slab_nw,
	12:slab_ne,
	09:slab_se,
	15:slab_all,
	05:slab_sn,
	10:slab_ew,
	07:slab_swn,
	11:slab_swe,
	13:slab_sen,
	14:slab_wne,
	1000:slab_temple_odd,
}

const slab_center = [
	dir.center, # subtile 0
	dir.center, # subtile 1
	dir.center, # subtile 2
	dir.center, # subtile 3
	dir.center, # subtile 4
	dir.center, # subtile 5
	dir.center, # subtile 6
	dir.center, # subtile 7
	dir.center, # subtile 8
]
const slab_s = [
	dir.s, # subtile 0
	dir.s, # subtile 1
	dir.s, # subtile 2
	dir.s, # subtile 3
	dir.s, # subtile 4
	dir.s, # subtile 5
	dir.s, # subtile 6
	dir.s, # subtile 7
	dir.s, # subtile 8
]
const slab_w = [
	dir.w, # subtile 0
	dir.w, # subtile 1
	dir.w, # subtile 2
	dir.w, # subtile 3
	dir.w, # subtile 4
	dir.w, # subtile 5
	dir.w, # subtile 6
	dir.w, # subtile 7
	dir.w, # subtile 8
]
const slab_n = [
	dir.n, # subtile 0
	dir.n, # subtile 1
	dir.n, # subtile 2
	dir.n, # subtile 3
	dir.n, # subtile 4
	dir.n, # subtile 5
	dir.n, # subtile 6
	dir.n, # subtile 7
	dir.n, # subtile 8
]
const slab_e = [
	dir.e, # subtile 0
	dir.e, # subtile 1
	dir.e, # subtile 2
	dir.e, # subtile 3
	dir.e, # subtile 4
	dir.e, # subtile 5
	dir.e, # subtile 6
	dir.e, # subtile 7
	dir.e, # subtile 8
]
const slab_sw = [
	dir.sw, # subtile 0
	dir.sw, # subtile 1
	dir.sw, # subtile 2
	dir.sw, # subtile 3
	dir.sw, # subtile 4
	dir.sw, # subtile 5
	dir.sw, # subtile 6
	dir.sw, # subtile 7
	dir.sw, # subtile 8
]
const slab_nw = [
	dir.nw, # subtile 0
	dir.nw, # subtile 1
	dir.nw, # subtile 2
	dir.nw, # subtile 3
	dir.nw, # subtile 4
	dir.nw, # subtile 5
	dir.nw, # subtile 6
	dir.nw, # subtile 7
	dir.nw, # subtile 8
]
const slab_ne = [
	dir.ne, # subtile 0
	dir.ne, # subtile 1
	dir.ne, # subtile 2
	dir.ne, # subtile 3
	dir.ne, # subtile 4
	dir.ne, # subtile 5
	dir.ne, # subtile 6
	dir.ne, # subtile 7
	dir.ne, # subtile 8
]
const slab_se = [
	dir.se, # subtile 0
	dir.se, # subtile 1
	dir.se, # subtile 2
	dir.se, # subtile 3
	dir.se, # subtile 4
	dir.se, # subtile 5
	dir.se, # subtile 6
	dir.se, # subtile 7
	dir.se, # subtile 8
]
const slab_all = [
	dir.all, # subtile 0
	dir.all, # subtile 1
	dir.all, # subtile 2
	dir.all, # subtile 3
	dir.all, # subtile 4
	dir.all, # subtile 5
	dir.all, # subtile 6
	dir.all, # subtile 7
	dir.all, # subtile 8
]
const slab_sn = [
	dir.n, # subtile 0
	dir.n, # subtile 1
	dir.n, # subtile 2
	dir.s, # subtile 3
	dir.all, # subtile 4
	dir.s, # subtile 5
	dir.s, # subtile 6
	dir.s, # subtile 7
	dir.s, # subtile 8
]

const slab_ew = [
	dir.w, # subtile 0
	dir.w, # subtile 1
	dir.e, # subtile 2
	dir.w, # subtile 3
	dir.all, # subtile 4
	dir.e, # subtile 5
	dir.w, # subtile 6
	dir.w, # subtile 7
	dir.e, # subtile 8
]

const slab_sen = [
	dir.ne, # subtile 0
	dir.ne, # subtile 1
	dir.ne, # subtile 2
	dir.se, # subtile 3
	dir.all, # subtile 4
	dir.all, # subtile 5
	dir.se, # subtile 6
	dir.se, # subtile 7
	dir.se, # subtile 8
]

const slab_swe = [
	dir.sw, # subtile 0
	dir.sw, # subtile 1
	dir.se, # subtile 2
	dir.sw, # subtile 3
	dir.all, # subtile 4
	dir.se, # subtile 5
	dir.sw, # subtile 6
	dir.all, # subtile 7
	dir.se, # subtile 8
]

const slab_swn = [
	dir.nw, # subtile 0
	dir.nw, # subtile 1
	dir.nw, # subtile 2
	dir.all, # subtile 3
	dir.all, # subtile 4
	dir.sw, # subtile 5
	dir.sw, # subtile 6
	dir.sw, # subtile 7
	dir.sw, # subtile 8
]

const slab_wne = [
	dir.nw, # subtile 0
	dir.all, # subtile 1
	dir.ne, # subtile 2
	dir.nw, # subtile 3
	dir.all, # subtile 4
	dir.ne, # subtile 5
	dir.nw, # subtile 6
	dir.nw, # subtile 7
	dir.ne, # subtile 8
]

const slab_temple_odd = [
	dir.s, # subtile 0
	dir.s, # subtile 1
	dir.s, # subtile 2
	dir.e, # subtile 3
	dir.all, # subtile 4
	dir.w, # subtile 5
	dir.n, # subtile 6
	dir.n, # subtile 7
	dir.n, # subtile 8
]

func update_wibble(xSlab, ySlab, slabID, includeNearby):
	# I'm using surrounding wibble to update this slab's wibble, instead of using surrounding slabID, this is for the sake of custom slabs
	
	var myWibble = Slabs.data[slabID][Slabs.WIBBLE_TYPE]
	
	var xWib = xSlab * 3
	var yWib = ySlab * 3
	
	# O T T O
	# L C C R
	# L C C R
	# O B B O
	
	var centerPos1 = Vector2(xWib+1, yWib+1)
	var centerPos2 = Vector2(xWib+2, yWib+1)
	var centerPos3 = Vector2(xWib+1, yWib+2)
	var centerPos4 = Vector2(xWib+2, yWib+2)
	
	var nPos1 = Vector2(xWib+1, yWib+0)
	var nPos2 = Vector2(xWib+2, yWib+0)
	
	var wPos1 = Vector2(xWib+0, yWib+1)
	var wPos2 = Vector2(xWib+0, yWib+2)
	
	var ePos1 = Vector2(xWib+3, yWib+1)
	var ePos2 = Vector2(xWib+3, yWib+2)
	
	var sPos1 = Vector2(xWib+1, yWib+3)
	var sPos2 = Vector2(xWib+2, yWib+3)
	
	var nwPos = Vector2(xWib+0, yWib+0)
	var nePos = Vector2(xWib+3, yWib+0)
	var swPos = Vector2(xWib+0, yWib+3)
	var sePos = Vector2(xWib+3, yWib+3)
	
	oDataWibble.set_cellv(centerPos1, myWibble)
	oDataWibble.set_cellv(centerPos2, myWibble)
	oDataWibble.set_cellv(centerPos3, myWibble)
	oDataWibble.set_cellv(centerPos4, myWibble)
	
	if myWibble == Slabs.WIBBLE_ON or includeNearby == true:
		for pos in [nPos1, nPos2, wPos1, wPos2, ePos1, ePos2, sPos1, sPos2, nwPos, nePos, swPos, sePos]:
			oDataWibble.set_cellv(pos, myWibble)
	else:
		var nCheck = oDataWibble.get_cellv(nPos1 + Vector2(0,-1))
		var wCheck = oDataWibble.get_cellv(wPos1 + Vector2(-1,0))
		var sCheck = oDataWibble.get_cellv(sPos1 + Vector2(0,1))
		var eCheck = oDataWibble.get_cellv(ePos1 + Vector2(1,0))
		
		var nwCheck = oDataWibble.get_cellv(nwPos + Vector2(-1,-1))
		var neCheck = oDataWibble.get_cellv(nePos + Vector2(1,-1))
		var swCheck = oDataWibble.get_cellv(swPos + Vector2(-1,1))
		var seCheck = oDataWibble.get_cellv(sePos + Vector2(1,1))
		
		if nCheck == myWibble:
			oDataWibble.set_cellv(nPos1, myWibble)
			oDataWibble.set_cellv(nPos2, myWibble)
		if wCheck == myWibble:
			oDataWibble.set_cellv(wPos1, myWibble)
			oDataWibble.set_cellv(wPos2, myWibble)
		if eCheck == myWibble:
			oDataWibble.set_cellv(ePos1, myWibble)
			oDataWibble.set_cellv(ePos2, myWibble)
		if sCheck == myWibble:
			oDataWibble.set_cellv(sPos1, myWibble)
			oDataWibble.set_cellv(sPos2, myWibble)
		
		if nwCheck == myWibble and nCheck == myWibble and wCheck == myWibble:
			oDataWibble.set_cellv(nwPos, myWibble)
		if neCheck == myWibble and nCheck == myWibble and eCheck == myWibble:
			oDataWibble.set_cellv(nePos, myWibble)
		if swCheck == myWibble and sCheck == myWibble and wCheck == myWibble:
			oDataWibble.set_cellv(swPos, myWibble)
		if seCheck == myWibble and sCheck == myWibble and eCheck == myWibble:
			oDataWibble.set_cellv(sePos, myWibble)

var slabsThatCanBeUsedAsCornerFiller = {
	Slabs.PATH:0,
	Slabs.WATER:1,
	Slabs.LAVA:2,
}

const blankCubes = [0,0,0,0,0,0,0,0]

func make_impenetrable_frail(fullSlabData, surrID):
	if oFrailImpenetrableCheckbox.pressed == false:
		return fullSlabData
	
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	var checkN = 0
	var checkS = 0
	var checkE = 0
	var checkW = 0
	if surrID[dir.n] == Slabs.WATER or surrID[dir.n] == Slabs.LAVA:
		checkN = surrID[dir.n]
	if surrID[dir.s] == Slabs.WATER or surrID[dir.s] == Slabs.LAVA:
		checkS = surrID[dir.s]
	if surrID[dir.e] == Slabs.WATER or surrID[dir.e] == Slabs.LAVA:
		checkE = surrID[dir.e]
	if surrID[dir.w] == Slabs.WATER or surrID[dir.w] == Slabs.LAVA:
		checkW = surrID[dir.w]
	
	# Water and lava in every direction, this is a single block.
	if checkN != 0 and checkS != 0 and checkE != 0 and checkW != 0:
		return fullSlabData
	
	if checkN != 0:
		if checkE != 0:
			match checkN:
				Slabs.WATER:
					slabCubes[2] = blankCubes.duplicate(true)
					slabFloor[2] = 545
				Slabs.LAVA:
					slabCubes[2] = blankCubes.duplicate(true)
					slabFloor[2] = Random.choose(rngLava)
		if checkW != 0:
			match checkN:
				Slabs.WATER:
					slabCubes[0] = blankCubes.duplicate(true)
					slabFloor[0] = 545
				Slabs.LAVA:
					slabCubes[0] = blankCubes.duplicate(true)
					slabFloor[0] = Random.choose(rngLava)
	
	if checkS != 0:
		if checkW != 0:
			match checkS:
				Slabs.WATER:
					slabCubes[6] = blankCubes.duplicate(true)
					slabFloor[6] = 545
				Slabs.LAVA:
					slabCubes[6] = blankCubes.duplicate(true)
					slabFloor[6] = Random.choose(rngLava)
		if checkE != 0:
			match checkS:
				Slabs.WATER:
					slabCubes[8] = blankCubes.duplicate(true)
					slabFloor[8] = 545
				Slabs.LAVA:
					slabCubes[8] = blankCubes.duplicate(true)
					slabFloor[8] = Random.choose(rngLava)
	
	return fullSlabData

func corner_filler_and_solo_slab(asset3x3group, surrID, bitmask, slabID):
	if oFrailSoloSlabsCheckbox.pressed == false:
		return asset3x3group
	
	if bitmask != 15:
		return asset3x3group
	if slabID != Slabs.ROCK and slabID != Slabs.EARTH and slabID != Slabs.GOLD:
		return asset3x3group

	var cornerTopLeft = null
	var cornerTopRight = null
	var cornerBottomLeft = null
	var cornerBottomRight = null

	if surrID[dir.n] == surrID[dir.w]:
		if slabsThatCanBeUsedAsCornerFiller.has(surrID[dir.n]):
			cornerTopLeft = surrID[dir.n]
			# In the case of how two filler slabs decide to fill their corners
			if slabsThatCanBeUsedAsCornerFiller.has(slabID) and surrID[dir.n] != surrID[dir.nw] and slabsThatCanBeUsedAsCornerFiller.has(surrID[dir.nw]):
				if slabsThatCanBeUsedAsCornerFiller[cornerTopLeft] > slabsThatCanBeUsedAsCornerFiller[slabID]:
					cornerTopLeft = null

	if surrID[dir.n] == surrID[dir.e]:
		if slabsThatCanBeUsedAsCornerFiller.has(surrID[dir.n]):
			cornerTopRight = surrID[dir.n]
			if slabsThatCanBeUsedAsCornerFiller.has(slabID) and surrID[dir.n] != surrID[dir.ne] and slabsThatCanBeUsedAsCornerFiller.has(surrID[dir.ne]):
				if slabsThatCanBeUsedAsCornerFiller[cornerTopRight] > slabsThatCanBeUsedAsCornerFiller[slabID]:
					cornerTopRight = null

	if surrID[dir.s] == surrID[dir.w]:
		if slabsThatCanBeUsedAsCornerFiller.has(surrID[dir.s]):
			cornerBottomLeft = surrID[dir.s]
			if slabsThatCanBeUsedAsCornerFiller.has(slabID) and surrID[dir.s] != surrID[dir.sw] and slabsThatCanBeUsedAsCornerFiller.has(surrID[dir.sw]):
				if slabsThatCanBeUsedAsCornerFiller[cornerBottomLeft] > slabsThatCanBeUsedAsCornerFiller[slabID]:
					cornerBottomLeft = null

	if surrID[dir.s] == surrID[dir.e]:
		if slabsThatCanBeUsedAsCornerFiller.has(surrID[dir.s]):
			cornerBottomRight = surrID[dir.s]
			if slabsThatCanBeUsedAsCornerFiller.has(slabID) and surrID[dir.s] != surrID[dir.se] and slabsThatCanBeUsedAsCornerFiller.has(surrID[dir.se]):
				if slabsThatCanBeUsedAsCornerFiller[cornerBottomRight] > slabsThatCanBeUsedAsCornerFiller[slabID]:
					cornerBottomRight = null

	if cornerTopLeft != null and cornerTopRight != null and cornerBottomLeft != null and cornerBottomRight != null:
		if Random.chance_int(50): cornerTopLeft = null
		if Random.chance_int(50): cornerTopRight = null
		if Random.chance_int(50): cornerBottomLeft = null
		if Random.chance_int(50): cornerBottomRight = null

	if cornerTopLeft != null:
		asset3x3group[0] = cornerTopLeft * 28 * 9
	if cornerTopRight != null:
		asset3x3group[2] = cornerTopRight * 28 * 9
	if cornerBottomLeft != null:
		asset3x3group[6] = cornerBottomLeft * 28 * 9
	if cornerBottomRight != null:
		asset3x3group[8] = cornerBottomRight * 28 * 9

	return asset3x3group
