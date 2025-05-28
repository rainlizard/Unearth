extends Node
onready var oReadData = Nodelist.list["oReadData"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
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
onready var oDataFakeSlab = Nodelist.list["oDataFakeSlab"]
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
onready var oPathStonePercent = Nodelist.list["oPathStonePercent"]
onready var oOnlyOwnership = Nodelist.list["oOnlyOwnership"]

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
	MIRROR_SLAB_AND_OWNER
	MIRROR_STYLE
	MIRROR_ONLY_OWNERSHIP
}

var autogen_was_called = false

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
						oDataFakeSlab.set_cellv(toPos, 0)
					else:
						oDataFakeSlab.set_cellv(toPos, slabID)
				MIRROR_STYLE:
					pass
				MIRROR_ONLY_OWNERSHIP:
					if slabID_is_ownable(slabID):
						calculateOwner = true
			
			if calculateOwner == true:
				if oMirrorOptions.ui_quadrants_have_owner(mainPaint) == false:
					oDataOwnership.set_cellv_ownership(toPos, mainPaint)
				else:
					if mainPaint == quadrantDestinationOwner:
						oDataOwnership.set_cellv_ownership(toPos, quadrantClickedOnOwner)
					else:
						match oMirrorOptions.splitType:
							0,1:
								oDataOwnership.set_cellv_ownership(toPos, quadrantDestinationOwner)
							2:
								var otherTwoQuadrants = []
								for i in 4:
									if oMirrorOptions.ownerValue[i] == quadrantClickedOnOwner: continue
									if oMirrorOptions.ownerValue[i] == mainPaint: continue
									otherTwoQuadrants.append(oMirrorOptions.ownerValue[i])
								
								if otherTwoQuadrants.size() == 2:
									if quadrantDestinationOwner == otherTwoQuadrants[0]:
										oDataOwnership.set_cellv_ownership(toPos, otherTwoQuadrants[1])
									else:
										oDataOwnership.set_cellv_ownership(toPos, otherTwoQuadrants[0])
								else:
									oDataOwnership.set_cellv_ownership(toPos, quadrantDestinationOwner)
			
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
	
	#var CODETIME_START = OS.get_ticks_msec()
	for pos in shapePositionArray:
		oDataOwnership.set_cellv_ownership(pos, ownership)
		
		if slabID < 1000:
			oDataFakeSlab.set_cellv(pos, 0)
		else:
			oDataFakeSlab.set_cellv(pos, slabID)
		
		if Slabs.data.has(slabID) and Slabs.data[slabID][Slabs.LIQUID_TYPE] == Slabs.WLB_BRIDGE and oBridgesOnlyOnLiquidCheckbox.pressed:
			var currentSlabOnPos = oDataSlab.get_cellv(pos)
			var isUnderlyingSlabLiquid = currentSlabOnPos == Slabs.WATER or currentSlabOnPos == Slabs.LAVA
			var isUnderlyingSlabBridge = Slabs.data.has(currentSlabOnPos) and Slabs.data[currentSlabOnPos][Slabs.LIQUID_TYPE] == Slabs.WLB_BRIDGE
			if isUnderlyingSlabLiquid == false and isUnderlyingSlabBridge == false:
				removeFromShape.append(pos)
		
		if removeFromShape.has(pos) == false:
			oDataSlab.set_cellv(pos, slabID)
			if oFortifyCheckBox.pressed == true:
				# The "ownership != 5" ensures that we don't accidentally spread those difficult-to-see neutral fortified walls
				# The "removeFromShape.has(pos) == false" check is for when you place a bridge in a spot you can't place it in
				if ownership != 5 and \
				Slabs.data.has(slabID) and \
				Slabs.data[slabID][Slabs.IS_OWNABLE] == true and \
				slabID != Slabs.WALL_AUTOMATIC and \
				Slabs.auto_wall_updates_these.has(slabID) == false:
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
					oDataOwnership.set_cellv_ownership(threePos, ownership)
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
	
	#print('Slab IDs set in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')

onready var oLoadingBar = Nodelist.list["oLoadingBar"]

func generate_slabs_based_on_id(shapePositionArray, updateNearby):
	oOverheadOwnership.update_ownership_image_based_on_shape(shapePositionArray)
	#var CODETIME_START = OS.get_ticks_msec()
	
	oEditor.mapHasBeenEdited = true
	
	# When adjusting "only ownership", do not affect the ownership of things on surrounding slabs (but we do need to adjust those slabs so we can't just set updateNearby to false)
	if oOnlyOwnership.visible == true and autogen_was_called == false:
		for pos in shapePositionArray:
			var slabID = oDataSlab.get_cell(pos.x, pos.y)
			var ownership = oDataOwnership.get_cell_ownership(pos.x, pos.y)
			if Slabs.data.has(slabID):
				oInstances.manage_thing_ownership_on_slab(pos.x, pos.y, ownership)
	
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
		
		var ownership = oDataOwnership.get_cell_ownership(pos.x, pos.y)
		
		if Slabs.data.has(slabID):
			do_slab(pos.x, pos.y, slabID, ownership)
			oInstances.manage_things_on_slab(pos.x, pos.y, slabID, ownership)
		
		currentLoad += 1
		
		if OS.get_ticks_msec() > loadTime+100:
			loadTime += 100
			oLoadingBar.value = (currentLoad/(totalLoadingSize))*100
			yield(get_tree(),'idle_frame')
	
	oLoadingBar.visible = false
	
	#print('Generated slabs in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	oOverheadGraphics.overhead2d_update_rect_single_threaded(shapePositionArray)
	yield(get_tree(),'idle_frame') # This is necessary for yielding this function to work. Unlike 'await' in Godot 4.0, You can only yield a function which itself also yields.

