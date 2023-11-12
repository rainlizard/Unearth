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
onready var oMirrorOptions = Nodelist.list["oMirrorOptions"]
onready var oMirrorPlacementCheckBox = Nodelist.list["oMirrorPlacementCheckBox"]
onready var oMirrorFlipCheckBox = Nodelist.list["oMirrorFlipCheckBox"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oFortifyCheckBox = Nodelist.list["oFortifyCheckBox"]
onready var oRoundPathNearLiquid = Nodelist.list["oRoundPathNearLiquid"]
onready var oRoundEarthNearPath = Nodelist.list["oRoundEarthNearPath"]
onready var oRoundEarthNearLiquid = Nodelist.list["oRoundEarthNearLiquid"]
onready var oRoundRockNearPath = Nodelist.list["oRoundRockNearPath"]
onready var oRoundRockNearLiquid = Nodelist.list["oRoundRockNearLiquid"]
onready var oRoundGoldNearPath = Nodelist.list["oRoundGoldNearPath"]
onready var oRoundGoldNearLiquid = Nodelist.list["oRoundGoldNearLiquid"]
onready var oRoundWaterNearLava = Nodelist.list["oRoundWaterNearLava"]
onready var oAutomaticTorchSlabsCheckbox = Nodelist.list["oAutomaticTorchSlabsCheckbox"]

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

enum {
	MIRROR_SLAB_AND_OWNER
	MIRROR_STYLE
	MIRROR_ONLY_OWNERSHIP
}

func mirror_placement(shapePositionArray, mirrorWhat):
	var mirroredPositionArray = []
	var actions = []
	match oMirrorOptions.splitType:
		0: actions = [0]
		1: actions = [1]
		2: actions = [0,1,2]
	
	var flip = oMirrorFlipCheckBox.pressed
	
	var fieldX = M.xSize
	var fieldY = M.ySize
	
	for performAction in actions:
		for fromPos in shapePositionArray:
			
			# To
			var toPos = oMirrorOptions.mirror_calculation(performAction, flip, fromPos, fieldX, fieldY)
			
			var slabID = oDataSlab.get_cellv(fromPos)
			
			var quadrantDestination = oMirrorOptions.get_quadrant(toPos, fieldX, fieldY)
			var quadrantClickedOn = oMirrorOptions.get_quadrant(fromPos, fieldX, fieldY)
			
			var quadrantDestinationOwner = 5
			var quadrantClickedOnOwner = 5
			var mainPaint = 5
			if slabID_is_ownable(slabID) or slabID >= 1000 or mirrorWhat == MIRROR_ONLY_OWNERSHIP:
				quadrantDestinationOwner = oMirrorOptions.ownerValue[quadrantDestination]
				quadrantClickedOnOwner = oMirrorOptions.ownerValue[quadrantClickedOn]
				mainPaint = oSelection.paintOwnership
			
			var calculateOwner = false
			
			match mirrorWhat:
				MIRROR_SLAB_AND_OWNER:
					calculateOwner = true
					oDataSlab.set_cellv(toPos, slabID)
					if slabID < 1000:
						oDataCustomSlab.set_cellv(toPos, 0)
					else:
						oDataCustomSlab.set_cellv(toPos, slabID)
				MIRROR_STYLE:
					pass
				MIRROR_ONLY_OWNERSHIP:
					calculateOwner = true
			
			if calculateOwner == true:
				if oMirrorOptions.ui_quadrants_have_owner(mainPaint) == false:
					oDataOwnership.set_cellv(toPos, mainPaint)
				else:
					if mainPaint == quadrantDestinationOwner:
						oDataOwnership.set_cellv(toPos, quadrantClickedOnOwner)
					else:
						match oMirrorOptions.splitType:
							0,1:
								oDataOwnership.set_cellv(toPos, quadrantDestinationOwner)
							2:
								var otherTwoQuadrants = []
								for i in 4:
									if oMirrorOptions.ownerValue[i] == quadrantClickedOnOwner: continue
									if oMirrorOptions.ownerValue[i] == mainPaint: continue
									otherTwoQuadrants.append(oMirrorOptions.ownerValue[i])
								
								if otherTwoQuadrants.size() == 2:
									if quadrantDestinationOwner == otherTwoQuadrants[0]:
										oDataOwnership.set_cellv(toPos, otherTwoQuadrants[1])
									else:
										oDataOwnership.set_cellv(toPos, otherTwoQuadrants[0])
								else:
									oDataOwnership.set_cellv(toPos, quadrantDestinationOwner)
			
			# Always add position to mirroredPositionArray, decide what to do with the positions after the loop is done.
			mirroredPositionArray.append(toPos)
	
	# Do different stuff with mirroredPositionArray depending on what we're mirroring
	match mirrorWhat:
		MIRROR_SLAB_AND_OWNER:
			oOverheadOwnership.update_ownership_image_based_on_shape(mirroredPositionArray)
		MIRROR_STYLE:
			oDataSlx.set_tileset_shape(mirroredPositionArray)
		MIRROR_ONLY_OWNERSHIP:
			oOverheadOwnership.update_ownership_image_based_on_shape(mirroredPositionArray)
	
	var updateNearby = oSelection.some_manual_placements_dont_update_nearby()
	generate_slabs_based_on_id(mirroredPositionArray, updateNearby) # Always necessary when updating ownership


func slabID_is_ownable(slabID):
	if oOwnableNaturalTerrain.pressed == false and Slabs.data.has(slabID) and Slabs.data[slabID][Slabs.IS_OWNABLE] == false:
		return false
	return true


func place_shape_of_slab_id(shapePositionArray, slabID, ownership):
	var ownable = slabID_is_ownable(slabID)
	if ownable == false and slabID < 1000:
		ownership = 5
	
	var surroundingPositions = {}
	var removeFromShape = []
	
	var CODETIME_START = OS.get_ticks_msec()
	for pos in shapePositionArray:
		oDataOwnership.set_cellv(pos, ownership)
		
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
#			Slabs.EARTH:
#				var autoEarthID = auto_torch_slab(pos.x, pos.y, slabID)
#				oDataSlab.set_cellv(pos, autoEarthID)
#			Slabs.WALL_AUTOMATIC:
#				var autoWallID = auto_wall(pos.x, pos.y, slabID)
#				oDataSlab.set_cellv(pos, autoWallID)
			_:
				oDataSlab.set_cellv(pos, slabID)
		
		if oFortifyCheckBox.pressed == true:
			if ownership != 5 and slabID != Slabs.WALL_AUTOMATIC and Slabs.auto_wall_updates_these.has(slabID) == false:
				surroundingPositions[Vector2(pos.x - 1, pos.y)] = 1
				surroundingPositions[Vector2(pos.x + 1, pos.y)] = 1
				surroundingPositions[Vector2(pos.x, pos.y - 1)] = 2
				surroundingPositions[Vector2(pos.x, pos.y + 1)] = 2
	
	# Fortify any walls that surround the shape
	for doPos in surroundingPositions.keys():
		if shapePositionArray.has(doPos) == false: # Skip the inside of the shape
			
			var side1
			var side2
			match surroundingPositions[doPos]:
				1:
					side1 = Vector2(0,1)
					side2 = Vector2(0,-1)
				2:
					side1 = Vector2(1,0)
					side2 = Vector2(-1,0)
			
			var threePosArray = [doPos, doPos+side1, doPos+side2]
			for i in 3:
				var threePos = threePosArray[i]
				
				var surrSlab = oDataSlab.get_cellv(threePos)
				# Only IDs that are EARTH or EARTH_WITH_TORCH will become fortified walls.
				if surrSlab == Slabs.EARTH or surrSlab == Slabs.EARTH_WITH_TORCH:
					oDataOwnership.set_cellv(threePos, ownership)
					#var autoWallID = auto_wall(threePos.x, threePos.y, slabID)
					oDataSlab.set_cellv(threePos, Slabs.WALL_AUTOMATIC)
					shapePositionArray.append(threePos)
				else:
					# Skip the corners if the NSEW direction isn't a reinforced wall
					if i == 0:
						if Slabs.auto_wall_updates_these.has(surrSlab) == false and surrSlab != Slabs.WALL_AUTOMATIC:
							break
	
	# Any removals to the shape
	for i in removeFromShape:
		shapePositionArray.erase(i)
	
	print('Slab IDs set in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

onready var oLoadingBar = Nodelist.list["oLoadingBar"]

func generate_slabs_based_on_id(shapePositionArray, updateNearby):
	oOverheadOwnership.update_ownership_image_based_on_shape(shapePositionArray)
	var CODETIME_START = OS.get_ticks_msec()
	
	oEditor.mapHasBeenEdited = true
	if updateNearby == true:
		# Include surrounding. This only takes 14ms to 'Update all slabs'
		var surroundingShape = {}
		var shapePositionDictionary = {}
		for pos in shapePositionArray:
			shapePositionDictionary[pos] = true
		for pos in shapePositionArray:
			if shapePositionDictionary.has(pos+Vector2(1,0)) == false: surroundingShape[pos+Vector2(1,0)] = true
			if shapePositionDictionary.has(pos+Vector2(-1,0)) == false: surroundingShape[pos+Vector2(-1,0)] = true
			if shapePositionDictionary.has(pos+Vector2(0,1)) == false: surroundingShape[pos+Vector2(0,1)] = true
			if shapePositionDictionary.has(pos+Vector2(0,-1)) == false: surroundingShape[pos+Vector2(0,-1)] = true
			if shapePositionDictionary.has(pos+Vector2(1,1)) == false: surroundingShape[pos+Vector2(1,1)] = true
			if shapePositionDictionary.has(pos+Vector2(-1,-1)) == false: surroundingShape[pos+Vector2(-1,-1)] = true
			if shapePositionDictionary.has(pos+Vector2(-1,1)) == false: surroundingShape[pos+Vector2(-1,1)] = true
			if shapePositionDictionary.has(pos+Vector2(1,-1)) == false: surroundingShape[pos+Vector2(1,-1)] = true
		# Merge
		shapePositionArray.append_array(surroundingShape.keys())
	#rectStart = Vector2(clamp(rectStart.x, 0, M.xSize-1), clamp(rectStart.y, 0, M.ySize-1))
	#rectEnd = Vector2(clamp(rectEnd.x, 0, M.xSize-1), clamp(rectEnd.y, 0, M.ySize-1))
	
	# Erase  (37ms)
	for i in range(shapePositionArray.size() - 1, -1, -1): # iterate in reverse
		var pos = shapePositionArray[i]
		if pos.x < 0:
			shapePositionArray.erase(pos)
			continue
		if pos.y < 0:
			shapePositionArray.erase(pos)
			continue
		if pos.x >= M.xSize:
			shapePositionArray.erase(pos)
			continue
		if pos.y >= M.ySize:
			shapePositionArray.erase(pos)
			continue
	
	oLoadingBar.visible = true
	oLoadingBar.value = 0
	var totalLoadingSize:float = max(1,shapePositionArray.size()) #abs((rectStart.x)-(rectEnd.x+1)) * abs((rectStart.y)-(rectEnd.y+1))
	var currentLoad:float = 0.0
	var loadTime = OS.get_ticks_msec()
	
	for pos in shapePositionArray:
		var slabID = oDataSlab.get_cell(pos.x, pos.y)
		var ownership = oDataOwnership.get_cell(pos.x, pos.y)
		do_slab(pos.x, pos.y, slabID, ownership)
		
		oInstances.manage_things_on_slab(pos.x, pos.y, slabID, ownership)
		
		currentLoad += 1
		
		if OS.get_ticks_msec() > loadTime+100:
			loadTime += 100
			oLoadingBar.value = (currentLoad/(totalLoadingSize))*100
			yield(get_tree(),'idle_frame')
	
	oLoadingBar.visible = false
	
	print('Generated slabs in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	oOverheadGraphics.overhead2d_update_rect(shapePositionArray)

func do_update_auto_walls(slabID):
	# Do not automatically update walls if you're manually placing a wall. (Slabs.WALL_AUTOMATIC is excluded from this check)
	if Slabs.auto_wall_updates_these.has(oSelection.paintSlab):
		return false
	if Slabs.auto_wall_updates_these.has(slabID): # Automatically update walls
		return true
	return false # Is not a wall
	
	# Only update nearby walls when placing automatic walls
#	if Slabs.auto_wall_updates_these.has(slabID) == true:
#		if oSelection.paintSlab == Slabs.WALL_AUTOMATIC:
#			return true
#		if oFortifyCheckBox.pressed == true:
#			return true
#	return false

func do_slab(xSlab, ySlab, slabID, ownership):
	var surrID = get_surrounding_slabIDs(xSlab, ySlab)
	var surrOwner = get_surrounding_ownership(xSlab, ySlab)
	
	if slabID == Slabs.WALL_AUTOMATIC or do_update_auto_walls(slabID) == true:
		slabID = auto_wall(xSlab, ySlab, slabID, surrID)
	elif slabID == Slabs.EARTH:
		slabID = auto_earth(xSlab, ySlab, slabID, surrID)
	
	if slabID >= 1000: # Custom Slab IDs
		if oCustomSlabSystem.data.has(slabID):
			slab_place_custom(xSlab, ySlab, slabID, ownership, surrID)
		return
	
	# Do not update custom slabs
	if oDataCustomSlab.get_cell(xSlab, ySlab) > 0:
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
	#Vector2(0,0), Vector2(M.xSize-1,M.ySize-1)
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	generate_slabs_based_on_id(shapePositionArray, updateNearby)

func auto_earth(xSlab:int, ySlab:int, slabID, surrID):
	slabID = auto_torch_slab(xSlab, ySlab, slabID, surrID)
	oDataSlab.set_cell(xSlab, ySlab, slabID)
	return slabID

func auto_wall(xSlab:int, ySlab:int, slabID, surrID):
	match oAutoWallArtButton.text:
		"Grouped":
			if xSlab % 15 < 15 or ySlab % 15 < 15: slabID = Slabs.WALL_WITH_PAIR
			if xSlab % 15 < 10 or ySlab % 15 < 10: slabID = Slabs.WALL_WITH_WOMAN
			if xSlab % 15 < 5 or ySlab % 15 < 5: slabID = Slabs.WALL_WITH_TWINS
		"Random":
			slabID = Random.choose([Slabs.WALL_WITH_TWINS, Slabs.WALL_WITH_WOMAN, Slabs.WALL_WITH_PAIR])
	
	# Checkerboard
	if (int(xSlab) % 2 == 0 and int(ySlab) % 2 == 0) or (int(xSlab) % 2 == 1 and int(ySlab) % 2 == 1):
		for dir in [Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,0)]:
			if oDataSlab.get_cell(xSlab+dir.x, ySlab+dir.y) == Slabs.CLAIMED_GROUND:
				slabID = Slabs.WALL_WITH_BANNER
	
	# Torch wall takes priority
	slabID = auto_torch_slab(xSlab, ySlab, slabID, surrID)
	oDataSlab.set_cell(xSlab, ySlab, slabID)
	return slabID

func auto_torch_slab(xSlab:int, ySlab:int, currentSlabID, surrID):
	if oAutomaticTorchSlabsCheckbox.pressed == false:
		return currentSlabID
	
	var claimed_ground_near = false
	# Check adjacent slabs for claimed ground if we are at every 5th slab along the x-axis or y-axis
	if xSlab % 5 == 0:
		if (xSlab + ySlab) % 2 == 1: # Is odd
			if surrID[dir.s] == Slabs.CLAIMED_GROUND:
				claimed_ground_near = true
		else:
			if surrID[dir.n] == Slabs.CLAIMED_GROUND:
				claimed_ground_near = true
	if ySlab % 5 == 0:
		if (xSlab + ySlab) % 2 == 1: # Is odd
			if surrID[dir.e] == Slabs.CLAIMED_GROUND:
				claimed_ground_near = true
		else:
			if surrID[dir.w] == Slabs.CLAIMED_GROUND:
				claimed_ground_near = true
	
	# If there's claimed ground near, change the slabID to the corresponding torch slab
	if claimed_ground_near == true:
		if currentSlabID == Slabs.EARTH:
			return Slabs.EARTH_WITH_TORCH
		else:
			return Slabs.WALL_WITH_TORCH
	
	return currentSlabID

func pick_torch_side(xSlab:int, ySlab:int, surrID):
	
	if xSlab % 5 == 0:
		if (xSlab + ySlab) % 2 == 1: # Is odd
			if surrID[dir.s] == Slabs.CLAIMED_GROUND or not Slabs.data[surrID[dir.s]][Slabs.IS_SOLID]:
				return dir.s
		else:
			if surrID[dir.n] == Slabs.CLAIMED_GROUND or not Slabs.data[surrID[dir.n]][Slabs.IS_SOLID]:
				return dir.n
	if ySlab % 5 == 0:
		if (xSlab + ySlab) % 2 == 1: # Is odd
			if surrID[dir.e] == Slabs.CLAIMED_GROUND or not Slabs.data[surrID[dir.e]][Slabs.IS_SOLID]:
				return dir.e
		else:
			if surrID[dir.w] == Slabs.CLAIMED_GROUND or not Slabs.data[surrID[dir.w]][Slabs.IS_SOLID]:
				return dir.w
	
	# If the direction fails, then pick any direction
	var preference = (xSlab + ySlab) % 4 # Prioritize directions based on the coordinate (basically it's random)
	if preference == 0 and not Slabs.data[surrID[dir.s]][Slabs.IS_SOLID]: return dir.s
	elif preference == 1 and not Slabs.data[surrID[dir.w]][Slabs.IS_SOLID]: return dir.w
	elif preference == 2 and not Slabs.data[surrID[dir.n]][Slabs.IS_SOLID]: return dir.n
	elif preference == 3 and not Slabs.data[surrID[dir.e]][Slabs.IS_SOLID]: return dir.e
	# Check the next available direction
	if not Slabs.data[surrID[dir.s]][Slabs.IS_SOLID]: return dir.s
	elif not Slabs.data[surrID[dir.w]][Slabs.IS_SOLID]: return dir.w
	elif not Slabs.data[surrID[dir.n]][Slabs.IS_SOLID]: return dir.n
	elif not Slabs.data[surrID[dir.e]][Slabs.IS_SOLID]: return dir.e
	return -1 # If all directions are solid, return -1 for no torch placement

func place_general(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType):
	var fullVariationIndex = slabID * 28
	
	var bitmask
	match bitmaskType:
		Slabs.BITMASK_GENERAL: bitmask = get_general_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_CLAIMED: bitmask = get_claimed_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_TALL: bitmask = get_tall_bitmask(surrID)
	
	var clmIndexGroup = make_slab(fullVariationIndex, bitmask)
	clmIndexGroup = modify_for_liquid(clmIndexGroup, surrID, slabID)
	
	var fullSlabData = dkdat_position_to_column_data(clmIndexGroup)
	fullSlabData = randomize_columns(fullSlabData, slabID, bitmaskType)
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	match slabID:
		Slabs.ROCK:
			if oRoundRockNearPath.pressed == true:
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.PATH, false)
			if oRoundRockNearLiquid.pressed == true:
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.WATER, false)
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.LAVA, false)
		Slabs.GOLD:
			if oRoundGoldNearPath.pressed == true:
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.PATH, false)
			if oRoundGoldNearLiquid.pressed == true:
				# Only solo blocks are adjusted for gold. Because there's already frailness going on by default
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.WATER, true)
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.LAVA, true)
		Slabs.EARTH:
			if oRoundEarthNearPath.pressed == true:
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.PATH, false)
			if oRoundEarthNearLiquid.pressed == true:
				# Only solo blocks are adjusted for earth. Because there's already frailness going on by default
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.WATER, true)
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.LAVA, true)
		Slabs.PATH:
			if oRoundPathNearLiquid.pressed == true:
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.WATER, false) # This plays better than the inversion of it. (WATER->PATH VS PATH->WATER)
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.LAVA, false) # This plays better than the inversion of it. (LAVA->PATH VS PATH->LAVA)
		Slabs.LAVA:
			if oRoundWaterNearLava.pressed == true:
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.WATER, false)
		Slabs.WATER:
			if oRoundWaterNearLava.pressed == true:
				fullSlabData = make_frail(fullSlabData, slabID, surrID, Slabs.LAVA, false)
		Slabs.EARTH_WITH_TORCH:
			slabCubes = adjust_torch_cubes(xSlab, ySlab, slabCubes, surrID)
		Slabs.CLAIMED_GROUND:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_FLOOR, bitmask, slabID)
		Slabs.DUNGEON_HEART:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_HEART, bitmask, slabID)
		Slabs.PORTAL:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_PORTAL, bitmask, slabID)
	
	set_columns(xSlab, ySlab, slabCubes, slabFloor)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab, slabID, ownership, fullVariationIndex, bitmask, surrID, surrOwner)

