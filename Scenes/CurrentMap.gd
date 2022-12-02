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
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oDataCustomSlab = Nodelist.list["oDataCustomSlab"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oDataKeeperFxLof = Nodelist.list["oDataKeeperFxLof"]


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
		oMenu.add_recent(newpath) # Add saved maps to the recent menu
	else:
		OS.set_window_title('Unearth v'+Constants.VERSION)
	path = newpath
	
	oGame.construct_command_line() # Always update command line whenever the path changes

func clear_map():
	
	var CODETIME_START = OS.get_ticks_msec()
	
	set_path_and_title("")
	
	# "tng, apt, lgt"
	var nodesToFree = get_tree().get_nodes_in_group("Instance")
	for i in nodesToFree.size():
		# Need to do it like this with pop_back() otherwise there's a Godot bug where it crashes when using queue_free() on too many instances at once.
		nodesToFree.pop_back().queue_free()
	
	# "lif"
	oDataLif.clear()
	# "wib"
	oDataSlx.clear_img()
	# "wib" (Wibble)
	oDataWibble.clear()
	# "wlb" (Water Lava Block)
	oDataLiquid.clear()
	# "slb"
	oDataSlab.clear()
	# "own"
	oDataOwnership.clear()
	oOverheadOwnership.clear()
	# "inf"
	oDataLevelStyle.data = 0
	# "dat"
	oDataClmPos.clear()
	# "clm"
	oDataClm.clear_all_column_data()
	oOverheadGraphics.clear_img()
	# 3D
	oGenerateTerrain.clear()
	#"TXT"
	oDataScript.data = ""
	# "UNE"
	oDataCustomSlab.clear()
	
	oScriptHelpers.clear()
	
	# "LOF" # Do this last in case other functions rely on the old map size
	oDataKeeperFxLof.clear_all()
	print('Cleared map in '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
