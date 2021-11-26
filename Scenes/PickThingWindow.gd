extends WindowDialog
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oThingTabs = Nodelist.list["oThingTabs"]
onready var oActionPointOptions = Nodelist.list["oActionPointOptions"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oCustomData = Nodelist.list["oCustomData"]
onready var oGridFunctions = Nodelist.list["oGridFunctions"]
onready var oPropertiesWindow = Nodelist.list["oPropertiesWindow"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oInspector = Nodelist.list["oInspector"]

enum {
	GRIDCON_PATH
	ICON_PATH
}

onready var tabs = {
	Things.TAB_CREATURE: [$ThingTabs/TabFolder/Creature,"res://dk_images/crspell_64/flight_std.png"],
	Things.TAB_FURNITURE: [$ThingTabs/TabFolder/Furniture,"res://dk_images/furniture/workshop_machine_fp/r1frame01.png"], #"res://dk_images/furniture/training_machine_fp/r1frame09.png"
	Things.TAB_DECORATION: [$ThingTabs/TabFolder/Decoration,"res://dk_images/statues/anim0906/r1frame01.png"],
	Things.TAB_EFFECT: [$ThingTabs/TabFolder/Effect,"res://dk_images/guisymbols_64/new_function_3.png"],
	Things.TAB_ACTION: [$ThingTabs/TabFolder/Action,"res://dk_images/guisymbols_64/sym_fight.png"], #"res://Art/ActionPoint.png"
	Things.TAB_GOLD: [$ThingTabs/TabFolder/Gold,"res://dk_images/symbols_64/creatr_stat_gold_std.png"], #"res://dk_images/valuables/gold_hoard1_fp/r1frame03.png" #"res://dk_images/valuables/gold_hoard2_fp/r1frame02.png" #"res://dk_images/valuables/gold_hoard4_fp/r1frame01.png"
	Things.TAB_SPELL: [$ThingTabs/TabFolder/Spell,"res://dk_images/keepower_64/speed_std.png"],
	Things.TAB_TRAP: [$ThingTabs/TabFolder/Trap,"res://dk_images/traps_doors/anim0845/r1frame04.png"],
	Things.TAB_BOX: [$ThingTabs/TabFolder/Box,"res://dk_images/traps_doors/anim0116/r1frame12.png"],
	Things.TAB_SPECIAL: [$ThingTabs/TabFolder/Special,"res://dk_images/trapdoor_64/bonus_box_std.png"],
	Things.TAB_FOOD: [$ThingTabs/TabFolder/Food,"res://dk_images/keepower_64/chicken_std.png"],
	Things.TAB_LAIR: [$ThingTabs/TabFolder/Lair,"res://dk_images/room_64/lair_std.png"],
	Things.TAB_POWER: [$ThingTabs/TabFolder/Power,"res://dk_images/power_hand/anim0783/r1frame03.png"],
	Things.TAB_DOOR: [$ThingTabs/TabFolder/Door,"res://dk_images/trapdoor_64/door_pers_braced_std.png"],
}

export var grid_item_size : Vector2
export var grid_window_scale : float setget update_scale
onready var oSelectedRect = $Clippy/SelectedRect
onready var oCenteredLabel = $Clippy/CenteredLabel
var scnGridItem = preload("res://Scenes/GenericGridItem.tscn")

## The purpose of "Clippy" is to hide the blue cursor if you scroll it off the window.

func _ready():
	get_close_button().expand = true
	get_close_button().hide()
	connect("resized",oGridFunctions,"_on_GridWindow_resized", [self])
	connect("item_rect_changed",oGridFunctions,"_on_GridWindow_item_rect_changed", [self])
	connect("visibility_changed",oGridFunctions,"_on_GridWindow_visibility_changed",[self])
	connect("gui_input",oGridFunctions,"_on_GridWindow_gui_input",[self])
	oThingTabs.tabSystem.connect("tab_changed",oGridFunctions,"_on_tab_changed",[self])
	
	grid_window_scale = 0.55
	grid_item_size = Vector2(96, 96)
	
	# Window's minimum size
	rect_min_size = Vector2(80,80)#Vector2((grid_item_size.x*grid_window_scale)+11, (grid_item_size.y*grid_window_scale)+11)
	
	while Settings.haveInitializedAllSettings == false:
		yield(get_tree(),'idle_frame')
	
	initialize_thing_grid_items()
	
	$ThingTabs.initialize([])

func initialize_thing_grid_items():
	remove_all_grid_items()
	
	var CODETIME_START = OS.get_ticks_msec()
	
	for thingCategory in [Things.TYPE.OBJECT, Things.TYPE.CREATURE, Things.TYPE.TRAP, Things.TYPE.DOOR, Things.TYPE.EFFECT, Things.TYPE.EXTRA]:
		match thingCategory:
			Things.TYPE.OBJECT:
				for subtype in Things.DATA_OBJECT:
					var putIntoTab = Things.DATA_OBJECT[subtype][Things.EDITOR_TAB]
					add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_OBJECT, thingCategory, subtype, Things.TEXTURE)
			Things.TYPE.CREATURE:
				for subtype in Things.DATA_CREATURE:
					var putIntoTab = Things.DATA_CREATURE[subtype][Things.EDITOR_TAB]
					add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_CREATURE, thingCategory, subtype, Things.PORTRAIT)
			Things.TYPE.TRAP:
				for subtype in Things.DATA_TRAP:
					var putIntoTab = Things.DATA_TRAP[subtype][Things.EDITOR_TAB]
					add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_TRAP, thingCategory, subtype, Things.TEXTURE)
			Things.TYPE.DOOR:
				for subtype in Things.DATA_DOOR:
					var putIntoTab = Things.DATA_DOOR[subtype][Things.EDITOR_TAB]
					add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_DOOR, thingCategory, subtype, Things.TEXTURE)
			Things.TYPE.EFFECT:
				for subtype in Things.DATA_EFFECT:
					var putIntoTab = Things.DATA_EFFECT[subtype][Things.EDITOR_TAB]
					add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_EFFECT, thingCategory, subtype, Things.TEXTURE)
			Things.TYPE.EXTRA:
				for subtype in Things.DATA_EXTRA:
					var putIntoTab = Things.DATA_EXTRA[subtype][Things.EDITOR_TAB]
					add_to_category(tabs[putIntoTab][GRIDCON_PATH], Things.DATA_EXTRA, thingCategory, subtype, Things.TEXTURE)
	
	print('Initialized Things window: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func add_to_category(tabNode, thingsData, type, subtype, portrait_or_texture):
	var gridcontainer = tabNode.get_node("ScrollContainer/GridContainer")
	var id = scnGridItem.instance()
	id.connect('mouse_entered',oThingDetails,"_on_thing_portrait_mouse_entered",[id])
	id.connect('gui_input',self,"_on_thing_portrait_gui_input",[id])
	id.set_meta("thingSubtype", subtype)
	id.set_meta("thingType", type)
	id.texture_normal = thingsData[subtype][portrait_or_texture]
	if id.texture_normal == null: id.texture_normal = preload('res://Art/ThingDarkened.png')
	var setText = thingsData[subtype][Things.NAME]
	
	add_item_to_grid(gridcontainer, id, setText)
	
	# Needed for when adding custom objects
	for i in 3:
		yield(get_tree(),'idle_frame')
		oGridFunctions._on_GridWindow_resized(self)

func _process(delta): # It's necessary to use _process to update selection, because ScrollContainer won't fire a signal while you're scrolling.
	update_selection_position()

func update_selection_position():
	if is_instance_valid(oSelectedRect.boundToItem) == true:
		oSelectedRect.rect_global_position = oSelectedRect.boundToItem.rect_global_position
		oSelectedRect.rect_size = oSelectedRect.boundToItem.rect_size

func _on_hovered_none():
	oCenteredLabel.get_node("Label").text = ""

func _on_hovered_over_item(id):
	var offset = Vector2(id.rect_size.x * 0.5, id.rect_size.y * 0.5)
	oCenteredLabel.rect_global_position = id.rect_global_position + offset
	oCenteredLabel.get_node("Label").text = id.get_meta("grid_item_text")

func add_item_to_grid(tabID, id, set_text):
	tabID.add_child(id)
	
	set_text = set_text.replace(" ","\n") # Use "New lines" wherever there was a space.
	id.set_meta("grid_item_text", set_text)
	id.connect("mouse_entered", self, "_on_hovered_over_item", [id])
	id.connect("mouse_exited", self, "_on_hovered_none")
	id.connect("pressed",self,"pressed",[id])
	id.rect_min_size = Vector2(grid_item_size.x * grid_window_scale, grid_item_size.y * grid_window_scale)

func currentGridContainer():
	return oThingTabs.get_current_tab_control().get_node("ScrollContainer/GridContainer")

func pressed(id):
	#oSelection.paintSlab = setValue # Set whatever this needs to be
	oPickSlabWindow.set_selection(null)
	
	
	set_selection(id.get_meta("thingType"), id.get_meta("thingSubtype"))
	
	oPlacingSettings.update_and_set_placing_tab()
	oInspector.deselect()

func set_selection(setType, setSubtype):
	if setType == Things.TYPE.EXTRA and setSubtype == 1:
		oActionPointOptions.visible = true
	else:
		oActionPointOptions.visible = false
	
	if setType == null:
		oSelection.paintThingType = null
		oSelection.paintSubtype = null
		oSelectedRect.boundToItem = null
		oSelectedRect.visible = false
		return
	
	
	# Check EVERY tab, not just the currently selected TAB. This is needed for when right clicking on a thing in the field then switching to that tab.
	for tabIndex in oThingTabs.get_tab_count():
		var tabID = oThingTabs.get_tab_control(tabIndex)

		var gc = tabID.get_node('ScrollContainer/GridContainer')
		for id in gc.get_children():
			if id.get_meta("thingType") == setType and id.get_meta("thingSubtype") == setSubtype:
				
				oSelectedRect.visible = true
				oSelectedRect.boundToItem = id
				oSelection.paintThingType = setType
				oSelection.paintSubtype = setSubtype
				
				oThingTabs.set_current_tab(tabIndex)

func update_scale(setvalue):
	var oGridContainer = currentGridContainer()
	if oGridContainer == null: return
	for id in oGridContainer.get_children():
		id.rect_min_size = Vector2(grid_item_size.x * setvalue, grid_item_size.y * setvalue)
	grid_window_scale = setvalue
	oGridFunctions._on_GridWindow_resized(self)

#func _on_ThingTabs_tab_changed(newTab):
#	update_scale(grid_window_scale)
#
#	# Make oSelectedRect visible if it's in the tab you switched to, otherwise make in invisible
#	oSelectedRect.visible = false
#	if is_instance_valid(oSelectedRect.boundToItem):
#		for id in currentGridContainer().get_children():
#			if id.get_meta("thingSubtype") == oSelectedRect.boundToItem.get_meta("thingSubtype") and id.get_meta("thingType") == oSelectedRect.boundToItem.get_meta("thingType"):
#				oSelectedRect.visible = true
#
#	oGridFunctions._on_GridWindow_resized(self)

func remove_all_grid_items():
	for tabIndex in oThingTabs.get_tab_count():
		var tabID = oThingTabs.get_tab_control(tabIndex)
		
		var gc = tabID.get_node('ScrollContainer/GridContainer')
		for id in gc.get_children():
			id.queue_free()

func _on_thing_portrait_gui_input(event, id):
	if event.is_action_pressed("mouse_right"):
		oPropertiesWindow.oPropertiesTabs.current_tab = 0
		oCustomData.remove_object(id.get_meta("thingType"), id.get_meta("thingSubtype"))
