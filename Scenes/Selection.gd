extends Node2D
onready var oSelector = Nodelist.list["oSelector"]
onready var oDataSlab = Nodelist.list["oDataSlab"]
onready var oDataOwnership = Nodelist.list["oDataOwnership"]
onready var oOverheadOwnership = Nodelist.list["oOverheadOwnership"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oOwnerSelection = Nodelist.list["oOwnerSelection"]
onready var oUi = Nodelist.list["oUi"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oSlabPlacement = Nodelist.list["oSlabPlacement"]
onready var oDataClm = Nodelist.list["oDataClm"]
onready var oDataClmPos = Nodelist.list["oDataClmPos"]
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oSlabStyle = Nodelist.list["oSlabStyle"]
onready var oDataSlx = Nodelist.list["oDataSlx"]
onready var oDisplayOverlapping = Nodelist.list["oDisplayOverlapping"]
onready var oOwnableNaturalTerrain = Nodelist.list["oOwnableNaturalTerrain"]
onready var oPropertiesWindow = Nodelist.list["oPropertiesWindow"]
onready var oRectangleSelection = Nodelist.list["oRectangleSelection"]
onready var oOnlyOwnership = Nodelist.list["oOnlyOwnership"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oCustomSlabsTab = Nodelist.list["oCustomSlabsTab"]
onready var oDataFakeSlab = Nodelist.list["oDataFakeSlab"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oEditingTools = Nodelist.list["oEditingTools"]
onready var oMirrorPlacementCheckBox = Nodelist.list["oMirrorPlacementCheckBox"]
onready var oLoadingBar = Nodelist.list["oLoadingBar"]
onready var oBrushPreview = Nodelist.list["oBrushPreview"]
onready var oPlaceThingsAnywhere = Nodelist.list["oPlaceThingsAnywhere"]
onready var oSlabSideViewer = Nodelist.list["oSlabSideViewer"]

enum {
	CONSTRUCT_BRUSH
	CONSTRUCT_PENCIL
	CONSTRUCT_RECTANGLE
	CONSTRUCT_FILL
}

var texBlueCursor = preload("res://Art/Cursor32x32Blue.png")
var texGreenCursor = preload("res://Art/Cursor32x32.png")
onready var TILE_SIZE = Constants.TILE_SIZE
onready var SUBTILE_SIZE = Constants.SUBTILE_SIZE

var cursorOverSlab = 0
var cursorOverSlabOwner = 5
var cursorOnInstancesArray = []

var paintSlab = null setget newPaintSlab
var paintThingType = null setget newPaintThingType
var paintSubtype = null setget newPaintSubtype
var paintOwnership = 0 setget newOwnership

func _process(delta):
	update_under_cursor()
	clean_up_cursor_array()
	
	if oSelector.mode == oSelector.MODE_SUBTILE:
		if cursorOnInstancesArray.empty() == false:
			$"../SubtileSelector".texture = texBlueCursor
		else:
			$"../SubtileSelector".texture = texGreenCursor

func _input(event):
	if oLoadingBar.visible == true: return
	
	if cursorOnInstancesArray.empty() == false and is_instance_valid(cursorOnInstancesArray[0]) == true and oSelector.mode == oSelector.MODE_SUBTILE:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	elif Input.get_current_cursor_shape() == Input.CURSOR_POINTING_HAND:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func newPaintThingType(value):
	if value != null: # This check is important
		oSelector.change_mode(oSelector.MODE_SUBTILE)
		oPickSlabWindow.set_selection(null) # Deselect anything in slab window
	paintThingType = value

func newPaintSubtype(value):
	if value != null: # This check is important
		oSelector.change_mode(oSelector.MODE_SUBTILE)
		oPickSlabWindow.set_selection(null) # Deselect anything in slab window
	paintSubtype = value

func newOwnership(value):
	oUi.update_theme_colour(value)
	oOwnerSelection.set_selection(value)
	paintOwnership = value

func newPaintSlab(value):
	oSelector.change_mode(oSelector.MODE_TILE)
	oPickThingWindow.set_selection(null, null)  # Deselect anything in thing window
	paintSlab = value

func update_under_cursor():
	cursorOverSlab = oSelector.get_slabID_at_pos(oSelector.cursorTile)
	cursorOverSlabOwner = oDataOwnership.get_cellv(oSelector.cursorTile)
	#oSlabSideViewer.update_side()

func update_paint():
	match oSelector.mode:
		oSelector.MODE_TILE:
			if oSlabStyle.visible == true:
				oSlabStyle.update_paint_for_slab_style(oSelector.cursorTile)
			elif oOnlyOwnership.visible == true:
				newOwnership(cursorOverSlabOwner)
				oOnlyOwnership.select_appropriate_button()
			else:
				if Slabs.data.has(cursorOverSlab) == true and cursorOverSlab < 1000:
					if Slabs.data[cursorOverSlab][Slabs.BITMASK_TYPE] == Slabs.BITMASK_WALL:
						# When you right click on a wall, select "Wall (Automatic)"
						cursorOverSlab = Slabs.WALL_AUTOMATIC
					if cursorOverSlab == Slabs.EARTH_WITH_TORCH:
						# When you right click on a torch wall, select "Earth"
						cursorOverSlab = Slabs.EARTH
				
				newPaintSlab(cursorOverSlab)
				oPickSlabWindow.set_selection(cursorOverSlab)
				
				if cursorOverSlabOwner != 5 or oOwnableNaturalTerrain.pressed == true or Slabs.data[cursorOverSlab][Slabs.IS_OWNABLE] == true:
					newOwnership(cursorOverSlabOwner)
				
		oSelector.MODE_SUBTILE:
			if cursorOnInstancesArray.empty() == false:
				if is_instance_valid(cursorOnInstancesArray[0]) == true:
					newOwnership(cursorOnInstancesArray[0].ownership)
					
					paintThingType = cursorOnInstancesArray[0].thingType
					paintSubtype = cursorOnInstancesArray[0].subtype
					oPickThingWindow.set_selection(paintThingType, paintSubtype)


func construct_shape_for_placement(constructType):
	if paintSlab == null: return
	
	oEditor.mapHasBeenEdited = true
	var shapePositionArray = []
	match constructType:
		CONSTRUCT_RECTANGLE:
			var rectStart = Vector2()
			var rectEnd = Vector2()
			if oRectangleSelection.beginTile.x < oRectangleSelection.endTile.x:
				rectStart.x = oRectangleSelection.beginTile.x
				rectEnd.x = oRectangleSelection.endTile.x
			else:
				rectStart.x = oRectangleSelection.endTile.x
				rectEnd.x = oRectangleSelection.beginTile.x
			if oRectangleSelection.beginTile.y < oRectangleSelection.endTile.y:
				rectStart.y = oRectangleSelection.beginTile.y
				rectEnd.y = oRectangleSelection.endTile.y
			else:
				rectStart.y = oRectangleSelection.endTile.y
				rectEnd.y = oRectangleSelection.beginTile.y
			for y in range(rectStart.y, rectEnd.y+1):
				for x in range(rectStart.x, rectEnd.x+1):
					shapePositionArray.append(Vector2(x,y))
		CONSTRUCT_PENCIL, CONSTRUCT_BRUSH:
			var ct_and_offset = oSelector.cursorTile + oBrushPreview.offsetBrushPos
			for pos in oBrushPreview.brushShapeArray:
				var newPos = pos + ct_and_offset
				if newPos.x < oEditor.fieldBoundary.position.x: continue
				if newPos.x > oEditor.fieldBoundary.end.x-1: continue
				if newPos.y < oEditor.fieldBoundary.position.y: continue
				if newPos.y > oEditor.fieldBoundary.end.y-1: continue
				shapePositionArray.append(newPos)
		CONSTRUCT_FILL:
			var beginTile = oSelector.world2tile(get_global_mouse_position())
			
			# Prevent clicking outside
			if beginTile.x < oEditor.fieldBoundary.position.x: return
			if beginTile.x > oEditor.fieldBoundary.end.x-1: return
			if beginTile.y < oEditor.fieldBoundary.position.y: return
			if beginTile.y > oEditor.fieldBoundary.end.y-1: return
			
			var coordsToCheck = [beginTile]
			var fillTargetID = oSelector.get_slabID_at_pos(oSelector.cursorTile)
			var checkedCoords = {}  # Use a dictionary to mimic set behavior for checked coordinates
			
			var preventFillingBorder = false
			if fillTargetID == Slabs.ROCK:
				preventFillingBorder = true
			
			while coordsToCheck.size() > 0:
				var coord = coordsToCheck.pop_back()
				
				if coord in checkedCoords: # Skip if already checked
					continue
				checkedCoords[coord] = true
				
				if preventFillingBorder:
					if coord.x < oEditor.fieldBoundary.position.x: continue
					if coord.x > oEditor.fieldBoundary.end.x-1: continue
					if coord.y < oEditor.fieldBoundary.position.y: continue
					if coord.y > oEditor.fieldBoundary.end.y-1: continue
				
				if oSelector.get_slabID_at_pos(coord) == fillTargetID:
					shapePositionArray.append(coord)
					
					var neighbors = [coord + Vector2(0,1), coord + Vector2(0,-1), coord + Vector2(1,0), coord + Vector2(-1,0)]
					for neighbor in neighbors:
						if not checkedCoords.has(neighbor):
							coordsToCheck.append(neighbor)
	
	if oSlabStyle.visible == true:
		oDataSlx.set_tileset_shape(shapePositionArray)
		if oMirrorPlacementCheckBox.pressed == true:
			oSlabPlacement.mirror_placement(shapePositionArray, oSlabPlacement.MIRROR_STYLE)
	elif oOnlyOwnership.visible == true:
		
		oOverheadOwnership.ownership_paint_shape(shapePositionArray, paintOwnership)
		oOverheadOwnership.ownership_update_things(shapePositionArray, paintOwnership)
		if oMirrorPlacementCheckBox.pressed == true:
			oSlabPlacement.mirror_placement(shapePositionArray, oSlabPlacement.MIRROR_ONLY_OWNERSHIP)
		
		var updateNearby = some_manual_placements_dont_update_nearby()
		oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, updateNearby)
	else:
		# Slab placement
		var useOwner = paintOwnership
		
		oSlabPlacement.place_shape_of_slab_id(shapePositionArray, paintSlab, useOwner)
		
		if oMirrorPlacementCheckBox.pressed == true:
			oSlabPlacement.mirror_placement(shapePositionArray, oSlabPlacement.MIRROR_SLAB_AND_OWNER)
		
		var updateNearby = some_manual_placements_dont_update_nearby()
		oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, updateNearby)

func some_manual_placements_dont_update_nearby():
	# Fake Slabs don't update the surroundings
	if oCustomSlabsTab.visible == true and oPickSlabWindow.oSelectedRect.visible == true:
		return false
	elif Slabs.doors.has(paintSlab): # Doors don't update the surroundings
		return false
	return true

func place_subtile(placeSubtile):
	if placeSubtile.x < 0 or placeSubtile.y < 0 or placeSubtile.x >= (M.xSize*3) or placeSubtile.y >= (M.ySize*3):
		return
	if oInstances.placement_is_obstructed(paintThingType, placeSubtile) == true:
		return
	
	if oSelector.position_meeting(get_global_mouse_position(), "Instance") == true:
		if Input.is_action_pressed("place_overlapping") == false: # While holding control, allow overlapping placements
			return
	oEditor.mapHasBeenEdited = true
	
	if paintThingType != null:
		var detectTerrainHeight = oDataClm.height[oDataClmPos.get_cell(placeSubtile.x,placeSubtile.y)]
		var newPos:Vector3 = Vector3(placeSubtile.x + 0.5, placeSubtile.y + 0.5, detectTerrainHeight)
		
		match paintThingType:
			Things.TYPE.EXTRA:
				match paintSubtype:
					1:
						oInstances.place_new_action_point(paintThingType, paintSubtype, newPos, paintOwnership)
						if oMirrorPlacementCheckBox.pressed == true:
							oInstances.mirror_instance_placement(paintThingType, paintSubtype, newPos, paintOwnership, oInstances.MIRROR_ACTIONPOINT)
					2:
						oInstances.place_new_light(paintThingType, paintSubtype, newPos, paintOwnership)
						if oMirrorPlacementCheckBox.pressed == true:
							oInstances.mirror_instance_placement(paintThingType, paintSubtype, newPos, paintOwnership, oInstances.MIRROR_LIGHT)
			_:
				oInstances.place_new_thing(paintThingType, paintSubtype, newPos, paintOwnership)
				if oMirrorPlacementCheckBox.pressed == true:
					oInstances.mirror_instance_placement(paintThingType, paintSubtype, newPos, paintOwnership, oInstances.MIRROR_THING)

func clean_up_cursor_array():
	for i in cursorOnInstancesArray:
		if is_instance_valid(i) == false:
			cursorOnInstancesArray.erase(i)
		else:
			if i.is_queued_for_deletion() == true:
				cursorOnInstancesArray.erase(i)

func manually_delete_one_instance(inst):
	if is_instance_valid(inst) == true:
		oEditor.mapHasBeenEdited = true
		
		if oInspector.inspectingInstance == inst:
			oInspector.deselect()
		
		if inst.is_in_group("ActionPoint"):
			oScriptHelpers.start() # Update when action points change
		
		if oMirrorPlacementCheckBox.pressed == true:
			oInstances.mirror_deletion_of_instance(inst)
		
		inst.queue_free()

#func ui_hover():
#	if oSelector.cursorIsOnGrid == true:
#		update_hover_slab()
#		update_hover_instance()
#	else:
#		oHoverSlab.visible = false
#		oHoverInstance.visible = false

#func update_hover_slab():
#	oHoverSlab.visible = true
#	oHoverSlab.set_slab_display(cursorOverSlab, cursorOverSlabOwner)

#func update_hover_instance():
#	if cursorOnInstancesArray != null:
#		oHoverInstance.visible = true
#		#oHoverInstance.set_instance_display(cursorOnInstancesArray.data)
#	else:
#		oHoverInstance.visible = false

				
				#match instanceTypeHeld:
					#INSTANCE_THING: createInstance = Thing.create(paintInstance.data, preload("res://Scenes/ThingInstance.tscn"))
#					INSTANCE_ACTIONPOINT: createInstance = ActionPoint.create(paintInstance.data, preload("res://Scenes/ActionPointInstance.tscn"))
				
#				createInstance.position = Vector2(placeSubtile.x*SUBTILE_SIZE, placeSubtile.y*SUBTILE_SIZE)
#				createInstance.position += Vector2(SUBTILE_SIZE*0.5,SUBTILE_SIZE*0.5)
