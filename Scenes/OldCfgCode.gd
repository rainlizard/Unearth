extends Node


var haveFullySetupDefaultData = false
var animation_id_to_image = {} # Just a shortcut, the real images are stored in the data structures
var custom_images_list = {} # Contains uppercase filename and real filename
var default_data = {}



#func load_cfg_stuff(map):
#	var CODETIME_START = OS.get_ticks_msec()
#	Things.reset_thing_data_to_default()
#	if Cube.tex.empty() == true:
#		Cube.read_cubes_cfg()
#
#	oCustomObjectSystem.load_file()
#
#	var parentDirectory = map.get_base_dir().get_base_dir()
#	var mainCfgName = map.get_base_dir().get_file() + ".cfg"
#	print("Parent directory: " + parentDirectory)
#	print("Main cfg name: " + mainCfgName)
#	var fullPathToMainCfg = oGame.get_precise_filepath(parentDirectory, mainCfgName)
#	if fullPathToMainCfg != "":
#		Things.get_cfgs_directory(fullPathToMainCfg)
#	print('load_cfg_stuff: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')



#func _init():
#	# This only takes 1ms
#	default_data["DATA_EXTRA"] = DATA_EXTRA.duplicate(true)
#	default_data["DATA_DOOR"] = DATA_DOOR.duplicate(true)
#	default_data["DATA_TRAP"] = DATA_TRAP.duplicate(true)
#	default_data["DATA_EFFECTGEN"] = DATA_EFFECTGEN.duplicate(true)
#	default_data["DATA_CREATURE"] = DATA_CREATURE.duplicate(true)
#	default_data["DATA_OBJECT"] = DATA_OBJECT.duplicate(true)
#
#
#func reset_thing_data_to_default():
#	if haveFullySetupDefaultData == false:
#		haveFullySetupDefaultData = true
#		var oGame = Nodelist.list["oGame"]
#		read_all_things_cfg_from_dir(oGame.DK_FXDATA_DIRECTORY, 0)
#
#	# Reset data. Takes 1ms.
#	DATA_EXTRA = default_data["DATA_EXTRA"].duplicate(true)
#	DATA_DOOR = default_data["DATA_DOOR"].duplicate(true)
#	DATA_TRAP = default_data["DATA_TRAP"].duplicate(true)
#	DATA_EFFECTGEN = default_data["DATA_EFFECTGEN"].duplicate(true)
#	DATA_CREATURE = default_data["DATA_CREATURE"].duplicate(true)
#	DATA_OBJECT = default_data["DATA_OBJECT"].duplicate(true)


func get_cfgs_directory(fullPathToMainCfg):
	var oGame = Nodelist.list["oGame"]
	
	var massiveString = file_to_upper_string(fullPathToMainCfg.get_base_dir(), fullPathToMainCfg.get_file())
	if massiveString is String:
		var bigListOfLines = massiveString.split('\n',false)
		for line in bigListOfLines:
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				if componentsOfLine[0].strip_edges() == "CONFIGS_LOCATION":
					var configsLocationValue = componentsOfLine[1].strip_edges()
					var fullCfgsDir = oGame.GAME_DIRECTORY.plus_file(configsLocationValue)
					
					read_all_things_cfg_from_dir(fullCfgsDir, 1)
					return

