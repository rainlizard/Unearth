extends VBoxContainer
onready var oCfgEditor = Nodelist.list["oCfgEditor"]
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]

func create_standard_config_control(parent: VBoxContainer, key: String, value, section_name: String, itemIndex: int, revert_button_scene, editor_context):
	var item_panel = PanelContainer.new()
	item_panel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	item_panel.add_stylebox_override("panel", oCfgEditor.create_darker_border_stylebox())
	item_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	parent.add_child(item_panel)
	
	var control_container = HBoxContainer.new()
	item_panel.add_child(control_container)
	
	var key_label = Label.new()
	key_label.text = key
	key_label.autowrap = true
	key_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	editor_context.setup_script_editor_font(key_label)
	control_container.add_child(key_label)
	
	var control_node = null
	if value is int:
		control_node = create_spinbox_control(control_container, key, value, section_name, editor_context)
	elif value is float:
		control_node = create_spinbox_control(control_container, key, value, section_name, editor_context, true)
	elif value is String:
		control_node = create_line_edit_control(control_container, key, value, section_name, editor_context)
	elif value is Array:
		control_node = create_array_control(control_container, key, value, section_name, editor_context)
	else:
		var fallback_label = Label.new()
		fallback_label.text = str(value)
		editor_context.setup_script_editor_font(fallback_label)
		control_container.add_child(fallback_label)
		control_node = fallback_label
	
	var revert_button = revert_button_scene.instance()
	revert_button.connect("pressed", editor_context, "_on_revert_pressed", [section_name, key])
	control_container.add_child(revert_button)
	
	item_panel.connect("mouse_entered", editor_context, "_on_control_mouse_entered", [key_label, control_node, section_name, key])
	item_panel.connect("mouse_exited", editor_context, "_on_control_mouse_exited", [key_label, control_node, section_name, key])
	
	if not editor_context.item_panels.has(section_name):
		editor_context.item_panels[section_name] = {}
	editor_context.item_panels[section_name][key] = {
		"panel": item_panel,
		"label": key_label,
		"control": control_node
	}
	
	editor_context.update_item_color(section_name, key, key_label)
	if control_node != null:
		editor_context.update_control_color(section_name, key, control_node)
	editor_context.update_panel_color(section_name, key, item_panel)

func create_spinbox_control(parent: HBoxContainer, key: String, value, section_name: String, editor_context, is_float: bool = false):
	var spinbox = CustomSpinBox.new()
	spinbox.mouse_filter = Control.MOUSE_FILTER_PASS
	spinbox.step = 1
	var limit = 9999999999.0 if is_float else 9999999999
	spinbox.min_value = -limit
	spinbox.max_value = limit
	spinbox.rect_min_size.x = 100
	spinbox.value = value
	spinbox.get_line_edit().add_constant_override("minimum_spaces", 0)
	editor_context.setup_script_editor_font(spinbox)
	spinbox.connect("value_changed", editor_context, "_on_value_changed", [section_name, key])
	spinbox.get_line_edit().connect("focus_entered", editor_context, "_on_spinbox_focus_entered", [spinbox])
	spinbox.get_line_edit().connect("focus_exited", editor_context, "_on_spinbox_focus_exited", [spinbox, section_name, key])
	parent.add_child(spinbox)
	return spinbox

func create_line_edit_control(parent: HBoxContainer, key: String, value: String, section_name: String, editor_context):
	var line_edit = LineEdit.new()
	line_edit.text = value
	line_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	editor_context.setup_script_editor_font(line_edit)
	line_edit.connect("text_changed", editor_context, "_on_text_changed", [section_name, key])
	parent.add_child(line_edit)
	return line_edit

func create_array_control(parent: HBoxContainer, key: String, value: Array, section_name: String, editor_context):
	var line_edit = LineEdit.new()
	line_edit.text = str(value)
	line_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	editor_context.setup_script_editor_font(line_edit)
	line_edit.connect("text_changed", editor_context, "_on_array_text_changed", [section_name, key])
	parent.add_child(line_edit)
	return line_edit


