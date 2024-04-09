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
	
	var count_ap = 0
	
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		if id.is_queued_for_deletion() == false:
			add_item("Action Point " + str(id.pointNumber))
			count_ap += 1
	
	var lines = clamp(count_ap, 1, lines_to_show)
	
	get_parent().get_parent().rect_min_size.y = 9 + (lines * item_height)

func _on_item_selected(idx):
	var txt = get_item_text(idx)
	txt = txt.replace("Action Point ", "")
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		if id.pointNumber == int(txt):
			oInspector.inspect_something(id)
	
	if is_instance_valid(oInspector.inspectingInstance):
		oCamera2D.center_camera_on_point(oInspector.inspectingInstance.position)


func _on_ActionPointListWindow_visibility_changed():
	if is_instance_valid(oActionPointListWindow) == false: return
	if oActionPointListWindow.visible == true:
		yield(get_tree(),'idle_frame')
		oActionPointListWindow.rect_position.x = 0
