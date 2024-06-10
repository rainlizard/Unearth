extends Node

onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oDataFakeSlab = Nodelist.list["oDataFakeSlab"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]

var value # just so I don't have to initialize the var in every function

func write_keeperfx_lof():
	var buffer = StreamPeerBuffer.new()
	var newString = ""
	newString += "; KeeperFX Level Overview File (LOF)" + "\n"
	newString += "MAP_FORMAT_VERSION = " + str(Version.unearth_map_format_version).pad_decimals(2) + "\n"
	newString += "NAME_TEXT = " + str(oDataLof.NAME_TEXT) + "\n"
	newString += "NAME_ID = " + str(oDataLof.NAME_ID) + "\n"
	newString += "KIND = " + str(oDataLof.KIND) + "\n"
	newString += "ENSIGN_POS = " + str(oDataLof.ENSIGN_POS) + "\n"
	newString += "ENSIGN_ZOOM = " + str(oDataLof.ENSIGN_ZOOM) + "\n"
	newString += "PLAYERS = " + str(oDataLof.PLAYERS) + "\n"
	newString += "OPTIONS = " + str(oDataLof.OPTIONS) + "\n"
	newString += "SPEECH = " + str(oDataLof.SPEECH) + "\n"
	newString += "LAND_VIEW = " + str(oDataLof.LAND_VIEW) + "\n"
	newString += "AUTHOR = " + str(oDataLof.AUTHOR) + "\n"
	newString += "DESCRIPTION = " + str(oDataLof.DESCRIPTION) + "\n"
	var dict = Time.get_date_dict_from_system()
	var setDate = str(dict["year"])+"-"+str(dict["month"])+"-"+str(dict["day"])
	newString += "DATE = " + str(setDate) + "\n"
	newString += "MAPSIZE = " + str(M.xSize) + " " + str(M.ySize)
	var scriptBytes = newString.to_ascii()
	buffer.put_data(scriptBytes)
	return buffer

func write_lif(filePath):
	var buffer = StreamPeerBuffer.new()
	var mapNumber = filePath.get_file().get_basename().to_upper().trim_prefix('MAP')
	
	# Remove 3 leading zeroes. I could remove 4 but I'm unsure if I should.
	for i in 3:
		mapNumber = mapNumber.trim_prefix('0')
	
	value = mapNumber + ', ' + oDataMapName.data
	
	buffer.put_data(value.to_utf8())
	return buffer

func write_txt():
	var buffer = StreamPeerBuffer.new()
	value = oDataScript.data
	# I'm only using \n (LF) instead of \r\n (CRLF), because to_ascii() is removing the \r (CR) for some reason.
	# Old Notepad will not display TXT files correctly.
	# Notepad++ displays correctly and apparently so does Notepad on Windows 10.
	
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	var scriptBytes = value.to_ascii()
	buffer.put_data(scriptBytes)
	return buffer

func write_une():
	var buffer = StreamPeerBuffer.new()
	buffer.data_array = oDataFakeSlab.buffer.data_array
	return buffer

func write_wlb():
	var buffer = StreamPeerBuffer.new()
	buffer.data_array = oDataLiquid.buffer.data_array
	return buffer

func write_wib():
	var buffer = StreamPeerBuffer.new()
	buffer.data_array = oDataWibble.buffer.data_array
	return buffer

func write_slb():
	var buffer = StreamPeerBuffer.new()
	buffer.data_array = oDataSlab.buffer.data_array
	return buffer

func write_own():
	var buffer = StreamPeerBuffer.new()
	buffer.data_array = oDataOwnership.buffer.data_array
	return buffer

