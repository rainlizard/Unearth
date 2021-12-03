extends WindowDialog
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oSlabTabs = Nodelist.list["oSlabTabs"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oGridFunctions = Nodelist.list["oGridFunctions"]
onready var oSlabPalette = Nodelist.list["oSlabPalette"]
onready var oSlabStyle = Nodelist.list["oSlabStyle"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oOnlyOwnership = Nodelist.list["oOnlyOwnership"]
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]

onready var oSelectedRect = $Clippy/SelectedRect
onready var oCenteredLabel = $Clippy/CenteredLabel
export var grid_item_size : Vector2
export var grid_window_scale : float setget update_scale

enum {
	GRIDCON_PATH
	ICON_PATH
}

# To adjust space around the icon, "hseparation" is actually the space between a tab's text and its icon. And also increase content_margin_left in theme.

onready var tabs = {
	Slabs.TAB_MAINSLAB: [$SlabTabs/TabFolder/MainSlabs/ScrollContainer/GridContainer, "res://edited_images/icon_slab1.png"], #"res://dk_images/crspell_64/dig_std.png"
	Slabs.TAB_OTHER: [$SlabTabs/TabFolder/WallSlabs/ScrollContainer/GridContainer, "res://edited_images/icon_slab2.png"], #"res://dk_images/crspell_64/dig_dis.png"
	Slabs.TAB_STYLE: [$SlabTabs/TabFolder/SlabStyle/ScrollContainer/GridContainer, "res://dk_images/magic_dust/anim0978/r1frame06.png"],
	Slabs.TAB_OWNER: [$SlabTabs/TabFolder/OnlyOwnership/ScrollContainer/GridContainer, "res://dk_images/furniture/flagpole_redflag_fp/r1frame05.png"], # "res://edited_images/ownership.png"
	Slabs.TAB_NONE: [null, ""],
}

func _ready():
	get_close_button().expand = true
	get_close_button().hide()
	connect("resized",oGridFunctions,"_on_GridWindow_resized", [self])
	connect("item_rect_changed",oGridFunctions,"_on_GridWindow_item_rect_changed", [self])
	connect("visibility_changed",oGridFunctions,"_on_GridWindow_visibility_changed",[self])
	connect("gui_input",oGridFunctions,"_on_GridWindow_gui_input",[self])
	oSlabTabs.tabSystem.connect("tab_changed",oGridFunctions,"_on_tab_changed",[self])
	oSlabTabs.tabSystem.connect("tab_changed",self,"_on_SlabTabs_tab_changed")
	
	grid_window_scale = 0.76
	grid_item_size = Vector2(96, 96)
	
	# Window's minimum size
	rect_min_size = Vector2((grid_item_size.x*grid_window_scale)+11, (grid_item_size.y*grid_window_scale)+11)
	$SlabTabs.initialize(["Main", "Other", "Style", "Ownership"])

func _process(delta): # It's necessary to use _process to update selection, because ScrollContainer won't fire a signal while you're scrolling.
	update_selection_position()


func update_selection_position():
	if is_instance_valid(oSelectedRect.boundToItem) == true:
		oSelectedRect.rect_global_position = oSelectedRect.boundToItem.rect_global_position
		oSelectedRect.rect_size = oSelectedRect.boundToItem.rect_size


func add_slabs():
	clear_grid()
	oOnlyOwnership.initialize_grid_items()
	oSlabStyle.initialize_grid_items()
	
	for slabID in Slabs.slabOrder:
		var putIntoTab = Slabs.data[slabID][Slabs.EDITOR_TAB]
		if putIntoTab != Slabs.TAB_NONE:
			var scene = load("res://Scenes/SlabDisplay.tscn")
			var id = scene.instance()
			var slabVariation
			
			match slabID:
				Slabs.PORTAL:
					slabVariation = (Slabs.PORTAL*28) + 8
					for i in 9:
						id.columns[i] = oSlabPalette.slabPal[slabVariation][i]
				Slabs.WALL_AUTOMATIC:
					slabVariation = Slabs.WALL_WITH_BANNER*28
					for i in 9:
						id.columns[i] = oSlabPalette.slabPal[slabVariation][i]
				_:
					if slabID < 43:
						slabVariation = slabID*28
					else:
						slabVariation = (42 * 28) + (8 * (slabID - 42))
					
					for i in 9:
						id.columns[i] = oSlabPalette.slabPal[slabVariation][i]
			
			id.set_meta("ID_of_slab", slabID)
			id.panelView = Slabs.data[slabID][Slabs.PANEL_VIEW]
			id.set_visual()
			add_child_to_grid(tabs[putIntoTab][GRIDCON_PATH], id, Slabs.data[slabID][Slabs.NAME])
	
	if visible == true:
		set_selection(oSelection.paintSlab) # Default initial selection
	

func pressed(id):
	var setValue = id.get_meta("ID_of_slab")
	oSelection.paintSlab = setValue
	oPickThingWindow.set_selection(null,null)
	set_selection(setValue)
	oPlacingSettings.update_and_set_placing_tab()


func add_child_to_grid(tabID, id, set_text):
	tabID.add_child(id)
	set_text = set_text.replace(" ","\n") # Use "New lines" wherever there was a space.
	id.set_meta("grid_item_text", set_text)
	id.connect("mouse_entered", self, "_on_hovered_over_item", [id])
	id.connect("mouse_exited", self, "_on_hovered_none")
	id.connect("pressed",self,"pressed",[id])
	id.rect_min_size = Vector2(grid_item_size.x * grid_window_scale, grid_item_size.y * grid_window_scale)
	oGridFunctions._on_GridWindow_resized(self)


func clear_grid():
	for tabIndex in oSlabTabs.get_tab_count():
		var tabID = oSlabTabs.get_tab_control(tabIndex)
		var gc = tabID.get_node('ScrollContainer/GridContainer')
		for id in gc.get_children():
			gc.remove_child(id) # Necessary because queue_free() isn't fast enough.
			id.queue_free()


func _on_hovered_none():
	oCenteredLabel.get_node("Label").text = ""


func _on_hovered_over_item(id):
	var offset
	match $SlabTabs.current_tab:
		2,3:
			offset = Vector2(id.rect_size.x * 0.5, id.rect_size.y * 0.25)
		_:
			offset = Vector2(id.rect_size.x * 0.5, id.rect_size.y * 0.50)
	oCenteredLabel.rect_global_position = id.rect_global_position + offset
	oCenteredLabel.get_node("Label").text = id.get_meta("grid_item_text")


func currentGridContainer():
	return oSlabTabs.get_current_tab_control().get_node("ScrollContainer/GridContainer")


func set_selection(setID):
	if setID == null:
		oSelectedRect.boundToItem = null
		oSelectedRect.visible = false
		return
	
	# Check EVERY tab, not just the currently selected TAB. This is needed for when right clicking on a thing in the field then switching to that tab.
	for tabIndex in oSlabTabs.get_tab_count():
		var tabID = oSlabTabs.get_tab_control(tabIndex)
		var gc = tabID.get_node('ScrollContainer/GridContainer')
		for id in gc.get_children():
			if id.has_meta("ID_of_slab") and id.get_meta("ID_of_slab") == setID:
				
				oSelectedRect.boundToItem = id
				oSelectedRect.visible = true
				oSelection.paintSlab = setID
				
				oSlabTabs.set_current_tab(tabIndex)


func update_scale(setvalue):
	var oGridContainer = currentGridContainer()
	if oGridContainer == null: return
	for id in oGridContainer.get_children():
		id.rect_min_size = Vector2(grid_item_size.x * setvalue, grid_item_size.y * setvalue)
	grid_window_scale = setvalue
	oGridFunctions._on_GridWindow_resized(self)


func _on_SlabTabs_tab_changed(tab):
	# When you change to or from tab 2, need to update grid to hide or show numbers
	oDisplaySlxNumbers.update_grid()
