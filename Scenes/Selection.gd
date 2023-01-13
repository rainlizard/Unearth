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
onready var oDataCustomSlab = Nodelist.list["oDataCustomSlab"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oEditingTools = Nodelist.list["oEditingTools"]
onready var oMirrorPlacementCheckBox = Nodelist.list["oMirrorPlacementCheckBox"]

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

var paintSlab = 0 setget newPaintSlab
var paintThingType = null setget newPaintThingType
var paintSubtype = null setget newPaintSubtype
var paintOwnership = 0 setget newOwnership

func _process(delta):
	get_slab_under_cursor()
	
	clean_up_cursor_array()
	
	if oSelector.mode == oSelector.MODE_SUBTILE:
		if cursorOnInstancesArray.empty() == false:
			$"../SubtileSelector".texture = texBlueCursor
		else:
			$"../SubtileSelector".texture = texGreenCursor

func _input(event):
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

func get_slab_under_cursor():
	cursorOverSlab = oSelector.get_slabID_at_pos(oSelector.cursorTile)
	cursorOverSlabOwner = oDataOwnership.get_cellv(oSelector.cursorTile)

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
				
				# Only change ownership paint under certain circumstances
#				var specialCircumstancesForOwnershipUpdate = false
#				if oOwnableNaturalTerrain.pressed == false: #cursorOverSlabOwner != 5 or 
#					if Slabs.data[cursorOverSlab][Slabs.IS_OWNABLE] == true:
#						specialCircumstancesForOwnershipUpdate = true
#				if oOwnableNaturalTerrain.pressed == true or specialCircumstancesForOwnershipUpdate == true:
				newOwnership(cursorOverSlabOwner)
				
		oSelector.MODE_SUBTILE:
			if cursorOnInstancesArray.empty() == false:
				if is_instance_valid(cursorOnInstancesArray[0]) == true:
					newOwnership(cursorOnInstancesArray[0].ownership)
					
					paintThingType = cursorOnInstancesArray[0].thingType
					paintSubtype = cursorOnInstancesArray[0].subtype
					oPickThingWindow.set_selection(paintThingType, paintSubtype)


func construct_shape_for_placement(constructType):
	oEditor.mapHasBeenEdited = true
	var rectStart = Vector2()
	var rectEnd = Vector2()
	
	var shapePositionArray = []
	match constructType:
		CONSTRUCT_RECTANGLE:
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
			
			var b = ((oEditingTools.BRUSH_SIZE)-1) / 2.0
			var beginTile = oSelector.world2tile(get_global_mouse_position()) - Vector2(floor(b),floor(b))
			var endTile = oSelector.world2tile(get_global_mouse_position()) + Vector2(ceil(b),ceil(b))
			
			# Clamp inside map
			beginTile.x = clamp(beginTile.x, oEditor.fieldBoundary.position.x, oEditor.fieldBoundary.end.x-1)
			beginTile.y = clamp(beginTile.y, oEditor.fieldBoundary.position.y, oEditor.fieldBoundary.end.y-1)
			endTile.x = clamp(endTile.x, oEditor.fieldBoundary.position.x, oEditor.fieldBoundary.end.x-1)
			endTile.y = clamp(endTile.y, oEditor.fieldBoundary.position.y, oEditor.fieldBoundary.end.y-1)
			
			if beginTile.x < endTile.x:
				rectStart.x = beginTile.x
				rectEnd.x = endTile.x
			else:
				rectStart.x = endTile.x
				rectEnd.x = beginTile.x
			if beginTile.y < endTile.y:
				rectStart.y = beginTile.y
				rectEnd.y = endTile.y
			else:
				rectStart.y = endTile.y
				rectEnd.y = beginTile.y
			var brushSizeX = abs(rectStart.x-rectEnd.x)
			var brushSizeY = abs(rectStart.y-rectEnd.y)
			var center = rectStart + (Vector2(brushSizeX,brushSizeY)*0.5)
			
			for y in range(rectStart.y, rectEnd.y+1):
				for x in range(rectStart.x, rectEnd.x+1):
					if constructType == CONSTRUCT_BRUSH:
						if (Vector2(x,y).distance_to(center)) < (max(brushSizeX+1,brushSizeY+1)*0.47):
							shapePositionArray.append(Vector2(x,y))
					else:
						shapePositionArray.append(Vector2(x,y))
		CONSTRUCT_FILL:
			var beginTile = oSelector.world2tile(get_global_mouse_position())
			var coordsToCheck = [beginTile]
			var fillTargetID = oSelector.get_slabID_at_pos(oSelector.cursorTile)
			
			var preventFillingBorder = false
			if fillTargetID == Slabs.ROCK:
				preventFillingBorder = true
			
			while coordsToCheck.size() > 0:
				var coord = coordsToCheck.pop_back()
				oSelector.get_slabID_at_pos(oSelector.cursorTile)
				
				if preventFillingBorder == true:
					if coord.x < oEditor.fieldBoundary.position.x: continue
					if coord.x > oEditor.fieldBoundary.end.x-1: continue
					if coord.y < oEditor.fieldBoundary.position.y: continue
					if coord.y > oEditor.fieldBoundary.end.y-1: continue
				
				if oSelector.get_slabID_at_pos(coord) == fillTargetID:
					shapePositionArray.append(coord)
					
					if shapePositionArray.has(coord + Vector2(0,1)) == false:
						coordsToCheck.append(coord + Vector2(0,1))
					if shapePositionArray.has(coord + Vector2(0,-1)) == false:
						coordsToCheck.append(coord + Vector2(0,-1))
					if shapePositionArray.has(coord + Vector2(1,0)) == false:
						coordsToCheck.append(coord + Vector2(1,0))
					if shapePositionArray.has(coord + Vector2(-1,0)) == false:
						coordsToCheck.append(coord + Vector2(-1,0))
	
	if oSlabStyle.visible == true:
		oDataSlx.set_tileset_shape(shapePositionArray)
	elif oOnlyOwnership.visible == true:
		oOverheadOwnership.ownership_paint_shape(shapePositionArray, paintOwnership)
		oOverheadOwnership.ownership_update_things(shapePositionArray, paintOwnership)
		oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, true)
	else:
		# Slab placement
		var useOwner = paintOwnership
		
		oSlabPlacement.place_shape_of_slab_id(shapePositionArray, paintSlab, useOwner)
		
		if oMirrorPlacementCheckBox.pressed == true:
			oSlabPlacement.mirror_placement(shapePositionArray)
		
		var updateNearby = true
		# Custom slabs don't update the surroundings
		if oCustomSlabsTab.visible == true and oPickSlabWindow.oSelectedRect.visible == true:
			updateNearby = false
		
		oSlabPlacement.generate_slabs_based_on_id(shapePositionArray, updateNearby)


