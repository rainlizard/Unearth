extends Node
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oGame = Nodelist.list["oGame"]
onready var oUiTools = Nodelist.list["oUiTools"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oDataLiquid = Nodelist.list["oDataLiquid"]
onready var oDataLif = Nodelist.list["oDataLif"]
onready var oMain = Nodelist.list["oMain"]
onready var oMessage = Nodelist.list["oMessage"]


var path = ""
var currentFilePaths = {} # [0] = pathString,  [1] = modified date

enum {
	PATHSTRING
	MODIFIED_DATE
}

func _on_ButtonNewMap_pressed():
	oOpenMap.open_map(Settings.unearthdata.plus_file("blank_map.slb"))

func set_path_and_title(newpath):
	if "unearthdata".plus_file("blank_map").to_upper() in newpath.to_upper():
		newpath = ""
	
	if newpath != "":
		OS.set_window_title(newpath + ' - Unearth v'+Constants.VERSION)
	else:
		OS.set_window_title('Unearth v'+Constants.VERSION)
	path = newpath
	
	oGame.construct_command_line() # Always update command line whenever the path changes

func clear_map():
	var CODETIME_START = OS.get_ticks_msec()
	
	set_path_and_title("")
	
	# "tng, apt, lgt"
	for i in get_tree().get_nodes_in_group("Instance"):
		i.queue_free()
	# "lif"
	oDataLif.clear()
	# "wib"
	oDataSlx.clear_img()
	# "wib" (Wibble)
	oDataWibble.clear()
	# "wlb" (Water Lava Block)
	oDataLiquid.clear()
	# "slb"
	oDataSlab.clear() #create(85,85, 0)
	# "own"
	oDataOwnership.clear()#create(85,85, 5) # 5 = No ownership
	oOverheadOwnership.clear()
	# "inf"
	oDataLevelStyle.data = 0 #clear()#create(1, 1, 0)
	# "dat"
	oDataClmPos.clear() #create((85*3)+1, (85*3)+1, 0)
	# "clm"
	oDataClm.clearAll()
	oOverheadGraphics.clear_img()
	# 3D
	oGenerateTerrain.clear()
	
	
	print('Cleared map in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
