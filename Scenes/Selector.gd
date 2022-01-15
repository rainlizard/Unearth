extends Node2D

onready var oSelection = Nodelist.list["oSelection"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oUiTools = Nodelist.list["oUiTools"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oSettingsWindow = Nodelist.list["oSettingsWindow"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oUseSlabOwnerCheckBox = Nodelist.list["oUseSlabOwnerCheckBox"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oUi = Nodelist.list["oUi"]
onready var oGame = Nodelist.list["oGame"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oDataWibble = Nodelist.list["oDataWibble"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oSlabStyle = Nodelist.list["oSlabStyle"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oEditingMode = Nodelist.list["oEditingMode"]
onready var oPropertiesWindow = Nodelist.list["oPropertiesWindow"]
onready var oEditingTools = Nodelist.list["oEditingTools"]
onready var oRectangleSelection = Nodelist.list["oRectangleSelection"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataCustomSlab = Nodelist.list["oDataCustomSlab"]

onready var TILE_SIZE = Constants.TILE_SIZE
onready var SUBTILE_SIZE = Constants.SUBTILE_SIZE

var fadeWallGraphics = 1.0

var canPlace = true
var cursorTile = Vector2()
var cursorSubtile = Vector2()
var previousPosTile = Vector2()
var previousPosSubtile = Vector2()

enum {MODE_TILE, MODE_SUBTILE}
var mode = MODE_TILE

#Rect2(Vector2(0,0), Vector2(85,85))

func _ready():
	change_mode(MODE_TILE)

func _process(delta):
	if oDataSlab.get_cell(0,0) == TileMap.INVALID_CELL:
		visible = false
		return
	
	update_cursor_position()
	
	visible = true
	if oUi.mouseOnUi == true or oEditor.currentView == oEditor.VIEW_3D or oUiTools.visible == false or oSettingsWindow.visible == true: # Prevent placing stuff in 3D view
		visible = false
	
	if oEditor.fieldBoundary.has_point(cursorTile) == false:
		visible = false
	
	if oEditor.currentView == oEditor.VIEW_2D:
		mouse_button_anywhere()
		if oUi.mouseOnUi == false:
			mouse_button_on_field()

func mouse_button_anywhere():
	if Input.is_action_pressed("mouse_left") == false:
		if oEditingTools.TOOL_SELECTED == oEditingTools.RECTANGLE:
			if oRectangleSelection.visible == true:
				oSelection.place_shape(oRectangleSelection.beginTile, oRectangleSelection.endTile)
				oRectangleSelection.clear()

func mouse_button_on_field():
	if Input.is_action_just_pressed("mouse_left"):
		
		if Input.is_action_pressed("place_overlapping"):
			canPlace = true
		else:
			if oSelection.cursorOnInstancesArray.empty() == false:
				if is_instance_valid(oSelection.cursorOnInstancesArray[0]) == true:
					oPropertiesWindow.oPropertiesTabs.current_tab = 0
					oInspector.inspect_something(oSelection.cursorOnInstancesArray[0])
			else:
				oInspector.deselect()
		
		match oEditingTools.TOOL_SELECTED:
			oEditingTools.PENCIL:
				pass
			oEditingTools.RECTANGLE:
				oRectangleSelection.set_initial_position(cursorTile)
	
	if Input.is_action_pressed("mouse_left"):
		
			match oEditingTools.TOOL_SELECTED:
				oEditingTools.PENCIL:
					if canPlace == true and visible == true:
						canPlace = false
						
						match mode:
							MODE_SUBTILE:
								var placeSubtile = world2subtile(get_global_mouse_position())
								oSelection.place_subtile(placeSubtile)
							MODE_TILE:
								var placeTile = world2tile(get_global_mouse_position())
								oSelection.place_shape(placeTile, placeTile)
				oEditingTools.RECTANGLE:
					oRectangleSelection.update_positions(cursorTile)
	
	if Input.is_action_pressed("mouse_right"):
		if visible == true:
			if oSelection.cursorOnInstancesArray.empty() == false:
				if is_instance_valid(oSelection.cursorOnInstancesArray[0]) == true:
					change_mode(MODE_SUBTILE)
			else:
				change_mode(MODE_TILE)
			oPlacingSettings.update_and_set_placing_tab()
			oSelection.update_paint()
	
	# Lose inspection when right clicking
	if Input.is_action_just_released("mouse_right"):
		if Input.is_action_pressed("place_overlapping") == false:
			oInspector.deselect()
	
	if Input.is_action_pressed("ui_delete"):
		oEditor.mapHasBeenEdited = true
		match mode:
			MODE_SUBTILE:
				var doDelete = false
				if Input.is_action_pressed("specify_delete"):
					if Input.is_action_just_pressed("ui_delete"):
						doDelete = true
				else:
					doDelete = true
				
				if doDelete == true:
					if oSelection.cursorOnInstancesArray.empty() == false:
						oSelection.delete_instance(oSelection.cursorOnInstancesArray[0])
			
			MODE_TILE:
				oInstances.delete_all_objects_on_slab(cursorTile.x,cursorTile.y)


#func _unhandled_input(event):
#	if event is InputEventMouseButton:
#		mouse_button()
	
#	match event:
#		InputEventMouseMotion:
#			if oCamera2D.desired_offset != Vector2():
#				update_cursor_position()

func update_cursor_position():
	cursorTile = world2tile(get_global_mouse_position())
	cursorSubtile = world2subtile(get_global_mouse_position())
	if cursorTile != previousPosTile:
		moved_to_new_tile()
		previousPosTile = cursorTile
	
	if cursorSubtile != previousPosSubtile:
		moved_to_new_subtile()
		previousPosSubtile = cursorSubtile
	
	match mode:
		MODE_TILE: position = cursorTile * TILE_SIZE
		MODE_SUBTILE: position = cursorSubtile * SUBTILE_SIZE

func moved_to_new_tile():
	if mode == MODE_TILE: canPlace = true

func moved_to_new_subtile():
	oColumnDetails.update_details()
	
	if mode == MODE_SUBTILE:
		canPlace = true
		if oUseSlabOwnerCheckBox.pressed == true and visible == true:
			if oUseSlabOwnerCheckBox.pressed == true:
				oSelection.paintOwnership = oDataOwnership.get_cellv(cursorTile)
				#oSelection.newOwnership(oDataOwnership.get_cellv(cursorTile))
			#oUi.update_theme_colour(oDataOwnership.get_cellv(cursorTile))
#		var realPos = Vector2((cursorSubtile.x*SUBTILE_SIZE)+(SUBTILE_SIZE/2),(cursorSubtile.y*SUBTILE_SIZE)+(SUBTILE_SIZE/2))
#		var instanceAtCursorSubtile = instance_position(realPos, "Instance")
#		print(instanceAtCursorSubtile)

#func fadeOutWalls(delta):
#	if Slabs.array[oSelection.cursorOverSlab][Slabs.SIDE_OF] == Slabs.SIDE_SLAB:
#		oWallStuff.fadeOut(delta)
#	else:
#		oWallStuff.fadeIn(delta)

func change_mode(changeModeTo):
	mode = changeModeTo
	match mode:
		MODE_TILE:
			position = cursorTile * TILE_SIZE
			$SubtileSelector.visible = false
			$TileSelector.visible = true
			oUseSlabOwnerCheckBox.visible = false
			oEditingMode.switch_mode("Slab")
			oEditingTools.switched_to_slab_mode()
			oInspector.deselect()
		MODE_SUBTILE:
			position = cursorSubtile * SUBTILE_SIZE
			$SubtileSelector.visible = true
			$TileSelector.visible = false
			oUseSlabOwnerCheckBox.visible = true
			oEditingTools.switched_to_thing_mode()
			oEditingMode.switch_mode("Thing")

func world2tile(pos):
	return Vector2(floor(pos.x/TILE_SIZE),floor(pos.y/TILE_SIZE))

func world2subtile(pos):
	return Vector2(floor(pos.x/SUBTILE_SIZE),floor(pos.y/SUBTILE_SIZE))

func instance_position(checkPos, checkGroup):
	var space = get_world_2d().direct_space_state
	for i in space.intersect_point(oInstances.global_transform.translated(checkPos).get_origin(), 32, [], 0x7FFFFFFF, true, true):
		if i["collider"].get_parent().is_in_group(checkGroup):
			return i["collider"].get_parent()
	return null

func position_meeting(checkPos, checkGroup):
	var space = get_world_2d().direct_space_state
	for i in space.intersect_point(oInstances.global_transform.translated(checkPos).get_origin(), 32, [], 0x7FFFFFFF, true, true):
		if i["collider"].get_parent().is_in_group(checkGroup):
			return true
	return false

func get_slabID_under_cursor():
	var customSlabID = oDataCustomSlab.get_cellv(cursorTile)
	if customSlabID != 0:
		return customSlabID
	else:
		return oDataSlab.get_cellv(cursorTile)