func do_update_auto_walls(slabID):
	# If this ID has been set to WALL_AUTOMATIC, by whatever reason, then it must be updated. This doesn't mean you're placing a WALL_AUTOMATIC, just that this slab has been set to it.
	if slabID == Slabs.WALL_AUTOMATIC:
		return true
	
	# Automatic torch slabs being disabled means we don't remove existing torch slabs either.
#	if oAutomaticTorchSlabsCheckbox.pressed == false and slabID == Slabs.WALL_WITH_TORCH:
#		return false
	
	# Do not automatically update anything if you're manually placing a wall.
	if Slabs.auto_wall_updates_these.has(oSelection.paintSlab):
		return false
	
	# If this ID is a wall
	if Slabs.auto_wall_updates_these.has(slabID):
		
		# If you're placing automatic walls, then you must update the nearby wall patterns, otherwise the torches get duplicated too much
		if oSelection.paintSlab == Slabs.WALL_AUTOMATIC:
			return true
		
		# If you're fortifying nearby walls, then they must be automatically set too
		if oFortifyCheckBox.pressed == true:
			return true
		
		# Never update a wall unless you're modifying it with WALL_AUTOMATIC or Fortify.
		return false
	
	return false # Is not a wall


func do_slab(xSlab, ySlab, slabID, ownership):
	var surrID = get_surrounding_slabIDs(xSlab, ySlab)
	var surrOwner = get_surrounding_ownership(xSlab, ySlab)
	
	if do_update_auto_walls(slabID) == true:
		slabID = auto_wall(xSlab, ySlab, slabID, surrID)
	
	if slabID == Slabs.EARTH or slabID == Slabs.EARTH_WITH_TORCH:
		slabID = auto_earth(xSlab, ySlab, slabID, surrID)
	
	if Slabs.fake_extra_data.has(slabID): # Fake Slab IDs
		slab_place_fake(xSlab, ySlab, slabID, ownership, surrID)
		return
	
	# Do not update Fake Slabs
	if oDataFakeSlab.get_cell(xSlab, ySlab) > 0:
		return
	
	# WIB (wibble)
	update_wibble(xSlab, ySlab, slabID, false)
	# WLB (Water Lava Block)
	if Slabs.data[slabID][Slabs.LIQUID_TYPE] != Slabs.WLB_BRIDGE:
		oDataLiquid.set_cell(xSlab, ySlab, Slabs.data[slabID][Slabs.LIQUID_TYPE])
	
	var bitmaskType = Slabs.data[slabID][Slabs.BITMASK_TYPE]
	place_general(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType)

func slab_place_fake(xSlab, ySlab, slabID, ownership, surrID):
	var recognizedAsID = Slabs.fake_extra_data[slabID][Slabs.FAKE_RECOGNIZED_AS]
	var wibbleEdges = Slabs.fake_extra_data[slabID][Slabs.FAKE_WIBBLE_EDGES]
	
	# WIB (wibble)
	update_wibble(xSlab, ySlab, slabID, wibbleEdges)
	
	# WLB (Water Lava Block)
	if Slabs.data[recognizedAsID][Slabs.LIQUID_TYPE] != Slabs.WLB_BRIDGE:
		var liquidValue = Slabs.data[slabID][Slabs.LIQUID_TYPE]
		oDataLiquid.set_cell(xSlab, ySlab, liquidValue)
	
	var constructedColumns = Slabs.fake_extra_data[slabID][Slabs.FAKE_CUBE_DATA]
	var constructedFloor = Slabs.fake_extra_data[slabID][Slabs.FAKE_FLOOR_DATA]
	
	set_columns(xSlab, ySlab, constructedColumns, constructedFloor)
	
	oDataSlab.set_cell(xSlab, ySlab, recognizedAsID)


