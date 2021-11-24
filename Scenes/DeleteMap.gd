extends Node
onready var oQuickMessage = Nodelist.list["oQuickMessage"]
onready var oEditor = Nodelist.list["oEditor"]

#var CODETIME_START
#var dir = Directory.new()

#func delete_map(filePath): # auto opens other files
#	var map = filePath.get_basename()
#
#	#var constructPath = baseDir.plus_file(mapName)
#
#	CODETIME_START = OS.get_ticks_msec()
#
#	var arrayOfMapFileTypes = oEditor.get_list_of_map_files(map)
#	if arrayOfMapFileTypes.size() > 0:
#		for i in arrayOfMapFileTypes:
#			delete_path(map.get_base_dir().plus_file(i))
#			oQuickMessage.message("Deleted map")
#	else:
#		oQuickMessage.message("Error: Unable to delete map")

#func delete_path(filePath):
#	if dir.remove(filePath) == OK:
#		print("Deleting : "+filePath)
#	else:
#		print("Cannot delete, file not found: " + filePath)


#	if dir.open(baseDir) == OK:
#		delete_path(constructPath + ".adi")
#		delete_path(constructPath + ".flg")
#		delete_path(constructPath + ".lgt")
#		delete_path(constructPath + ".lif")
#		delete_path(constructPath + ".txt")
#		delete_path(constructPath + ".vsn")
#		delete_path(constructPath + ".wib")
#		delete_path(constructPath + ".wlb")
#		delete_path(constructPath + ".clm")
#		delete_path(constructPath + ".dat")
#		delete_path(constructPath + ".apt")
#		delete_path(constructPath + ".tng")
#		delete_path(constructPath + ".inf")
#		delete_path(constructPath + ".own")
#		delete_path(constructPath + ".slb")