func place_fortified_wall(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType):
	var fullVariationIndex = slabID * 28
	
	var bitmask = get_wall_bitmask(xSlab, ySlab, surrID, ownership)
	var clmIndexGroup = make_slab(fullVariationIndex, bitmask)
	
	# Wall corners
	# 0 1 2
	# 3 4 5
	# 6 7 8
	var wallS = Slabs.data[ surrID[dir.s] ][Slabs.BITMASK_TYPE]
	var wallW = Slabs.data[ surrID[dir.w] ][Slabs.BITMASK_TYPE]
	var wallN = Slabs.data[ surrID[dir.n] ][Slabs.BITMASK_TYPE]
	var wallE = Slabs.data[ surrID[dir.e] ][Slabs.BITMASK_TYPE]
	if wallN == bitmaskType and wallE == bitmaskType and Slabs.data[ surrID[dir.ne] ][Slabs.IS_SOLID] == false:
		clmIndexGroup[2] = ((fullVariationIndex + dir.all) * 9) + 2
	if wallN == bitmaskType and wallW == bitmaskType and Slabs.data[ surrID[dir.nw] ][Slabs.IS_SOLID] == false:
		clmIndexGroup[0] = ((fullVariationIndex + dir.all) * 9) + 0
	if wallS == bitmaskType and wallE == bitmaskType and Slabs.data[ surrID[dir.se] ][Slabs.IS_SOLID] == false:
		clmIndexGroup[8] = ((fullVariationIndex + dir.all) * 9) + 8
	if wallS == bitmaskType and wallW == bitmaskType and Slabs.data[ surrID[dir.sw] ][Slabs.IS_SOLID] == false:
		clmIndexGroup[6] = ((fullVariationIndex + dir.all) * 9) + 6
	
	clmIndexGroup = modify_wall_based_on_nearby_room_and_liquid(clmIndexGroup, surrID, slabID)
	
	var fullSlabData = dkdat_position_to_column_data(clmIndexGroup)
	fullSlabData = randomize_columns(fullSlabData, slabID, bitmaskType)
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	if slabID == Slabs.WALL_WITH_TORCH:
		slabCubes = adjust_torch_cubes(xSlab, ySlab, slabCubes, surrID)
	
	slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_WALL, bitmask, slabID)
	
	set_columns(xSlab, ySlab, slabCubes, slabFloor)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab, slabID, ownership, fullVariationIndex, bitmask, surrID, surrOwner)


