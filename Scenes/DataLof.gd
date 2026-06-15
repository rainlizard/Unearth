extends Node
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]

var MAP_FORMAT_VERSION = ""
var NAME_TEXT = ""
var NAME_ID = ""
var ENSIGN_POS = ""
var ENSIGN_ZOOM = ""
var PLAYERS = ""
var OPTIONS = ""
var SPEECH = ""
var LAND_VIEW = ""
var KIND = ""
var AUTHOR = ""
var DESCRIPTION = ""
var DATE = ""
var campaign_map_size_enabled = false

func use_size(x, y): #called from _on_ButtonNewMapOK_pressed() and read_lof()
	M.xSize = x
	M.ySize = y

func uses_campaign_map_size():
	return campaign_map_size_enabled

func clear_all():
	campaign_map_size_enabled = false
	MAP_FORMAT_VERSION = ""
	KIND = ""
	#NAME_TEXT = "" # This is set inside of oDataMapName, so don't clear it here
	OPTIONS = ""
	AUTHOR = ""
	DESCRIPTION = ""
	DATE = ""
	
	NAME_ID = ""
	ENSIGN_POS = ""
	ENSIGN_ZOOM = ""
	PLAYERS = ""
	SPEECH = ""
	LAND_VIEW = ""
	
	M.xSize = 85
	M.ySize = 85

func get_map_section_name(mapPath):
	return mapPath.get_file().get_basename().to_lower()

func get_campaign_map_section(mapPath, cfgData = null):
	if cfgData == null:
		cfgData = oConfigFileManager.current_mappack_cfg_data
	return cfgData.get(get_map_section_name(mapPath), null)

func use_campaign_map_size(mapPath):
	campaign_map_size_enabled = false
	var mapSection = get_campaign_map_section(mapPath)
	if mapSection == null:
		return
	for key in mapSection.keys():
		if str(key).to_upper() != "MAPSIZE":
			continue
		var mapSize = mapSection[key]
		if mapSize is Array and mapSize.size() >= 2 and int(mapSize[0]) > 0 and int(mapSize[1]) > 0:
			campaign_map_size_enabled = true
			use_size(int(mapSize[0]), int(mapSize[1]))
		return

func write_campaign_map_size(mapPath, campaignFile):
	var cfgPath = campaignFile["path"]
	if cfgPath == "" or get_campaign_map_section(mapPath, campaignFile["config"]) == null:
		return true
	var file = File.new()
	if file.open(cfgPath, File.READ) != OK:
		return false
	var lines = Array(file.get_as_text().split("\n"))
	file.close()
	var sectionName = get_map_section_name(mapPath)
	var mapSizeLine = "MAPSIZE = " + str(M.xSize) + " " + str(M.ySize)
	var inMapSection = false
	var insertIndex = -1
	for i in range(lines.size()):
		var stripped = str(lines[i]).strip_edges()
		if stripped.begins_with("[") and stripped.ends_with("]"):
			if inMapSection:
				break
			inMapSection = stripped.substr(1, stripped.length() - 2).to_lower() == sectionName
			if inMapSection:
				insertIndex = i + 1
			continue
		if inMapSection == false or stripped.begins_with(";"):
			continue
		var delimiterPos = stripped.find("=")
		if delimiterPos == -1:
			continue
		var key = stripped.substr(0, delimiterPos).strip_edges().to_upper()
		if key == "MAPSIZE":
			lines[i] = mapSizeLine
			insertIndex = -1
			break
	if insertIndex != -1:
		lines.insert(insertIndex, mapSizeLine)
	if file.open(cfgPath, File.WRITE) != OK:
		return false
	file.store_string("\n".join(lines))
	file.close()
	return true

func lof_name_text(pathString):
	var buffer = oBuffers.file_path_to_buffer(pathString)
	
	buffer.seek(0)
	var value = buffer.get_string(buffer.get_size())
	value = value.replace(char(0x200B), "") # Remove zero width spaces
	
	var mapName = ""
	if "NAME_TEXT" in value:
		var array = value.split("\n")
		for line in array:
			if line.begins_with(";"):
				continue
			var lineParts = line.split("=")
			if lineParts.size() == 2:
				if lineParts[0].strip_edges() == "NAME_TEXT":
					mapName = lineParts[1].strip_edges()
					break
	
	return mapName
