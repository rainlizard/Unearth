extends Node2D
onready var oSelector = Nodelist.list["oSelector"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oSelectionStatus = Nodelist.list["oSelectionStatus"]

onready var SUBTILE_SIZE = Constants.SUBTILE_SIZE

var inspectingInstance = null setget set_inspector_instance
var inspectorSubtile = null setget set_inspector_subtile

func _ready():
	set_inspector_subtile(Vector2(-1000000,-1000000))

func set_inspector_subtile(setval):
	position = setval * SUBTILE_SIZE - Vector2(SUBTILE_SIZE/2,SUBTILE_SIZE/2)
	inspectorSubtile = setval

func set_inspector_instance(setval):
	# Previously selected instance
	if is_instance_valid(inspectingInstance):
		inspectingInstance.instance_was_deselected() # Update draw event of previously selected instance
	
	# Newly selected instance
	inspectingInstance = setval
	if is_instance_valid(setval): setval.instance_was_selected()

func inspect_something(id):
	if is_instance_valid(id) and inspectingInstance != id: # Allow deselect by left clicking the same thing again
		set_inspector_instance(id)
		set_inspector_subtile(Vector2(id.locationX, id.locationY))
		oSelectionStatus.visible = true
	else:
		deselect()

func deselect():
	if is_instance_valid(oThingDetails) == false: return # (initial mode select)
	set_inspector_instance(null)
	set_inspector_subtile(Vector2(-1000000,-1000000))
	oSelectionStatus.visible = false
