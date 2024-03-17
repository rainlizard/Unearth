extends Node
onready var oInstances = Nodelist.list["oInstances"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oPlaceLockedCheckBox = Nodelist.list["oPlaceLockedCheckBox"]
onready var oLavaEffectPercent = Nodelist.list["oLavaEffectPercent"]
onready var oWaterEffectPercent = Nodelist.list["oWaterEffectPercent"]
onready var oSelector = Nodelist.list["oSelector"]

onready var dir = oSlabPlacement.dir

func place_slab_objects(xSlab, ySlab, slabID, ownership, clmIndexGroup, bitmask, surrID, bitmaskType):
	oInstances.delete_attached_instances_on_slab(xSlab, ySlab)
	
	match slabID:
		Slabs.WATER:
			if Random.rng.randf_range(0.0, 100.0) < oWaterEffectPercent.value:
				create_effect(xSlab, ySlab, ownership, Things.TYPE.EFFECTGEN, 2)
		Slabs.LAVA:
			if Random.rng.randf_range(0.0, 100.0) < oLavaEffectPercent.value:
				create_effect(xSlab, ySlab, ownership, Things.TYPE.EFFECTGEN, 1)
		Slabs.PRISON:
			var subtiles_with_bars = prison_bar_bitmask(slabID, surrID)
			for i in range(9):
				spawn_object(xSlab, ySlab, slabID, ownership, i, clmIndexGroup[i], subtiles_with_bars.has(i))
		_:
			if Slabs.is_door(slabID):
				create_door_thing(xSlab, ySlab, ownership)
			else:
				for i in range(9):
					spawn_object(xSlab, ySlab, slabID, ownership, i, clmIndexGroup[i], true)

func create_effect(xSlab, ySlab, ownership, effectType, effectSubtype):
	var xSubtile = (xSlab*3) + Random.randi_range(0,2) + 0.5
	var ySubtile = (ySlab*3) + Random.randi_range(0,2) + 0.5
	var createAtPos = Vector3(xSubtile, ySubtile, 0)
	oInstances.place_new_thing(effectType, effectSubtype, createAtPos, ownership)

func spawn_object(xSlab, ySlab, slabID, ownership, subtile, clmIndex, shouldSpawn):
	var variation = int(clmIndex / 9)
	var convertedSubtile = clmIndex % 9
	var objectStuff = get_object(variation, convertedSubtile)
	if objectStuff.size() > 0 and shouldSpawn:
		oInstances.spawn_attached(xSlab, ySlab, slabID, ownership, subtile, objectStuff)

func get_object(variation, subtile):
	if variation < Slabset.tng.size():
		for objectStuff in Slabset.tng[variation]:
			if subtile == objectStuff[Slabset.obj.SUBTILE]:
				return objectStuff
	return []

func create_door_thing(xSlab, ySlab, ownership):
	var createAtPos = Vector3((xSlab*3)+1.5, (ySlab*3)+1.5, 5)
	var rememberLockedState = 0
	
	var doorID = oInstances.get_node_on_subtile(createAtPos.x, createAtPos.y, "Door")
	if is_instance_valid(doorID):
		rememberLockedState = doorID.doorLocked
		doorID.queue_free()
	
	var id = oInstances.place_new_thing(Things.TYPE.DOOR, 0, createAtPos, ownership)
	id.doorLocked = rememberLockedState
	
	if oPlaceLockedCheckBox.visible:
		id.doorLocked = 1 if oPlaceLockedCheckBox.pressed else 0
	
	id.update_spinning_key()

func prison_bar_bitmask(slabID, surrID):
	var subtiles_with_bars = []
	var bar_subtiles = {
		dir.s: [6, 7, 8],
		dir.w: [0, 3, 6],
		dir.n: [0, 1, 2],
		dir.e: [2, 5, 8]
	}
	for direction in [dir.s, dir.w, dir.n, dir.e]:
		if not Slabs.data[surrID[direction]][Slabs.IS_SOLID] and slabID != surrID[direction]:
			subtiles_with_bars.append_array(bar_subtiles[direction])
	return subtiles_with_bars