func write_tng():
	var buffer = StreamPeerBuffer.new()
	var numberOfTngEntries = get_tree().get_nodes_in_group("Thing").size()
	buffer.put_16(numberOfTngEntries)
	
	for thingNode in get_tree().get_nodes_in_group("Thing"):
		if thingNode.is_queued_for_deletion() == true:
			continue
		buffer.put_8(fmod(thingNode.locationX,1.0) * 256) # 0
		buffer.put_8(int(thingNode.locationX)) # 1
		buffer.put_8(fmod(thingNode.locationY,1.0) * 256) # 2
		buffer.put_8(int(thingNode.locationY)) # 3
		buffer.put_8(fmod(thingNode.locationZ,1.0) * 256) # 4
		buffer.put_8(int(thingNode.locationZ)) # 5
		buffer.put_8(thingNode.thingType) # 6
		buffer.put_8(thingNode.subtype) # 7
		buffer.put_8(thingNode.ownership) # 8
		
		if thingNode.effectRange != null:
			buffer.put_8(fmod(thingNode.effectRange,1.0) * 256) # 9
			buffer.put_8(int(thingNode.effectRange)) # 10
		else:
			buffer.put_8(thingNode.data9) # 9
			buffer.put_8(thingNode.data10) # 10
		
		if thingNode.parentTile != null:
			buffer.put_16(thingNode.parentTile) # 11-12
		elif thingNode.index != null:
			buffer.put_16(thingNode.index) # 11-12
		else:
			buffer.put_16(thingNode.data11_12) # 11-12
		
		if thingNode.doorOrientation != null:
			buffer.put_8(thingNode.doorOrientation) # 13
		else:
			buffer.put_8(thingNode.data13) # 13
		
		if thingNode.creatureLevel != null:
			buffer.put_8(thingNode.creatureLevel - 1) # 14
		elif thingNode.doorLocked != null:
			buffer.put_8(thingNode.doorLocked) # 14
		elif thingNode.herogateNumber != null:
			buffer.put_8(thingNode.herogateNumber) # 14
		elif thingNode.boxNumber != null:
			buffer.put_8(thingNode.boxNumber) # 14
		else:
			buffer.put_8(thingNode.data14) # 14
		
		buffer.put_8(thingNode.data15) # 15
		buffer.put_8(thingNode.data16) # 16
		buffer.put_8(thingNode.data17) # 17
		buffer.put_16(thingNode.data18_19) # 18-19
		buffer.put_8(thingNode.data20) # 20
	return buffer


func write_tngfx():
	var buffer = StreamPeerBuffer.new()
	var groupNames = {
		Things.TYPE.OBJECT: "Object",
		Things.TYPE.CREATURE: "Creature",
		Things.TYPE.EFFECTGEN: "EffectGen",
		Things.TYPE.TRAP: "Trap",
		Things.TYPE.DOOR: "Door"
	}

	var lines = PoolStringArray()
	lines.append("[common]")
	lines.append("") # This gets changed at the end
	
	var entryNumber = 0
	for thingType in [Things.TYPE.DOOR, Things.TYPE.OBJECT, Things.TYPE.CREATURE, Things.TYPE.EFFECTGEN, Things.TYPE.TRAP]:
		var groupName = groupNames[thingType]
		
		for thingNode in get_tree().get_nodes_in_group(groupName):
			if thingNode.is_queued_for_deletion() == true:
				continue
			lines.append("")
			lines.append("[thing" + str(entryNumber) + "]")
			lines.append("ThingType = \"" + groupName + "\"")
			lines.append("Subtype = " + str(thingNode.subtype))
			lines.append("Ownership = " + str(thingNode.ownership))

			if thingNode.effectRange != null:
				lines.append("EffectRange = [" + str(int(thingNode.effectRange)) + ", " + str(int(fmod(thingNode.effectRange, 1.0) * 256)) + "]")
			if thingNode.parentTile != null:
				lines.append("ParentTile = " + str(thingNode.parentTile))
			if thingNode.index != null:
				lines.append("Index = " + str(thingNode.index))
			if thingNode.doorOrientation != null:
				lines.append("DoorOrientation = " + str(thingNode.doorOrientation))
			if thingNode.creatureLevel != null:
				lines.append("CreatureLevel = " + str(thingNode.creatureLevel))
			if thingNode.doorLocked != null:
				lines.append("DoorLocked = " + str(thingNode.doorLocked))
			if thingNode.herogateNumber != null:
				lines.append("HerogateNumber = " + str(thingNode.herogateNumber))
			if thingNode.boxNumber != null:
				lines.append("CustomBox = " + str(thingNode.boxNumber))
			if thingNode.creatureName != null and thingNode.creatureName != "":
				lines.append("CreatureName = \"" + thingNode.creatureName + "\"")
			if thingNode.creatureGold != null:
				lines.append("CreatureGold = " + str(thingNode.creatureGold))
			if thingNode.creatureInitialHealth != null:
				lines.append("CreatureInitialHealth = " + str(thingNode.creatureInitialHealth))
			if thingNode.orientation != null:
				lines.append("Orientation = " + str(thingNode.orientation))
			if thingNode.goldValue != null:
				lines.append("GoldValue = " + str(thingNode.goldValue))

			lines.append("SubtileX = [" + str(int(thingNode.locationX)) + ", " + str(int(fmod(thingNode.locationX, 1.0) * 256)) + "]")
			lines.append("SubtileY = [" + str(int(thingNode.locationY)) + ", " + str(int(fmod(thingNode.locationY, 1.0) * 256)) + "]")
			lines.append("SubtileZ = [" + str(int(thingNode.locationZ)) + ", " + str(int(fmod(thingNode.locationZ, 1.0) * 256)) + "]")
			entryNumber += 1
	
	lines.set(1, "ThingsCount = " + str(entryNumber))
	buffer.put_data("\n".join(lines).to_ascii())
	
	return buffer


