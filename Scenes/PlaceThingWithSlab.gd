extends Node
onready var oInstances = Nodelist.list["oInstances"]
onready var oDkSlabThings = Nodelist.list["oDkSlabThings"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]

onready var dir = oSlabPlacement.dir

# The way things placed from slabs.tng works, is that we use the same coordinates (via bitmask and slabVariation) as what's in slabs.dat/clm (level 1000)
# Except we change the positions based on some placement rules.
# For example the Prison bars need extra rules for detecting nearby walls, but the original slab cubes did not need these rules.
# So objects have their own placement rules, though we use the original bitmask/slabvariation (from oSlabPlacement) as a basis to work from.

func place_slab_objects(xSlab, ySlab, slabID, ownership, slabVariation, bitmask, surrounding):
	oInstances.delete_attached_objects_on_slab(xSlab, ySlab)
	
	if slabID == Slabs.PRISON:
		bitmask = prison_bar_bitmask(slabID, surrounding)
	elif slabID == Slabs.WALL_WITH_TORCH or slabID == Slabs.EARTH_WITH_TORCH:
		bitmask = torch_object_bitmask(xSlab, ySlab, surrounding)
	elif slabID in [Slabs.WOODEN_DOOR_1, Slabs.WOODEN_DOOR_2, Slabs.BRACED_DOOR_1, Slabs.BRACED_DOOR_2, Slabs.IRON_DOOR_1, Slabs.IRON_DOOR_2, Slabs.MAGIC_DOOR_1, Slabs.MAGIC_DOOR_2]:
		create_door_thing(xSlab, ySlab, ownership)
	
	var customSlab = oSlabPlacement.bitmaskToSlab[bitmask]
	if bitmask == 0 and Slabs.rooms_with_middle_object.has(slabID):
		var isMiddle = determineIfMiddle(slabID, surrounding, bitmask)
		if isMiddle == false:
			customSlab = oSlabPlacement.slab_all
	
	for subtile in 9:
		var idx = get_obj_idx(slabVariation + customSlab[subtile], subtile)
		if idx != -1:
			oInstances.spawn(xSlab, ySlab, slabID, ownership, subtile, oDkSlabThings.tngObject[idx])

func create_door_thing(xSlab, ySlab, ownership):
	var createAtPos = Vector3((xSlab*3)+1.5, (ySlab*3)+1.5, 5)
	
	var doorID = oInstances.get_node_of_group_on_subtile("Door", createAtPos.x, createAtPos.y)
	if is_instance_valid(doorID) == false:
		oInstances.place_new_thing(Things.TYPE.DOOR, 0, createAtPos, ownership) #subtype determined in oInstances

func determineIfMiddle(slabID, surrounding, bitmask):
	if bitmask == 0:
		if slabID == surrounding[dir.se] and slabID == surrounding[dir.sw] and slabID == surrounding[dir.ne] and slabID == surrounding[dir.nw]:
			return true
	return false

func get_obj_idx(newSlabVar, subtile):
	var idx = oDkSlabThings.tngIndex[newSlabVar]
	if idx >= oDkSlabThings.numberOfThings: return -1
	# "tngIndex" has one index per slabVariation.
	# But there are actually multiple entries inside "tngObject" with the same slabVariation value. Their index is grouped up, that's why I do idx+=1.
	while true:
		if subtile == oDkSlabThings.tngObject[idx][2]:
			return idx
		
		idx += 1
		if idx >= oDkSlabThings.numberOfThings: return -1
		if oDkSlabThings.tngObject[idx][1] != newSlabVar:
			return -1

func prison_bar_bitmask(slabID, surrounding):
	var bitmask = 0
	if Slabs.data[ surrounding[dir.s] ][Slabs.IS_SOLID] == false and slabID != surrounding[dir.s]: bitmask += 1
	if Slabs.data[ surrounding[dir.w] ][Slabs.IS_SOLID] == false and slabID != surrounding[dir.w]: bitmask += 2
	if Slabs.data[ surrounding[dir.n] ][Slabs.IS_SOLID] == false and slabID != surrounding[dir.n]: bitmask += 4
	if Slabs.data[ surrounding[dir.e] ][Slabs.IS_SOLID] == false and slabID != surrounding[dir.e]: bitmask += 8
	return bitmask

func torch_object_bitmask(xSlab, ySlab, surrounding):
	var torchSide = oSlabPlacement.calculate_torch_side(xSlab, ySlab)
	
	if Slabs.data[ surrounding[torchSide] ][Slabs.IS_SOLID] == true:
		torchSide = -1
	
	if torchSide == 0: return 01 #s
	elif torchSide == 1: return 02 #w
	elif torchSide == 2: return 04 #n
	elif torchSide == 3: return 08 #e
	elif torchSide == -1: return 0 #center

