extends Node
onready var oInstances = Nodelist.list["oInstances"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oPlaceLockedCheckBox = Nodelist.list["oPlaceLockedCheckBox"]
onready var oLavaEffectPercent = Nodelist.list["oLavaEffectPercent"]
onready var oWaterEffectPercent = Nodelist.list["oWaterEffectPercent"]
onready var oSelector = Nodelist.list["oSelector"]

onready var dir = oSlabPlacement.dir

# The way things placed from slabs.tng works, is that we use the same coordinates (via bitmask and fullVariationIndex) as what's in slabs.dat/clm (level 1000)
# Except we change the positions based on some placement rules.
# For example the Prison bars need extra rules for detecting nearby walls, but the original slab cubes did not need these rules.
# So objects have their own placement rules, though we use the original bitmask/fullVariationIndex (from oSlabPlacement) as a basis to work from.

func place_slab_objects(xSlab, ySlab, slabID, ownership, slabVar, bitmask, surrID, surrOwner):
	oInstances.delete_attached_objects_on_slab(xSlab, ySlab)
	
	if slabID == Slabs.PRISON:
		bitmask = prison_bar_bitmask(slabID, surrID)
	elif slabID == Slabs.WALL_WITH_TORCH or slabID == Slabs.EARTH_WITH_TORCH:
		bitmask = torch_object_bitmask(xSlab, ySlab, surrID)
	elif slabID in [Slabs.WOODEN_DOOR_1, Slabs.WOODEN_DOOR_2, Slabs.BRACED_DOOR_1, Slabs.BRACED_DOOR_2, Slabs.IRON_DOOR_1, Slabs.IRON_DOOR_2, Slabs.MAGIC_DOOR_1, Slabs.MAGIC_DOOR_2]:
		create_door_thing(xSlab, ySlab, ownership)
	elif slabID == Slabs.WATER:
		if Random.rng.randf_range(0.0, 100.0) < oWaterEffectPercent.value:
			var xSubtile = (xSlab*3) + Random.randi_range(0,2) + 0.5
			var ySubtile = (ySlab*3) + Random.randi_range(0,2) + 0.5
			var zSubtile = 0
			var createAtPos = Vector3(xSubtile, ySubtile, zSubtile)
			oInstances.place_new_thing(Things.TYPE.EFFECTGEN, 2, createAtPos, ownership)
	elif slabID == Slabs.LAVA:
		if Random.rng.randf_range(0.0, 100.0) < oLavaEffectPercent.value:
			var xSubtile = (xSlab*3) + Random.randi_range(0,2) + 0.5
			var ySubtile = (ySlab*3) + Random.randi_range(0,2) + 0.5
			var zSubtile = 0
			var createAtPos = Vector3(xSubtile, ySubtile, zSubtile)
			oInstances.place_new_thing(Things.TYPE.EFFECTGEN, 1, createAtPos, ownership)
	
	var constructedSlab = oSlabPlacement.bitmaskToSlab[bitmask]
	if bitmask == 0 and Slabs.rooms_with_middle_object.has(slabID):
		var isMiddle = determine_if_middle(slabID, ownership, bitmask, surrID, surrOwner)
		if isMiddle == false:
			constructedSlab = oSlabPlacement.slab_all
	#print(slabVar + constructedSlab[0])
	#print(slabVar)
	
	for subtile in 9:
		var objectStuff = get_object(slabVar + constructedSlab[subtile], subtile)
		if objectStuff.size() > 0:
			oInstances.spawn(xSlab, ySlab, slabID, ownership, subtile, objectStuff)

func create_door_thing(xSlab, ySlab, ownership):
	var createAtPos = Vector3((xSlab*3)+1.5, (ySlab*3)+1.5, 5)
	
	var rememberLockedState = 0 # This is the fallback value if oPlaceLockedCheckBox isn't being used
	
	# Destroy existing door thing
	var doorID = oInstances.get_node_on_subtile(createAtPos.x, createAtPos.y, "Door")
	if is_instance_valid(doorID) == true:
		rememberLockedState = doorID.doorLocked
		
		doorID.position = Vector2(-500000,-500000) # Not sure if this is necessary
		doorID.queue_free()
	
	# Recreate door thing
	var id = oInstances.place_new_thing(Things.TYPE.DOOR, 0, createAtPos, ownership) #subtype determined in oInstances
	id.doorLocked = rememberLockedState
	
	# Overwrite locked state with ui checkbox setting
	if oPlaceLockedCheckBox.visible == true:
		# Only affect the slab under cursor
		#if xSlab == oSelector.cursorTile.x and ySlab == oSelector.cursorTile.y:
		# Set locked state to checkbox state
		if oPlaceLockedCheckBox.pressed == true:
			id.doorLocked = 1
		else:
			id.doorLocked = 0
	
	id.update_spinning_key()

func determine_if_middle(slabID, ownership, bitmask, surrID, surrOwner):
	if bitmask == 0:
		if slabID == surrID[dir.se] and slabID == surrID[dir.sw] and slabID == surrID[dir.ne] and slabID == surrID[dir.nw] and ownership == surrOwner[dir.se] and ownership == surrOwner[dir.sw] and ownership == surrOwner[dir.ne] and ownership == surrOwner[dir.nw]:
			return true
	return false

func get_object(slabVar, subtile):
	if slabVar < Slabset.tng.size():
		for objectStuff in Slabset.tng[slabVar]:
			if subtile == objectStuff[2]:
				return objectStuff
	return []
#	if slabVar >= Slabset.tng.size(): return -1 # Out of bounds, causes crash
#
#	var idx = Slabset.tng[slabVar]
#	if idx >= Slabset.numberOfThings: return -1
#	# "tng" has one index per fullVariationIndex.
#	# But there are actually multiple entries inside "tngObject" with the same fullVariationIndex value. Their index is grouped up, that's why I do idx+=1.
#	while true:
#		if subtile == Slabset.tngObject[idx][2]:
#			return idx
#
#		idx += 1
#		if idx >= Slabset.numberOfThings: return -1
#		if Slabset.tngObject[idx][1] != slabVar:
#			return -1

func prison_bar_bitmask(slabID, surrID):
	var bitmask = 0
	if Slabs.data[ surrID[dir.s] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.s]: bitmask += 1
	if Slabs.data[ surrID[dir.w] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.w]: bitmask += 2
	if Slabs.data[ surrID[dir.n] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.n]: bitmask += 4
	if Slabs.data[ surrID[dir.e] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.e]: bitmask += 8
	return bitmask

func torch_object_bitmask(xSlab, ySlab, surrID):
	var torchSide = oSlabPlacement.pick_torch_side(xSlab, ySlab, surrID)
	
	print(torchSide)
	
	if Slabs.data[ surrID[torchSide] ][Slabs.IS_SOLID] == true:
		torchSide = -1
	
	if torchSide == 0: return 01 # south torch
	elif torchSide == 1: return 02 # west torch
	elif torchSide == 2: return 04 # north torch
	elif torchSide == 3: return 08 # east torch
	elif torchSide == -1: return 0 # no torch