func write_apt():
	var buffer = StreamPeerBuffer.new()
	var numberOfActionPoints = get_tree().get_nodes_in_group("ActionPoint").size()
	buffer.put_32(numberOfActionPoints)
	
	for apNode in get_tree().get_nodes_in_group("ActionPoint"):
		if apNode.is_queued_for_deletion() == true:
			continue
		buffer.put_8(fmod(apNode.locationX,1.0) * 256) # 0
		buffer.put_8(int(apNode.locationX)) # 1
		buffer.put_8(fmod(apNode.locationY,1.0) * 256) # 2
		buffer.put_8(int(apNode.locationY)) # 3
		buffer.put_8(fmod(apNode.pointRange,1.0) * 256) # 4
		buffer.put_8(int(apNode.pointRange)) # 5
		buffer.put_8(apNode.pointNumber) # 6
		buffer.put_8(apNode.data7) # 7
	return buffer


func write_aptfx():
	var buffer = StreamPeerBuffer.new()
	var lines = PoolStringArray()
	lines.append("[common]")
	lines.append("") # This gets changed at the end
	
	var entryNumber = 0
	for apNode in get_tree().get_nodes_in_group("ActionPoint"):
		if apNode.is_queued_for_deletion() == true:
			continue
		lines.append("")
		lines.append("[actionpoint" + str(entryNumber) + "]")
		
		if apNode.pointNumber != null:
			lines.append("PointNumber = " + str(apNode.pointNumber))
		
		if apNode.pointRange != null:
			var setRange = str(int(apNode.pointRange))
			var setRangeInner = str(fmod(apNode.pointRange, 1.0) * 256)
			lines.append("PointRange = [" + setRange + ", " + setRangeInner + "]")
		
		lines.append("SubtileX = [" + str(int(apNode.locationX)) + ", " + str(int(fmod(apNode.locationX, 1.0) * 256)) + "]")
		lines.append("SubtileY = [" + str(int(apNode.locationY)) + ", " + str(int(fmod(apNode.locationY, 1.0) * 256)) + "]")
		
		entryNumber += 1
	
	lines.set(1, "ActionPointsCount = " + str(entryNumber))
	buffer.put_data("\n".join(lines).to_ascii())
	return buffer

func write_lgt():
	var buffer = StreamPeerBuffer.new()
	var numberOfLightPoints = get_tree().get_nodes_in_group("Light").size()
	buffer.put_32(numberOfLightPoints)
	
	for lightNode in get_tree().get_nodes_in_group("Light"):
		if lightNode.is_queued_for_deletion() == true:
			continue
		buffer.put_8(fmod(lightNode.lightRange,1.0) * 256) # 0
		buffer.put_8(int(lightNode.lightRange)) # 1
		buffer.put_8(lightNode.lightIntensity) # 2
		buffer.put_8(lightNode.data3) # 3
		buffer.put_8(lightNode.data4) # 4
		buffer.put_8(lightNode.data5) # 5
		buffer.put_8(lightNode.data6) # 6
		buffer.put_8(lightNode.data7) # 7
		buffer.put_8(lightNode.data8) # 8
		buffer.put_8(lightNode.data9) # 9
		buffer.put_8(fmod(lightNode.locationX,1.0) * 256) # 10
		buffer.put_8(int(lightNode.locationX)) # 11
		buffer.put_8(fmod(lightNode.locationY,1.0) * 256) # 12
		buffer.put_8(int(lightNode.locationY)) # 13
		buffer.put_8(fmod(lightNode.locationZ,1.0) * 256) # 14
		buffer.put_8(int(lightNode.locationZ)) # 15
		buffer.put_8(lightNode.data16) # 16
		buffer.put_8(lightNode.data17) # 17
		buffer.put_16(lightNode.parentTile) # 18-19
	return buffer

