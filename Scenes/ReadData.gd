extends Node

onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oDataCustomSlab = Nodelist.list["oDataCustomSlab"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oMessage = Nodelist.list["oMessage"]

onready var TILE_SIZE = Constants.TILE_SIZE
onready var SUBTILE_SIZE = Constants.SUBTILE_SIZE

#var tng_creation_order = []
#var lgt_creation_order = []
#var apt_creation_order = []

var value # just so I don't have to initialize the var in every function

func read_lof(buffer):
	# Be sure to default to 85x85 in case it can't be read.
	oDataLof.use_size(85,85)
	oDataLof.KIND = "FREE" # Default to free if it can't be read. Goes ABOVE the check.
	
	buffer.seek(0)
	value = buffer.get_string(buffer.get_size())
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	var array = value.split("\n")
	for line in array:
		if line.begins_with(";"):
			continue
		
		var lineParts = line.split("=")
		
		if lineParts.size() == 2:
			if lineParts[0].strip_edges() == "MAP_FORMAT_VERSION":
				oDataLof.MAP_FORMAT_VERSION = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "NAME_TEXT":
				oDataMapName.set_map_name(lineParts[1].strip_edges())
			if lineParts[0].strip_edges() == "NAME_ID":
				oDataLof.NAME_ID = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "KIND":
				oDataLof.KIND = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "ENSIGN_POS":
				oDataLof.ENSIGN_POS = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "ENSIGN_ZOOM":
				oDataLof.ENSIGN_ZOOM = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "PLAYERS":
				oDataLof.PLAYERS = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "OPTIONS":
				oDataLof.OPTIONS = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "SPEECH":
				oDataLof.SPEECH = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "LAND_VIEW":
				oDataLof.LAND_VIEW = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "AUTHOR":
				oDataLof.AUTHOR = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "DESCRIPTION":
				oDataLof.DESCRIPTION = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "DATE":
				oDataLof.DATE = lineParts[1].strip_edges()
			if lineParts[0].strip_edges() == "MAPSIZE":
				var sizeString = lineParts[1].strip_edges().split(" ")
				if sizeString.size() == 2:
					var x = sizeString[0].to_int()
					var y = sizeString[1].to_int()
					oDataLof.use_size(x,y)

func new_keeperfx_lof():
	oDataLof.KIND = "FREE"

func read_mapsize_from_lof(buffer):
	buffer.seek(0)
	value = buffer.get_string(buffer.get_size())
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	var array = value.split("\n")
	for line in array:
		if line.begins_with(";"):
			continue
		
		var lineParts = line.split("=")
		
		if lineParts.size() == 2:
			if lineParts[0].strip_edges() == "MAPSIZE":
				var sizeString = lineParts[1].strip_edges().split(" ")
				if sizeString.size() == 2:
					var x = sizeString[0].to_int()
					var y = sizeString[1].to_int()
					return Vector2(x,y)
	return Vector2(85,85)

func read_slx(buffer):
	# 0 = Use map's original
	# 1 = Tileset 0
	# 2 = Tileset 1
	# 3 = Tileset 2, etc.
	buffer.seek(0)
	oDataSlx.slxImgData.create(M.xSize, M.ySize, false, Image.FORMAT_RGB8)
	oDataSlx.slxTexData.create_from_image(oDataSlx.slxImgData, 0)
	oDataSlx.slxImgData.lock()
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			value = buffer.get_u8()
			var lower4bits = value & 0x0F
			# Red value will be used to store the slx value
			oDataSlx.slxImgData.set_pixel(xSlab, ySlab, Color8(lower4bits,0,0,255))
	oDataSlx.slxImgData.unlock()
	oDataSlx.slxTexData.set_data(oDataSlx.slxImgData)

func new_slx():
	oDataSlx.slxImgData.create(M.xSize, M.ySize, false, Image.FORMAT_RGB8)
	oDataSlx.slxImgData.fill(Color(0,0,0,1))
	oDataSlx.slxTexData.create_from_image(oDataSlx.slxImgData, 0)

func read_une(buffer):
	buffer.seek(0)
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			value = buffer.get_u16()
			oDataCustomSlab.set_cell(xSlab,ySlab,value)
func new_une():
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			oDataCustomSlab.set_cell(xSlab,ySlab,0)

func read_wlb(buffer):
	buffer.seek(0)
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			value = buffer.get_u8()
			oDataLiquid.set_cell(xSlab,ySlab,value)
func new_wlb():
	pass

func read_wib(buffer):
	buffer.seek(0)
	var dataHeight = (M.ySize*3)+1
	var dataWidth = (M.xSize*3)+1
	for subtileY in dataHeight:
		for subtileX in dataWidth:
			value = buffer.get_u8()
			oDataWibble.set_cell(subtileX,subtileY,value)
func new_wib():
	pass

func read_inf(buffer):
	buffer.seek(0)
	value = buffer.get_u8()
	oDataLevelStyle.data = value
func new_inf():
	pass

func read_txt(buffer):
	buffer.seek(0)
	value = buffer.get_string(buffer.get_size())
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	oDataScript.data = value
func new_txt():
	pass

func read_slb(buffer):
	buffer.seek(0)
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			#print('x:' + str(xSlab) + " " + 'y:' + str(ySlab))
			value = buffer.get_u8()
			buffer.get_u8() # skip second byte
			oDataSlab.set_cell(xSlab,ySlab,value)
func new_slb():
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			oDataSlab.set_cell(xSlab,ySlab,0)

func read_own(buffer):
	buffer.seek(0)
	var dataHeight = (M.ySize*3)+1
	var dataWidth = (M.xSize*3)+1
	for ySubtile in dataHeight:
		for xSubtile in dataWidth:
			value = buffer.get_u8()
			oDataOwnership.set_cell(xSubtile/3,ySubtile/3,value)
func new_own():
	pass

func read_dat(buffer):
	buffer.seek(0)
	var dataHeight = (M.ySize*3)+1
	var dataWidth = (M.xSize*3)+1
	for ySubtile in dataHeight:
		for xSubtile in dataWidth:
			#buffer.seek(2*(xSubtile + (ySubtile*dataWidth)))
			value = 65536 - buffer.get_u16()
			if value == 65536: value = 0
			
			oDataClmPos.set_cell(xSubtile,ySubtile,value)
func new_dat():
	var dataHeight = (M.ySize*3)+1
	var dataWidth = (M.xSize*3)+1
	for ySubtile in dataHeight:
		for xSubtile in dataWidth:
			oDataClmPos.set_cell(xSubtile,ySubtile,0)

func read_clm(buffer):
	buffer.seek(0)
	var numberOfClmEntries = buffer.get_u16()
	buffer.seek(4)
	oDataClm.unknownData = 65536 - buffer.get_u16()
	if oDataClm.unknownData == 65536: oDataClm.unknownData = 0
	buffer.seek(8) # For reading maps
	for entry in numberOfClmEntries:
		
		oDataClm.utilized.append(buffer.get_u16()) # 0-1
		
		var specialByte = buffer.get_u8() # 2
		var get_permanent = specialByte & 1
		var get_lintel = (specialByte >> 1) & 7
		var get_height = (specialByte >> 4) & 15
		oDataClm.permanent.append(get_permanent)
		oDataClm.lintel.append(get_lintel)
		oDataClm.height.append(get_height)
		
#		var get_height = specialByte / 16
#		oDataClm.height.append(get_height)
#		specialByte -= get_height * 16
#		var get_lintel = specialByte / 2
#		oDataClm.lintel.append(get_lintel)
#		specialByte -= get_lintel * 2
#		var get_permanent = specialByte
#		oDataClm.permanent.append(get_permanent)
		
		oDataClm.solidMask.append(buffer.get_u16()) # 3-4
		oDataClm.floorTexture.append(buffer.get_u16()) # 5-6
		oDataClm.orientation.append(buffer.get_u8()) # 7
		
		oDataClm.cubes.append([])
		oDataClm.cubes[entry].resize(8)
		for cubeNumber in 8:
			oDataClm.cubes[entry][cubeNumber] = buffer.get_u16() # 8-23
func new_clm():
	var numberOfClmEntries = 2048
	oDataClm.unknownData = 0
	for entry in numberOfClmEntries:
		oDataClm.utilized.append(0)
		oDataClm.permanent.append(0)
		oDataClm.lintel.append(0)
		oDataClm.height.append(0)
		oDataClm.solidMask.append(0)
		oDataClm.floorTexture.append(0)
		oDataClm.orientation.append(0)
		oDataClm.cubes.append([])
		oDataClm.cubes[entry].resize(8)
		for cubeNumber in 8:
			oDataClm.cubes[entry][cubeNumber] = 0

func read_apt(buffer):
	buffer.seek(0)
	var numberOfActionPoints = buffer.get_u32()
	print('Number of action points: '+str(numberOfActionPoints))
	
	var apScn = preload("res://Scenes/ActionPointInstance.tscn")
	
	for entry in numberOfActionPoints:
		var id = apScn.instance()
		
		id.locationX = (buffer.get_u8() / 256.0) + buffer.get_u8() # 0-1
		id.locationY = (buffer.get_u8() / 256.0) + buffer.get_u8() # 2-3
		id.pointRange = (buffer.get_u8() / 256.0) + buffer.get_u8() # 4-5
		id.pointNumber = buffer.get_u8() # 6
		id.data7 = buffer.get_u8() # 7
		
		oInstances.add_child(id)
func new_apt():
	pass

func read_lgt(buffer):
	buffer.seek(0)
	var numberOfLightPoints = buffer.get_u32()
	print('Number of light points: '+str(numberOfLightPoints))
	
	var lightScn = preload("res://Scenes/LightInstance.tscn")
	
	for entry in numberOfLightPoints:
		var id = lightScn.instance()
		
		id.lightRange = (buffer.get_u8() / 256.0) + buffer.get_u8() # 0-1
		id.lightIntensity = buffer.get_u8() # 2
		
		#7 bytes: unknown # 3-9
		id.data3 = buffer.get_u8()
		id.data4 = buffer.get_u8()
		id.data5 = buffer.get_u8()
		id.data6 = buffer.get_u8()
		id.data7 = buffer.get_u8()
		id.data8 = buffer.get_u8()
		id.data9 = buffer.get_u8()
		
		id.locationX = (buffer.get_u8() / 256.0) + buffer.get_u8() # 10-11
		id.locationY = (buffer.get_u8() / 256.0) + buffer.get_u8() # 12-13
		id.locationZ = (buffer.get_u8() / 256.0) + buffer.get_u8() # 14-15
		
		id.data16 = buffer.get_u8() # Unknown 16
		id.data17 = buffer.get_u8() # Unknown 17
		
		id.parentTile = buffer.get_u16() # 18-19
		
		oInstances.add_child(id)
func new_lgt():
	pass

func read_lgtfx(buffer):
	value = buffer.get_string(buffer.get_size())
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	
	var c = ConfigFile.new()
	var err = c.parse(value.to_upper())
	
	if err == OK:
		var numberOfLgtEntries = c.get_value("COMMON", "LIGHTSCOUNT")
		var lightScn = preload("res://Scenes/LightInstance.tscn")
		
		for entryNumber in numberOfLgtEntries:
			var section = "LIGHT"+str(entryNumber)
			if c.has_section(section) == false:
				continue
			
			var id = lightScn.instance()
			
			id.locationX = c.get_value(section, "SUBTILEX")[0] + (c.get_value(section, "SUBTILEX")[1] / 256.0)
			id.locationY = c.get_value(section, "SUBTILEY")[0] + (c.get_value(section, "SUBTILEY")[1] / 256.0)
			id.locationZ = c.get_value(section, "SUBTILEZ")[0] + (c.get_value(section, "SUBTILEZ")[1] / 256.0)
			
			id.lightIntensity = c.get_value(section, "LIGHTINTENSITY")
			id.lightRange = c.get_value(section, "LIGHTRANGE")[0] + (c.get_value(section, "LIGHTRANGE")[1] / 256.0)
			
			id.parentTile = c.get_value(section, "PARENTTILE", 65535) # Default to manually placed
			id.data3 = 0
			id.data4 = 0
			id.data5 = 0
			id.data6 = 0
			id.data7 = 0
			id.data8 = 0
			id.data9 = 0
			id.data16 = 0
			id.data17 = 0
			oInstances.add_child(id)
	else:
		oMessage.big(".lgtfx unparsable", "The map did not load correctly! Because the .lgtfx file has an error in it, likely from being manually edited. Do not save! Please close the map and fix the .lgtfx file.")

func new_lgtfx():
	pass

func read_tng(buffer):
	buffer.seek(0)
	
	#tng_creation_order.clear()
	
	var numberOfTngEntries = buffer.get_u16() # Reads two bytes as one value. This allows for thing amounts up to 65025 (255*255) I believe.
	print('Number of TNG entries: '+str(numberOfTngEntries))
	
	var thingScn = preload("res://Scenes/ThingInstance.tscn")
	
	for entryNumber in numberOfTngEntries:
		
		var id = thingScn.instance()
		id.locationX = (buffer.get_u8() / 256.0) + buffer.get_u8() # 0-1
		id.locationY = (buffer.get_u8() / 256.0) + buffer.get_u8() # 2-3
		id.locationZ = (buffer.get_u8() / 256.0) + buffer.get_u8() # 4-5
		id.thingType = buffer.get_u8() # 6
		id.subtype = buffer.get_u8() # 7
		id.ownership = buffer.get_u8() # 8
		id.data9 = buffer.get_u8() # 9
		id.data10 = buffer.get_u8() # 10
		id.data11_12 = buffer.get_u16() # 11-12
		id.data13 = buffer.get_u8() # 13
		id.data14 = buffer.get_u8() # 14
		id.data15 = buffer.get_u8() # 15
		id.data16 = buffer.get_u8() # 16
		id.data17 = buffer.get_u8() # 17
		id.data18_19 = buffer.get_u16() # 18-19
		id.data20 = buffer.get_u8() # 20
		
		match id.thingType:
			Things.TYPE.OBJECT:
				id.parentTile = id.data11_12
				if id.subtype == 49: # Hero Gate
					id.herogateNumber = id.data14
				elif id.subtype == 133: # Mysterious Box
					id.boxNumber = id.data14
			Things.TYPE.CREATURE:
				id.index = id.data11_12
				id.creatureLevel = id.data14 + 1 # 14
			Things.TYPE.EFFECTGEN:
				id.effectRange = (id.data9 / 256.0) + id.data10 # 9-10
				id.parentTile = id.data11_12
			Things.TYPE.TRAP:
				id.index = id.data11_12
				pass
			Things.TYPE.DOOR:
				id.index = id.data11_12
				id.doorOrientation = id.data13 # 13
				id.doorLocked = id.data14 # 14
		
		oInstances.add_child(id)
		#tng_creation_order.append(id)
func new_tng():
	pass

func read_tngfx(buffer):
	
	value = buffer.get_string(buffer.get_size())
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	
	var c = ConfigFile.new()
	var err = c.parse(value)
	
	if err == OK:
		var numberOfTngEntries = c.get_value("common", "ThingsCount")
		var thingScn = preload("res://Scenes/ThingInstance.tscn")
		for entryNumber in numberOfTngEntries:
			var section = "thing"+str(entryNumber)
			if c.has_section(section) == false:
				continue
			
			var id = thingScn.instance()
			
			id.locationX = c.get_value(section, "SubtileX")[0] + (c.get_value(section, "SubtileX")[1] / 256.0)
			id.locationY = c.get_value(section, "SubtileY")[0] + (c.get_value(section, "SubtileY")[1] / 256.0)
			id.locationZ = c.get_value(section, "SubtileZ")[0] + (c.get_value(section, "SubtileZ")[1] / 256.0)
			
			id.subtype = c.get_value(section, "Subtype")
			id.ownership = c.get_value(section, "Ownership")
			
			match c.get_value(section, "ThingType"):
				"Object": id.thingType = Things.TYPE.OBJECT
				"Creature": id.thingType = Things.TYPE.CREATURE
				"EffectGen": id.thingType = Things.TYPE.EFFECTGEN
				"Trap": id.thingType = Things.TYPE.TRAP
				"Door": id.thingType = Things.TYPE.DOOR
				"Effect":
					if oDataLof.MAP_FORMAT_VERSION == "": # This is for an old map format bug, read "Effect" as "EffectGen"
						id.thingType = Things.TYPE.EFFECTGEN
				
				_: id.thingType = Things.TYPE.NONE
			
			match id.thingType:
				Things.TYPE.OBJECT:
					id.parentTile = c.get_value(section, "ParentTile")
					if id.subtype == 49: # Hero Gate
						id.herogateNumber = c.get_value(section, "HerogateNumber")
					elif id.subtype == 133: # Mysterious Box
						id.boxNumber = c.get_value(section, "CustomBox")
					elif id.subtype in Things.LIST_OF_GOLDPILES:
						id.goldValue = c.get_value(section, "GoldValue", -1)
					id.orientation = c.get_value(section, "Orientation", -1)
				Things.TYPE.CREATURE:
					id.index = c.get_value(section, "Index")
					id.creatureLevel = c.get_value(section, "CreatureLevel")
					id.creatureName = c.get_value(section, "CreatureName", "")
					id.creatureGold = c.get_value(section, "CreatureGold", -1)
					id.creatureInitialHealth = c.get_value(section, "CreatureInitialHealth", -1)
					#id.orientation = c.get_value(section, "Orientation", -1)
				Things.TYPE.EFFECTGEN:
					id.effectRange = c.get_value(section, "EffectRange")[0] + (c.get_value(section, "EffectRange")[1] / 256.0)
					id.parentTile = c.get_value(section, "ParentTile")
					id.orientation = c.get_value(section, "Orientation", -1)
				Things.TYPE.TRAP:
					id.index = c.get_value(section, "Index")
					id.orientation = c.get_value(section, "Orientation", -1)
				Things.TYPE.DOOR:
					id.index = c.get_value(section, "Index")
					id.doorOrientation = c.get_value(section, "DoorOrientation")
					id.doorLocked = c.get_value(section, "DoorLocked")
			id.data9 = 0
			id.data10 = 0
			id.data11_12 = 0
			id.data13 = 0
			id.data14 = 0
			id.data15 = 0
			id.data16 = 0
			id.data17 = 0
			id.data18_19 = 0
			id.data20 = 0
			oInstances.add_child(id)
	else:
		oMessage.big(".tngfx unparsable", "The map did not load correctly! The .tngfx file has an error in it, likely from being manually edited. Do not save! Please close the map and fix the .tngfx file.")

func new_tngfx():
	pass


func read_aptfx(buffer):
	value = buffer.get_string(buffer.get_size())
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	
	var c = ConfigFile.new()
	var err = c.parse(value.to_upper())
	
	if err == OK:
		var numberOfAptEntries = c.get_value("COMMON", "ACTIONPOINTSCOUNT")
		var apScn = preload("res://Scenes/ActionPointInstance.tscn")
		
		for entryNumber in numberOfAptEntries:
			var section = "ACTIONPOINT"+str(entryNumber)
			if c.has_section(section) == false:
				continue
			
			var id = apScn.instance()
			
			id.locationX = c.get_value(section, "SUBTILEX")[0] + (c.get_value(section, "SUBTILEX")[1] / 256.0)
			id.locationY = c.get_value(section, "SUBTILEY")[0] + (c.get_value(section, "SUBTILEY")[1] / 256.0)
			
			id.pointNumber = c.get_value(section, "POINTNUMBER")
			id.pointRange = c.get_value(section, "POINTRANGE")[0] + (c.get_value(section, "POINTRANGE")[1] / 256.0)
			id.data7 = 0
			oInstances.add_child(id)
	else:
		oMessage.big(".aptfx unparsable", "The map did not load correctly! Because the .aptfx file has an error in it, likely from being manually edited. Do not save! Please close the map and fix the .aptfx file.")

func new_aptfx():
	pass

#	var bufferPos = 0
#	buffer.seek(bufferPos)
#	# These are unused for now but they can be used for extending maximum TNG entries beyond 65,535
#	var numberOfTngEntries = buffer.get_u32()
#	var numberOfLgtEntries = buffer.get_u32()
#	var numberOfAptEntries = buffer.get_u32()
#	bufferPos += 12
#
#	for entry in tng_creation_order.size():
#		bufferPos += (entry * 256)
#		buffer.seek(bufferPos)
#		var id = tng_creation_order[entry]
#		id.locationX = buffer.get_u32() + (id.locationX - int(id.locationX)) # 0-3
#		id.locationY = buffer.get_u32() + (id.locationY - int(id.locationY)) # 4-7
#		id.locationZ = buffer.get_u32() + (id.locationZ - int(id.locationZ)) # 8-11
#		# Unused : 12-255
#
#	for entry in lgt_creation_order.size():
#		bufferPos += (entry * 256)
#		buffer.seek(bufferPos)
#		var id = lgt_creation_order[entry]
#		id.locationX = buffer.get_u32() + (id.locationX - int(id.locationX)) # 0-3
#		id.locationY = buffer.get_u32() + (id.locationY - int(id.locationY)) # 4-7
#		id.locationZ = buffer.get_u32() + (id.locationZ - int(id.locationZ)) # 8-11
#		# Unused : 12-255
#
#	for entry in apt_creation_order.size():
#		bufferPos += (entry * 256)
#		buffer.seek(bufferPos)
#		var id = apt_creation_order[entry]
#		id.locationX = buffer.get_u32() + (id.locationX - int(id.locationX)) # 0-3
#		id.locationY = buffer.get_u32() + (id.locationY - int(id.locationY)) # 4-7
#		# Unused : 12-255

#func _ready(): #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	var file = File.new()
#	file.open("res://unearthdata/dklevels.lof",File.READ)
#	var buffer = StreamPeerBuffer.new()
#	buffer.data_array = file.get_buffer(file.get_len())
#	file.close()
#
#	read_lif(buffer)

func read_lif(buffer):
	var array = lif_buffer_to_array(buffer)
	var mapName = lif_array_to_map_name(array)
	oDataMapName.set_map_name(mapName)

func new_lif():
	pass

# These get their own functions because it's also used for Viewing Map Files before you open them
func lif_buffer_to_array(buffer):
	var stringFile = buffer.get_string(buffer.get_size())
	# Divide string into lines
	var array = stringFile.split("\n")
	# Convert from PoolStringArray to normal array, for the sake of being editable
	array = Array(array)
	
	# Each line by their comma
	for i in array.size():
		var subArray = Array(array[i].split(","))
		for z in subArray.size():
			subArray[z] = subArray[z].strip_edges(true, true)
		
		array[i] = subArray
	return array

# Map name
func lif_array_to_map_name(array):
	# First number in array is the "line", the second number is whether it's map number or map name
	if array.size() == 0: return "" # Lines
	if array[0].size() <= 1: return "" # Need both map number and map name to be present
	
	if array.size() >= 2: # Two lines
		if "#" in array[0][1]: # If translation ID marker ("#") present, then read the next line
			return array[1][0].trim_prefix(';')
	
	# Read map name normally
	return array[0][1]



























#func parse_lif_text(file):
#	#I'm using get_csv_line() which means the lines MUST have commas separating the values.
#	var array = []
#	while true:
#		var stringArray = file.get_csv_line()
#		if stringArray.size() > 1:
#			stringArray[0] = stringArray[0].strip_edges(true,true)
#			stringArray[1] = stringArray[1].strip_edges(true,true)
#
#			# If second array has Translation ID (so it looks like #201 or something), then read the next line.
#			if "#" in stringArray[1]:
#				stringArray[1] = file.get_line().trim_prefix(';')
#			array.append(stringArray)
#		else:
#			break
#	# Array can look like this: [[80, Morkardar], [81, Korros Tor], [82, Kari-Mar], [83, Belbata], [84, Caddis Fell], [85, Pladitz], [86, Abbadon], [87, Svatona], [88, Kanasko], [91, Netzcaro], [93, Batezek], [94, Benetzaron], [95, Daka-Gorn], [97, Dixaroc], [92, Belial]]
#	# Or like this if there's only one entry: [[80, Morkardar]]
#	return array







	# Move to the next character until a number isn't found
	# Then strip spaces and commas from the beginning
	
#	var string = buffer.get_as_text()
#	var newString = ""
#	for i in string.length():
#		if string.substr(i,1).is_valid_integer() == false:
#
#			# Get rid of comma if there's one
#			if string.substr(i,1) == ",":
#				i+=1
#
#			newString = string.right(i)
#			break
#	return newString.strip_edges(true,true)
