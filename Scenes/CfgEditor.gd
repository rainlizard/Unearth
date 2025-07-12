extends WindowDialog

onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCfgTabs = Nodelist.list["oCfgTabs"]

onready var main_panel = $CfgTabs/TabRules/MarginContainer/ScrollContainer/MarginContainer
onready var main_container = $CfgTabs/TabRules/MarginContainer/ScrollContainer/MarginContainer/HBoxContainer
onready var revert_button_scene = preload("res://Class/GenericRevertButton.tscn")

var ui_built: bool = false


func _ready():
	oCfgTabs.set_tab_title(0, "Rules")
	
	connect("about_to_show", self, "_on_about_to_show")
	yield(get_tree(),'idle_frame')
	Utils.popup_centered(self)


func _on_about_to_show():
	if not ui_built:
		start()
		ui_built = true


func start():
	build_rules_editor()


func create_darker_border_stylebox():
	var stylebox = StyleBoxFlat.new()
	stylebox.content_margin_left = 12
	stylebox.content_margin_right = 12
	stylebox.content_margin_top = 1
	stylebox.content_margin_bottom = 1
	stylebox.bg_color = Color("#2c2a32")
	stylebox.border_width_left = 1
	stylebox.border_width_top = 1
	stylebox.border_width_right = 1
	stylebox.border_width_bottom = 1
	stylebox.border_color = Color8(44,42,50)*0.80
	stylebox.shadow_size = 0
	stylebox.anti_aliasing = true
	return stylebox


func build_rules_editor():
	for child in main_container.get_children():
		child.queue_free()
	
	var rules_data = oConfigFileManager.DATA_RULES
	if rules_data.empty():
		create_no_data_label()
		return
	
	var left_column = VBoxContainer.new()
	left_column.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	left_column.add_constant_override("separation", 10)
	main_container.add_child(left_column)
	
	var right_column = VBoxContainer.new()
	right_column.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	right_column.add_constant_override("separation", 10)
	main_container.add_child(right_column)
	
	for section_name in rules_data.keys():
		var left_items = count_total_items_in_column(left_column)
		var right_items = count_total_items_in_column(right_column)
		var target_column = left_column if left_items <= right_items else right_column
		create_section_vbox_in_column(target_column, section_name, rules_data[section_name])


func create_no_data_label():
	var label = Label.new()
	label.text = "No rules configuration loaded. Load a map first."
	label.align = Label.ALIGN_CENTER
	setup_script_editor_font(label)
	main_container.add_child(label)


func count_total_items_in_column(column: VBoxContainer) -> int:
	var total_items = 0
	for section_vbox in column.get_children():
		if section_vbox is VBoxContainer:
			total_items += section_vbox.get_child_count() - 1
	return total_items


func create_section_vbox_in_column(parent_column: VBoxContainer, section_name: String, section_data: Dictionary):
	var section_vbox = VBoxContainer.new()
	section_vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	section_vbox.add_constant_override("separation", 0)
	parent_column.add_child(section_vbox)
	
	var header_panel = PanelContainer.new()
	header_panel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	
	var header_label = Label.new()
	header_label.text = "[" + section_name + "]"
	header_label.align = Label.ALIGN_CENTER
	header_label.valign = Label.VALIGN_CENTER
	setup_script_editor_font(header_label)
	header_panel.add_child(header_label)
	
	section_vbox.add_child(header_panel)
	
	var itemIndex = 0
	for key in section_data.keys():
		var value = section_data[key]
		create_config_control(section_vbox, key, value, section_name, itemIndex)
		itemIndex += 1
	
	update_section_header_color(section_name, header_panel)


func create_config_control(parent: VBoxContainer, key: String, value, section_name: String, itemIndex: int):
	var item_panel = PanelContainer.new()
	item_panel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	item_panel.add_stylebox_override("panel", create_darker_border_stylebox())
	item_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	parent.add_child(item_panel)
	
	var control_container = HBoxContainer.new()
	item_panel.add_child(control_container)
	
	var key_label = Label.new()
	key_label.text = key
	key_label.autowrap = true
	key_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	setup_script_editor_font(key_label)
	control_container.add_child(key_label)
	
	var control_node = null
	if value is int:
		control_node = create_spinbox_control(control_container, key, value, section_name)
	elif value is float:
		control_node = create_spinbox_control(control_container, key, value, section_name, true)
	elif value is String:
		control_node = create_line_edit_control(control_container, key, value, section_name)
	elif value is Array:
		control_node = create_array_control(control_container, key, value, section_name)
	else:
		var fallback_label = Label.new()
		fallback_label.text = str(value)
		setup_script_editor_font(fallback_label)
		control_container.add_child(fallback_label)
		control_node = fallback_label
	
	var revert_button = revert_button_scene.instance()
	revert_button.connect("pressed", self, "_on_revert_pressed", [section_name, key])
	control_container.add_child(revert_button)
	
	item_panel.connect("mouse_entered", self, "_on_control_mouse_entered", [key_label, control_node, section_name, key])
	item_panel.connect("mouse_exited", self, "_on_control_mouse_exited", [key_label, control_node, section_name, key])
	
	update_item_color(section_name, key, key_label)
	if control_node != null:
		update_control_color(section_name, key, control_node)
	update_panel_color(section_name, key, item_panel)