func place_subtile(placeSubtile):
	if placeSubtile.x < 0 or placeSubtile.y < 0 or placeSubtile.x >= (M.xSize*3) or placeSubtile.y >= (M.ySize*3):
		return
	
	if oSelector.position_meeting(get_global_mouse_position(), "Instance") == true:
		if Input.is_action_pressed("place_overlapping") == false: # While holding control, allow overlapping placements
			return
	oEditor.mapHasBeenEdited = true
	
	if paintThingType != null:
		var detectTerrainHeight = oDataClm.height[oDataClmPos.get_cell(placeSubtile.x,placeSubtile.y)]
		var newPos = Vector3(placeSubtile.x + 0.5, placeSubtile.y + 0.5, detectTerrainHeight)
		
		match paintThingType:
			Things.TYPE.EXTRA:
				match paintSubtype:
					1: oInstances.place_new_action_point(paintThingType, paintSubtype, newPos, paintOwnership)
					2: oInstances.place_new_light(paintThingType, paintSubtype, newPos, paintOwnership)
			_:
				oInstances.place_new_thing(paintThingType, paintSubtype, newPos, paintOwnership)


func clean_up_cursor_array():
	for i in cursorOnInstancesArray:
		if is_instance_valid(i) == false:
			cursorOnInstancesArray.erase(i)
		else:
			if i.is_queued_for_deletion() == true:
				cursorOnInstancesArray.erase(i)

func manually_delete_one_instance(inst):
	if is_instance_valid(inst) == true:
		if oInspector.inspectingInstance == inst:
			oInspector.deselect()
		
		if inst.is_in_group("ActionPoint"):
			oScriptHelpers.start() # Update when action points change
		
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
