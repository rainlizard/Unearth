extends Node
onready var oInstances = Nodelist.list["oInstances"]
onready var oDkTng = Nodelist.list["oDkTng"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]

onready var dir = oSlabPlacement.dir

# The way things placed from slabs.tng works, is that we use the same coordinates (via bitmask and slabVariation) as what's in slabs.dat/clm (level 1000)
# Except we change the positions based on some placement rules.
# For example the Prison bars need extra rules for detecting nearby walls, but the original slab cubes did not need these rules.
# So objects have their own placement rules, though we use the original bitmask/slabvariation (from oSlabPlacement) as a basis to work from.

func place_slab_objects(xSlab, ySlab, slabID, ownership, slabVariation, bitmask, surrID, surrOwner):
	oInstances.delete_attached_objects_on_slab(xSlab, ySlab)
	
	if slabID == Slabs.PRISON:
		bitmask = prison_bar_bitmask(slabID, surrID)
	elif slabID == Slabs.WALL_WITH_TORCH or slabID == Slabs.EARTH_WITH_TORCH:
		bitmask = torch_object_bitmask(xSlab, ySlab, surrID)
	elif slabID in [Slabs.WOODEN_DOOR_1, Slabs.WOODEN_DOOR_2, Slabs.BRACED_DOOR_1, Slabs.BRACED_DOOR_2, Slabs.IRON_DOOR_1, Slabs.IRON_DOOR_2, Slabs.MAGIC_DOOR_1, Slabs.MAGIC_DOOR_2]:
		create_door_thing(xSlab, ySlab, ownership)
	
	var constructedSlab = oSlabPlacement.bitmaskToSlab[bitmask]
	if bitmask == 0 and Slabs.rooms_with_middle_object.has(slabID):
		var isMiddle = determine_if_middle(slabID, ownership, bitmask, surrID, surrOwner)
		if isMiddle == false:
			constructedSlab = oSlabPlacement.slab_all
	#print(slabVariation + constructedSlab[0])
	for subtile in 9:
		var idx = get_obj_idx(slabVariation + constructedSlab[subtile], subtile)
		if idx != -1:
			oInstances.spawn(xSlab, ySlab, slabID, ownership, subtile, oDkTng.tngObject[idx])

func create_door_thing(xSlab, ySlab, ownership):
	var createAtPos = Vector3((xSlab*3)+1.5, (ySlab*3)+1.5, 5)
	var doorID = oInstances.get_node_on_subtile("Door", createAtPos.x, createAtPos.y)
	if is_instance_valid(doorID) == true:
		# Change existing door thing's ownership
		doorID.ownership = ownership
	else:
		# No door thing, so create it
		oInstances.place_new_thing(Things.TYPE.DOOR, 0, createAtPos, ownership) #subtype determined in oInstances
	
	# This isn't important, key ownership doesn't matter, but change it anyway
	var keyID = oInstances.get_node_on_subtile("Key", createAtPos.x, createAtPos.y)
	if is_instance_valid(keyID) == true:
		keyID.ownership = ownership

func determine_if_middle(slabID, ownership, bitmask, surrID, surrOwner):
	if bitmask == 0:
		if slabID == surrID[dir.se] and slabID == surrID[dir.sw] and slabID == surrID[dir.ne] and slabID == surrID[dir.nw] and ownership == surrOwner[dir.se] and ownership == surrOwner[dir.sw] and ownership == surrOwner[dir.ne] and ownership == surrOwner[dir.nw]:
			return true
	return false

func get_obj_idx(newSlabVar, subtile):
	if newSlabVar >= 1304: return -1 # Out of bounds, causes crash
	
	var idx = oDkTng.tngIndex[newSlabVar]
	if idx >= oDkTng.numberOfThings: return -1
	# "tngIndex" has one index per slabVariation.
	# But there are actually multiple entries inside "tngObject" with the same slabVariation value. Their index is grouped up, that's why I do idx+=1.
	while true:
		if subtile == oDkTng.tngObject[idx][2]:
			return idx
		
		idx += 1
		if idx >= oDkTng.numberOfThings: return -1
		if oDkTng.tngObject[idx][1] != newSlabVar:
			return -1

func prison_bar_bitmask(slabID, surrID):
	var bitmask = 0
	if Slabs.data[ surrID[dir.s] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.s]: bitmask += 1
	if Slabs.data[ surrID[dir.w] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.w]: bitmask += 2
	if Slabs.data[ surrID[dir.n] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.n]: bitmask += 4
	if Slabs.data[ surrID[dir.e] ][Slabs.IS_SOLID] == false and slabID != surrID[dir.e]: bitmask += 8
	return bitmask

func torch_object_bitmask(xSlab, ySlab, surrID):
	var torchSide = oSlabPlacement.calculate_torch_side(xSlab, ySlab)
	
	if Slabs.data[ surrID[torchSide] ][Slabs.IS_SOLID] == true:
		torchSide = -1
	
	if torchSide == 0: return 01 #s
	elif torchSide == 1: return 02 #w
	elif torchSide == 2: return 04 #n
	elif torchSide == 3: return 08 #e
	elif torchSide == -1: return 0 #center

