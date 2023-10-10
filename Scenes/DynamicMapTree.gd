extends Tree
onready var oEditor = Nodelist.list["oEditor"]
onready var oSourceMapTree = Nodelist.list["oSourceMapTree"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oLineEditFilter = Nodelist.list["oLineEditFilter"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]

var searchResultTreeItemDirs = [] # Just used for killing items with no children


func _ready():
	set_column_expand(0,false)
	set_column_min_width(0,135)


func update_dynamic_tree():
	# Display tree. Collapse things depending on the state of the CURRENT_MAP and search field.
	if oLineEditFilter.text == "" and oCurrentMap.path == "":
		search_tree(oLineEditFilter.text, true)
	elif oCurrentMap.path != "":
		search_tree(oLineEditFilter.text, true)
	else:
		search_tree(oLineEditFilter.text, false)


func search_tree(searchText, collapseResults):
	var CODETIME_START = OS.get_ticks_msec()
	
	clear()
	searchResultTreeItemDirs.clear()
	create_item() # Create root
	get_root().set_text(0,"maptree root")
	
	get_tree_items_recursively(oSourceMapTree.get_root(), get_root(), searchText, collapseResults)
	oSourceMapTree.kill_childless_tree_items(searchResultTreeItemDirs)
	
	print('Tree searched in: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	highlight_current_map()


func get_tree_items_recursively(fromItem, toItem, searchText, collapseResults):
	var currentSlbPath = ""
	if oCurrentMap.currentFilePaths.has("SLB") == true:
		currentSlbPath = oCurrentMap.currentFilePaths["SLB"][oCurrentMap.PATHSTRING]
	
	fromItem = fromItem.get_children()
	if fromItem != null:
		while true:
			var newTreeItem
			if fromItem.get_metadata(1) == "is_a_directory":
				newTreeItem = oSourceMapTree.add_tree_dir(self, toItem, fromItem.get_metadata(0))
				
				if fromItem.get_metadata(0).to_upper() in currentSlbPath.to_upper():
					newTreeItem.set_collapsed(false)
				else:
					newTreeItem.set_collapsed(collapseResults)
				
				searchResultTreeItemDirs.append(newTreeItem)
				get_tree_items_recursively(fromItem, newTreeItem, searchText, collapseResults)
			else: #is_a_file
				var allowDisplay = true
				
				var path = fromItem.get_metadata(0)
				var lifMapName = fromItem.get_text(1)
				
				if searchText.length() > 0 and (not searchText.to_upper() in path.to_upper()) and (not searchText.to_upper() in lifMapName.to_upper()):
					allowDisplay = false
				
				if allowDisplay == true:
					newTreeItem = oSourceMapTree.add_tree_file(self, toItem, path)
					newTreeItem.set_text(1, lifMapName)
					
					# Scrolls the tree to the map you've opened
					if path == currentSlbPath:
						newTreeItem.select(0)
						ensure_cursor_is_visible()
			
			fromItem = fromItem.get_next()
			if fromItem == null:
				break


func _on_DynamicMapTree_item_selected():
	# Never collapse root node
	var item = get_selected()
	if item == get_root(): return

	# Selected item signal is firing when changing "collapsed"
	disconnect('item_selected',self,"_on_DynamicMapTree_item_selected")
	disconnect('item_selected',oMapBrowser,"_on_DynamicMapTree_item_selected")
	
	item.collapsed = !item.collapsed
	connect('item_selected',self,"_on_DynamicMapTree_item_selected")
	connect('item_selected',oMapBrowser,"_on_DynamicMapTree_item_selected")


func highlight_current_map():
	var currentSlbPath = ""
	if oCurrentMap.currentFilePaths.has("SLB") == true:
		currentSlbPath = oCurrentMap.currentFilePaths["SLB"][oCurrentMap.PATHSTRING]
	else:
		return
	
	# Find "currentSlbPath" within the tree
	# Highlight the item.
	# Undo highlights for other items.
	# call_recursive
	
	if get_root() == null: return #fixes a weird crash
	
	var CODETIME_START = OS.get_ticks_msec()
	get_root().call_recursive("clear_custom_bg_color",0)
	get_root().call_recursive("clear_custom_bg_color",1)
	get_root().call_recursive("clear_custom_color",0)
	get_root().call_recursive("clear_custom_color",1)
	
	recursive_highlight(get_root(),currentSlbPath)
	
	print('Map highlighted in: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')


func recursive_highlight(item,currentSlbPath):
	item = item.get_children()
	if item != null:
		while true:
			if item.get_metadata(0).to_upper() in currentSlbPath.to_upper(): # In subdir
				item.set_custom_color(0,Color(125/255.0, 133/255.0, 227/255.0, 1))
				item.set_custom_color(1,Color(125/255.0, 133/255.0, 227/255.0, 1))
				
				if item.get_metadata(0).to_upper() == currentSlbPath.to_upper(): # Same exact file
					item.set_custom_bg_color(0,Color(58/255.0, 62/255.0, 105/255.0, 1))
					item.set_custom_bg_color(1,Color(58/255.0, 62/255.0, 105/255.0, 1))
			
			recursive_highlight(item,currentSlbPath)
			item = item.get_next()
			if item == null: break
