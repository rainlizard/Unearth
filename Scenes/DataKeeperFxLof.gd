extends Node
var KIND
var NAME_TEXT
var OPTIONS
var AUTHOR
var DESCRIPTION
var DATE

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
	M.xSize = 85
	M.ySize = 85