func _on_ConfirmAutoGen_confirmed():
	var CODETIME_START = OS.get_ticks_msec()
	oMessage.quick("Auto-generated all slabs")
	var updateNearby = true
	#Vector2(0,0), Vector2(M.xSize-1,M.ySize-1)
	var shapePositionArray = []
	for ySlab in range(0, M.ySize):
		for xSlab in range(0, M.xSize):
			shapePositionArray.append(Vector2(xSlab,ySlab))
	
	autogen_was_called = true
	yield(generate_slabs_based_on_id(shapePositionArray, updateNearby), "completed")
	autogen_was_called = false
	
	print('Auto-generated all slabs: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func auto_earth(xSlab:int, ySlab:int, slabID, surrID):
	
	if slabID == Slabs.EARTH or slabID == Slabs.EARTH_WITH_TORCH:
		slabID = try_upgrade_to_torch_slab(xSlab, ySlab, slabID, surrID)
	
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
		for i in [Vector2(0,1),Vector2(-1,0),Vector2(0,-1),Vector2(1,0)]:
			if oDataSlab.get_cell(xSlab+i.x, ySlab+i.y) == Slabs.CLAIMED_GROUND:
				slabID = Slabs.WALL_WITH_BANNER
	
	# Torch wall takes priority
	slabID = try_upgrade_to_torch_slab(xSlab, ySlab, slabID, surrID)
	oDataSlab.set_cell(xSlab, ySlab, slabID)
	return slabID

func try_upgrade_to_torch_slab(xSlab:int, ySlab:int, currentSlabID, surrID):
	if oAutomaticTorchSlabsCheckbox.pressed == false:
		return currentSlabID
	
	# Check adjacent slabs for claimed ground if we are at every 5th slab along the x-axis or y-axis
	var sporadic_conditions = false
	var isOdd = (xSlab + ySlab) % 2 == 1
	if xSlab % 5 == 0:
		if isOdd and surrID[dir.s] == Slabs.CLAIMED_GROUND:
			sporadic_conditions = true
		elif !isOdd and surrID[dir.n] == Slabs.CLAIMED_GROUND:
			sporadic_conditions = true
	if ySlab % 5 == 0:
		if isOdd and surrID[dir.e] == Slabs.CLAIMED_GROUND:
			sporadic_conditions = true
		elif !isOdd and surrID[dir.w] == Slabs.CLAIMED_GROUND:
			sporadic_conditions = true
	
	# If there's claimed ground near, change the slabID to the corresponding torch slab
	if sporadic_conditions:
		if currentSlabID == Slabs.EARTH or currentSlabID == Slabs.EARTH_WITH_TORCH:
			return Slabs.EARTH_WITH_TORCH
		else:
			return Slabs.WALL_WITH_TORCH
	else:
		if currentSlabID == Slabs.EARTH_WITH_TORCH:
			return Slabs.EARTH
	return currentSlabID



# Torch sides: S:0, W:1, N:2, E:3, None:-1
# Torch subtiles: S:7, W:3, N:1, E:5, None:-1
const torchSubtileToKeepMap = {0:7, 1:3, 2:1, 3:5, -1:-1}
func set_torch_side(xSlab, ySlab, slabID, slabsetIndexGroup, constructedColumns, bitmask, surrID):
	var torchDirection = calculate_torch_side(xSlab, ySlab, surrID)
	var torchSubtileToKeep = torchSubtileToKeepMap[torchDirection]
	
	#Slabs.WALL_WITH_TORCH = 5
	#Slabs.WALL_UNDECORATED = 9
	#Slabs.EARTH_WITH_TORCH = 3
	#Slabs.EARTH = 2
	var IdDiff
	if slabID == Slabs.WALL_WITH_TORCH:
		IdDiff = Slabs.WALL_WITH_TORCH - Slabs.WALL_UNDECORATED
	elif slabID == Slabs.EARTH_WITH_TORCH:
		IdDiff = Slabs.EARTH_WITH_TORCH - Slabs.EARTH
	else:
		return
	
	var variDiff = IdDiff * 28 * 9
	var undecoratedGroup = []
	undecoratedGroup.resize(9)
	for i in 9:
		undecoratedGroup[i] = slabsetIndexGroup[i] - variDiff
	
	# This code REMOVES torches, it doesn't add torches. It sets columns to the undecorated columns.
	for subtile in [7, 3, 1, 5]:  # S W N E
		if torchSubtileToKeep != subtile:
			# Wall Torch Cube: 119
			# Earth Torch Cube: 24
			if constructedColumns[subtile][3] == 119 or constructedColumns[subtile][3] == 24:
				# For the torch cube
				constructedColumns[subtile][3] = constructedColumns[subtile][2] # Replace using the wall cube below it
				# For the torch objects
				slabsetIndexGroup[subtile] = undecoratedGroup[subtile]


func calculate_torch_side(xSlab:int, ySlab:int, surrID):
	# Check if the slab is at a multiple of 5 position
	var sporadicDir = null
	if xSlab % 5 == 0:
		if (xSlab + ySlab) % 2 == 1: # Is odd
			sporadicDir = dir.s
		else:
			sporadicDir = dir.n
	if ySlab % 5 == 0:
		if (xSlab + ySlab) % 2 == 1: # Is odd
			sporadicDir = dir.e
		else:
			sporadicDir = dir.w
	if sporadicDir != null:
		var slabAtDir = surrID[sporadicDir]
		if slabAtDir == Slabs.CLAIMED_GROUND:
			return sporadicDir
		if Slabs.data[slabAtDir][Slabs.IS_SOLID] == false and Slabs.is_door(slabAtDir) == false:
			if Slabs.rooms_that_have_walls.has(slabAtDir) == false:
				return sporadicDir
	
	# Create the directions array with the preference direction first
	var directions = []
	match (xSlab + ySlab) % 4: # Prioritize directions based on the coordinate (basically it's random)
		0: directions = [dir.s, dir.w, dir.n, dir.e]
		1: directions = [dir.w, dir.n, dir.e, dir.s]
		2: directions = [dir.n, dir.e, dir.s, dir.w]
		3: directions = [dir.e, dir.s, dir.w, dir.n]
	for direction in directions: # Check each direction in the array
		var slabAtDir = surrID[direction]
		if Slabs.data[slabAtDir][Slabs.IS_SOLID] == false and Slabs.is_door(slabAtDir) == false:
			if Slabs.rooms_that_have_walls.has(slabAtDir) == false:
				return direction
	
	return -1 # If all directions are solid or doors, return -1 for no torch placement


func determine_door_direction(xSlab, ySlab, slabID, surrID, bitmaskType):
	if Slabs.data[ surrID[dir.e] ][Slabs.IS_SOLID] == true and Slabs.data[ surrID[dir.w] ][Slabs.IS_SOLID] == true:
		if bitmaskType == Slabs.BITMASK_DOOR1:
			var newSlabID = slabID+1
			if Slabs.data.has(newSlabID):
				slabID = newSlabID # Go to DOOR 2
				bitmaskType = Slabs.BITMASK_DOOR2
				oDataSlab.set_cell(xSlab, ySlab, slabID)
			else:
				oMessage.quick("Slab structure is missing the other Door ID: " + str(newSlabID))
	elif Slabs.data[ surrID[dir.n] ][Slabs.IS_SOLID] == true and Slabs.data[ surrID[dir.s] ][Slabs.IS_SOLID] == true:
		if bitmaskType == Slabs.BITMASK_DOOR2:
			var newSlabID = slabID-1
			if Slabs.data.has(newSlabID):
				slabID = newSlabID # Go to DOOR 1
				bitmaskType = Slabs.BITMASK_DOOR1
				oDataSlab.set_cell(xSlab, ySlab, slabID)
			else:
				oMessage.quick("Slab structure is missing the other Door ID: " + str(newSlabID))
	return [slabID, bitmaskType]



func place_general(xSlab, ySlab, slabID, ownership, surrID, surrOwner, bitmaskType):
	var modifyForLiquid = true
	
	var bitmask
	match bitmaskType:
		Slabs.BITMASK_BLOCK:
			bitmask = get_tall_bitmask(surrID)
		Slabs.BITMASK_FLOOR:
			bitmask = get_general_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_CLAIMED:
			bitmask = get_claimed_bitmask(slabID, ownership, surrID, surrOwner)
		Slabs.BITMASK_REINFORCED:
			bitmask = get_wall_bitmask(xSlab, ySlab, surrID, ownership)
		Slabs.BITMASK_SIMPLE:
			bitmask = 1 # Always use south variation
			modifyForLiquid = false
		Slabs.BITMASK_DOOR1, Slabs.BITMASK_DOOR2: # Make sure door is facing the correct direction by changing its Slab based on surrounding slabs.
			bitmask = 1 # Always use south variation
			var stuff = determine_door_direction(xSlab, ySlab, slabID, surrID, bitmaskType)
			slabID = stuff[0]
			bitmaskType = stuff[1]
			modifyForLiquid = false
	# SlabID is adjusted by determine_door_direction(), so make_slab() needs to occur right after
	var slabsetIndexGroup = make_slab(slabID*28, bitmask)
	
	
	if bitmaskType == Slabs.BITMASK_REINFORCED:
		fill_reinforced_wall_corners(slabID, slabsetIndexGroup, surrID, bitmaskType)
		modify_wall_based_on_nearby_room_and_liquid(slabsetIndexGroup, surrID, slabID)
	else:
		if modifyForLiquid == true:
			modify_for_liquid(slabsetIndexGroup, surrID, slabID)
	
	
	var columnsetIndexList = slabset_position_to_column_data(slabsetIndexGroup, ownership)
	var constructedSlabData = get_constructed_slab_data(columnsetIndexList)
	var constructedColumns = constructedSlabData[0]
	var constructedFloor = constructedSlabData[1]
	
	if slabID == Slabs.WALL_WITH_TORCH or slabID == Slabs.EARTH_WITH_TORCH:
		set_torch_side(xSlab, ySlab, slabID, slabsetIndexGroup, constructedColumns, bitmask, surrID)
	
	adjust_ownership_graphic(columnsetIndexList, constructedColumns, ownership)
	randomize_columns(columnsetIndexList, constructedColumns)
	make_frail(constructedSlabData, slabID, surrID)
	
	if slabID == Slabs.LAVA: # Just hardcode the random FloorTexture for lava. I think it only looks different in the editor.
		for i in constructedFloor.size():
			constructedFloor[i] = Random.choose([546,547])
	elif slabID == Slabs.PATH:
		randomize_path_cubes(constructedColumns)
	
	set_columns(xSlab, ySlab, constructedColumns, constructedFloor)
	oPlaceThingWithSlab.place_slab_objects(xSlab, ySlab, slabID, ownership, slabsetIndexGroup, bitmask, surrID, bitmaskType)

func randomize_path_cubes(constructedColumns):
	var pthClean = Cube.rngCube["PathClean"]
	var pthStones = Cube.rngCube["PathWithStones"]
	for i in 9:
		var cubeID = constructedColumns[i][0]
		if cubeID in pthClean or cubeID in pthStones:
			if Random.rng.randf_range(0.0, 100.0) < oPathStonePercent.value:
				constructedColumns[i][0] = Random.choose(pthStones)
			else:
				constructedColumns[i][0] = Random.choose(pthClean)

func get_constructed_slab_data(columnsetIndexList):
	var constructedColumns = []
	var constructedFloor = []
	constructedColumns.resize(9)
	constructedFloor.resize(9)
	
	for subtile in 9:
		var columnsetIndex = columnsetIndexList[subtile]
		constructedColumns[subtile] = Columnset.cubes[columnsetIndex]
		constructedFloor[subtile] = Columnset.floorTexture[columnsetIndex]
	
	return [constructedColumns.duplicate(true), constructedFloor.duplicate(true)]

func fill_reinforced_wall_corners(slabID, slabsetIndexGroup, surrID, bitmaskType):
	# Wall corners
	# 0 1 2
	# 3 4 5
	# 6 7 8
	var wallS = Slabs.data[ surrID[dir.s] ][Slabs.BITMASK_TYPE]
	var wallW = Slabs.data[ surrID[dir.w] ][Slabs.BITMASK_TYPE]
	var wallN = Slabs.data[ surrID[dir.n] ][Slabs.BITMASK_TYPE]
	var wallE = Slabs.data[ surrID[dir.e] ][Slabs.BITMASK_TYPE]
	var fullVariationIndex = slabID * 28
	if wallN == bitmaskType and wallE == bitmaskType and Slabs.data[ surrID[dir.ne] ][Slabs.IS_SOLID] == false:
		slabsetIndexGroup[2] = ((fullVariationIndex + dir.all) * 9) + 2
	if wallN == bitmaskType and wallW == bitmaskType and Slabs.data[ surrID[dir.nw] ][Slabs.IS_SOLID] == false:
		slabsetIndexGroup[0] = ((fullVariationIndex + dir.all) * 9) + 0
	if wallS == bitmaskType and wallE == bitmaskType and Slabs.data[ surrID[dir.se] ][Slabs.IS_SOLID] == false:
		slabsetIndexGroup[8] = ((fullVariationIndex + dir.all) * 9) + 8
	if wallS == bitmaskType and wallW == bitmaskType and Slabs.data[ surrID[dir.sw] ][Slabs.IS_SOLID] == false:
		slabsetIndexGroup[6] = ((fullVariationIndex + dir.all) * 9) + 6

func randomize_columns(columnsetIndexList, constructedColumns):
	# For each subtile
	for subtile in range(9):  # Assuming you have 9 subtiles, adjust if necessary
		var dkClmIndex = columnsetIndexList[subtile]

		# Check if the current column has RNG cube types
		if Columnset.columnsContainingRngCubes.has(dkClmIndex):
			var rngCubeTypesInColumn = Columnset.columnsContainingRngCubes[dkClmIndex]
			# For each cube in the column
			for cubeIndex in range(8):  # Assuming 8 cubes per column
				var cubeID = constructedColumns[subtile][cubeIndex]

				# Iterate through each RNG cube type in the column
				for rngType in rngCubeTypesInColumn:
					# Check if the cube ID is part of the current RNG type
					if cubeID in Cube.rngCube[rngType]:
						# Select a random cube ID from the corresponding RNG cube group
						var randomCubeID = Cube.rngCube[rngType][randi() % Cube.rngCube[rngType].size()]

						# Replace the cube with a random one from the same group
						constructedColumns[subtile][cubeIndex] = randomCubeID
						break  # Don't bother looking at the other rngTypes for this cube position
	return constructedColumns

func adjust_ownership_graphic(columnsetIndexList, constructedColumns, ownership):
	for subtile in 9:
		var dkClmIndex = columnsetIndexList[subtile]
		if Columnset.columnsContainingOwnedCubes.has(dkClmIndex):
			var listOfStrings = Columnset.columnsContainingOwnedCubes[dkClmIndex]
			for cubeIndex in 8:
				var cubeID = constructedColumns[subtile][cubeIndex]
				for stringType in listOfStrings:
					if Cube.ownedCube[stringType].has(cubeID):
						
						# If the cube is a neutral cube, then don't change it to a player cube (because this can be a normal wall)
						if cubeID == Cube.ownedCube[stringType][5]:
							continue
						
						var setFinalCube = Cube.ownedCube[stringType][ownership]
						constructedColumns[subtile][cubeIndex] = setFinalCube
						break  # Once matched, no need to check further

func slabset_position_to_column_data(slabsetIndexGroup, ownership):
	var columnsetIndexList = []
	columnsetIndexList.resize(9)
	for subtile in 9:
		var variation = slabsetIndexGroup[subtile] / 9
		var columnsetIndex = Slabset.fetch_columnset_index(variation, subtile)
		columnsetIndexList[subtile] = columnsetIndex
	return columnsetIndexList


#	var clmIndexArray = [0,0,0, 0,0,0, 0,0,0]
#	for i in 9:
#		var fullVariationIndex = slabsetIndexGroup[i] / 9
#		var newSubtile = slabsetIndexGroup[i] - (fullVariationIndex*9)
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
#		oDataClmPos.set_cell_clmpos((xSlab*3)+xSubtile, (ySlab*3)+ySubtile, array[i])

func set_columns(xSlab, ySlab, constructedColumns, constructedFloor):
	oDataClm.a_column_has_changed_since_last_updating_utilized = true
	for i in 9:
		var clmIndex = oDataClm.index_entry(constructedColumns[i], constructedFloor[i])
		
		var ySubtile = i/3
		var xSubtile = i - (ySubtile*3)
		oDataClmPos.set_cell_clmpos((xSlab*3)+xSubtile, (ySlab*3)+ySubtile, clmIndex)

func get_tall_bitmask(surrID):
	var bitmask = 0
	if Slabs.data[ surrID[dir.s] ][Slabs.IS_SOLID] == false: bitmask += 1
	if Slabs.data[ surrID[dir.w] ][Slabs.IS_SOLID] == false: bitmask += 2
	if Slabs.data[ surrID[dir.n] ][Slabs.IS_SOLID] == false: bitmask += 4
	if Slabs.data[ surrID[dir.e] ][Slabs.IS_SOLID] == false: bitmask += 8
	return bitmask

func get_general_bitmask(slabID, ownership, surrID, surrOwner):
	var bitmask = 0 # Center
	if slabID != surrID[dir.s] or ownership != surrOwner[dir.s]: bitmask += 1
	if slabID != surrID[dir.w] or ownership != surrOwner[dir.w]: bitmask += 2
	if slabID != surrID[dir.n] or ownership != surrOwner[dir.n]: bitmask += 4
	if slabID != surrID[dir.e] or ownership != surrOwner[dir.e]: bitmask += 8
	
	# There's two kinds of 'constructed' middle slabs. slab_center and slab_partial_center
	if bitmask == 0:
		if slabID != surrID[dir.se] or slabID != surrID[dir.sw] or slabID != surrID[dir.ne] or slabID != surrID[dir.nw] or ownership != surrOwner[dir.se] or ownership != surrOwner[dir.sw] or ownership != surrOwner[dir.ne] or ownership != surrOwner[dir.nw]:
			bitmask = 500 # partial_center
	
	return bitmask

func get_wall_bitmask(xSlab, ySlab, surrID, ownership):
	var ownerS = oDataOwnership.get_cell_ownership(xSlab, ySlab+1)
	var ownerW = oDataOwnership.get_cell_ownership(xSlab-1, ySlab)
	var ownerN = oDataOwnership.get_cell_ownership(xSlab, ySlab-1)
	var ownerE = oDataOwnership.get_cell_ownership(xSlab+1, ySlab)
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
	if (slabID != surrID[dir.s] and Slabs.is_door(surrID[dir.s]) == false) or ownership != surrOwner[dir.s]: bitmask += 1
	if (slabID != surrID[dir.w] and Slabs.is_door(surrID[dir.w]) == false) or ownership != surrOwner[dir.w]: bitmask += 2
	if (slabID != surrID[dir.n] and Slabs.is_door(surrID[dir.n]) == false) or ownership != surrOwner[dir.n]: bitmask += 4
	if (slabID != surrID[dir.e] and Slabs.is_door(surrID[dir.e]) == false) or ownership != surrOwner[dir.e]: bitmask += 8
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
	
	for i in surrID.size():
		if Slabs.data.has(surrID[i]) == false:
			surrID[i] = 0
	
	return surrID

func get_surrounding_ownership(xSlab, ySlab):
	var surrOwner = []
	surrOwner.resize(8)
	surrOwner[dir.n] = oDataOwnership.get_cell_ownership(xSlab, ySlab-1)
	surrOwner[dir.s] = oDataOwnership.get_cell_ownership(xSlab, ySlab+1)
	surrOwner[dir.e] = oDataOwnership.get_cell_ownership(xSlab+1, ySlab)
	surrOwner[dir.w] = oDataOwnership.get_cell_ownership(xSlab-1, ySlab)
	surrOwner[dir.ne] = oDataOwnership.get_cell_ownership(xSlab+1, ySlab-1)
	surrOwner[dir.nw] = oDataOwnership.get_cell_ownership(xSlab-1, ySlab-1)
	surrOwner[dir.se] = oDataOwnership.get_cell_ownership(xSlab+1, ySlab+1)
	surrOwner[dir.sw] = oDataOwnership.get_cell_ownership(xSlab-1, ySlab+1)
	return surrOwner



func modify_wall_based_on_nearby_room_and_liquid(slabsetIndexGroup, surrID, slabID):
	# Combined modify_room_face() and modify_for_liquid() so that there won't be a conflict.
	# This function should opnly be used by Walls.
	
	var modify0 = 0; var modify1 = 0; var modify2 = 0; var modify3 = 0; var modify4 = 0; var modify5 = 0; var modify6 = 0; var modify7 = 0; var modify8 = 0
	
	if Slabs.rooms_that_have_walls.has(surrID[dir.s]):
		var wallFaceForRoom = surrID[dir.s] + 1
		var offset = ((wallFaceForRoom-slabID)*28)*9
		if surrID[dir.se] == surrID[dir.s] and surrID[dir.sw] == surrID[dir.s]:
			offset += 9*9
		modify6 = offset
		modify7 = offset
		modify8 = offset
	
	if Slabs.rooms_that_have_walls.has(surrID[dir.w]):
		var wallFaceForRoom = surrID[dir.w] + 1
		var offset = ((wallFaceForRoom-slabID)*28)*9
		if surrID[dir.sw] == surrID[dir.w] and surrID[dir.nw] == surrID[dir.w]:
			offset += 9*9
		modify0 = offset
		modify3 = offset
		modify6 = offset
	if Slabs.rooms_that_have_walls.has(surrID[dir.n]):
		var wallFaceForRoom = surrID[dir.n] + 1
		var offset = ((wallFaceForRoom-slabID)*28)*9
		if surrID[dir.ne] == surrID[dir.n] and surrID[dir.nw] == surrID[dir.n]:
			offset += 9*9
		modify0 = offset
		modify1 = offset
		modify2 = offset
	if Slabs.rooms_that_have_walls.has(surrID[dir.e]):
		var wallFaceForRoom = surrID[dir.e] + 1
		var offset = ((wallFaceForRoom-slabID)*28)*9
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
	
	slabsetIndexGroup[0] += modify0
	slabsetIndexGroup[1] += modify1
	slabsetIndexGroup[2] += modify2
	slabsetIndexGroup[3] += modify3
	slabsetIndexGroup[4] += modify4
	slabsetIndexGroup[5] += modify5
	slabsetIndexGroup[6] += modify6
	slabsetIndexGroup[7] += modify7
	slabsetIndexGroup[8] += modify8


func modify_for_liquid(slabsetIndexGroup, surrID, slabID):
	
	# Don't modify slab if slab is liquid
	if slabID == Slabs.WATER or slabID == Slabs.LAVA:
		return
	
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
	
	slabsetIndexGroup[0] += modify0
	slabsetIndexGroup[1] += modify1
	slabsetIndexGroup[2] += modify2
	slabsetIndexGroup[3] += modify3
	slabsetIndexGroup[4] += modify4
	slabsetIndexGroup[5] += modify5
	slabsetIndexGroup[6] += modify6
	slabsetIndexGroup[7] += modify7
	slabsetIndexGroup[8] += modify8

func make_slab(fullVariationIndex, bitmask):
	var slabsetIndexGroup = bitmaskToSlab[bitmask].duplicate()
	for subtile in 9:
		slabsetIndexGroup[subtile] = ((fullVariationIndex + slabsetIndexGroup[subtile]) * 9) + subtile
	return slabsetIndexGroup

var bitmaskToSlab = {
	00: VariationConstructs.slab_center,
	500: VariationConstructs.slab_partial_center,
	01: VariationConstructs.slab_s,
	02: VariationConstructs.slab_w,
	04: VariationConstructs.slab_n,
	08: VariationConstructs.slab_e,
	03: VariationConstructs.slab_sw,
	06: VariationConstructs.slab_nw,
	12: VariationConstructs.slab_ne,
	09: VariationConstructs.slab_se,
	15: VariationConstructs.slab_solo,
	05: VariationConstructs.slab_sn,
	10: VariationConstructs.slab_ew,
	07: VariationConstructs.slab_swn,
	11: VariationConstructs.slab_swe,
	13: VariationConstructs.slab_sen,
	14: VariationConstructs.slab_wne,
}

func update_wibble(xSlab, ySlab, slabID, includeNearby):
	# I'm using surrounding wibble to update this slab's wibble, instead of using surrounding slabID, this is for the sake of Fake Slabs
	
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
const waterFloor = 545
const lavaFloors = [546, 547]

func has_neighbor_of_type(surrID, slabType):
	return {
		dir.n: surrID[dir.n] == slabType,
		dir.s: surrID[dir.s] == slabType,
		dir.e: surrID[dir.e] == slabType,
		dir.w: surrID[dir.w] == slabType,
		dir.ne: surrID[dir.ne] == slabType,
		dir.nw: surrID[dir.nw] == slabType,
		dir.se: surrID[dir.se] == slabType,
		dir.sw: surrID[dir.sw] == slabType
	}

func randomize_gold_transition(constructedSlabData, surrID, neighborType):
	var constructedColumns = constructedSlabData[0]
	var constructedFloor = constructedSlabData[1]
	var neighbors = has_neighbor_of_type(surrID, neighborType)

	var side_to_columns = {
		dir.n: [0, 1, 2], dir.s: [6, 7, 8], dir.w: [0, 3, 6], dir.e: [2, 5, 8],
		dir.nw: [0], dir.ne: [2], dir.sw: [6], dir.se: [8]
	}

	var currentSlabNearLava = false
	for i in 8:
		if surrID[i] == Slabs.LAVA:
			currentSlabNearLava = true
			break

	var all_gold_types = Cube.rngCube.get("GoldNearLava", []) + \
						 Cube.rngCube.get("DenseGoldNearLava", []) + \
						 Cube.rngCube.get("Gold", []) + \
						 Cube.rngCube.get("DenseGold", [])

	var modifiedColumns = {}

	for side_direction in range(8):
		if neighbors[side_direction]:
			var columns_to_check = side_to_columns.get(side_direction, [])

			for columnIndex in columns_to_check:
				if columnIndex == 4 or modifiedColumns.has(columnIndex):
					continue

				var floorTex = constructedFloor[columnIndex]
				var isClearedByLiquid = (floorTex == waterFloor or floorTex in lavaFloors) and constructedColumns[columnIndex] == blankCubes

				if not isClearedByLiquid and Random.chance_int(50):
					var currentCube = constructedColumns[columnIndex][4]

					if currentCube in all_gold_types:
						var replacementSet = Cube.rngCube.get("IntermediateGold", [])
						var intermediateLavaSet = Cube.rngCube.get("IntermediateGoldNearLava", [])
						if currentSlabNearLava and intermediateLavaSet.size() > 0:
							replacementSet = intermediateLavaSet

						if replacementSet.size() > 0:
							constructedColumns[columnIndex][4] = Random.choose(replacementSet)

				modifiedColumns[columnIndex] = true

func make_frail(constructedSlabData, slabID, surrID):
	match slabID:
		Slabs.ROCK:
			if oRoundRockNearPath.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.PATH, false)
			if oRoundRockNearLiquid.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.WATER, false)
				frail_condition(constructedSlabData, slabID, surrID, Slabs.LAVA, false)
		Slabs.GOLD:
			if has_neighbor_of_type(surrID, Slabs.DENSE_GOLD).values().has(true):
				randomize_gold_transition(constructedSlabData, surrID, Slabs.DENSE_GOLD)
			
			if oRoundGoldNearPath.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.PATH, false)
			if oRoundGoldNearLiquid.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.WATER, true)
				frail_condition(constructedSlabData, slabID, surrID, Slabs.LAVA, true)
		Slabs.DENSE_GOLD:
			if has_neighbor_of_type(surrID, Slabs.GOLD).values().has(true):
				randomize_gold_transition(constructedSlabData, surrID, Slabs.GOLD)
		Slabs.EARTH:
			if oRoundEarthNearPath.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.PATH, false)
			if oRoundEarthNearLiquid.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.WATER, true)
				frail_condition(constructedSlabData, slabID, surrID, Slabs.LAVA, true)
		Slabs.PATH:
			if oRoundPathNearLiquid.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.WATER, false)
				frail_condition(constructedSlabData, slabID, surrID, Slabs.LAVA, false)
		Slabs.LAVA:
			if oRoundWaterNearLava.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.WATER, false)
		Slabs.WATER:
			if oRoundWaterNearLava.pressed == true:
				frail_condition(constructedSlabData, slabID, surrID, Slabs.LAVA, false)