func place_other(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType): # These slabs only have 8 variations each, compared to the others which have 28 each.
	var fullVariationIndex = slabID * 28
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
	
	var bitmask = 1
	var clmIndexGroup = make_slab(fullVariationIndex, bitmask)
	
	var fullSlabData = dkdat_position_to_column_data(clmIndexGroup)
	fullSlabData = randomize_columns(fullSlabData, slabID, bitmaskType)
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	match slabID:
		Slabs.WOODEN_DOOR_1, Slabs.BRACED_DOOR_1, Slabs.IRON_DOOR_1, Slabs.MAGIC_DOOR_1:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_DOOR_1, 0, slabID)
		Slabs.WOODEN_DOOR_2, Slabs.BRACED_DOOR_2, Slabs.IRON_DOOR_2, Slabs.MAGIC_DOOR_2:
			slabCubes = set_ownership_graphic(slabCubes, ownership, OWNERSHIP_GRAPHIC_DOOR_2, 0, slabID)
	
	set_columns(xSlab, ySlab, slabCubes, slabFloor)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab, slabID, ownership, fullVariationIndex, bitmask, null, null)

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
const stoneRatio = 0.15

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

func dkdat_position_to_column_data(clmIndexGroup):
	var slabCubes = []
	var slabFloor = []
	#print(clmIndexGroup)
	
	for subtile in 9:
		var variation = clmIndexGroup[subtile] / 9
		var dkClmIndex = Slabset.fetch_column_index(variation, subtile)
		
		# Get the cube data from oDkClm
		slabCubes.append(Columnset.cubes[dkClmIndex])
		slabFloor.append(Columnset.floorTexture[dkClmIndex])
	return [slabCubes.duplicate(true), slabFloor.duplicate(true)] # So they're no longer references


