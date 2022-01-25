extends Node
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]

var objectsFile = ConfigFile.new()

func _init():
	load_file()

func add_object(array):
	print("Objected added: " + str(array))
	var section = 'OBJECT:' + str(array[0]) + ':' + str(array[1])
	objectsFile.set_value(section,"NAME", array[2])
	objectsFile.set_value(section,"IMAGE", array[3])
	objectsFile.set_value(section,"PORTRAIT", array[4])
	objectsFile.set_value(section,"TAB", array[5])
	
	objectsFile.save(Settings.unearthdata.plus_file("custom_objects.cfg"))
	load_file()
	oPickThingWindow.initialize_thing_grid_items()

func load_file():
	objectsFile.load(Settings.unearthdata.plus_file("custom_objects.cfg"))
	
	for sectionName in objectsFile.get_sections():
		var sectionNameArray = sectionName.split(":")
		var objThingType = int(sectionNameArray[1])
		var objSubtype = int(sectionNameArray[2])
		
		var objName = objectsFile.get_value(sectionName, "NAME", "")
		var objImage = objectsFile.get_value(sectionName, "IMAGE", "")
		var objPortrait = objectsFile.get_value(sectionName, "PORTRAIT", "")
		var objTab = objectsFile.get_value(sectionName, "TAB", 0)
		if objImage == "": objImage = null # This is to prevent an annoying line in the Debugger
		if objPortrait == "": objPortrait = null
		
		var constructArray = [
			objName,
			objImage,
			objPortrait,
			objTab,
		]
		match objThingType:
			Things.TYPE.OBJECT: Things.DATA_OBJECT[objSubtype] = constructArray
			Things.TYPE.CREATURE: Things.DATA_CREATURE[objSubtype] = constructArray
			Things.TYPE.EFFECT: Things.DATA_EFFECT[objSubtype] = constructArray
			Things.TYPE.TRAP: Things.DATA_TRAP[objSubtype] = constructArray
			Things.TYPE.DOOR: Things.DATA_DOOR[objSubtype] = constructArray
		
		#print(Things.DATA_OBJECT[objSubtype])
	
	print('Custom objects loaded into memory')

func remove_object(thingType, subtype):
	oPickThingWindow.set_selection(null, null)
	print('Attempting to remove thingType:' + str(thingType) + ', subtype:'+str(subtype))
	
	var section = 'OBJECT:'+str(thingType)+':'+str(subtype)
	if objectsFile.has_section(section):
		objectsFile.erase_section(section)
		print('Removed custom object type: '+str(thingType) + ' subtype: '+ str(subtype))
	
	match thingType:
		Things.TYPE.OBJECT: Things.DATA_OBJECT.erase(subtype)
		Things.TYPE.CREATURE: Things.DATA_CREATURE.erase(subtype)
		Things.TYPE.EFFECT: Things.DATA_EFFECT.erase(subtype)
		Things.TYPE.TRAP: Things.DATA_TRAP.erase(subtype)
		Things.TYPE.DOOR: Things.DATA_DOOR.erase(subtype)
	
	objectsFile.save(Settings.unearthdata.plus_file("custom_objects.cfg"))
	load_file()
	oPickThingWindow.initialize_thing_grid_items()
