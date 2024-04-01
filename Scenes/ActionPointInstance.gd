extends Node2D
onready var oSelection = Nodelist.list["oSelection"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oActionPointList = Nodelist.list["oActionPointList"]

var ownership = 5 # Not used by Dungeon Keeper, this is just to make it easy for the editor.
var thingType = Things.TYPE.EXTRA
var subtype = 1 # As written in Things.DATA_EXTRA

var locationX = null setget set_location_x
var locationY = null setget set_location_y
var locationZ = null setget set_location_z # This is actually unused for action points, but its presence fixes errors
var pointRange = null setget set_pointrange
var pointNumber = null setget set_pointNumber
var data7 = null

func set_location_x(setVal):
	if locationX != null and locationY != null:
		remove_from_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))
	locationX = setVal
	position.x = locationX * 32
	if locationX != null and locationY != null:
		add_to_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))

func set_location_y(setVal):
	if locationX != null and locationY != null:
		remove_from_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))
	locationY = setVal
	position.y = locationY * 32
	if locationX != null and locationY != null:
		add_to_group("slab_location_group_" + str(floor(locationX/3)) + '_' + str(floor(locationY/3)))

func set_location_z(setVal): # This is actually unused for action points, but its presence fixes errors
	locationZ = setVal

func set_pointNumber(setval):
	pointNumber = setval
	$TextureRect/Number.text = str(pointNumber)

func set_pointrange(setval):
	pointRange = setval
	update()

func instance_was_selected(): update()
func instance_was_deselected(): update()
func _draw():
	if oSelection.cursorOnInstancesArray.has(self) or oInspector.inspectingInstance == self:
		draw_arc(Vector2(0,0), (pointRange * 32)+16, 0, PI*2, 64, Color(1,0,0,1), 4, false)

func _on_MouseDetection_mouse_entered():
	if oSelection.cursorOnInstancesArray.has(self) == false:
		oSelection.cursorOnInstancesArray.append(self)
	oSelection.clean_up_cursor_array()
	oThingDetails.update_details()
	update()

func _on_MouseDetection_mouse_exited():
	if oSelection.cursorOnInstancesArray.has(self):
		oSelection.cursorOnInstancesArray.erase(self)
	oSelection.clean_up_cursor_array()
	oThingDetails.update_details()
	update()

func _on_VisibilityNotifier2D_screen_entered():
	visible = true

func _on_VisibilityNotifier2D_screen_exited():
	visible = false



func _enter_tree():
	yield(get_tree(),'idle_frame')
	if oActionPointList:
		oActionPointList.update_ap_list()

func _exit_tree():
	if oActionPointList:
		oActionPointList.update_ap_list()