#	var clmIndexArray = [0,0,0, 0,0,0, 0,0,0]
#	for i in 9:
#		var fullVariationIndex = clmIndexGroup[i] / 9
#		var newSubtile = clmIndexGroup[i] - (fullVariationIndex*9)
#
#		# Prevent crash if I do something dumb, just show a purple tile
#		if fullVariationIndex >= oSlabPalette.slabPal.size():
#			clmIndexArray[i] = oSlabPalette.slabPal[1303][0] # Show purple
#			continue
#
#		clmIndexArray[i] = oSlabPalette.slabPal[fullVariationIndex][newSubtile] # slab variation - subtile of that variation
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

func adjust_torch_cubes(xSlab, ySlab, slabCubes, surrID):
	var torchSideToKeep = pick_torch_side(xSlab, ySlab, surrID)
	
	var side = 0
	for subtile in [7,3,1,5]: # S W N E
		if torchSideToKeep != side:
			# Wall Torch Cube: 119
			# Earth Torch Cube: 24
			if slabCubes[subtile][3] == 119 or slabCubes[subtile][3] == 24:
				# Paint with "normal wall" cube.
				var replaceUsingCubeBelowIt = slabCubes[subtile][2]
				slabCubes[subtile][3] = replaceUsingCubeBelowIt
		side += 1
	return slabCubes

