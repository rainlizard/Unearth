extends Node
onready var oInstances = Nodelist.list["oInstances"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]

onready var dir = oSlabPlacement.dir

func place_slab_objects(xSlab, ySlab, slabID, ownership, clmIndexGroup, bitmask, surrID, bitmaskType, options):
	var spawnRoomObjects = oSlabPlacement.should_reset(options, "room_objects")
	var spawnDoodads = oSlabPlacement.should_reset(options, "random_doodads")
	
	if spawnDoodads:
		delete_doodads_on_slab(xSlab, ySlab, slabID)
	
	if spawnRoomObjects:
		oInstances.delete_attached_instances_on_slab(xSlab, ySlab)
		if Slabs.is_door(slabID):
			create_door_thing(xSlab, ySlab, ownership)
		
		if slabID == Slabs.PRISON:
			var subtiles_with_bars = prison_bar_bitmask(slabID, surrID)
			for i in range(9):
				spawn_object(xSlab, ySlab, slabID, ownership, i, clmIndexGroup[i], subtiles_with_bars.has(i))
		else:
			for i in range(9):
				spawn_object(xSlab, ySlab, slabID, ownership, i, clmIndexGroup[i], true)
	
	if spawnDoodads:
		for doodad in Settings.slabDoodads.get(slabID, []):
			for subtile in 9:
				if Random.rng.randf_range(0.0, 100.0) < doodad[2]:
					spawn_doodad(xSlab, ySlab, ownership, doodad, subtile)

func delete_doodads_on_slab(xSlab, ySlab, slabID):
	var doodads = Settings.slabDoodads.get(slabID, [])
	if doodads.empty(): return
	for id in oInstances.get_all_nodes_on_slab(xSlab, ySlab, ["Thing"]):
		for doodad in doodads:
			if id.thingType == doodad[0] and id.subtype == doodad[1]:
				oInstances.kill_instance(id)
				break

func spawn_doodad(xSlab, ySlab, ownership, doodad, subtile):
	var xSubtile = (xSlab*3) + (subtile % 3) + 0.5
	var ySubtile = (ySlab*3) + (subtile / 3) + 0.5
	if oInstances.get_all_instances_on_subtile(xSubtile, ySubtile).empty() == false: # Don't overlap things already on this subtile
		return
	var orientation = doodad[3]
	if orientation == -1:
		orientation = Constants.listOrientations[Random.rng.randi_range(0, Constants.listOrientations.size()-1)]
	var createAtPos = Vector3(xSubtile, ySubtile, 0)
	oInstances.place_new_thing(doodad[0], doodad[1], createAtPos, ownership, doodad[4], orientation)

func spawn_object(xSlab, ySlab, slabID, ownership, subtile, clmIndex, shouldSpawn):
	var variation = int(clmIndex / 9)
	var convertedSubtile = clmIndex % 9
	var objectStuffArray = get_object(variation, convertedSubtile)
	if objectStuffArray.size() > 0 and shouldSpawn:
		for objectStuff in objectStuffArray:
			oInstances.spawn_attached(xSlab, ySlab, slabID, ownership, subtile, objectStuff)

func get_object(variation, subtile):
	var objectStuffArray = []
	if variation < Slabset.tng.size():
		for objectStuff in Slabset.tng[variation]:
			if subtile == objectStuff[Slabset.obj.SUBTILE]:
				objectStuffArray.append(objectStuff)
	return objectStuffArray

func create_door_thing(xSlab, ySlab, ownership):
	var createAtPos = Vector3((xSlab*3)+1.5, (ySlab*3)+1.5, 5)
	
	var existingDoorNode = oInstances.get_node_on_subtile(createAtPos.x, createAtPos.y, "Door")
	var newDoorNode = oInstances.place_new_thing(Things.TYPE.DOOR, 0, createAtPos, ownership)

	if is_instance_valid(existingDoorNode):
		newDoorNode.doorLocked = existingDoorNode.doorLocked
		oInstances.kill_instance(existingDoorNode)
	
	newDoorNode.update_spinning_key()

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
