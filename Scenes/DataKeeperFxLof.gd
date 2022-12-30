extends Node

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

func set_date():
	var dict = Time.get_date_dict_from_system()
	DATE = str(dict["year"])+"-"+str(dict["month"])+"-"+str(dict["day"])


func use_size(x, y): #called from _on_ButtonNewMapOK_pressed() and read_keeperfx_lof()
	M.xSize = x
	M.ySize = y

func clear_all():
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