func frail_condition(constructedSlabData, slabID, surrID, frailCornerType, onlyAdjustSoloBlocks):
	var constructedColumns = constructedSlabData[0]
	var constructedFloor = constructedSlabData[1]
	
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
			return
	
	if checkN == checkE:
		if slabID < checkN: # Decide which one to prioritize
			if checkN == surrID[dir.n] and checkE == surrID[dir.e]:
				frail_fill_corner(checkN, 2, constructedColumns, constructedFloor)
		else:
			if checkN == surrID[dir.ne]:
				frail_fill_corner(checkN, 2, constructedColumns, constructedFloor)
	
	if checkN == checkW:
		if slabID < checkW: # Decide which one to prioritize
			if checkN == surrID[dir.n] and checkW == surrID[dir.w]:
				frail_fill_corner(checkW, 0, constructedColumns, constructedFloor)
		else:
			if checkW == surrID[dir.nw]:
				frail_fill_corner(checkW, 0, constructedColumns, constructedFloor)
	
	if checkS == checkW:
		if slabID < checkS: # Decide which one to prioritize
			if checkS == surrID[dir.s] and checkW == surrID[dir.w]:
				frail_fill_corner(checkS, 6, constructedColumns, constructedFloor)
		else:
			if checkS == surrID[dir.sw]:
				frail_fill_corner(checkS, 6, constructedColumns, constructedFloor)
	
	if checkS == checkE:
		if slabID < checkE: # Decide which one to prioritize
			if checkS == surrID[dir.s] and checkE == surrID[dir.e]:
				frail_fill_corner(checkE, 8, constructedColumns, constructedFloor)
		else:
			if checkE == surrID[dir.se]:
				frail_fill_corner(checkE, 8, constructedColumns, constructedFloor)


