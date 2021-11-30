extends Tree

onready var oGame = Nodelist.list["oGame"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oReadData = Nodelist.list["oReadData"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oDynamicMapTree = Nodelist.list["oDynamicMapTree"]

var treeItemsThatWantNames = {} # <BASENAME> <TreeItem>
var lifNames = {} # <BASENAME> <LifNameString>


func update_source_tree(): # Call this whenever there's an update to the filesystem, or whenever you open the map list
	var CODETIME_START = OS.get_ticks_msec()
	
	treeItemsThatWantNames.clear()
	lifNames.clear()
	clear()
	create_item() # Important to create root
	get_root().set_text(0,"SourceMapTree root")
	
	scan_all_paths(oGame.GAME_DIRECTORY)
	
	# For the remaining items without lif names
	for BASENAME in treeItemsThatWantNames:
		var fetchItem = treeItemsThatWantNames[BASENAME]
		var txt = getSpecialLifText(BASENAME)
		fetchItem.set_text(1, txt)
	
	print('SourceMapTree updated in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func scan_all_paths(rootPath):
	var dir = Directory.new()
	if dir.open(rootPath) == OK:
		dir.list_dir_begin(true, false)
		add_directory_contents(dir, self)
		dir.list_dir_end()
	else:
		push_error("An error occurred when trying to access the path.")


func add_directory_contents(dir, treeItem):
	var fileName = dir.get_next()
	
	var pathsToSort = []
	
	while (fileName != ""):
		var pathString = dir.get_current_dir().plus_file(fileName)
		pathsToSort.append([pathString, dir.current_is_dir()])
		fileName = dir.get_next()
	
	if OS.get_name() == "X11":
		pathsToSort.sort_custom(MyCustomSorter, "sort_ascending")
	
	for i in pathsToSort:
		var pathString = i[0]
		
		if i[1] == true: # Is a directory
			# Directory
			
			var newTreeItem = add_tree_dir(self, treeItem, pathString)
			
			var subDir = Directory.new()
			subDir.open(pathString)
			subDir.list_dir_begin(true, false)
			add_directory_contents(subDir, newTreeItem)
			#subDir.list_dir_end()
		else:
			# File
			var EXT = pathString.get_extension().to_upper()
			if EXT == "SLB":
				var newTreeItem = add_tree_file(self,treeItem, pathString)
				SLB_WANTS_NAME(pathString, newTreeItem)
			elif EXT == "LIF":
				LIF_WANTS_TO_GIVE_NAME(pathString)


class MyCustomSorter:
	static func sort_ascending(a, b):
		# Need custom sort for Linux as files were shown in random order. There's an additional problem where it's also putting uppercase map names first unless I change the case while comparing.
		if a[0].to_upper() < b[0].to_upper():
			return true
		return false


func add_tree_dir(theTree, parentItem, path): # theTree argument is important because MapTree is using these functions too.
	var newTreeItem = theTree.create_item(parentItem)
	newTreeItem.set_text(0, path.get_file().to_lower())
	newTreeItem.set_metadata(0, path)
	newTreeItem.set_metadata(1, "is_a_directory")
	return newTreeItem


func add_tree_file(theTree, parentItem, path):
	var newTreeItem = theTree.create_item(parentItem)
	newTreeItem.set_text(0, path.get_file().get_basename().to_lower())
	newTreeItem.set_metadata(0, path.get_basename())
	newTreeItem.set_metadata(1, "is_a_file")
	return newTreeItem


func kill_childless_tree_items(array): # Feed this an array of DIRECTORY TreeItems
	# I have an array of all the directories, I don't know whether they have children or not.
	# Delete the items without children - however that will create more childless items.
	var somethingWasErased = true
	while somethingWasErased == true:
		somethingWasErased = false
		for item in array:
			if is_instance_valid(item):
				if item.get_children() == null: # Kill if has no children
					item.free()
					somethingWasErased = true


func SLB_WANTS_NAME(pathString,newTreeItem):
	var BASENAME = pathString.get_basename().to_upper()
	if lifNames.has(BASENAME):
		newTreeItem.set_text(1, lifNames[BASENAME])
		lifNames.erase(BASENAME)
	else:
		treeItemsThatWantNames[BASENAME] = newTreeItem


func LIF_WANTS_TO_GIVE_NAME(pathString):
	var lifNameText = lif_name_text(pathString)
	var BASENAME = pathString.get_basename().to_upper()
	if treeItemsThatWantNames.has(BASENAME):
		var fetchItem = treeItemsThatWantNames[BASENAME]
		fetchItem.set_text(1, lifNameText)
		treeItemsThatWantNames.erase(BASENAME)
	else:
		lifNames[BASENAME] = lifNameText


func lif_name_text(pathString):
	var f = File.new()
	f.open(pathString, File.READ)
	var lifArray = oReadData.parse_lif_text(f)
	f.close()
	
	if lifArray.empty() == false:
		var lifName = lifArray[0][1]
		return lifName
	
	return ""


func getSpecialLifText(BASENAME):
	# No lif name found, so check dklevels.lof and ddisk1.lif
	var checkLifPath = ""
	if "KEEPORIG" in BASENAME or "ORIGPLUS" in BASENAME:
		checkLifPath = Settings.unearthdata.plus_file("dklevels.lof")
	if "DEEPDNGN" in BASENAME:
		checkLifPath = Settings.unearthdata.plus_file("ddisk1.lif")

	if checkLifPath != "":
		var f = File.new()
		f.open(checkLifPath, File.READ)
		var lifArray = oReadData.parse_lif_text(f)
		f.close()

		if lifArray.empty() == false:
			for line in lifArray.size():
				var lifNumber = lifArray[line][0].pad_zeros(5)
				var mapNumber = BASENAME.get_file().trim_prefix("MAP")
				if lifNumber == mapNumber:
					return lifArray[line][1]
	return ""




#func give_lif_names_to_tree_items():
#	var lifArray
#	# Erase from lifFilePaths too if that would help with speed?
#
#	for treeItem in listOfTreeItemFiles:
#		var path = treeItem.get_metadata(0)
#		var lifPath = ""
#
#		for i in lifFilePaths:
#			if i.get_basename().to_upper() == path.get_basename().to_upper():
#				lifPath = i
#				lifFilePaths.erase(i)
#				break
#
#		var lifMapName = ""
#		lifArray = get_lif_array(lifPath)
#		if lifArray.empty() == false:
#			lifMapName = lifArray[0][1] # [line #], [number or name]
#
#		# No lif name found, so check dklevels.lof and ddisk1.lif
#		if lifMapName == "":
#			lifPath = ""
#			if "KEEPORIG" in path.to_upper() or "ORIGPLUS" in path.to_upper():
#				lifPath = Settings.unearthdata.plus_file("dklevels.lof")
#			if "DEEPDNGN" in path.to_upper():
#				lifPath = Settings.unearthdata.plus_file("ddisk1.lif")
#
#			if lifPath != "":
#				lifArray = get_lif_array(lifPath)
#				if lifArray.empty() == false:
#					for line in lifArray.size():
#						var lifNumber = lifArray[line][0].pad_zeros(5)
#						var mapNumber = path.get_file().to_upper().trim_prefix("MAP")
#						if lifNumber == mapNumber:
#							lifMapName = lifArray[line][1]
#							break
#
#		treeItem.set_text(1, lifMapName)
#
#func get_lif_array(lifPath):
#	var file = File.new()
#	if file.file_exists(lifPath) == true:
#		file.open(lifPath, File.READ)
#		var returnedData = oReadData.parse_lif_text(file)
#		file.close()
#		return returnedData
#	return []
