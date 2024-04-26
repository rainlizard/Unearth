extends ItemList
onready var oInspector = Nodelist.list["oInspector"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oActionPointListWindow = Nodelist.list["oActionPointListWindow"]


const item_height = 25

var lines_to_show = 10

func _ready():
	connect("item_selected",self,"_on_item_selected")
	update_ap_list()

func update_ap_list():
	if is_inside_tree() == false: return # Fixes an annoying crash-on-exit.
	clear()

	var action_points = []
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		if id.is_queued_for_deletion() == false:
			action_points.append(id)
	action_points.sort_custom(self, "sort_action_points")
	
	var hero_gates = []
	for id in get_tree().get_nodes_in_group("Thing"):
		if id.is_queued_for_deletion() == false:
			if id.is_in_group("HeroGate"):
				hero_gates.append(id)
	hero_gates.sort_custom(self, "sort_hero_gates")
	
	for id in action_points:
		add_item("Action Point " + str(id.pointNumber))
	for id in hero_gates:
		add_item("Hero Gate " + str(id.herogateNumber))
	
	
	
	var lines = clamp(action_points.size(), 1, lines_to_show)
	get_parent().get_parent().rect_min_size.y = 9 + (lines * item_height)
	
	yield(get_tree(),'idle_frame')
	get_parent().set_deferred("scroll_vertical",1000000)

func sort_action_points(a, b):
	return a.pointNumber < b.pointNumber
func sort_hero_gates(a, b):
	return a.herogateNumber < b.herogateNumber

func _on_item_selected(idx):
	var txt = get_item_text(idx)

	if txt.begins_with("Action Point "):
		txt = txt.replace("Action Point ", "")
		for id in get_tree().get_nodes_in_group("ActionPoint"):
			if id.pointNumber == int(txt):
				oInspector.inspect_something(id)
	elif txt.begins_with("Hero Gate "):
		txt = txt.replace("Hero Gate ", "")
		for id in get_tree().get_nodes_in_group("Thing"):
			if id.is_in_group("HeroGate"):
				if id.herogateNumber == int(txt):
					oInspector.inspect_something(id)
	
	if is_instance_valid(oInspector.inspectingInstance):
		oCamera2D.center_camera_on_point(oInspector.inspectingInstance.position)


func _on_ActionPointListWindow_visibility_changed():
	if is_instance_valid(oActionPointListWindow) == false: return
	if oActionPointListWindow.visible == true:
		yield(get_tree(),'idle_frame')
		oActionPointListWindow.rect_position.x = 0