func frail_fill_corner(slabID, index, constructedColumns, constructedFloor):
	match slabID:
		Slabs.WATER:
			constructedFloor[index] = 545
			constructedColumns[index] = blankCubes.duplicate(true)
		Slabs.LAVA:
			constructedFloor[index] = Random.choose([546,547]) # Lava floor
			constructedColumns[index] = blankCubes.duplicate(true)
		Slabs.PATH:
			constructedFloor[index] = 207
			constructedColumns[index] = blankCubes.duplicate(true)
			if Cube.stoneRatio < randf():
				constructedColumns[index] = blankCubes.duplicate(true)
				constructedColumns[index][0] = Random.choose(Cube.rngCube["PathClean"])
			else:
				constructedColumns[index] = blankCubes.duplicate(true)
				constructedColumns[index][0] = Random.choose(Cube.rngCube["PathWithStones"])
		Slabs.EARTH:
			constructedFloor[index] = 27
			constructedColumns[index] = blankCubes.duplicate(true)
			constructedColumns[index][0] = 25 # No need to randomize the path cube, it's not visible and the game overwrites it anyway.
			constructedColumns[index][1] = Random.choose(Cube.rngCube["Earth"])
			constructedColumns[index][2] = Random.choose(Cube.rngCube["Earth"])
			constructedColumns[index][3] = Random.choose(Cube.rngCube["Earth"])
			constructedColumns[index][4] = 5
		Slabs.GOLD:
			constructedFloor[index] = 27
			constructedColumns[index] = blankCubes.duplicate(true)
			constructedColumns[index][0] = 25
			constructedColumns[index][1] = Random.choose(Cube.rngCube["Gold"])
			constructedColumns[index][2] = Random.choose(Cube.rngCube["Gold"])
			constructedColumns[index][3] = Random.choose(Cube.rngCube["Gold"])
			constructedColumns[index][4] = Random.choose(Cube.rngCube["Gold"])
		Slabs.DENSE_GOLD:
			constructedFloor[index] = 27
			constructedColumns[index] = blankCubes.duplicate(true)
			constructedColumns[index][0] = 25
			constructedColumns[index][1] = Random.choose(Cube.rngCube["DenseGold"])
			constructedColumns[index][2] = Random.choose(Cube.rngCube["DenseGold"])
			constructedColumns[index][3] = Random.choose(Cube.rngCube["DenseGold"])
			constructedColumns[index][4] = Random.choose(Cube.rngCube["DenseGold"])
		Slabs.ROCK:
			constructedFloor[index] = 29
			constructedColumns[index] = blankCubes.duplicate(true)
			constructedColumns[index][0] = 45
			constructedColumns[index][1] = 45
			constructedColumns[index][2] = 44
			constructedColumns[index][3] = 44
			constructedColumns[index][4] = 43