func read_all_things_cfg_from_dir(dir, load_into):
	var CODETIME_START = OS.get_ticks_msec()
	
	for i in 4:
		match i:
			0:
				var massiveString = file_to_upper_string(dir, "OBJECTS.CFG")
				if massiveString is String:
					if load_into == 0:
						cfg_objects(massiveString, default_data["DATA_OBJECT"])
					else:
						cfg_objects(massiveString, Things.DATA_OBJECT)
			1:
				var massiveString = file_to_upper_string(dir, "CREATURE.CFG")
				if massiveString is String:
					if load_into == 0:
						cfg_creatures(massiveString, default_data["DATA_CREATURE"])
					else:
						cfg_creatures(massiveString, Things.DATA_CREATURE)
			2:
				var massiveString = file_to_upper_string(dir, "TRAPDOOR.CFG")
				if massiveString is String:
					if load_into == 0:
						cfg_traps(massiveString, default_data["DATA_TRAP"])
					else:
						cfg_traps(massiveString, Things.DATA_TRAP)
			3:
				var massiveString = file_to_upper_string(dir, "TRAPDOOR.CFG")
				if massiveString is String:
					if load_into == 0:
						cfg_doors(massiveString, default_data["DATA_DOOR"])
					else:
						cfg_doors(massiveString, Things.DATA_DOOR)
	print('All thing cfgs read in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func cfg_objects(massiveString, DATA_ARRAY):
	
	var listSections = massiveString.split('[OBJECT',false)
	if listSections.size() > 0: listSections.remove(0) # get rid of the first section since it just contains stuff before [object0]
	var objectID = 0
	for section in listSections:
		
		var bigListOfLines = section.split('\n',false)
		if bigListOfLines.size() > 0:
			var header = bigListOfLines[0].strip_edges() # First line will always be the header, because that's where it was split at
			objectID = header.to_int() # Set objectID to header
			if DATA_ARRAY.has(objectID) == false:
				DATA_ARRAY[objectID] = [null, null, null, null, null, null] # Initialize empty space for each new entry in .cfg
		
		for line in bigListOfLines:
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				
				if componentsOfLine[0].strip_edges() == "NAME":
					var thingCfgName = componentsOfLine[1].strip_edges()
					var do = false
					if default_data["DATA_OBJECT"].has(objectID) == false:
						do = true
					if DATA_ARRAY[objectID][Things.NAME] == null:
						do = true
#					elif default_data["DATA_OBJECT"][objectID][NAME] == null:
#						do = true
#					elif thingCfgName != default_data["DATA_OBJECT"][objectID][KEEPERFX_NAME] or DATA_ARRAY[objectID][KEEPERFX_NAME] == null:
#						do = true
					
					if do == true:
						DATA_ARRAY[objectID][Things.KEEPERFX_NAME] = thingCfgName # Always set CFG name
						DATA_ARRAY[objectID][Things.NAME] = thingCfgName.capitalize()
						look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName)
					
				elif componentsOfLine[0].strip_edges() == "GENRE" and objectID != 0:
					var thingGenre = componentsOfLine[1].strip_edges()
					var thingTab = Things.GENRE_TO_TAB[thingGenre]
					
					var do = false
					if default_data["DATA_OBJECT"].has(objectID) == false:
						do = true
					elif DATA_ARRAY[objectID][Things.EDITOR_TAB] == null: #thingTab != default_data["DATA_OBJECT"][objectID][EDITOR_TAB] or
						do = true
					
					if do == true:
						DATA_ARRAY[objectID][Things.EDITOR_TAB] = thingTab
					
				elif componentsOfLine[0].strip_edges() == "ANIMATIONID":
					var thingAnimationID = componentsOfLine[1].strip_edges()
					look_for_images_to_load(DATA_ARRAY, objectID, thingAnimationID)
					DATA_ARRAY[objectID][Things.ANIMATION_ID] = thingAnimationID
					
					if DATA_ARRAY[objectID][Things.TEXTURE] == null:
						call_deferred("set_image_based_on_animation_id", Things.TYPE.OBJECT, objectID, thingAnimationID) # Do it next frame after everything has been appended inside animation_id_to_image, so we can look through it all.
					else:
						animation_id_to_image[thingAnimationID] = DATA_ARRAY[objectID][Things.TEXTURE]

func cfg_traps(massiveString, DATA_ARRAY):
	var listSections = massiveString.split('[TRAP',false)
	if listSections.size() > 0: listSections.remove(0) # get rid of the first section since it just contains stuff before [object0]
	var objectID = 0
	for section in listSections:
		
		var bigListOfLines = section.split('\n',false)
		if bigListOfLines.size() > 0:
			var header = bigListOfLines[0].strip_edges() # First line will always be the header, because that's where it was split at
			objectID = header.to_int() # Set objectID to header
			if DATA_ARRAY.has(objectID) == false:
				DATA_ARRAY[objectID] = [null, null, null, null, null, null] # Initialize empty space for each new entry in .cfg
		
		var already_assigned_name = false # This is needed otherwise traps and doors sometimes use each other's fields
		var already_assigned_animation_id = false
		
		for line in bigListOfLines:
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				
				if componentsOfLine[0].strip_edges() == "NAME" and already_assigned_name == false:
					var thingCfgName = componentsOfLine[1].strip_edges()
					DATA_ARRAY[objectID][Things.KEEPERFX_NAME] = thingCfgName # Always set CFG name
					already_assigned_name = true
					if DATA_ARRAY[objectID][Things.NAME] == null or objectID >= 7: # Only change name if it's a newly added item OR a Dummy Trap
						DATA_ARRAY[objectID][Things.NAME] = thingCfgName.capitalize()
					look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName)
				elif componentsOfLine[0].strip_edges() == "ANIMATIONID" and already_assigned_animation_id == false:
					var thingAnimationID = componentsOfLine[1].strip_edges()
					look_for_images_to_load(DATA_ARRAY, objectID, thingAnimationID)
					DATA_ARRAY[objectID][Things.ANIMATION_ID] = thingAnimationID
					already_assigned_animation_id = true
					
					if DATA_ARRAY[objectID][Things.TEXTURE] == null:
						call_deferred("set_image_based_on_animation_id", Things.TYPE.TRAP, objectID, thingAnimationID) # Do it next frame after everything has been appended inside animation_id_to_image, so we can look through it all.
					else:
						animation_id_to_image[thingAnimationID] = DATA_ARRAY[objectID][Things.TEXTURE]