func create_popup_selection(title: String, items: Array, callback: FuncRef, editor_context):
	var popup_selection = WindowDialog.new()
	popup_selection.window_title = title
	popup_selection.rect_size = Vector2(700, 400)
	popup_selection.popup_exclusive = true
	
	var container = VBoxContainer.new()
	container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	container.add_constant_override("separation", 5)
	container.add_constant_override("margin_left", 10)
	container.add_constant_override("margin_right", 10)
	container.add_constant_override("margin_top", 10)
	container.add_constant_override("margin_bottom", 10)
	popup_selection.add_child(container)
	
	var scroll_container = ScrollContainer.new()
	scroll_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	scroll_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	scroll_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	scroll_container.rect_min_size.y = 0
	container.add_child(scroll_container)
	
	var center_container = CenterContainer.new()
	center_container.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	center_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	scroll_container.add_child(center_container)
	
	var item_container = GridContainer.new()
	item_container.columns = 3
	item_container.add_constant_override("hseparation", 20)
	item_container.add_constant_override("vseparation", 2)
	center_container.add_child(item_container)
	
	editor_context.current_selection_callback = callback
	
	for item in items:
		var link_button = LinkButton.new()
		link_button.text = item
		link_button.rect_min_size.x = 0
		editor_context.setup_script_editor_font(link_button)
		link_button.connect("pressed", editor_context, "_on_selection_item_pressed", [item])
		item_container.add_child(link_button)
	
	popup_selection.connect("popup_hide", editor_context, "_on_popup_selection_closed")
	editor_context.add_child(popup_selection)
	editor_context.popup_selection = popup_selection
	popup_selection.popup_centered()


func check_default_value_exists(section_name: String, array_index: int) -> bool:
	var default_section = oCfgEditor.oConfigFileManager.default_data.get(section_name)
	return default_section is Array and array_index >= 0 and array_index < default_section.size()


func check_item_difference(section_name: String, array_index: int) -> bool:
	if not check_default_value_exists(section_name, array_index):
		return true
	var current_section = oCfgEditor.oConfigFileManager.DATA_RULES[section_name]
	var default_section = oCfgEditor.oConfigFileManager.default_data[section_name]
	if not (current_section is Array) or array_index >= current_section.size():
		return true
	return current_section[array_index] != default_section[array_index]


func perform_item_revert(section_name: String, array_index: int) -> bool:
	var default_section = oCfgEditor.oConfigFileManager.default_data.get(section_name)
	var current_section = oCfgEditor.oConfigFileManager.DATA_RULES.get(section_name)
	if not default_section or not (default_section is Array and current_section is Array):
		print("No valid default data for ", section_name)
		return false
	if array_index < 0 or array_index >= default_section.size() or array_index >= current_section.size():
		print("Invalid array index for ", section_name, ".", array_index)
		return false
	current_section[array_index] = default_section[array_index].duplicate()
	print("Reverted ", section_name, ".", array_index, " to default")
	return true


func handle_label_mouse_entered(label: Label, tooltip_text: String = ""):
	label.add_color_override("font_color", oCfgEditor.UI_TEXT_HOVER)
	if tooltip_text != "" and oCustomTooltip:
		oCustomTooltip.set_text(tooltip_text)


func handle_label_mouse_exited(label: Label, array_index: int, section_name: String):
	update_label_color(array_index, label, section_name)
	if oCustomTooltip:
		oCustomTooltip.set_text("")


func update_label_color(array_index: int, label: Label, section_name: String):
	var is_different = check_item_difference(section_name, array_index)
	if is_different:
		label.add_color_override("font_color", oCfgEditor.UI_TEXT_MODIFIED)
	else:
		label.add_color_override("font_color", oCfgEditor.UI_TEXT_NORMAL)


func create_selection_popup(title: String, items: Array, callback: FuncRef, array_index: int):
	var wrapped_callback = funcref(oCfgEditor, "_on_link_button_pressed")
	wrapped_callback.set_meta("title", title)
	wrapped_callback.set_meta("items", items)
	wrapped_callback.set_meta("callback", callback)
	wrapped_callback.set_meta("metadata", {"array_index": array_index})
	create_popup_selection(title, items, wrapped_callback, oCfgEditor)