func modify_wall_based_on_nearby_room_and_liquid(clmIndexGroup, surrID, slabID):
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
	
	clmIndexGroup[0] += modify0
	clmIndexGroup[1] += modify1
	clmIndexGroup[2] += modify2
	clmIndexGroup[3] += modify3
	clmIndexGroup[4] += modify4
	clmIndexGroup[5] += modify5
	clmIndexGroup[6] += modify6
	clmIndexGroup[7] += modify7
	clmIndexGroup[8] += modify8
	
	return clmIndexGroup


func modify_for_liquid(clmIndexGroup, surrID, slabID):
	
	# Don't modify slab if slab is liquid
	if slabID == Slabs.WATER or slabID == Slabs.LAVA:
		return clmIndexGroup
	
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
	
	clmIndexGroup[0] += modify0
	clmIndexGroup[1] += modify1
	clmIndexGroup[2] += modify2
	clmIndexGroup[3] += modify3
	clmIndexGroup[4] += modify4
	clmIndexGroup[5] += modify5
	clmIndexGroup[6] += modify6
	clmIndexGroup[7] += modify7
	clmIndexGroup[8] += modify8
	
	return clmIndexGroup

func make_slab(fullVariationIndex, bitmask):
	var constructedSlab = bitmaskToSlab[bitmask].duplicate()
	for subtile in 9:
		constructedSlab[subtile] = ((fullVariationIndex+constructedSlab[subtile]) * 9) + subtile
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