func cfg_doors(massiveString, DATA_ARRAY):
	var listSections = massiveString.split('[DOOR',false)
	if listSections.size() > 0: listSections.remove(0) # get rid of the first section since it just contains stuff before [object0]
	var objectID = 0
	for section in listSections:
		var bigListOfLines = section.split('\n',false)
		if bigListOfLines.size() > 0:
			var header = bigListOfLines[0].strip_edges() # First line will always be the header, because that's where it was split at
			objectID = header.to_int() # Set objectID to header
			if DATA_ARRAY.has(objectID) == false:
				DATA_ARRAY[objectID] = [null, null, null, null, null, null] # Initialize empty space for each new entry in .cfg
		
		var already_assigned_name = false # This is needed otherwise traps and doors sometimes use each other's fields
		var already_assigned_animation_id = false
		
		for line in bigListOfLines:
			
			var componentsOfLine = line.split('=', false)
			if componentsOfLine.size() >= 2:
				
				if componentsOfLine[0].strip_edges() == "NAME" and already_assigned_name == false:
					var thingCfgName = componentsOfLine[1].strip_edges()
					DATA_ARRAY[objectID][Things.KEEPERFX_NAME] = thingCfgName
					already_assigned_name = true
					if DATA_ARRAY[objectID][Things.NAME] == null: # Only set editor name if it's a newly added item
						DATA_ARRAY[objectID][Things.NAME] = thingCfgName.capitalize()
					look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName)
				elif componentsOfLine[0].strip_edges() == "ANIMATIONID" and already_assigned_animation_id == false:
					var thingAnimationID = componentsOfLine[1].strip_edges()
					look_for_images_to_load(DATA_ARRAY, objectID, thingAnimationID)
					DATA_ARRAY[objectID][Things.ANIMATION_ID] = thingAnimationID
					already_assigned_animation_id = true
					
					if DATA_ARRAY[objectID][Things.TEXTURE] == null:
						call_deferred("set_image_based_on_animation_id", Things.TYPE.DOOR, objectID, thingAnimationID) # Do it next frame after everything has been appended inside animation_id_to_image, so we can look through it all.
					else:
						animation_id_to_image[thingAnimationID] = DATA_ARRAY[objectID][Things.TEXTURE]

func cfg_creatures(massiveString, DATA_ARRAY):
	var bigListOfLines = massiveString.split('\n',false)
	for line in bigListOfLines:
		var componentsOfLine = line.split('=', false)
		if componentsOfLine.size() >= 2:
			if componentsOfLine[0].strip_edges() == "CREATURES":
				var creaturesList = componentsOfLine[1].strip_edges().split(' ', false)
				var objectID = 0
				creaturesList.insert(0, "")
				while true:
					if objectID > 0: # Ignore null
						if DATA_ARRAY.has(objectID) == false:
							DATA_ARRAY[objectID] = [null, null, null, null, null, null] # Initialize empty space for each new entry in .cfg
						
						var thingCfgName = creaturesList[objectID].strip_edges()
						#if DATA_ARRAY[objectID][KEEPERFX_NAME] == null:
						DATA_ARRAY[objectID][Things.KEEPERFX_NAME] = thingCfgName
						#DATA_ARRAY[objectID][Things.NAME] = get_proper_creature_name(thingCfgName.capitalize())
						DATA_ARRAY[objectID][Things.EDITOR_TAB] = Things.TAB_CREATURE
						look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName)
					
					objectID += 1
					if objectID >= creaturesList.size():
						return
				
				return # exit early

