extends Node

func _on_GridWindow_visibility_changed(callingNode): # Initial load for correct grid arrangement
	if callingNode.visible == true:
		_on_GridWindow_resized(callingNode)

func _on_GridWindow_gui_input(event, callingNode):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			callingNode.raise()

func _on_GridWindow_item_rect_changed(callingNode):
	if Settings.haveInitializedAllSettings == false: return # Necessary because otherwise this signal is firing too early. Settings haven't loaded the values from the cfg file yet.
	match callingNode.name:
		"PropertiesWindow":
			Settings.set_setting("details_viewer_window_position", callingNode.rect_position)
		"PickSlabWindow":
			Settings.set_setting("slab_window_size", callingNode.rect_size)
			Settings.set_setting("slab_window_position", callingNode.rect_position)
		"SlabStyleWindow":
			Settings.set_setting("slab_style_window_size", callingNode.rect_size)
			Settings.set_setting("slab_style_window_position", callingNode.rect_position)
		"PickThingWindow":
			Settings.set_setting("thing_window_size", callingNode.rect_size)
			Settings.set_setting("thing_window_position", callingNode.rect_position)

func _on_GridWindow_resized(callingNode):
	var oGridContainer = callingNode.currentGridContainer()
	if oGridContainer == null: return
	
	var maxWidth
	var maxHeight
	match callingNode.name:
		"PickSlabWindow":
			maxWidth = floor(oGridContainer.get_parent().get_parent().rect_size.x/(callingNode.grid_item_size.x*callingNode.grid_window_scale))
			maxHeight = floor(oGridContainer.get_parent().get_parent().rect_size.y/(callingNode.grid_item_size.y*callingNode.grid_window_scale))
		"PickThingWindow":
			maxWidth = floor(oGridContainer.get_parent().get_parent().rect_size.x/(callingNode.grid_item_size.x*callingNode.grid_window_scale))
			maxHeight = floor(oGridContainer.get_parent().get_parent().rect_size.y/(callingNode.grid_item_size.y*callingNode.grid_window_scale))
		"SlabStyleWindow":
			maxWidth = floor(oGridContainer.get_parent().rect_size.x/(callingNode.grid_item_size.x*callingNode.grid_window_scale))
			maxHeight = floor(oGridContainer.get_parent().rect_size.y/(callingNode.grid_item_size.y*callingNode.grid_window_scale))
	if maxWidth > 0: oGridContainer.set_columns(maxWidth)
	# If the window is wider than tall, then fit the grid items within maxHeight
	if maxWidth > maxHeight and maxHeight > 0:
		var itemCount = oGridContainer.get_child_count()
		if itemCount > 0:
			oGridContainer.set_columns(ceil(float(itemCount)/float(maxHeight)))


func _on_tab_changed(newTab, callingNode):
	callingNode.update_scale(callingNode.grid_window_scale)
	
	# Make oSelectedRect visible if it's in the tab you switched to, otherwise make it invisible
	callingNode.oSelectedRect.visible = false
	if callingNode.oSelectedRect.boundToItem != null:
		for id in callingNode.currentGridContainer().get_children():
			if callingNode.oSelectedRect.boundToItem == id:
				callingNode.oSelectedRect.visible = true
	
	_on_GridWindow_resized(callingNode)
