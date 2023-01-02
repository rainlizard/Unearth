extends Node

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

func use_size(x, y): #called from _on_ButtonNewMapOK_pressed() and read_keeperfx_lof()
	M.xSize = x
	M.ySize = y

func clear_all():
	MAP_FORMAT_VERSION = ""
	KIND = ""
	NAME_TEXT = ""
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

func lof_name_text(pathString):
	var buffer = Filetypes.file_path_to_buffer(pathString)
	
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