func set_image_based_on_animation_id(thingType, objectID, thingAnimationID):
	if int(thingAnimationID) == 0:
		return # This is important, if ANIMATIONID is 0 then it shouldn't be set. It should be a grey diamond.
	
	if animation_id_to_image.has(thingAnimationID):
		match thingType:
			Things.TYPE.OBJECT: Things.DATA_OBJECT[objectID][Things.TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.CREATURE: Things.DATA_CREATURE[objectID][Things.TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.EFFECTGEN: Things.DATA_EFFECTGEN[objectID][Things.TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.TRAP: Things.DATA_TRAP[objectID][Things.TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.DOOR: Things.DATA_DOOR[objectID][Things.TEXTURE] = animation_id_to_image[thingAnimationID]
			Things.TYPE.EXTRA: Things.DATA_EXTRA[objectID][Things.TEXTURE] = animation_id_to_image[thingAnimationID]

func file_to_upper_string(dir, fileName):
	var oGame = Nodelist.list["oGame"]
	var path = oGame.get_precise_filepath(dir, fileName)
	
	var file = File.new()
	if path == "" or file.open(path, File.READ) != OK:
		return -1
	var massiveString = file.get_as_text().to_upper() # Make it easier to read by making it all upper case
	file.close()
	return massiveString


#func get_zip_files_in_dir(path):
#	var array = []
#	var dir = Directory.new()
#	if dir.open(path) == OK:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			if dir.current_is_dir():
#				pass
#			else:
#				if file_name.get_extension().to_upper() == "ZIP":
#					array.append(path.plus_file(file_name))
#			file_name = dir.get_next()
#	else:
#		print("An error occurred when trying to access the path.")
#	return array

func look_for_images_to_load(DATA_ARRAY, objectID, thingCfgName):
	if custom_images_list.empty() == true:
		custom_images_list = get_png_filenames_in_dir(Settings.unearthdata.plus_file("custom-object-images"))
	
	var dir = Settings.unearthdata.plus_file("custom-object-images")
	
	var uppercaseImageFilename = thingCfgName+".PNG".to_upper()
	var uppercasePortraitFilename = thingCfgName+"_PORTRAIT.PNG".to_upper()
	
	var realImageFilename = ""
	var realPortraitFilename = ""
	
	if custom_images_list.has(uppercaseImageFilename):
		 realImageFilename = custom_images_list[uppercaseImageFilename]
	
	if custom_images_list.has(uppercasePortraitFilename):
		 realPortraitFilename = custom_images_list[uppercasePortraitFilename]
	
	if realImageFilename != "":
		var img = Image.new()
		var err = img.load(dir.plus_file(realImageFilename))
		if err == OK:
			var tex = ImageTexture.new()
			tex.create_from_image(img, Texture.FLAG_MIPMAPS+Texture.FLAG_ANISOTROPIC_FILTER)
			DATA_ARRAY[objectID][Things.TEXTURE] = tex
	
	if realPortraitFilename != "":
		var img = Image.new()
		var err = img.load(dir.plus_file(realPortraitFilename))
		if err == OK:
			var tex = ImageTexture.new()
			tex.create_from_image(img, Texture.FLAG_MIPMAPS+Texture.FLAG_ANISOTROPIC_FILTER)
			DATA_ARRAY[objectID][Things.PORTRAIT] = tex



func get_png_filenames_in_dir(path):
	var dictionary = {}
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.get_extension().to_upper() == "PNG":
					dictionary[file_name.to_upper().replace(" ", "_")] = file_name
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return dictionary


#func load_custom_images_into_array(DATA_ARRAY, thingtypeImageFolder):
#	print("Loading /thing-images/" + thingtypeImageFolder + " directory ...")
#	var arrayOfFilenames = get_png_files_in_dir(Settings.unearthdata.plus_file("thing-images").plus_file(thingtypeImageFolder))
#	for i in arrayOfFilenames:
#		var subtypeID = int(i.get_file().get_basename())
#		var img = Image.new()
#		var err = img.load(i)
#		if err == OK:
#			var tex = ImageTexture.new()
#			tex.create_from_image(img)
#			if DATA_ARRAY.has(subtypeID):
#				DATA_ARRAY[subtypeID][TEXTURE] = tex


#func get_png_files_in_dir(path):
#	var array = []
#	var dir = Directory.new()
#	if dir.open(path) == OK:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			if dir.current_is_dir():
#				pass
#			else:
#				if file_name.get_extension().to_upper() == "PNG":
#					var fileNumber = file_name.get_file().get_basename()
#					if Utils.string_has_letters(fileNumber) == false:
#						array.append(path.plus_file(file_name))
#			file_name = dir.get_next()
#	else:
#		print("An error occurred when trying to access the path.")
#	return array


#
#static func thing_text(array):
#	var typeArgument = array[THING_TYPE]
#	var subtypeArgument = array[THING_SUBTYPE]
#
#	match typeArgument:
#		TYPE.NONE: return ''
#		TYPE.ITEM: return DATA_OBJECT[subtypeArgument][NAME]
#		TYPE.CREATURE: return DATA_CREATURE[subtypeArgument][NAME]
#		TYPE.EFFECT: return DATA_EFFECTGEN[subtypeArgument][NAME]
#		TYPE.TRAP: return DATA_TRAP[subtypeArgument][NAME]
#		TYPE.DOOR: return DATA_DOOR[subtypeArgument][NAME]
#	return 'UNKNOWN'
#
#static func thing_portrait(array):
#	var typeArgument = array[THING_TYPE]
#	var subtypeArgument = array[THING_SUBTYPE]
#
#	var tmp = null
#	# If the portait field in the array is null, use the texture.
#	match typeArgument:
#		TYPE.NONE:
#			return null
#		TYPE.ITEM:
#			tmp = DATA_OBJECT[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_OBJECT[subtypeArgument][TEXTURE]
#		TYPE.CREATURE:
#			tmp = DATA_CREATURE[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_CREATURE[subtypeArgument][TEXTURE]
#		TYPE.EFFECT:
#			tmp = DATA_EFFECTGEN[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_EFFECTGEN[subtypeArgument][TEXTURE]
#		TYPE.TRAP:
#			tmp = DATA_TRAP[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_TRAP[subtypeArgument][TEXTURE]
#		TYPE.DOOR:
#			tmp = DATA_DOOR[subtypeArgument][PORTRAIT]
#			if tmp == null: tmp = DATA_DOOR[subtypeArgument][TEXTURE]
#	return tmp
#
#static func create(array, thingScn):
#	var id = thingScn.instance()
#	id.data = array
#	id.setPosition()
#	id.setOwnership()
#	return id
#
#func get_ownership():
#	return self.data[OWNERSHIP]
#func get_type():
#	return self.data[THING_TYPE]
#func get_subtype():
#	return self.data[THING_SUBTYPE]


#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################

#	match id.data[THING_TYPE]:
#		TYPE.CREATURE:
#			id.data[CREATURE_LEVEL] = array[CREATURE_LEVEL]
#		TYPE.EFFECT:
#			id.data[THING_RANGE] = array[THING_RANGE]
#			id.data[THING_RANGE_WITHIN] = array[THING_RANGE_WITHIN]

#static func read_thing(node):
##	var SUBTILE_SIZE = 32
##	var TILE_SIZE = 96
#
#	if node == null: return null
#
#	var array = [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0]
#	# 6: Thing type
#
#	var wholeX = floor(node.position.x / SUBTILE_SIZE)
#	var wholeY = floor(node.position.y / SUBTILE_SIZE)
#	var wholeZ = floor(node.altitude / SUBTILE_SIZE)
#	var decimalX = (node.position.x / SUBTILE_SIZE) - wholeX
#	var decimalY = (node.position.y / SUBTILE_SIZE) - wholeY
#	var decimalZ = (node.altitude / SUBTILE_SIZE) - wholeZ
#
#	array[0] = (decimalX * 256)
#	array[1] = wholeX
#	array[2] = (decimalY * 256)
#	array[3] = wholeY
#	array[4] = (decimalZ * 256)
#	array[5] = wholeZ
#	array[6] = node.data[THING_TYPE]
#	array[7] = node.data[THING_SUBTYPE]
#	array[8] = node.data[OWNERSHIP]
#
#	match node.get_type():
#		TYPE.NONE:
#			pass
#		TYPE.ITEM:
#			# Item/decoration
#			#array[11] = node.parentTile
#			#array[12] = node.parentTile
#			pass
#		TYPE.CREATURE:
#			array[14] = node.data[CREATURE_LEVEL]
#		TYPE.EFFECT:
#			array[9] = node.data[THING_RANGE_WITHIN]
#			array[10] = node.data[THING_RANGE]
#			pass
#		TYPE.TRAP:
#			pass
#		TYPE.DOOR:
#			# Door
#			#array[13] = node.doorOrientation
#			#array[14] = node.doorLocked
#			pass
#
#	return array

#enum {
#	SUBTILE_X_WITHIN = 0
#	SUBTILE_X = 1
#	SUBTILE_Y_WITHIN = 2
#	SUBTILE_Y = 3
#	SUBTILE_Z_WITHIN = 4
#	SUBTILE_Z = 5
#	THING_TYPE = 6
#	THING_SUBTYPE = 7
#	OWNERSHIP = 8
#
#	# Depends on type:
#	THING_RANGE_WITHIN = 9
#	THING_RANGE = 10
#	PARENT_TILE1 = 11
#	PARENT_TILE2 = 12
#	DOOR_ORIENTATION = 13
#	CREATURE_LEVEL = 14
#	DOOR_LOCKED = 14
#	HEROGATE_NUMBER = 14
#}
