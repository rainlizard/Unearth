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
onready var oDataLif = Nodelist.list["oDataLif"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oDataCustomSlab = Nodelist.list["oDataCustomSlab"]

onready var TILE_SIZE = Constants.TILE_SIZE
onready var SUBTILE_SIZE = Constants.SUBTILE_SIZE

var value # just so I don't have to initialize the var in every function

func read_slx(buffer):
	# 0 = Use map's original
	# 1 = Tileset 0
	# 2 = Tileset 1
	# 3 = Tileset 2, etc.
	buffer.seek(0)
	oDataSlx.slxImgData.lock()
	for ySlab in 85:
		for xSlab in 85:
			value = buffer.get_u8()
			var lower4bits = value & 0x0F
			# Red value will be used to store the slx value
			oDataSlx.slxImgData.set_pixel(xSlab, ySlab, Color8(lower4bits,0,0,255))
	oDataSlx.slxImgData.unlock()
	oDataSlx.slxTexData.set_data(oDataSlx.slxImgData)

func read_une(buffer):
	buffer.seek(0)
	for ySlab in 85:
		for xSlab in 85:
			value = buffer.get_u16()
			oDataCustomSlab.set_cell(xSlab,ySlab,value)

func read_wlb(buffer):
	buffer.seek(0)
	for ySlab in 85:
		for xSlab in 85:
			value = buffer.get_u8()
			oDataLiquid.set_cell(xSlab,ySlab,value)

func read_wib(buffer):
	buffer.seek(0)
	for ySubtile in 256:
		for xSubtile in 256:
			value = buffer.get_u8()
			oDataWibble.set_cell(xSubtile,ySubtile,value)

func read_inf(buffer):
	buffer.seek(0)
	value = buffer.get_u8()
	oDataLevelStyle.data = value

func read_txt(buffer):
	buffer.seek(0)
	value = buffer.get_string(buffer.get_size())
	
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	oDataScript.data = value

func read_slb(buffer):
	buffer.seek(0)
	for y in 85:
		for x in 85:
			#buffer.seek( 2 * ( (y*85) + x ) )
			value = buffer.get_u8()
			buffer.get_u8() # skip second byte
			oDataSlab.set_cell(x,y,value)

func read_own(buffer):
	buffer.seek(0)
	var dataHeight = (85*3)+1
	var dataWidth = (85*3)+1
	for ySubtile in dataHeight:
		for xSubtile in dataWidth:
			value = buffer.get_u8()
			oDataOwnership.set_cell(xSubtile/3,ySubtile/3,value)

func read_dat(buffer):
	buffer.seek(0)
	var dataHeight = (85*3)+1
	var dataWidth = (85*3)+1
	for ySubtile in dataHeight:
		for xSubtile in dataWidth:
			#buffer.seek(2*(xSubtile + (ySubtile*dataWidth)))
			value = 65536 - buffer.get_u16()
			if value == 65536: value = 0
			
			oDataClmPos.set_cell(xSubtile,ySubtile,value)

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
		
		# Is 18 and 19 required?
		id.data18 = buffer.get_u8() # 18
		id.data19 = buffer.get_u8() # 19
		
		oInstances.add_child(id)

func read_tng(buffer):
	buffer.seek(0)
	
	var numberOfTngEntries = buffer.get_u16() # Reads two bytes as one value. This allows for thing amounts up to 65025 (255*255) I believe.
	print('Number of TNG entries: '+str(numberOfTngEntries))
	
	var thingScn = preload("res://Scenes/ThingInstance.tscn")
	
	for entry in numberOfTngEntries:
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
		id.data18 = buffer.get_u8() # 18
		id.data19 = buffer.get_u8() # 19
		id.data20 = buffer.get_u8() # 20
		
		match id.thingType:
			Things.TYPE.OBJECT:
				id.sensitiveTile = id.data11_12
				if id.subtype == 49: # Hero Gate
					id.herogateNumber = id.data14
				elif id.subtype == 133: # Mysterious Box
					id.boxNumber = id.data14
			Things.TYPE.CREATURE:
				id.index = id.data11_12
				id.creatureLevel = id.data14 + 1 # 14
			Things.TYPE.EFFECT:
				id.effectRange = (id.data9 / 256.0) + id.data10 # 9-10
				id.sensitiveTile = id.data11_12
			Things.TYPE.TRAP:
				id.index = id.data11_12
				pass
			Things.TYPE.DOOR:
				id.index = id.data11_12
				id.doorOrientation = id.data13 # 13
				id.doorLocked = id.data14 # 14
		
		oInstances.add_child(id)

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
	oDataLif.data = mapName

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
