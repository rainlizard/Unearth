extends Node2D
onready var oSelection = Nodelist.list["oSelection"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oColumnDetails = Nodelist.list["oColumnDetails"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oUiTools = Nodelist.list["oUiTools"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oPreferencesWindow = Nodelist.list["oPreferencesWindow"]
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
onready var oDataFakeSlab = Nodelist.list["oDataFakeSlab"]
onready var oQuickMapPreview = Nodelist.list["oQuickMapPreview"]
onready var oColumnEditor = Nodelist.list["oColumnEditor"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oMirrorPlacementCheckBox = Nodelist.list["oMirrorPlacementCheckBox"]
onready var oLoadingBar = Nodelist.list["oLoadingBar"]
onready var oBrushPreview = Nodelist.list["oBrushPreview"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oSlabSideViewer = Nodelist.list["oSlabSideViewer"]
onready var oAddCustomSlabWindow = Nodelist.list["oAddCustomSlabWindow"]
onready var oDisplaySlxNumbers = Nodelist.list["oDisplaySlxNumbers"]
onready var oOwnerSelection = Nodelist.list["oOwnerSelection"]
onready var oSlabNameDisplay = Nodelist.list["oSlabNameDisplay"]
onready var oUndoStates = Nodelist.list["oUndoStates"]

onready var TILE_SIZE = Constants.TILE_SIZE
onready var SUBTILE_SIZE = Constants.SUBTILE_SIZE

var fadeWallGraphics = 1.0

var canPlace = true
var cursorTile = Vector2()
var cursorSubtile = Vector2()
var previousPosTile = Vector2()
var previousPosSubtile = Vector2()

var prev_global_mouse_position = Vector2()
var mouse_movement_vector = Vector2()

var holdClickOnInstance = null
var draggingInstance = false
var drag_init_relative_pos = Vector2()

var preventClickWhenFocusing = false

enum {MODE_TILE, MODE_SUBTILE}
var mode = MODE_TILE

func _ready():
	change_mode(MODE_TILE)

func _process(delta):
	if oDataSlab.get_cell(0,0) == TileMap.INVALID_CELL:
		visible = false
		return
	
	update_cursor_position()
	
	visible = true
	if oUi.mouseOnUi == true: visible = false
	if oEditor.currentView == oEditor.VIEW_3D: visible = false
	if oUiTools.visible == false: visible = false
	if oPreferencesWindow.visible == true: visible = false
	if oQuickMapPreview.visible == true: visible = false
	if oEditor.fieldBoundary.has_point(cursorTile) == false: visible = false
	if preventClickWhenFocusing == true: visible = false
	
	if oEditor.currentView == oEditor.VIEW_2D:
		mouse_button_anywhere()
		if oUi.mouseOnUi == false:
			mouse_button_on_field()
		else:
			# Dragging an instance over UI, so reset its drag positon to original.
			if draggingInstance == true and is_instance_valid(holdClickOnInstance) and Input.is_action_just_released("mouse_left"):
				holdClickOnInstance.global_position = subtile2world(Vector2(holdClickOnInstance.locationX, holdClickOnInstance.locationY))
				holdClickOnInstance = null
				draggingInstance = false

func mouse_button_anywhere():
	if Input.is_action_pressed("mouse_left") == false:
		if oEditingTools.TOOL_SELECTED == oEditingTools.RECTANGLE:
			if oRectangleSelection.visible == true:
				oSelection.construct_shape_for_placement(oSelection.CONSTRUCT_RECTANGLE)
				oRectangleSelection.clear()

func mouse_button_on_field():
	if oLoadingBar.visible == true: return
	if preventClickWhenFocusing == true: return
	
	# Initial on-press button
	if Input.is_action_just_pressed("mouse_left"):
		match mode:
			MODE_TILE:
				match oEditingTools.TOOL_SELECTED:
					oEditingTools.RECTANGLE:
						oRectangleSelection.set_initial_position(cursorTile)
					oEditingTools.PAINTBUCKET:
						oSelection.construct_shape_for_placement(oSelection.CONSTRUCT_FILL)
			MODE_SUBTILE:
				draggingInstance = false
				
				var youClickedOnAnAlreadyInspectedThing = false
				if oInspector.inspectorSubtile.floor() == cursorSubtile.floor():
					if is_instance_valid(oInspector.inspectingInstance):
						youClickedOnAnAlreadyInspectedThing = true
				
				if Input.is_action_pressed("place_overlapping"):
					canPlace = true
				
				# Check if something is under the cursor and initiate dragging
				# If you're clicking on an inspected subtile, then drag the inspected object. (helps with stacked objects))
				
				var thingAtCursor
				
				if youClickedOnAnAlreadyInspectedThing == true:
					thingAtCursor = oInspector.inspectingInstance
					oInspector.deselect()
				else:
					thingAtCursor = instance_position(get_global_mouse_position(), "Instance")
				if is_instance_valid(thingAtCursor):
					holdClickOnInstance = thingAtCursor
					drag_init_relative_pos = thingAtCursor.global_position - get_global_mouse_position()
				
				if youClickedOnAnAlreadyInspectedThing == false:
					if oSelection.cursorOnInstancesArray.empty() == false:
						if is_instance_valid(oSelection.cursorOnInstancesArray[0]) == true:
							oInspector.inspect_something(oSelection.cursorOnInstancesArray[0])
					else:
						oInspector.deselect()
	
	# Holding down button
	if Input.is_action_pressed("mouse_left"):
		if is_instance_valid(holdClickOnInstance) and Input.is_action_pressed("place_overlapping") == false:
			if mouse_movement_vector != Vector2(0,0) or get_global_mouse_position() != prev_global_mouse_position:
				draggingInstance = true
				holdClickOnInstance.global_position = get_global_mouse_position() + drag_init_relative_pos
		else:
			match oEditingTools.TOOL_SELECTED:
				oEditingTools.PENCIL, oEditingTools.BRUSH:
					if canPlace == true and visible == true:
						canPlace = false
						match mode:
							MODE_SUBTILE:
								var placeSubtile = world2subtile(get_global_mouse_position())
								oSelection.place_subtile(placeSubtile)
							MODE_TILE:
								match oEditingTools.TOOL_SELECTED:
									oEditingTools.PENCIL:
										oSelection.construct_shape_for_placement(oSelection.CONSTRUCT_PENCIL)
									oEditingTools.BRUSH:
										oSelection.construct_shape_for_placement(oSelection.CONSTRUCT_BRUSH)
								
				oEditingTools.RECTANGLE:
					oRectangleSelection.update_positions(cursorTile)
	
	mouse_movement_vector = get_global_mouse_position()-prev_global_mouse_position
	prev_global_mouse_position = get_global_mouse_position()
	
	# Release button
	if Input.is_action_just_released("mouse_left"):
		OS.move_window_to_foreground() # See if this helps any issues which cause Unearth minimize button to stop working.
		if is_instance_valid(holdClickOnInstance):
			if draggingInstance == true:
				draggingInstance = false
				var snapToPos = world2subtile(get_global_mouse_position())
				var originalPosition = Vector2(holdClickOnInstance.locationX, holdClickOnInstance.locationY)
				holdClickOnInstance.locationX = snapToPos.x + 0.5
				holdClickOnInstance.locationY = snapToPos.y + 0.5
				
				# Readjust the thing's height when dragging it from different heights
				if holdClickOnInstance.locationZ != 2.875: # don't knock torches onto the ground if dragging them (accidental clicks would knock them down too)
					var detectTerrainHeight = oDataClm.height[oDataClmPos.get_cell_clmpos(snapToPos.x,snapToPos.y)]
					holdClickOnInstance.locationZ = detectTerrainHeight
				
				oInstances.mirror_adjusted_value(holdClickOnInstance, "locationXYZ", originalPosition)
				oInspector.inspect_something(holdClickOnInstance)
				oInspector.set_inspector_instance(holdClickOnInstance)
				oInspector.set_inspector_subtile(Vector2(holdClickOnInstance.locationX, holdClickOnInstance.locationY))
				oInspector.oSelectionStatus.visible = true
				
				if Vector2(holdClickOnInstance.locationX, holdClickOnInstance.locationY) != originalPosition:
					oEditor.mapHasBeenEdited = true
			
			holdClickOnInstance = null
	
	if Input.is_action_pressed("mouse_right"):
		if visible == true:
			if oSelection.cursorOnInstancesArray.empty() == false:
				if is_instance_valid(oSelection.cursorOnInstancesArray[0]) == true:
					change_mode(MODE_SUBTILE)
			else:
				change_mode(MODE_TILE)
			oSelection.update_paint()
			oPlacingSettings.set_placing_tab_and_update_it()
	
	if Input.is_action_pressed("mouse_right"):
		if visible == true:
			if oAddCustomSlabWindow.visible == true:
				#oMessage.quick("Sent column indexes to Fake Slab window")
				oAddCustomSlabWindow.get_column_indexes_on_tile(cursorTile)
	
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
						oSelection.manually_delete_one_instance(oSelection.cursorOnInstancesArray[0])
						canPlace = true # Allow placing on the tile you just deleted, without needing to move cursor off of it
			
			MODE_TILE:
				var nodesOnSlab = oInstances.get_all_nodes_on_slab(cursorTile.x,cursorTile.y, ["Thing","ActionPoint","Light"])
				for inst in nodesOnSlab:
					if oMirrorPlacementCheckBox.pressed == true:
						oInstances.mirror_deletion_of_instance(inst)
					oInstances.kill_instance(inst)
		
		oThingDetails.update_details()


func _input(event):
	if Input.is_action_pressed('adjust_range'):
		var inst = oInspector.inspectingInstance
		if is_instance_valid(inst):
			if inst.thingType == Things.TYPE.EFFECTGEN:
				handle_zoom(event, inst, "effectRange", "Effect range: ")
			elif inst.thingType == Things.TYPE.EXTRA and inst.subtype == 1:
				handle_zoom(event, inst, "pointRange", "Action point range: ")
			if inst.thingType == Things.TYPE.EXTRA and inst.subtype == 2:
				handle_zoom(event, inst, "lightRange", "Light range: ")

func handle_zoom(event, instance, property_name, message_prefix):
	if event.is_action_released('zoom_in'):
		adjust_range(instance, property_name, 1, message_prefix)
	if event.is_action_released('zoom_out'):
		adjust_range(instance, property_name, -1, message_prefix)

func adjust_range(instance, property_name, increment, message_prefix):
	var newRange = clamp(instance.get(property_name) + increment, 0, 32767)
	instance.set(property_name, newRange)
	oThingDetails.update_details()
	#oMessage.quick(message_prefix + str(newRange))
	get_tree().set_input_as_handled()
	var originalPosition = Vector2(instance.locationX, instance.locationY)
	oInstances.mirror_adjusted_value(instance, property_name, originalPosition)

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
			oOwnerSelection.call_deferred("update_ownership_options")
			oEditingMode.switch_mode("Slab")
			oEditingTools.switched_to_slab_mode()
			oInspector.deselect()
			oBrushPreview.update_img()
			oDisplaySlxNumbers.update_grid()
		MODE_SUBTILE:
			position = cursorSubtile * SUBTILE_SIZE
			$SubtileSelector.visible = true
			$TileSelector.visible = false
			oOwnerSelection.call_deferred("update_ownership_options")
			oEditingTools.switched_to_thing_mode()
			oEditingMode.switch_mode("Thing")
			oBrushPreview.update_img()
			oDisplaySlxNumbers.update_grid()

func world2tile(pos):
	return Vector2(floor(pos.x/TILE_SIZE),floor(pos.y/TILE_SIZE))

func world2subtile(pos):
	return Vector2(floor(pos.x/SUBTILE_SIZE),floor(pos.y/SUBTILE_SIZE))

func subtile2world(subtilePos):
	return Vector2(subtilePos.x * SUBTILE_SIZE,subtilePos.y * SUBTILE_SIZE)

func instance_position(checkPos, checkGroup):
	var space = get_world_2d().direct_space_state
	for i in space.intersect_point(oInstances.global_transform.translated(checkPos).get_origin(), 32, [], 0x7FFFFFFF, true, true):
		if i.collider.get_parent().is_in_group(checkGroup):
			return i.collider.get_parent()
	return null

func position_meeting(checkPos, checkGroup):
	var space = get_world_2d().direct_space_state
	for i in space.intersect_point(oInstances.global_transform.translated(checkPos).get_origin(), 32, [], 0x7FFFFFFF, true, true):
		if i.collider.get_parent().is_in_group(checkGroup):
			return true
	return false

func get_slabID_at_pos(pos):
	var customSlabID = oDataFakeSlab.get_cellv(pos)
	if customSlabID > 0:
		return customSlabID
	else:
		return oDataSlab.get_cellv(pos)


func _on_Selector_visibility_changed():
	# If suddenly becoming visible due to a menu closing, then don't place until you move the cursor
	# For example, this prevents placing a block when closing the map browser
	if visible == true:
		canPlace = false

func _notification(what: int):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		preventClickWhenFocusing = true
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		yield(get_tree().create_timer(0.25), "timeout")
		preventClickWhenFocusing = false