#func randomize_columns(constructedSlabData, slabID, bitmaskType):
#	var constructedColumns = constructedSlabData[0]
#	var constructedFloor = constructedSlabData[1]
#
#	if bitmaskType == Slabs.BITMASK_REINFORCED:
#		for i in 9:
#			if constructedColumns[i][0] in rngEarthPathUnderneath:
#				constructedColumns[i][0] = 25 # No need to randomize the path cube, it's not visible and the game overwrites it anyway.
#			if constructedColumns[i][1] in rngWall:
#				constructedColumns[i][1] = Random.choose(rngWall)
#			if constructedColumns[i][2] in rngWall:
#				constructedColumns[i][2] = Random.choose(rngWall)
#			if constructedColumns[i][3] in rngWall:
#				constructedColumns[i][3] = Random.choose(rngWall)
#	else:
#		match slabID:
#			Slabs.PATH:
#				for i in 9:
#					if constructedColumns[i][0] in rngPathClean or constructedColumns[i][0] in rngPathWithStones:
#						if stoneRatio < randf():
#							constructedColumns[i][0] = Random.choose(rngPathClean)
#						else:
#							constructedColumns[i][0] = Random.choose(rngPathWithStones)
#			Slabs.EARTH:
#				for i in 9:
#					if constructedColumns[i][0] in rngEarthPathUnderneath:
#						constructedColumns[i][0] = 25 # No need to randomize the path cube, it's not visible and the game overwrites it anyway.
#					if constructedColumns[i][1] in rngEarth: # This one applies when near water
#						constructedColumns[i][1] = Random.choose(rngEarth)
#					if constructedColumns[i][2] in rngEarth:
#						constructedColumns[i][2] = Random.choose(rngEarth)
#					if constructedColumns[i][3] in rngEarth:
#						constructedColumns[i][3] = Random.choose(rngEarth)
#
#			Slabs.CLAIMED_GROUND:
#				for i in 9:
#					if constructedColumns[i][0] in rngClaimedGround:
#						constructedColumns[i][0] = Random.choose(rngClaimedGround)
#			Slabs.GOLD:
#				for i in 9:
#					if constructedColumns[i][1] in rngGold: # This one applies when near water
#						constructedColumns[i][1] = Random.choose(rngGold)
#					if constructedColumns[i][2] in rngGold:
#						constructedColumns[i][2] = Random.choose(rngGold)
#					if constructedColumns[i][3] in rngGold:
#						constructedColumns[i][3] = Random.choose(rngGold)
#					if constructedColumns[i][4] in rngGold:
#						constructedColumns[i][4] = Random.choose(rngGold)
#
#					if constructedColumns[i][1] in rngGoldNearLava:
#						constructedColumns[i][1] = Random.choose(rngGoldNearLava)
#					if constructedColumns[i][2] in rngGoldNearLava:
#						constructedColumns[i][2] = Random.choose(rngGoldNearLava)
#					if constructedColumns[i][3] in rngGoldNearLava:
#						constructedColumns[i][3] = Random.choose(rngGoldNearLava)
#					if constructedColumns[i][4] in rngGoldNearLava:
#						constructedColumns[i][4] = Random.choose(rngGoldNearLava)
#			Slabs.LAVA:
#				for i in 9:
#					if constructedFloor[i] in rngLava:
#						constructedFloor[i] = Random.choose(rngLava)
#			Slabs.LIBRARY:
#				for i in 9:
#					if constructedColumns[i][0] in rngLibrary:
#						constructedColumns[i][0] = Random.choose(rngLibrary)
#			Slabs.GEMS:
#				for i in 9:
#					if constructedColumns[i][2] in rngGems:
#						constructedColumns[i][2] = Random.choose(rngGems)
#					if constructedColumns[i][3] in rngGems:
#						constructedColumns[i][3] = Random.choose(rngGems)
#					if constructedColumns[i][4] in rngGems:
#						constructedColumns[i][4] = Random.choose(rngGems)
