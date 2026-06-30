extends TabContainer
onready var oInspector = Nodelist.list["oInspector"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oActionPointListWindow = Nodelist.list["oActionPointListWindow"]
onready var oCreatureList = Nodelist.list["oCreatureList"]
onready var oActionPointHeroGateList = Nodelist.list["oActionPointHeroGateList"]


const ITEM_HEIGHT = 25
const LINES_TO_SHOW = 10
const CREATURE_LIST_OWNERSHIP_COLORS = [
	Color8(255, 90, 80),
	Color8(112, 150, 255),
	Color8(86, 225, 90),
	Color8(242, 220, 70),
	Color8(242, 242, 242),
	Color8(160, 160, 160),
	Color8(224, 120, 220),
	Color8(115, 115, 125),
	Color8(255, 155, 70),
]

var selecting_from_list = false


func _ready():
	for list in [oCreatureList, oActionPointHeroGateList]:
		list.connect("item_selected", self, "_on_item_selected", [list])
	update_ap_list()


func update_ap_list():
	if is_inside_tree() == false: return # Fixes an annoying crash-on-exit.
	populate_list(oCreatureList, get_creature_entries())
	populate_list(oActionPointHeroGateList, get_action_point_entries() + get_hero_gate_entries())
	update_list_height()


func update_if_visible():
	if is_instance_valid(oActionPointListWindow) and oActionPointListWindow.visible == true:
		update_ap_list()


func populate_list(list, entries):
	list.clear()
	for entry in entries:
		list.add_item(entry[0])
		var item_index = list.get_item_count() - 1
		list.set_item_metadata(item_index, entry[1])
		if entry.size() > 2:
			list.set_item_custom_fg_color(item_index, entry[2])


func get_creature_entries():
	var entries = []
	var creatures = []
	for id in get_tree().get_nodes_in_group("Creature"):
		if id.is_queued_for_deletion() == false:
			creatures.append(id)
	creatures.sort_custom(self, "sort_things")

	for id in creatures:
		entries.append([get_creature_text(id), id, CREATURE_LIST_OWNERSHIP_COLORS[id.ownership]])
	return entries


func get_action_point_entries():
	var entries = []
	var action_points = []
	for id in get_tree().get_nodes_in_group("ActionPoint"):
		if id.is_queued_for_deletion() == false:
			action_points.append(id)
	action_points.sort_custom(self, "sort_action_points")
	for id in action_points:
		entries.append(["Action Point " + str(id.pointNumber), id])
	return entries


func get_hero_gate_entries():
	var entries = []
	var hero_gates = []
	for id in get_tree().get_nodes_in_group("Thing"):
		if id.is_queued_for_deletion() == false:
			if id.is_in_group("HeroGate") and id.herogateNumber != null:
				hero_gates.append(id)
	hero_gates.sort_custom(self, "sort_hero_gates")
	for id in hero_gates:
		entries.append(["Hero Gate " + str(id.herogateNumber), id])
	return entries


func update_list_height():
	var count = max(oCreatureList.get_item_count(), oActionPointHeroGateList.get_item_count())
	var lines = clamp(count, 1, LINES_TO_SHOW)
	rect_min_size.y = 35 + (lines * ITEM_HEIGHT)
	
	yield(get_tree(),'idle_frame')
	oCreatureList.get_parent().set_deferred("scroll_vertical", 1000000)
	oActionPointHeroGateList.get_parent().set_deferred("scroll_vertical", 1000000)


func get_creature_text(id):
	return Things.fetch_name(id.thingType, id.subtype) + " (" + str(id.locationX) + ", " + str(id.locationY) + ")"


func sort_things(a, b):
	if a.ownership != b.ownership:
		return a.ownership < b.ownership
	var name_a = Things.fetch_name(a.thingType, a.subtype)
	var name_b = Things.fetch_name(b.thingType, b.subtype)
	if name_a == name_b:
		if a.locationY == b.locationY:
			return a.locationX < b.locationX
		return a.locationY < b.locationY
	return name_a < name_b


func sort_action_points(a, b):
	return a.pointNumber < b.pointNumber


func sort_hero_gates(a, b):
	return a.herogateNumber < b.herogateNumber


func _on_item_selected(idx, list):
	var id = list.get_item_metadata(idx)
	if is_instance_valid(id) == false: return
	if list == oCreatureList:
		oActionPointHeroGateList.unselect_all()
	else:
		oCreatureList.unselect_all()
	selecting_from_list = true
	oInspector.inspect_something(id)
	selecting_from_list = false
	if oInspector.inspectingInstance == id:
		oCamera2D.center_camera_on_point(id.position)


func unselect_all():
	oCreatureList.unselect_all()
	oActionPointHeroGateList.unselect_all()


func _on_ActionPointListWindow_visibility_changed():
	if is_instance_valid(oActionPointListWindow) == false: return
	if oActionPointListWindow.visible == true:
		update_ap_list()
		yield(get_tree(),'idle_frame')
		oActionPointListWindow.rect_position.x = 0
