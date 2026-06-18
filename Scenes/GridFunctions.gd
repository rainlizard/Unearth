extends Node

func _ready():
	get_viewport().connect("size_changed", self, "_on_window_maximized")

func _on_window_maximized():
	yield(get_tree(),'idle_frame')
	var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
	var oPickThingWindow = Nodelist.list["oPickThingWindow"]
	if oPickSlabWindow.visible:
		_on_GridWindow_resized(oPickSlabWindow)
	if oPickThingWindow.visible:
		_on_GridWindow_resized(oPickThingWindow)

func _on_GridWindow_visibility_changed(callingNode): # Initial load for correct grid arrangement
	if callingNode.visible == true:
		for i in 2:
			yield(get_tree(),'idle_frame')
			_on_GridWindow_resized(callingNode)

func _on_GridWindow_gui_input(event, callingNode):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			callingNode.raise()



func _on_GridWindow_resized(callingNode):
	var oGridContainer = callingNode.current_grid_container()
	if oGridContainer == null: return
	
	var scrollContainer = oGridContainer.get_parent()
	var tabControl = scrollContainer.get_parent()
	var panelStyle = tabControl.get_stylebox("panel")
	tabControl.rect_position = Vector2.ZERO
	tabControl.rect_size = tabControl.get_parent().rect_size
	scrollContainer.rect_position = Vector2(panelStyle.get_margin(MARGIN_LEFT), panelStyle.get_margin(MARGIN_TOP))
	scrollContainer.rect_size = tabControl.rect_size - panelStyle.get_minimum_size()
	scrollContainer.notification(Container.NOTIFICATION_SORT_CHILDREN)
	
	var hseparation = oGridContainer.get_constant("hseparation")
	var vseparation = oGridContainer.get_constant("vseparation")
	var itemWidth = callingNode.grid_item_size.x * callingNode.grid_window_scale
	var itemHeight = callingNode.grid_item_size.y * callingNode.grid_window_scale
	var availableWidth = scrollContainer.rect_size.x
	var availableHeight = scrollContainer.rect_size.y
	var maxWidth = floor((availableWidth + hseparation) / (itemWidth + hseparation))
	var maxHeight = floor((availableHeight + vseparation) / (itemHeight + vseparation))
	var itemCount = oGridContainer.get_child_count()
	if itemCount == 0 or maxWidth <= 0 or maxHeight <= 0: return
	var maxColumns = int(min(maxWidth, itemCount))
	var windowShape = float(maxWidth) / float(maxHeight)
	var columnCount = int(round(sqrt(float(itemCount) * windowShape)))
	columnCount = int(clamp(columnCount, 1, maxColumns))
	var rowCount = ceil(float(itemCount) / float(columnCount))
	var gridHeight = (rowCount * itemHeight) + (max(rowCount - 1, 0) * vseparation)
	if gridHeight > availableHeight:
		var scrollbarWidth = scrollContainer.get_v_scrollbar().rect_size.x
		if scrollbarWidth <= 0:
			scrollbarWidth = scrollContainer.get_v_scrollbar().get_combined_minimum_size().x
		availableWidth -= scrollbarWidth
		maxWidth = floor((availableWidth + hseparation) / (itemWidth + hseparation))
		if maxWidth <= 0: return
		maxColumns = int(min(maxWidth, itemCount))
		windowShape = float(maxWidth) / float(maxHeight)
		columnCount = int(round(sqrt(float(itemCount) * windowShape)))
	oGridContainer.set_columns(int(clamp(columnCount, 1, maxColumns)))
	oGridContainer.notification(Container.NOTIFICATION_SORT_CHILDREN)

func _on_tab_changed(newTab, callingNode):
	callingNode.update_scale(callingNode.grid_window_scale)
	
	# Make oSelectedRect visible if it's in the tab you switched to, otherwise make it invisible
	callingNode.oSelectedRect.visible = false
	if callingNode.oSelectedRect.boundToItem != null:
		for id in callingNode.current_grid_container().get_children():
			if callingNode.oSelectedRect.boundToItem == id:
				callingNode.oSelectedRect.visible = true