const blankCubes = [0,0,0,0,0,0,0,0]


func make_frail(fullSlabData, slabID, surrID, frailCornerType, onlyAdjustSoloBlocks):
	var slabCubes = fullSlabData[0]
	var slabFloor = fullSlabData[1]
	
	var checkN = -1
	var checkS = -1
	var checkE = -1
	var checkW = -1
	
	if surrID[dir.n] == frailCornerType and surrID[dir.n] != slabID:
		checkN = surrID[dir.n]
	if surrID[dir.s] == frailCornerType and surrID[dir.s] != slabID:
		checkS = surrID[dir.s]
	if surrID[dir.e] == frailCornerType and surrID[dir.e] != slabID:
		checkE = surrID[dir.e]
	if surrID[dir.w] == frailCornerType and surrID[dir.w] != slabID:
		checkW = surrID[dir.w]
	
	# Solo block
	if checkN != -1 and checkS != -1 and checkE != -1 and checkW != -1:
		if Random.chance_int(50): checkN = -1
		if Random.chance_int(50): checkS = -1
		if Random.chance_int(50): checkE = -1
		if Random.chance_int(50): checkW = -1
	else:
		if onlyAdjustSoloBlocks == true:
			return fullSlabData
	
	if checkN == checkE:
		if slabID < checkN: # Decide which one to prioritize
			if checkN == surrID[dir.n] and checkE == surrID[dir.e]:
				frail_fill_corner(checkN, 2, slabCubes, slabFloor)
		else:
			if checkN == surrID[dir.ne]:
				frail_fill_corner(checkN, 2, slabCubes, slabFloor)
	
	if checkN == checkW:
		if slabID < checkW: # Decide which one to prioritize
			if checkN == surrID[dir.n] and checkW == surrID[dir.w]:
				frail_fill_corner(checkW, 0, slabCubes, slabFloor)
		else:
			if checkW == surrID[dir.nw]:
				frail_fill_corner(checkW, 0, slabCubes, slabFloor)
	
	if checkS == checkW:
		if slabID < checkS: # Decide which one to prioritize
			if checkS == surrID[dir.s] and checkW == surrID[dir.w]:
				frail_fill_corner(checkS, 6, slabCubes, slabFloor)
		else:
			if checkS == surrID[dir.sw]:
				frail_fill_corner(checkS, 6, slabCubes, slabFloor)
	
	if checkS == checkE:
		if slabID < checkE: # Decide which one to prioritize
			if checkS == surrID[dir.s] and checkE == surrID[dir.e]:
				frail_fill_corner(checkE, 8, slabCubes, slabFloor)
		else:
			if checkE == surrID[dir.se]:
				frail_fill_corner(checkE, 8, slabCubes, slabFloor)
	
	return fullSlabData

