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
	cursorOverSlab = oDataSlab.get_cellv(oSelector.cursorTile)
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
				# Do not allow grabbing paint of custom slabs
				if oDataCustomSlab.get_cellv(oSelector.cursorTile) == 1:
					return
				
				if Slabs.data.has(cursorOverSlab) == true:
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


func place_shape(beginTile,endTile):
	oEditor.mapHasBeenEdited = true
	
	var rectStart = Vector2()
	var rectEnd = Vector2()
	
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
	
	var shapePositionArray = []
	for y in range(rectStart.y, rectEnd.y+1):
		for x in range(rectStart.x, rectEnd.x+1):
			shapePositionArray.append(Vector2(x,y))
	
	if oSlabStyle.visible == true:
		oDataSlx.set_tileset_shape(shapePositionArray)
	elif oOnlyOwnership.visible == true:
		oOverheadOwnership.ownership_update_shape(shapePositionArray, paintOwnership)
		oSlabPlacement.generate_slabs_based_on_id(rectStart, rectEnd)
	else:
		# Slab placement
		var useOwner = paintOwnership
		if oOwnableNaturalTerrain.pressed == false and Slabs.data.has(paintSlab) and Slabs.data[paintSlab][Slabs.IS_OWNABLE] == false:
			useOwner = 5
		oSlabPlacement.place_shape_of_slab_id(shapePositionArray, paintSlab, useOwner)
		
		var updateNearby = true
		# Custom slabs don't update the surroundings
		if oCustomSlabsTab.visible == true and oPickSlabWindow.oSelectedRect.visible == true:
			updateNearby = false
		
		oSlabPlacement.generate_slabs_based_on_id(rectStart, rectEnd, updateNearby)

#func place_tile(placeTile):
#	if placeTile.x < 0 or placeTile.y < 0 or placeTile.x >= 85 or placeTile.y >= 85:
#		return
#
#	oEditor.mapHasBeenEdited = true
#
#	if oSlabStyle.visible == true: # Texture placement
#		oDataSlx.set_tileset_shape([placeTile])
#	elif oOnlyOwnership.visible == true: # Ownership placement
#		oOverheadOwnership.ownership_update_shape([placeTile], paintOwnership)
#		oSlabPlacement.generate_slabs_based_on_id(placeTile, placeTile)
#	else: # Slab placement
#		var CODETIME_START = OS.get_ticks_msec()
#		oInstances.delete_all_objects_on_slab(placeTile.x,placeTile.y)
#
#		var useOwner = paintOwnership
#		if oOwnableNaturalTerrain.pressed == false and Slabs.data[paintSlab][Slabs.IS_OWNABLE] == false:
#			useOwner = 5
#
#		oSlabPlacement.place_slab(placeTile.x, placeTile.y, paintSlab, useOwner, true)
#
#		print('Slab manually placed in : '+str(OS.get_ticks_msec()-CODETIME_START)+'ms')
		
#			oGraphics.erase_slab(x, y)
#			oGraphics.place_slab(x, y, paintSlab)
#			oGraphics.apply_autotile( Vector2((x-1)*3,(y-1)*3), Vector2(((x+1)*3)+2,((y+1)*3)+2) )

func place_subtile(placeSubtile):
	if placeSubtile.x < 0 or placeSubtile.y < 0 or placeSubtile.x >= 255 or placeSubtile.y >= 255:
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

func delete_instance(inst):
	if is_instance_valid(inst) == true:
		if oInspector.inspectingInstance == inst:
			oInspector.deselect()
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
