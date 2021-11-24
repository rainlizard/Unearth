extends Tree
onready var oEditor = Nodelist.list["oEditor"]
onready var oSourceTree = Nodelist.list["oSourceTree"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]


var searchResultTreeItemDirs = [] # Just used for killing items with no children

func _ready():
	set_column_expand(0,false)
	set_column_min_width(0,135)

func searchTree(searchText, collapseResults):
	var CODETIME_START = OS.get_ticks_msec()
	
	clear()
	searchResultTreeItemDirs.clear()
	create_item() # Create root
	get_root().set_text(0,"maptree root")
	
	getTreeItemsRecursively(oSourceTree.get_root(), get_root(), searchText, collapseResults)
	oSourceTree.kill_childless_tree_items(searchResultTreeItemDirs)
	
	print('time: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
	
	highlight_current_map()

func getTreeItemsRecursively(fromItem, toItem, searchText, collapseResults):
	fromItem = fromItem.get_children()
	if fromItem != null:
		while true:
			var newTreeItem
			if fromItem.get_metadata(1) == "is_a_directory":
				newTreeItem = oSourceTree.add_tree_dir(self, toItem, fromItem.get_metadata(0))
				
				if fromItem.get_metadata(0) in oCurrentMap.path:
					newTreeItem.set_collapsed(false)
				else:
					newTreeItem.set_collapsed(collapseResults)
				
				searchResultTreeItemDirs.append(newTreeItem)
				getTreeItemsRecursively(fromItem, newTreeItem, searchText, collapseResults)
			else: #is_a_file
				var allowDisplay = true
				
				var path = fromItem.get_metadata(0)
				var lifMapName = fromItem.get_text(1)
				
				if searchText.length() > 0 and (not searchText.to_upper() in path.to_upper()) and (not searchText.to_upper() in lifMapName.to_upper()):
					allowDisplay = false
				
				if allowDisplay == true:
					newTreeItem = oSourceTree.add_tree_file(self, toItem, path)
					newTreeItem.set_text(1, lifMapName)
					
					# Scrolls the tree to the map you've opened
					if oCurrentMap.path == path:
						newTreeItem.select(0)
						ensure_cursor_is_visible()
			
			fromItem = fromItem.get_next()
			if fromItem == null:
				break

func _on_MapTree_item_selected():
	# Never collapse root node
	var item = get_selected()
	if item == get_root(): return
	
	# Selected item signal is firing when changing "collapsed"
	disconnect('item_selected',self,"_on_MapTree_item_selected")
	item.collapsed = !item.collapsed
	connect('item_selected',self,"_on_MapTree_item_selected")


func highlight_current_map():
	var path = oCurrentMap.path
	# Find "path" within the tree
	# Highlight the item.
	# Undo highlights for other items.
	# call_recursive
	
	if get_root() == null: return #fixes a weird crash
	
	var CODETIME_START = OS.get_ticks_msec()
	get_root().call_recursive("clear_custom_bg_color",0)
	get_root().call_recursive("clear_custom_bg_color",1)
	get_root().call_recursive("clear_custom_color",0)
	get_root().call_recursive("clear_custom_color",1)
	
	
	
	
	
	recursiveHighlight(get_root(),path)
	
	print('time: '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')


func recursiveHighlight(item,path):
	item = item.get_children()
	if item != null:
		while true:
			if item.get_metadata(0) in path:
				item.set_custom_color(0,Color(125/255.0, 133/255.0, 227/255.0, 1))
				item.set_custom_color(1,Color(125/255.0, 133/255.0, 227/255.0, 1))
				if item.get_metadata(0) == path:
					item.set_custom_bg_color(0,Color(58/255.0, 62/255.0, 105/255.0, 1))
					item.set_custom_bg_color(1,Color(58/255.0, 62/255.0, 105/255.0, 1))
			
			recursiveHighlight(item,path)
			item = item.get_next()
			if item == null: break
