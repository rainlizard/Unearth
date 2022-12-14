extends Node

onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oDataLif = Nodelist.list["oDataLif"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oDataCustomSlab = Nodelist.list["oDataCustomSlab"]
onready var oDataKeeperFxLof = Nodelist.list["oDataKeeperFxLof"]

var value # just so I don't have to initialize the var in every function

func write_keeperfx_lof(buffer):
	var newString = ""
	newString += "; KeeperFX Level Overview File (LOF)" + "\n"
	
	newString += "NAME_TEXT = " + str(oDataKeeperFxLof.NAME_TEXT) + "\n"
	newString += "NAME_ID = " + str(oDataKeeperFxLof.NAME_ID) + "\n"
	newString += "KIND = " + str(oDataKeeperFxLof.KIND) + "\n"
	newString += "ENSIGN_POS = " + str(oDataKeeperFxLof.ENSIGN_POS) + "\n"
	newString += "ENSIGN_ZOOM = " + str(oDataKeeperFxLof.ENSIGN_ZOOM) + "\n"
	newString += "PLAYERS = " + str(oDataKeeperFxLof.PLAYERS) + "\n"
	newString += "OPTIONS = " + str(oDataKeeperFxLof.OPTIONS) + "\n"
	newString += "SPEECH = " + str(oDataKeeperFxLof.SPEECH) + "\n"
	newString += "LAND_VIEW = " + str(oDataKeeperFxLof.LAND_VIEW) + "\n"
	newString += "AUTHOR = " + str(oDataKeeperFxLof.AUTHOR) + "\n"
	newString += "DESCRIPTION = " + str(oDataKeeperFxLof.DESCRIPTION) + "\n"
	newString += "DATE = " + str(oDataKeeperFxLof.DATE) + "\n"
	newString += "MAPSIZE = " + str(M.xSize) + " " + str(M.ySize)
	var scriptBytes = newString.to_ascii()
	buffer.put_data(scriptBytes)


func write_lif(buffer, filePath):
	var mapNumber = filePath.get_file().get_basename().to_upper().trim_prefix('MAP')
	
	# Remove 3 leading zeroes. I could remove 4 but I'm unsure if I should.
	for i in 3:
		mapNumber = mapNumber.trim_prefix('0')
	
	value = mapNumber + ', ' + oDataLif.data
	
	buffer.put_data(value.to_utf8())

func write_txt(buffer):
	value = oDataScript.data
	# I'm only using \n (LF) instead of \r\n (CRLF), because to_ascii() is removing the \r (CR) for some reason.
	# Old Notepad will not display TXT files correctly.
	# Notepad++ displays correctly and apparently so does Notepad on Windows 10.
	
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	var scriptBytes = value.to_ascii()
	buffer.put_data(scriptBytes)

func write_une(buffer):
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			value = oDataCustomSlab.get_cell(xSlab,ySlab)
			buffer.put_16(value)

func write_wlb(buffer):
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			value = oDataLiquid.get_cell(xSlab,ySlab)
			buffer.put_8(value)

func write_wib(buffer):
	var dataHeight = (M.ySize*3)+1
	var dataWidth = (M.xSize*3)+1
	for subtileY in dataHeight:
		for subtileX in dataWidth:
			buffer.put_8(oDataWibble.get_cell(subtileX,subtileY))

func write_slb(buffer):
	for y in M.ySize:
		for x in M.xSize:
			value = oDataSlab.get_cell(x,y)
			#print('x:' + str(x) + " " + 'y:' + str(y))
			buffer.put_8(value)
			buffer.put_8(0)

func write_own(buffer):
	var dataHeight = (M.ySize*3)+1
	var dataWidth = (M.xSize*3)+1
	for subtileY in dataHeight:
		for subtileX in dataWidth:
			buffer.seek(subtileX + (subtileY*dataWidth))
			value = oDataOwnership.get_cell(subtileX/3,subtileY/3)
			buffer.put_8(value)

func write_tng(buffer):
	var numberOfTngEntries = get_tree().get_nodes_in_group("Thing").size()
	buffer.put_16(numberOfTngEntries)
	
	for thingNode in get_tree().get_nodes_in_group("Thing"):
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
		
		if thingNode.sensitiveTile != null:
			buffer.put_16(thingNode.sensitiveTile) # 11-12
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
		buffer.put_8(thingNode.data18) # 18
		buffer.put_8(thingNode.data19) # 19
		buffer.put_8(thingNode.data20) # 20


func write_tngfx(buffer):
	var t = ""
	var numberOfTngEntries = get_tree().get_nodes_in_group("Thing").size()
	t += "[common]" + "\n"
	t += "ThingsCount = " + str(numberOfTngEntries) + "\n"
	
	var entryNumber = 0
	for thingType in [Things.TYPE.OBJECT, Things.TYPE.CREATURE, Things.TYPE.EFFECT, Things.TYPE.TRAP, Things.TYPE.DOOR]:
		var groupName = "UnknownThingType"
		match thingType:
			Things.TYPE.OBJECT: groupName = "Object"
			Things.TYPE.CREATURE: groupName = "Creature"
			Things.TYPE.EFFECT: groupName = "Effect"
			Things.TYPE.TRAP: groupName = "Trap"
			Things.TYPE.DOOR: groupName = "Door"
		for thingNode in get_tree().get_nodes_in_group(groupName):
			t += "\n"
			t += "[thing"+str(entryNumber)+"]" + "\n"
			
			t += "ThingType = \"" +groupName + "\"\n"
			
			var setSubtype = "???"
			match thingType:
				Things.TYPE.OBJECT:
					if Things.DATA_OBJECT.has(thingNode.subtype):
						setSubtype = Things.DATA_OBJECT[thingNode.subtype][Things.KEEPERFX_ID]
				Things.TYPE.CREATURE:
					if Things.DATA_CREATURE.has(thingNode.subtype):
						setSubtype = Things.DATA_CREATURE[thingNode.subtype][Things.KEEPERFX_ID]
				Things.TYPE.EFFECT:
					if Things.DATA_EFFECT.has(thingNode.subtype):
						setSubtype = Things.DATA_EFFECT[thingNode.subtype][Things.KEEPERFX_ID]
				Things.TYPE.TRAP:
					if Things.DATA_TRAP.has(thingNode.subtype):
						setSubtype = Things.DATA_TRAP[thingNode.subtype][Things.KEEPERFX_ID]
				Things.TYPE.DOOR:
					if Things.DATA_DOOR.has(thingNode.subtype):
						setSubtype = Things.DATA_DOOR[thingNode.subtype][Things.KEEPERFX_ID]
			if setSubtype == null:
				setSubtype = "???"
			t += "Subtype = \"" + setSubtype + "\"\n"
			
			t += "Ownership = " +str(thingNode.ownership) + "\n"
			
			if thingNode.effectRange != null:
				var setRange = str(int(thingNode.effectRange))
				var setRangeInner = str(fmod(thingNode.effectRange,1.0) * 256)
				t += "EffectRange = [" + setRange + ", " + setRangeInner + "]" + "\n"
			
			if thingNode.sensitiveTile != null:
				t += "ParentTile = " +str(thingNode.sensitiveTile) + "\n"
			elif thingNode.index != null:
				t += "Index = " +str(thingNode.index) + "\n"
			
			if thingNode.doorOrientation != null:
				t += "DoorOrientation = " +str(thingNode.doorOrientation) + "\n"
			
			if thingNode.creatureLevel != null:
				t += "CreatureLevel = " +str(thingNode.creatureLevel) + "\n"
			elif thingNode.doorLocked != null:
				t += "DoorLocked = " +str(thingNode.doorLocked) + "\n"
			elif thingNode.herogateNumber != null:
				t += "HerogateNumber = " +str(thingNode.herogateNumber) + "\n"
			elif thingNode.boxNumber != null:
				t += "CustomBox = " +str(thingNode.boxNumber) + "\n"
			
			var x = str(int(thingNode.locationX))
			var xInner = str(fmod(thingNode.locationX,1.0) * 256)
			var y = str(int(thingNode.locationY))
			var yInner = str(fmod(thingNode.locationY,1.0) * 256)
			var z = str(int(thingNode.locationZ))
			var zInner = str(fmod(thingNode.locationZ,1.0) * 256)
			
			t += "SubtileX = [" + x + ", " + xInner + "]" + "\n"
			t += "SubtileY = [" + y + ", " + yInner + "]" + "\n"
			t += "SubtileZ = [" + z + ", " + zInner + "]" + "\n"
			entryNumber += 1
	
	buffer.put_data(t.to_ascii())


func write_apt(buffer):
	var numberOfActionPoints = get_tree().get_nodes_in_group("ActionPoint").size()
	buffer.put_32(numberOfActionPoints)
	
	for apNode in get_tree().get_nodes_in_group("ActionPoint"):
		buffer.put_8(fmod(apNode.locationX,1.0) * 256) # 0
		buffer.put_8(int(apNode.locationX)) # 1
		buffer.put_8(fmod(apNode.locationY,1.0) * 256) # 2
		buffer.put_8(int(apNode.locationY)) # 3
		buffer.put_8(fmod(apNode.pointRange,1.0) * 256) # 4
		buffer.put_8(int(apNode.pointRange)) # 5
		buffer.put_8(apNode.pointNumber) # 6
		buffer.put_8(apNode.data7) # 7

func write_lgt(buffer):
	var numberOfLightPoints = get_tree().get_nodes_in_group("Light").size()
	buffer.put_32(numberOfLightPoints)
	
	for lightNode in get_tree().get_nodes_in_group("Light"):
		
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
		buffer.put_8(lightNode.data18) # 18
		buffer.put_8(lightNode.data19) # 19

func write_inf(buffer):
	value = oDataLevelStyle.data
	buffer.put_8(value)

func write_slx(buffer):
	oDataSlx.slxImgData.lock()
	for ySlab in M.ySize:
		for xSlab in M.xSize:
			value = oDataSlx.slxImgData.get_pixel(xSlab,ySlab).r8
			# This is unncessary as the lower 4 bits will be used anyway, if the number is in the range 0-15
			var lower4bits = value & 0x0F
			buffer.put_8(lower4bits)
	oDataSlx.slxImgData.unlock()

func write_dat(buffer):
	var dataHeight = (M.ySize*3)+1
	var dataWidth = (M.xSize*3)+1
	for subtileY in dataHeight:
		for subtileX in dataWidth:
			buffer.seek(2*(subtileX + (subtileY*dataWidth)))
			
			value = 65536 - oDataClmPos.get_cell(subtileX,subtileY)
			if value == 65536: value = 0
			
			buffer.put_16(value)

func write_clm(buffer):
	oDataClm.update_all_utilized()
	
	var numberOfClmEntries = 2048
	buffer.put_16(numberOfClmEntries)
	buffer.put_data([0,0])
	buffer.put_16(oDataClm.unknownData)
	buffer.put_data([0,0])
	
	for entry in numberOfClmEntries:
		buffer.put_16(oDataClm.utilized[entry]) # 0-1
		#buffer.put_8(oDataClm.permanent[entry] + (oDataClm.lintel[entry]*2) + (oDataClm.height[entry]*16)) # 2
		buffer.put_8((oDataClm.permanent[entry] & 1) + ((oDataClm.lintel[entry] & 7) << 1) + ((oDataClm.height[entry] & 15) << 4))
		buffer.put_16(oDataClm.solidMask[entry]) # 3-4
		buffer.put_16(oDataClm.floorTexture[entry]) # 5-6
		buffer.put_8(oDataClm.orientation[entry]) # 7
		
		for cubeNumber in 8:
			buffer.put_16(oDataClm.cubes[entry][cubeNumber]) # 8-23
	
#		var specialByte = buffer.put_8() # 2
#		var get_height = specialByte / 16
#		oDataClm.height.append(get_height)
#		specialByte -= get_height * 16
#		var get_lintel = specialByte / 2
#		oDataClm.lintel.append(get_lintel)
#		specialByte -= get_lintel * 2
#		var get_permanent = specialByte
#		oDataClm.permanent.append(get_permanent)


#	for entry in numberOfClmEntries:
#		var twentyFourByteArray = oDataClm.data[entry]
#
#		buffer.put_16(oDataClm.utilized[entry])
#
#		var pos = 8 + (entry * 24)
#		for i in range(2, 24): # Skip "USE" value
#		#for i in 24:
#			buffer.seek(pos+i)
#			value = twentyFourByteArray[i]
#			buffer.put_8(value)

