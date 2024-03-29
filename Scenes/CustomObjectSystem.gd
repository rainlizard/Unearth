extends Node
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]

var objectsFile = ConfigFile.new()

func add_object(array):
	print("Objected added: " + str(array))
	var section = 'OBJECT:' + str(array[0]) + ':' + str(array[1])
	objectsFile.set_value(section,"NAME", array[2])
	#objectsFile.set_value(section,"IMAGE", array[3])
	#objectsFile.set_value(section,"PORTRAIT", array[4])
	objectsFile.set_value(section,"TAB", array[5])
	
	objectsFile.save(Settings.unearthdata.plus_file("custom_objects.cfg"))
	load_file()
	oPickThingWindow.initialize_thing_grid_items()

func load_file():
	var LOAD_CUSTOM_OBJECTS_CODETIME_START = OS.get_ticks_msec()
	
	objectsFile.load(Settings.unearthdata.plus_file("custom_objects.cfg"))
	
	for sectionName in objectsFile.get_sections():
		var sectionNameArray = sectionName.split(":")
		var objThingType = int(sectionNameArray[1])
		var objSubtype = int(sectionNameArray[2])
		
		var objName = objectsFile.get_value(sectionName, "NAME", "")
#		var objImage = objectsFile.get_value(sectionName, "IMAGE", "")
#		var objPortrait = objectsFile.get_value(sectionName, "PORTRAIT", "")
		var objTab = objectsFile.get_value(sectionName, "TAB", 0)
		
		var constructArray = [
			objName, # NAME
			null, # KEEPERFX_NAME
			null, # ANIMATION_ID
			null, # TEXTURE
			null, # PORTRAIT
			objTab,
		]
		match objThingType:
			Things.TYPE.OBJECT: Things.DATA_OBJECT[objSubtype] = constructArray
			Things.TYPE.CREATURE: Things.DATA_CREATURE[objSubtype] = constructArray
			Things.TYPE.EFFECTGEN: Things.DATA_EFFECTGEN[objSubtype] = constructArray
			Things.TYPE.TRAP: Things.DATA_TRAP[objSubtype] = constructArray
			Things.TYPE.DOOR: Things.DATA_DOOR[objSubtype] = constructArray
		
		#print(Things.DATA_OBJECT[objSubtype])
	
	print('Loaded custom objects: ' + str(OS.get_ticks_msec() - LOAD_CUSTOM_OBJECTS_CODETIME_START) + 'ms')

func remove_object(thingType, subtype):
	var section = 'OBJECT:'+str(thingType)+':'+str(subtype)
	if objectsFile.has_section(section) == false: return	
	
	objectsFile.erase_section(section)
	
	
	match thingType:
		Things.TYPE.OBJECT: Things.DATA_OBJECT.erase(subtype)
		Things.TYPE.CREATURE: Things.DATA_CREATURE.erase(subtype)
		Things.TYPE.EFFECTGEN: Things.DATA_EFFECTGEN.erase(subtype)
		Things.TYPE.TRAP: Things.DATA_TRAP.erase(subtype)
		Things.TYPE.DOOR: Things.DATA_DOOR.erase(subtype)
	
	objectsFile.save(Settings.unearthdata.plus_file("custom_objects.cfg"))
	load_file()
	oPickThingWindow.set_selection(null, null)
	oPickThingWindow.initialize_thing_grid_items()
	
	print('Removed custom object type: '+str(thingType) + ' subtype: '+ str(subtype))
