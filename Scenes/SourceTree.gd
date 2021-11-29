extends Tree

onready var oGame = Nodelist.list["oGame"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oReadData = Nodelist.list["oReadData"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oMapTree = Nodelist.list["oMapTree"]
onready var oLineEditFilter = Nodelist.list["oLineEditFilter"]

var lifFilePaths = []
var listOfTreeItemFiles = []
var listOfTreeItemDirectories = [] # Just used for killing items with no children

func updateSourceTree(): # Call this whenever there's an update to the filesystem, or whenever you open the map list
	
	clear()
	create_item() # Important to create root
	get_root().set_text(0,"sourcetree root")
	
	lifFilePaths.clear()
	listOfTreeItemFiles.clear()
	listOfTreeItemDirectories.clear()
	
	var CODETIME_START = OS.get_ticks_msec()
	get_dir_contents(oGame.GAME_DIRECTORY)
	kill_childless_tree_items(listOfTreeItemDirectories)
	give_lif_names_to_tree_items()
	print('time: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	 
	# Display tree. Collapse things depending on the state of the CURRENT_MAP and search field.
	if oLineEditFilter.text == "" and oCurrentMap.path == "":
		oMapTree.searchTree(oLineEditFilter.text, true)
	elif oCurrentMap.path != "":
		oMapTree.searchTree(oLineEditFilter.text, true)
	else:
		oMapTree.searchTree(oLineEditFilter.text, false)

func get_dir_contents(rootPath):
	var dir = Directory.new()
	if dir.open(rootPath) == OK:
		dir.list_dir_begin(true, false)
		_add_dir_contents(dir, self)
	else:
		push_error("An error occurred when trying to access the path.")

func _add_dir_contents(dir: Directory, treeItem):
	var file_name = dir.get_next()
	while (file_name != ""):
		var path = dir.get_current_dir().plus_file(file_name)
		if dir.current_is_dir():
			
			var newTreeItem = add_tree_dir(self,treeItem,path)
			listOfTreeItemDirectories.append(newTreeItem)
			
			var subDir = Directory.new()
			subDir.open(path)
			subDir.list_dir_begin(true, false)
			_add_dir_contents(subDir, newTreeItem)
		else:
			#print("Found file: %s" % path)
			if path.get_extension().to_upper() == "SLB":
				var newTreeItem = add_tree_file(self,treeItem,path)
				listOfTreeItemFiles.append(newTreeItem)
			elif path.get_extension().to_upper() == "LIF":
				lifFilePaths.append(path)
		file_name = dir.get_next()
	dir.list_dir_end()

func add_tree_dir(theTree, parentItem, path): # theTree argument is important because MapTree is using these functions too.
	var newTreeItem = theTree.create_item(parentItem)
	newTreeItem.set_text(0, path.get_file().to_lower())
	newTreeItem.set_metadata(0, path)
	newTreeItem.set_metadata(1, "is_a_directory")
	return newTreeItem

func add_tree_file(theTree, parentItem,path):
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

func give_lif_names_to_tree_items():
	var lifArray
	# Erase from lifFilePaths too if that would help with speed?
	
	for treeItem in listOfTreeItemFiles:
		var path = treeItem.get_metadata(0)
		var lifPath = ""
		
		for i in lifFilePaths:
			if i.get_basename().to_upper() == path.get_basename().to_upper():
				lifPath = i
				lifFilePaths.erase(i)
				break
		
		var lifMapName = ""
		lifArray = get_lif_array(lifPath)
		if lifArray.empty() == false:
			lifMapName = lifArray[0][1] # [line #], [number or name]
		
		# No lif name found, so check dklevels.lof and ddisk1.lif
		if lifMapName == "":
			lifPath = ""
			if "KEEPORIG" in path.to_upper() or "ORIGPLUS" in path.to_upper():
				lifPath = Settings.unearthdata.plus_file("dklevels.lof")
			if "DEEPDNGN" in path.to_upper():
				lifPath = Settings.unearthdata.plus_file("ddisk1.lif")
			
			if lifPath != "":
				lifArray = get_lif_array(lifPath)
				if lifArray.empty() == false:
					for line in lifArray.size():
						var lifNumber = lifArray[line][0].pad_zeros(5)
						var mapNumber = path.get_file().to_upper().trim_prefix("MAP")
						if lifNumber == mapNumber:
							lifMapName = lifArray[line][1]
							break
		
		treeItem.set_text(1, lifMapName)

func get_lif_array(lifPath):
	var file = File.new()
	if file.file_exists(lifPath) == true:
		file.open(lifPath, File.READ)
		var returnedData = oReadData.parse_lif_text(file)
		file.close()
		return returnedData
	return []
