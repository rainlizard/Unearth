extends Tree
onready var oGame = Nodelist.list["oGame"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oDataLof = Nodelist.list["oDataLof"]

var treeItemsThatWantNames = {} # <BASENAME> <TreeItem>
var gatherMapNames = {} # <BASENAME> <LifNameString>

var allMapsForRandomizier = []

func update_source_tree(): # Call this whenever there's an update to the filesystem, or whenever you open the map list
	var CODETIME_START = OS.get_ticks_msec()
	
	allMapsForRandomizier.clear()
	
	treeItemsThatWantNames.clear()
	gatherMapNames.clear()
	clear()
	create_item() # Important to create root
	get_root().set_text(0,"SourceMapTree root")
	
	var path
	path = oGame.GAME_DIRECTORY.plus_file("levels")
	var levelsTreeItem = add_tree_dir(self, self, path)
	deep_scan(path, levelsTreeItem)
	path = oGame.GAME_DIRECTORY.plus_file("campgns")
	var campgnsTreeItem = add_tree_dir(self, self, path)
	deep_scan(path, campgnsTreeItem)
	
	# For the remaining items without lif names
	for BASENAME in treeItemsThatWantNames:
		var fetchItem = treeItemsThatWantNames[BASENAME]
		var txt = oDataMapName.get_special_lif_text(BASENAME)
		fetchItem.set_text(1, txt)
	
	print('SourceMapTree updated in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func deep_scan(rootPath, parentTreeItem):
	var dir = Directory.new()
	if dir.open(rootPath) == OK:
		dir.list_dir_begin(true, false)
		add_directory_contents(dir, parentTreeItem)
		dir.list_dir_end()
	else:
		push_error("An error occurred when trying to access the path.")


func add_directory_contents(dir, treeItem):
	var fileName = dir.get_next()
	var pathsToSort = []
	var itemsToAdd = []  # Temporary list to batch add items
	
	while (fileName != ""):
		var pathString = dir.get_current_dir().plus_file(fileName)
		pathsToSort.append([pathString, dir.current_is_dir()])
		fileName = dir.get_next()
	
	if OS.get_name() == "X11":
		pathsToSort.sort_custom(MyCustomSorter, "sort_ascending")
	
	for i in pathsToSort:
		var pathString = i[0]
		if i[1] == true:  # Is a directory
			itemsToAdd.append(["dir", pathString, treeItem])
		else:
			itemsToAdd.append(["file", pathString, treeItem])
	
	# Now, add the items to the Tree in one batch
	for itemData in itemsToAdd:
		var itemType = itemData[0]
		var pathString = itemData[1]
		var parentItem = itemData[2]
		if itemType == "dir":
			var newTreeItem = add_tree_dir(self, parentItem, pathString)
			var subDir = Directory.new()
			subDir.open(pathString)
			subDir.list_dir_begin(true, false)
			add_directory_contents(subDir, newTreeItem)
		elif itemType == "file":
			var EXT = pathString.get_extension().to_upper()
			if EXT == "SLB":
				var newTreeItem = add_tree_file(self,treeItem, pathString)
				SLB_WANTS_NAME(pathString, newTreeItem)
				allMapsForRandomizier.append(pathString)
			elif EXT == "LIF":
				LIF_WANTS_TO_GIVE_NAME(pathString)
			elif EXT == "LOF":
				LOF_WANTS_TO_GIVE_NAME(pathString)

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
	newTreeItem.set_metadata(0, path)
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
	if gatherMapNames.has(BASENAME):
		newTreeItem.set_text(1, gatherMapNames[BASENAME])
		gatherMapNames.erase(BASENAME)
	else:
		treeItemsThatWantNames[BASENAME] = newTreeItem


func LIF_WANTS_TO_GIVE_NAME(pathString):
	var getNameText = oDataMapName.lif_name_text(pathString)
	
	var BASENAME = pathString.get_basename().to_upper()
	if treeItemsThatWantNames.has(BASENAME):
		var fetchItem = treeItemsThatWantNames[BASENAME]
		fetchItem.set_text(1, getNameText)
		treeItemsThatWantNames.erase(BASENAME)
	else:
		gatherMapNames[BASENAME] = getNameText

func LOF_WANTS_TO_GIVE_NAME(pathString):
	var getNameText = oDataLof.lof_name_text(pathString)
	
	var BASENAME = pathString.get_basename().to_upper()
	if treeItemsThatWantNames.has(BASENAME):
		var fetchItem = treeItemsThatWantNames[BASENAME]
		fetchItem.set_text(1, getNameText)
		treeItemsThatWantNames.erase(BASENAME)
	else:
		gatherMapNames[BASENAME] = getNameText
