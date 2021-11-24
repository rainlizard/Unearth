extends Node
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]

var CUSTOM_OBJECTS = {}


func load_custom_objects(NEW_CUSTOM_OBJECTS):
	
	CUSTOM_OBJECTS = NEW_CUSTOM_OBJECTS
	
	for thingType in CUSTOM_OBJECTS:
		for subtype in CUSTOM_OBJECTS[thingType]:
			var array = CUSTOM_OBJECTS[thingType][subtype]
			
			match thingType:
				Things.TYPE.OBJECT: Things.DATA_OBJECT[subtype] = array
				Things.TYPE.CREATURE: Things.DATA_CREATURE[subtype] = array
				Things.TYPE.EFFECT: Things.DATA_EFFECT[subtype] = array
				Things.TYPE.TRAP: Things.DATA_TRAP[subtype] = array
				Things.TYPE.DOOR: Things.DATA_DOOR[subtype] = array
	print('Custom objects loaded into memory')


func add_object(thingType, subtype, array):
	CUSTOM_OBJECTS[thingType] = {
		subtype : array
	}
	
	Settings.set_setting("custom_objects", CUSTOM_OBJECTS)
	oPickThingWindow.initialize_thing_grid_items()

func remove_object(thingType, subtype):
	oPickThingWindow.set_selection(null, null)
	
	
	print('Attempting to remove object...')
	if CUSTOM_OBJECTS.has(thingType) and CUSTOM_OBJECTS[thingType].has(subtype):
		CUSTOM_OBJECTS[thingType].erase(subtype)
		
		match thingType:
			Things.TYPE.OBJECT: Things.DATA_OBJECT.erase(subtype)
			Things.TYPE.CREATURE: Things.DATA_CREATURE.erase(subtype)
			Things.TYPE.EFFECT: Things.DATA_EFFECT.erase(subtype)
			Things.TYPE.TRAP: Things.DATA_TRAP.erase(subtype)
			Things.TYPE.DOOR: Things.DATA_DOOR.erase(subtype)
		
		Settings.set_setting("custom_objects", CUSTOM_OBJECTS)
		oPickThingWindow.initialize_thing_grid_items()
		print('Removed custom object type: '+str(thingType) + ' subtype: '+ str(subtype))
	else:
		print('Object not found in Custom Objects dictionary')
	#print(CUSTOM_OBJECTS)
