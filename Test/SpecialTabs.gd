extends VBoxContainer
class_name SpecialTabContainer

onready var container = self#$"MarginContainer"
onready var tabSystem = $"TopTabsSection/Tabs"


func _ready():
	tabSystem.rect_min_size.y = 24
	for i in get_child_tabs():
		tabSystem.add_tab(i.name)
	
	show_only_tab(0)

func get_child_tabs():
	var array = container.get_children()
	array.erase(0) # remove "TopTabsSection" from array of children
	return array

func _on_Tabs_tab_changed(tab):
	show_only_tab(tab)

func show_only_tab(tab):
	tabSystem.ensure_tab_visible(tab) # Put this before setting "current_tab", it has a different effect
	tabSystem.current_tab = tab
	
	for i in get_child_tabs():
		if i.get_index() == tabSystem.current_tab:
			i.visible = true
		else:
			i.visible = false

func _on_Tabs_reposition_active_tab_request(idx_to):
	container.move_child(container.get_child(tabSystem.current_tab), idx_to+1)


#func set_tab_title_names():
#	tabSystem.disconnect("resized",self,"_on_Tabs_resized")
#
#	for i in tabDictionary:
#		var node = tabDictionary[i]
#		if is_instance_valid(node):
#			print(node.name)
#			tabSystem.set_tab_title(i, node.name)
#	yield(get_tree(),'idle_frame')
#
#	while true:
#		if tabSystem.get_offset_buttons_visible() == true:
#			var tabWithLargestWidth = get_widest_tab_title()
#
#			var titleName = tabSystem.get_tab_title(tabWithLargestWidth)
#
#			titleName.erase(titleName.length()-1,1)
#
#			tabSystem.set_tab_title(tabWithLargestWidth, titleName)
#
#			yield(get_tree(),'idle_frame')
#		else:
#			print('break')
#			break
#	tabSystem.connect("resized",self,"_on_Tabs_resized")

#func get_widest_tab_title():
#	var tabWithLargestWidth = 0
#	for i in tabSystem.get_tab_count():
#		if tabSystem.get_tab_rect(tabWithLargestWidth).size.x < tabSystem.get_tab_rect(i).size.x:
#			tabWithLargestWidth = i
#	return tabWithLargestWidth

#func _on_Tabs_resized():
#	set_tab_title_names()


func _on_TextureButtonLeft_pressed():
	var gotoTab = tabSystem.current_tab-1
	if gotoTab == -1:
		gotoTab = tabSystem.get_tab_count()-1
	show_only_tab(gotoTab)


func _on_TextureButtonRight_pressed():
	var gotoTab = tabSystem.current_tab+1
	if gotoTab == tabSystem.get_tab_count():
		gotoTab = 0
	show_only_tab(gotoTab)
