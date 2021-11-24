extends Panel
onready var oSelection = Nodelist.list["oSelection"]
onready var oTreeOfOverlaps = Nodelist.list["oTreeOfOverlaps"]
onready var oThingDetails = Nodelist.list["oThingDetails"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oSelector = Nodelist.list["oSelector"]

var treeRoot
var timeToDisplay = 0
var previousInstancesArray = []

func _ready():
	visible = false
	oTreeOfOverlaps.get_child(4).modulate = Color(0,0,0,0)

func _unhandled_input(event):
	if visible == false: return
	if event.is_action_pressed("cycle_overlapping"):
		if oSelection.cursorOnInstancesArray.size() >= 2:
			oSelection.cursorOnInstancesArray.push_front(oSelection.cursorOnInstancesArray.pop_back())
			
			# If cursor is hovering the subtile that's selected via inspector, switch inspector selection
			if oInspector.inspectorSubtile.floor() == oSelector.cursorSubtile.floor():
				oInspector.set_inspector_instance(oSelection.cursorOnInstancesArray[0])
				#oInspector.inspect_something(oSelection.cursorOnInstancesArray[0])

func _process(delta):
	rect_position = get_global_mouse_position()
	rect_position.x += 20
	
	if oSelection.cursorOnInstancesArray.size() < 2:
		oTreeOfOverlaps.clear()
		visible = false
	
	
	if oSelection.cursorOnInstancesArray == previousInstancesArray:
		timeToDisplay += 1
	else:
		timeToDisplay = 0
		previousInstancesArray = oSelection.cursorOnInstancesArray.duplicate()
	
	if timeToDisplay >= 10:
		if oSelection.cursorOnInstancesArray.size() >= 2:
			visible = true
		else:
			visible = false
		
		update_overlap_tree()

func update_overlap_tree():
	oTreeOfOverlaps.clear()
	treeRoot = oTreeOfOverlaps.create_item()
	#print(oSelection.cursorOnInstancesArray)
	rect_size.y = 42
	for i in oSelection.cursorOnInstancesArray:
		if is_instance_valid(i) and i.is_queued_for_deletion() == false:
			var item = oTreeOfOverlaps.create_item(treeRoot)
			item.set_text(0, oThingDetails.retrieve_thing_name(i.thingType, i.subtype))
			rect_size.y += 29
	
	var highlightItem = oTreeOfOverlaps.get_item_at_position(Vector2(10,10))
	if is_instance_valid(highlightItem) and highlightItem.is_queued_for_deletion() == false:
		highlightItem.set_custom_bg_color(0, Color8(48,46,54), false)
		highlightItem.set_custom_color(0, Color(1,1,1,1))