func write_lgtfx():
	var buffer = StreamPeerBuffer.new()
	var lines = PoolStringArray()
	lines.append("[common]")
	lines.append("") # This gets changed at the end
	
	var entryNumber = 0
	for lightNode in get_tree().get_nodes_in_group("Light"):
		if lightNode.is_queued_for_deletion() == true:
			continue
		lines.append("")
		lines.append("[light" + str(entryNumber) + "]")
		
		if lightNode.lightIntensity != null:
			lines.append("LightIntensity = " + str(lightNode.lightIntensity))
		
		if lightNode.lightRange != null:
			var setRange = str(int(lightNode.lightRange))
			var setRangeInner = str(fmod(lightNode.lightRange, 1.0) * 256)
			lines.append("LightRange = [" + setRange + ", " + setRangeInner + "]")
		
		if lightNode.parentTile != null:
			lines.append("ParentTile = " + str(lightNode.parentTile))
		
		lines.append("SubtileX = [" + str(int(lightNode.locationX)) + ", " + str(int(fmod(lightNode.locationX, 1.0) * 256)) + "]")
		lines.append("SubtileY = [" + str(int(lightNode.locationY)) + ", " + str(int(fmod(lightNode.locationY, 1.0) * 256)) + "]")
		lines.append("SubtileZ = [" + str(int(lightNode.locationZ)) + ", " + str(int(fmod(lightNode.locationZ, 1.0) * 256)) + "]")
		
		entryNumber += 1
	
	lines.set(1, "LightsCount = " + str(entryNumber))
	buffer.put_data("\n".join(lines).to_ascii())
	return buffer


func write_inf():
	var buffer = StreamPeerBuffer.new()
	value = oDataLevelStyle.data
	buffer.put_8(value)
	return buffer

func write_slx():
	var buffer = StreamPeerBuffer.new()
	var slx_data = oDataSlx.slxImgData.get_data()
	
	for i in range(0, slx_data.size(), 3):
		buffer.put_8(slx_data[i])
	
	return buffer


func write_dat():
	var buffer = StreamPeerBuffer.new()
	buffer.data_array = oDataClmPos.buffer.data_array
	return buffer

func write_clm():
	var buffer = StreamPeerBuffer.new()

	buffer.put_32(oDataClm.column_count)
	buffer.put_32(oDataClm.unknownData)
	var data = PoolByteArray()
	data.resize(oDataClm.column_count * 24)

	var utilized = oDataClm.utilized
	var permanent = oDataClm.permanent
	var lintel = oDataClm.lintel
	var height = oDataClm.height
	var solidMask = oDataClm.solidMask
	var floorTexture = oDataClm.floorTexture
	var orientation = oDataClm.orientation
	var cubes = oDataClm.cubes

	for entry in oDataClm.column_count:
		var index = entry * 24

		data[index] = utilized[entry] & 0xFF
		data[index + 1] = (utilized[entry] >> 8) & 0xFF

		data[index + 2] = (permanent[entry] & 1) + ((lintel[entry] & 7) << 1) + ((height[entry] & 15) << 4)

		data[index + 3] = solidMask[entry] & 0xFF
		data[index + 4] = (solidMask[entry] >> 8) & 0xFF

		data[index + 5] = floorTexture[entry] & 0xFF
		data[index + 6] = (floorTexture[entry] >> 8) & 0xFF

		data[index + 7] = orientation[entry]

		var cubesEntry = cubes[entry]
		for cubeNumber in 8:
			var cube = cubesEntry[cubeNumber]
			data[index + 8 + cubeNumber * 2] = cube & 0xFF
			data[index + 9 + cubeNumber * 2] = (cube >> 8) & 0xFF

	buffer.put_data(data)
	return buffer