func create_spinbox_control(parent: HBoxContainer, key: String, value, section_name: String, is_float: bool = false):
	var spinbox = CustomSpinBox.new()
	spinbox.mouse_filter = Control.MOUSE_FILTER_PASS
	
	if is_float:
		spinbox.step = 1
		spinbox.min_value = -9999999999.0
		spinbox.max_value = 9999999999.0
	else:
		spinbox.step = 1
		spinbox.min_value = -9999999999
		spinbox.max_value = 9999999999
	
	spinbox.rect_min_size.x = 100
	spinbox.value = value
	spinbox.get_line_edit().add_constant_override("minimum_spaces", 0)
	setup_script_editor_font(spinbox)
	
	spinbox.connect("value_changed", self, "_on_value_changed", [section_name, key])
	spinbox.get_line_edit().connect("focus_entered", self, "_on_spinbox_focus_entered", [spinbox])
	spinbox.get_line_edit().connect("focus_exited", self, "_on_spinbox_focus_exited", [spinbox, section_name, key])
	parent.add_child(spinbox)
	return spinbox


func create_line_edit_control(parent: HBoxContainer, key: String, value: String, section_name: String):
	var line_edit = LineEdit.new()
	line_edit.text = value
	line_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	setup_script_editor_font(line_edit)
	line_edit.connect("text_changed", self, "_on_text_changed", [section_name, key])
	parent.add_child(line_edit)
	return line_edit


func create_array_control(parent: HBoxContainer, key: String, value: Array, section_name: String):
	var line_edit = LineEdit.new()
	line_edit.text = str(value)
	line_edit.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	setup_script_editor_font(line_edit)
	line_edit.connect("text_changed", self, "_on_array_text_changed", [section_name, key])
	parent.add_child(line_edit)
	return line_edit


func setup_script_editor_font(control: Control):
	var font = DynamicFont.new()
	var font_data = load("res://Theme/Hack_Regular.ttf")
	font_data.antialiased = true
	font.font_data = font_data
	font.size = Settings.get_setting("script_editor_font_size")
	font.use_mipmaps = true
	font.use_filter = true
	
	if control is Label:
		control.add_font_override("font", font)
	elif control is LineEdit:
		control.add_font_override("font", font)
	elif control is Button:
		control.add_font_override("font", font)
	elif control is SpinBox:
		control.get_line_edit().add_font_override("font", font)


func _on_value_changed(new_value, section_name: String, key: String):
	oConfigFileManager.DATA_RULES[section_name][key] = new_value
	#print("Updated ", section_name, ".", key, " = ", new_value)
	update_colors_after_change(section_name, key)


func _on_text_changed(new_text: String, section_name: String, key: String):
	oConfigFileManager.DATA_RULES[section_name][key] = new_text
	#print("Updated ", section_name, ".", key, " = ", new_text)
	update_colors_after_change(section_name, key)


func _on_array_text_changed(new_text: String, section_name: String, key: String):
	oConfigFileManager.DATA_RULES[section_name][key] = new_text
	#print("Updated ", section_name, ".", key, " = ", new_text)
	update_colors_after_change(section_name, key)


func _on_revert_pressed(section_name: String, key: String):
	if oConfigFileManager.default_data.has(section_name) and oConfigFileManager.default_data[section_name].has(key):
		oConfigFileManager.DATA_RULES[section_name][key] = oConfigFileManager.default_data[section_name][key]
		print("Reverted ", section_name, ".", key, " to default: ", oConfigFileManager.default_data[section_name][key])
		rebuild_ui()
	else:
		print("No default value found for ", section_name, ".", key)


