extends ItemList
onready var oInspector = Nodelist.list["oInspector"]
onready var oCamera2D = Nodelist.list["oCamera2D"]

const item_height = 25

var lines_to_show = 1
var view_ap_list = false

func _ready():
	connect("item_selected",self,"_on_item_selected")
	update_section_visibility()

func update_ap_list():
	if is_inside_tree() == false: return # Fixes an annoying crash-on-exit.
	
	clear()
	
	var items_added = 0
	
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		if id.is_queued_for_deletion() == false:
			add_item("Action Point " + str(id.pointNumber))
			items_added += 1
	
	var lines = clamp(items_added, 1, lines_to_show)
	
	get_parent().get_parent().rect_min_size.y = 9 + (lines * item_height)


func _on_ShowHideAPButton_pressed():
	view_ap_list = !view_ap_list
	update_section_visibility()


func update_section_visibility():
	if view_ap_list == false:
		get_parent().scroll_vertical_enabled = false
		get_parent().get_v_scrollbar().visible = false
		self_modulate.a = 0
		lines_to_show = 1
	else:
		get_parent().scroll_vertical_enabled = true
		get_parent().get_v_scrollbar().visible = true
		self_modulate.a = 1
		lines_to_show = 5
	update_ap_list()

func _on_item_selected(idx):
	var txt = get_item_text(idx)
	txt = txt.replace("Action Point ", "")
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		if id.pointNumber == int(txt):
			oInspector.inspect_something(id)
	
	if is_instance_valid(oInspector.inspectingInstance):
		oCamera2D.center_camera_on_point(oInspector.inspectingInstance.position)
