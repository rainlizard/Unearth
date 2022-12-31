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