func _on_control_mouse_entered(key_label: Label, control_node: Control, section_name: String, key: String):
	key_label.add_color_override("font_color", Color("#e6d9c1"))
	if control_node != null:
		if control_node is SpinBox:
			control_node.get_line_edit().add_color_override("font_color", Color("#e6d9c1"))
		else:
			control_node.add_color_override("font_color", Color("#e6d9c1"))
	
	var comments = oConfigFileManager.get_comments_for_key("rules.cfg", section_name, key)
	if comments.size() > 0:
		var comment_text = ""
		for comment in comments:
			comment_text += comment + "\n"
		comment_text = comment_text.strip_edges()
		oMessage.quick(comment_text)


func _on_control_mouse_exited(key_label: Label, control_node: Control, section_name: String, key: String):
	update_item_color(section_name, key, key_label)
	if control_node != null:
		if control_node is SpinBox:
			if control_node.get_line_edit().has_focus() == false:
				update_control_color(section_name, key, control_node)
		else:
			update_control_color(section_name, key, control_node)

func _on_spinbox_focus_entered(spinbox: SpinBox):
	spinbox.get_line_edit().add_color_override("font_color", Color("#e6d9c1"))


func _on_spinbox_focus_exited(spinbox: SpinBox, section_name: String, key: String):
	update_control_color(section_name, key, spinbox)


func update_item_color(section_name: String, key: String, label: Label):
	if oConfigFileManager.is_item_different(section_name, key):
		label.add_color_override("font_color", Color("#e6d9c1"))
	else:
		label.add_color_override("font_color", Color8(109,107,127))

func update_control_color(section_name: String, key: String, control: Control):
	if oConfigFileManager.is_item_different(section_name, key):
		if control is SpinBox:
			control.get_line_edit().add_color_override("font_color", Color("#e6d9c1"))
		else:
			control.add_color_override("font_color", Color("#e6d9c1"))
	else:
		if control is SpinBox:
			control.get_line_edit().add_color_override("font_color", Color8(109,107,127))
		else:
			control.add_color_override("font_color", Color8(148,145,159))


func update_panel_color(section_name: String, key: String, item_panel: PanelContainer):
	if oConfigFileManager.is_item_different(section_name, key):
		item_panel.modulate = Color(1.4, 1.4, 1.7, 1.0)
	else:
		item_panel.modulate = Color(1, 1, 1, 1)


func update_section_header_color(section_name: String, header_panel: PanelContainer):
	var header_label = header_panel.get_child(0)
	if oConfigFileManager.is_section_different(section_name):
		header_label.add_color_override("font_color", Color.white)
		header_panel.modulate = Color(1.4, 1.4, 1.7, 1.0)
	else:
		header_label.add_color_override("font_color", Color("#ff9ea3"))
		header_panel.modulate = Color(1, 1, 1, 1)


func update_colors_after_change(section_name: String, key: String):
	yield(get_tree(), "idle_frame")
	update_specific_item_colors(section_name, key)
	update_specific_section_header_color(section_name)


func update_specific_item_colors(section_name: String, key: String):
	var section_vbox = find_section_vbox(section_name)
	if section_vbox == null:
		return
	
	for child in section_vbox.get_children():
		if child is PanelContainer and child.get_child_count() > 0:
			var control_container = child.get_child(0)
			if control_container is HBoxContainer and control_container.get_child_count() > 0:
				var key_label = control_container.get_child(0)
				if key_label is Label and key_label.text == key:
					update_item_color(section_name, key, key_label)
					if control_container.get_child_count() > 1:
						var control_node = control_container.get_child(1)
						update_control_color(section_name, key, control_node)
					update_panel_color(section_name, key, child)
					break


func update_specific_section_header_color(section_name: String):
	var section_vbox = find_section_vbox(section_name)
	if section_vbox == null:
		return
	
	if section_vbox.get_child_count() > 0:
		var header_panel = section_vbox.get_child(0)
		if header_panel is PanelContainer:
			update_section_header_color(section_name, header_panel)


func find_section_vbox(section_name: String) -> VBoxContainer:
	for column in main_container.get_children():
		if column is VBoxContainer:
			for child in column.get_children():
				if child is VBoxContainer and child.get_child_count() > 0:
					var header_panel = child.get_child(0)
					if header_panel is PanelContainer and header_panel.get_child_count() > 0:
						var header_label = header_panel.get_child(0)
						if header_label is Label and header_label.text == "[" + section_name + "]":
							return child
	return null


func rebuild_ui():
	build_rules_editor()