func frail_fill_corner(slabID, index, slabCubes, slabFloor):
	match slabID:
		Slabs.WATER:
			slabFloor[index] = 545
			slabCubes[index] = blankCubes.duplicate(true)
		Slabs.LAVA:
			slabFloor[index] = Random.choose(rngLava)
			slabCubes[index] = blankCubes.duplicate(true)
		Slabs.PATH:
			slabFloor[index] = 207
			slabCubes[index] = blankCubes.duplicate(true)
			if stoneRatio < randf():
				slabCubes[index] = blankCubes.duplicate(true)
				slabCubes[index][0] = Random.choose(rngPathClean)
			else:
				slabCubes[index] = blankCubes.duplicate(true)
				slabCubes[index][0] = Random.choose(rngPathWithStones)
		Slabs.EARTH:
			slabFloor[index] = 27
			slabCubes[index] = blankCubes.duplicate(true)
			slabCubes[index][0] = 25 # No need to randomize the path cube, it's not visible and the game overwrites it anyway.
			slabCubes[index][1] = Random.choose(rngEarth)
			slabCubes[index][2] = Random.choose(rngEarth)
			slabCubes[index][3] = Random.choose(rngEarth)
			slabCubes[index][4] = 5
		Slabs.GOLD:
			slabFloor[index] = 27
			slabCubes[index] = blankCubes.duplicate(true)
			slabCubes[index][0] = 25
			slabCubes[index][1] = Random.choose(rngGold)
			slabCubes[index][2] = Random.choose(rngGold)
			slabCubes[index][3] = Random.choose(rngGold)
			slabCubes[index][4] = Random.choose(rngGold)
		Slabs.ROCK:
			slabFloor[index] = 29
			slabCubes[index] = blankCubes.duplicate(true)
			slabCubes[index][0] = 45
			slabCubes[index][1] = 45
			slabCubes[index][2] = 44
			slabCubes[index][3] = 44
			slabCubes[index][4] = 43
