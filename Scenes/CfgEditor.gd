extends WindowDialog

# Color Constants
const UI_BACKGROUND = Color("#2c2a32")
const UI_BORDER = Color8(44, 42, 50)
const UI_TEXT_NORMAL = Color8(145, 142, 169)
const UI_TEXT_MODIFIED = Color.white
const UI_TEXT_HOVER = Color8(255, 217, 193)
const UI_TEXT_CONTROL_ALTERNATE = Color8(148, 145, 159)
const UI_HEADER_NORMAL = Color("#ff9ea3")
const UI_PANEL_NORMAL = Color(1, 1, 1, 1)
const UI_PANEL_MODIFIED = Color(1.4, 1.4, 1.7, 1.0)

onready var oTabRules = Nodelist.list["oTabRules"]
onready var oRulesSacrifices = Nodelist.list["oRulesSacrifices"]
onready var oRulesResearch = Nodelist.list["oRulesResearch"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oCfgTabs = Nodelist.list["oCfgTabs"]
onready var oLabelCfgComment = Nodelist.list["oLabelCfgComment"]
onready var oPanelCfgComment = Nodelist.list["oPanelCfgComment"]
onready var oCurrentlyOpenRules = Nodelist.list["oCurrentlyOpenRules"]

onready var main_panel = $CfgTabs/TabRules/MarginContainer/ScrollContainer/VBoxContainer/MarginContainer
onready var main_container = $CfgTabs/TabRules/MarginContainer/ScrollContainer/VBoxContainer/MarginContainer/HBoxContainer
onready var scroll_container = $CfgTabs/TabRules/MarginContainer/ScrollContainer
onready var revert_button_scene = preload("res://Class/GenericRevertButton.tscn")

var font = DynamicFont.new()
var control_references: Dictionary = {}
var section_vboxes: Dictionary = {}
var item_panels: Dictionary = {}
var popup_selection: WindowDialog = null
var current_selection_callback: FuncRef = null

func _ready():
	oCfgTabs.set_tab_title(0, "Rules")
	oPanelCfgComment.visible = false
	oPanelCfgComment.set_v_size_flags(Control.SIZE_SHRINK_END)
	
	connect("about_to_show", self, "_on_about_to_show")
	oPanelCfgComment.connect("mouse_entered", self, "_on_panel_cfg_comment_mouse_entered")
	oConfigFileManager.connect("config_file_status_changed", self, "_on_config_status_changed")
	
	yield(get_tree(),'idle_frame')
	Utils.popup_centered(self)


func _on_about_to_show():
	print("???")
	setup_font()
	start()

func setup_font():
	var font_data = load("res://Theme/Hack_Regular.ttf")
	font_data.antialiased = true
	font.font_data = font_data
	font.size = Settings.get_setting("script_editor_font_size")
	font.use_mipmaps = true
	font.use_filter = true


func create_darker_border_stylebox():
	var stylebox = StyleBoxFlat.new()
	stylebox.content_margin_left = 12
	stylebox.content_margin_right = 12
	stylebox.content_margin_top = 1
	stylebox.content_margin_bottom = 1
	stylebox.bg_color = UI_BACKGROUND
	stylebox.border_width_left = 1
	stylebox.border_width_top = 1
	stylebox.border_width_right = 1
	stylebox.border_width_bottom = 1
	stylebox.border_color = UI_BORDER*0.80
	stylebox.shadow_size = 0
	stylebox.anti_aliasing = true
	return stylebox


func setup_script_editor_font(control: Control):
	if control is Label:
		control.add_font_override("font", font)
	elif control is LineEdit:
		control.add_font_override("font", font)
	elif control is Button:
		control.add_font_override("font", font)
	elif control is LinkButton:
		control.add_font_override("font", font)
	elif control is SpinBox:
		control.get_line_edit().add_font_override("font", font)


func start():
	build_rules_editor()
	setup_script_editor_font(oLabelCfgComment)
	update_rules_paths_label()


func build_rules_editor():
	for child in main_container.get_children():
		child.queue_free()
	
	var rules_data = oConfigFileManager.current_data.get("rules.cfg", {})
	if rules_data.empty():
		create_no_data_label()
		return
	
	var main_vbox = VBoxContainer.new()
	main_vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	main_vbox.add_constant_override("separation", 10)
	main_container.add_child(main_vbox)
	
	
	var columns_container = HBoxContainer.new()
	columns_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	columns_container.add_constant_override("separation", 10)
	main_vbox.add_child(columns_container)
	
	var left_column = VBoxContainer.new()
	left_column.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	left_column.add_constant_override("separation", 10)
	columns_container.add_child(left_column)
	
	var right_column = VBoxContainer.new()
	right_column.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	right_column.add_constant_override("separation", 10)
	columns_container.add_child(right_column)
	
	for section_name in rules_data.keys():
		if section_name == "research":
			create_section_vbox_in_column(right_column, section_name, rules_data[section_name])
		elif section_name == "sacrifices":
			create_section_vbox_in_column(right_column, section_name, rules_data[section_name])
		else:
			create_section_vbox_in_column(left_column, section_name, rules_data[section_name])


func create_no_data_label():
	var label = Label.new()
	label.text = "No rules configuration loaded. Load a map first."
	label.align = Label.ALIGN_CENTER
	setup_script_editor_font(label)
	main_container.add_child(label)



func create_section_vbox_in_column(parent_column: VBoxContainer, section_name: String, section_data):
	var section_vbox = create_section_container(parent_column, section_name)
	var header_panel = create_section_header(section_vbox, section_name)
	populate_section_items(section_vbox, section_data, section_name)
	create_section_add_button(section_vbox, section_name)
	update_section_header_color(section_name, header_panel)


func create_section_container(parent: VBoxContainer, section_name: String) -> VBoxContainer:
	var section_vbox = VBoxContainer.new()
	section_vbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	section_vbox.add_constant_override("separation", 0)
	parent.add_child(section_vbox)
	section_vboxes[section_name] = section_vbox
	return section_vbox


func create_section_header(section_vbox: VBoxContainer, section_name: String) -> PanelContainer:
	var header_panel = PanelContainer.new()
	header_panel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	var header_container = HBoxContainer.new()
	header_panel.add_child(header_container)
	var header_label = Label.new()
	header_label.text = "[" + section_name + "]"
	header_label.align = Label.ALIGN_CENTER
	header_label.valign = Label.VALIGN_CENTER
	header_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	setup_script_editor_font(header_label)
	header_container.add_child(header_label)
	var section_revert_button = revert_button_scene.instance()
	section_revert_button.connect("pressed", self, "_on_revert_section_pressed", [section_name])
	header_container.add_child(section_revert_button)
	section_vbox.add_child(header_panel)
	return header_panel


func populate_section_items(section_vbox: VBoxContainer, section_data, section_name: String):
	var itemIndex = 0
	if section_data is Array:
		for i in range(section_data.size()):
			create_config_control(section_vbox, i, section_data[i], section_name, itemIndex)
			itemIndex += 1
	else:
		for key in section_data.keys():
			create_config_control(section_vbox, key, section_data[key], section_name, itemIndex)
			itemIndex += 1


func create_section_add_button(section_vbox: VBoxContainer, section_name: String):
	if section_name == "sacrifices" or section_name == "research":
		var button_container = HBoxContainer.new()
		var add_button = Button.new()
		add_button.text = "Add new"
		add_button.rect_min_size.x = 120
		add_button.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
		setup_script_editor_font(add_button)
		button_container.add_child(add_button)
		button_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button_container.alignment = BoxContainer.ALIGN_CENTER
		section_vbox.add_child(button_container)
		if section_name == "sacrifices":
			add_button.connect("pressed", oRulesSacrifices, "_on_add_sacrifice_pressed", [section_name])
			oRulesSacrifices.add_button = add_button
		else:
			add_button.connect("pressed", oRulesResearch, "_on_add_research_pressed", [section_name])
			oRulesResearch.add_button = add_button


func create_config_control(parent: VBoxContainer, key, value, section_name: String, itemIndex: int):
	if section_name == "sacrifices":
		oRulesSacrifices.create_sacrifice_control(parent, key, value, section_name, itemIndex, revert_button_scene, self)
	elif section_name == "research":
		oRulesResearch.create_research_control(parent, key, value, section_name, itemIndex, revert_button_scene, self)
	else:
		oTabRules.create_standard_config_control(parent, str(key), value, section_name, itemIndex, revert_button_scene, self)


func _on_value_changed(new_value, section_name: String, key: String):
	update_data_value(section_name, key, new_value)


func _on_text_changed(new_text: String, section_name: String, key: String):
	update_data_value(section_name, key, new_text)


func _on_array_text_changed(new_text: String, section_name: String, key: String):
	update_data_value(section_name, key, new_text)


func update_data_value(section_name: String, key: String, value):
	oConfigFileManager.current_data["rules.cfg"][section_name][key] = value
	update_colors_after_change(section_name, key)


func _on_revert_pressed(section_name: String, key: String):
	if perform_single_revert(section_name, key):
		rebuild_ui()


func perform_single_revert(section_name: String, key: String) -> bool:
	if not oConfigFileManager.default_data.has("rules.cfg"):
		print("No default rules.cfg data found")
		return false
	var default_section = oConfigFileManager.default_data["rules.cfg"].get(section_name)
	if default_section and default_section.has(key):
		oConfigFileManager.current_data["rules.cfg"][section_name][key] = default_section[key]
		print("Reverted ", section_name, ".", key, " to default")
		return true
	print("No default value found for ", section_name, ".", key)
	return false


func _on_revert_section_pressed(section_name: String):
	if oConfigFileManager.default_data.has("rules.cfg") and oConfigFileManager.default_data["rules.cfg"].has(section_name):
		oConfigFileManager.current_data["rules.cfg"][section_name] = oConfigFileManager.default_data["rules.cfg"][section_name].duplicate(true)
		print("Reverted entire section [", section_name, "] to defaults")
		update_section_after_revert(section_name)
	else:
		print("No default data found for section [", section_name, "]")


func update_section_after_revert(section_name: String):
	if section_name in ["sacrifices", "research"]:
		rebuild_specific_section(section_name)
	else:
		update_all_standard_controls(section_name)
		update_specific_section_header_color(section_name)


func rebuild_specific_section(section_name: String):
	var section_vbox = find_section_vbox(section_name)
	if section_vbox == null:
		return
	
	# Clear old control references for this section
	if section_name == "sacrifices":
		oRulesSacrifices.control_references.clear()
	elif section_name == "research":
		oRulesResearch.control_references.clear()
	
	# Clear old item panels for this section
	if item_panels.has(section_name):
		item_panels[section_name].clear()
	
	# Remove all children except the header (first child)
	var children_to_remove = []
	for i in range(1, section_vbox.get_child_count()):
		children_to_remove.append(section_vbox.get_child(i))
	
	for child in children_to_remove:
		section_vbox.remove_child(child)
		child.queue_free()
	
	# Rebuild the section content
	var section_data = oConfigFileManager.current_data["rules.cfg"][section_name]
	var itemIndex = 0
	
	if section_data is Array:
		for i in range(section_data.size()):
			var value = section_data[i]
			create_config_control(section_vbox, i, value, section_name, itemIndex)
			itemIndex += 1
	else:
		for key in section_data.keys():
			var value = section_data[key]
			create_config_control(section_vbox, key, value, section_name, itemIndex)
			itemIndex += 1
	
	# Add the "Add new" button for sacrifices/research
	if section_name == "sacrifices":
		var button_container = HBoxContainer.new()
		var add_button = Button.new()
		add_button.text = "Add new"
		add_button.hint_tooltip = "Add new sacrifice"
		add_button.rect_min_size.x = 120
		add_button.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
		setup_script_editor_font(add_button)
		add_button.connect("pressed", oRulesSacrifices, "_on_add_sacrifice_pressed", [section_name])
		button_container.add_child(add_button)
		button_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button_container.alignment = BoxContainer.ALIGN_CENTER
		section_vbox.add_child(button_container)
		oRulesSacrifices.add_button = add_button
	elif section_name == "research":
		var button_container = HBoxContainer.new()
		var add_button = Button.new()
		add_button.text = "Add new"
		add_button.hint_tooltip = "Add new research"
		add_button.rect_min_size.x = 120
		add_button.set_h_size_flags(Control.SIZE_SHRINK_CENTER)
		setup_script_editor_font(add_button)
		add_button.connect("pressed", oRulesResearch, "_on_add_research_pressed", [section_name])
		button_container.add_child(add_button)
		button_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button_container.alignment = BoxContainer.ALIGN_CENTER
		section_vbox.add_child(button_container)
		oRulesResearch.add_button = add_button
	
	# Update section header color
	update_specific_section_header_color(section_name)


func update_all_standard_controls(section_name: String):
	if not item_panels.has(section_name):
		return
	
	var section_data = oConfigFileManager.current_data["rules.cfg"][section_name]
	for key in item_panels[section_name]:
		var item_data = item_panels[section_name][key]
		var control = item_data["control"]
		
		if section_data.has(key):
			var value = section_data[key]
			if control is SpinBox:
				control.value = value
			elif control is LineEdit:
				control.text = str(value)
		
		update_specific_item_colors(section_name, key)


func _on_control_mouse_entered(key_label: Label, control_node: Control, section_name: String, key: String):
	key_label.add_color_override("font_color", UI_TEXT_HOVER)
	if control_node != null:
		if control_node is SpinBox:
			control_node.get_line_edit().add_color_override("font_color", UI_TEXT_HOVER)
		else:
			control_node.add_color_override("font_color", UI_TEXT_HOVER)
	
	yield(get_tree(),'idle_frame')
	
	var comments = oConfigFileManager.get_comments_for_key("rules.cfg", section_name, key)
	if comments.size() > 0:
		var comment_text = ""
		for comment in comments:
			comment_text += comment + "\n"
		comment_text = comment_text.strip_edges()
		oPanelCfgComment.visible = true
		oLabelCfgComment.text = comment_text
	else:
		oPanelCfgComment.visible = false
		oLabelCfgComment.text = ""


func _on_control_mouse_exited(key_label: Label, control_node: Control, section_name: String, key: String):
	update_item_color(section_name, key, key_label)
	if control_node != null:
		if control_node is SpinBox:
			if control_node.get_line_edit().has_focus() == false:
				update_control_color(section_name, key, control_node)
		else:
			update_control_color(section_name, key, control_node)

func _on_spinbox_focus_entered(spinbox: SpinBox):
	spinbox.get_line_edit().add_color_override("font_color", UI_TEXT_HOVER)


func _on_spinbox_focus_exited(spinbox: SpinBox, section_name: String, key: String):
	update_control_color(section_name, key, spinbox)


func update_item_color(section_name: String, key, label: Label):
	var is_different = check_item_difference(section_name, key)
	var color = UI_TEXT_MODIFIED if is_different else UI_TEXT_NORMAL
	label.add_color_override("font_color", color)

func update_control_color(section_name: String, key, control: Control):
	var is_different = check_item_difference(section_name, key)
	var color = UI_TEXT_MODIFIED if is_different else UI_TEXT_CONTROL_ALTERNATE
	if control is SpinBox:
		control.get_line_edit().add_color_override("font_color", color)
	else:
		control.add_color_override("font_color", color)


func update_panel_color(section_name: String, key, item_panel: PanelContainer):
	var is_modified = check_item_difference(section_name, key)
	item_panel.modulate = UI_PANEL_MODIFIED if is_modified else UI_PANEL_NORMAL


func check_item_difference(section_name: String, key) -> bool:
	if section_name == "sacrifices" and key is int:
		return oRulesSacrifices.is_sacrifice_item_different(key)
	elif section_name == "research":
		if key is String and key.is_valid_integer():
			return oRulesResearch.is_research_item_different(int(key))
		elif key is int:
			return oRulesResearch.is_research_item_different(key)
	elif key is String:
		return oConfigFileManager.is_item_different(section_name, key)
	return oConfigFileManager.is_section_different(section_name)


func update_section_header_color(section_name: String, header_panel: PanelContainer):
	var header_container = header_panel.get_child(0)
	var header_label = header_container.get_child(0)
	if oConfigFileManager.is_section_different(section_name):
		header_label.add_color_override("font_color", UI_TEXT_MODIFIED)
		header_panel.modulate = UI_PANEL_MODIFIED
	else:
		header_label.add_color_override("font_color", UI_HEADER_NORMAL)
		header_panel.modulate = UI_PANEL_NORMAL


func update_colors_after_change(section_name: String, key):
	yield(get_tree(), "idle_frame")
	update_specific_item_colors(section_name, key)
	update_specific_section_header_color(section_name)
	if section_name == "sacrifices":
		oRulesSacrifices.update_all_sacrifice_labels_color()
	elif section_name == "research":
		oRulesResearch.update_all_research_labels_color()


func update_specific_item_colors(section_name: String, key):
	if not item_panels.has(section_name) or not item_panels[section_name].has(key):
		return
	
	var item_data = item_panels[section_name][key]
	var panel = item_data["panel"]
	var label = item_data["label"]
	var control = item_data["control"]
	
	update_item_color(section_name, key, label)
	if control != null:
		update_control_color(section_name, key, control)
	update_panel_color(section_name, key, panel)


func update_specific_section_header_color(section_name: String):
	var section_vbox = find_section_vbox(section_name)
	if section_vbox == null:
		return
	
	if section_vbox.get_child_count() > 0:
		var header_panel = section_vbox.get_child(0)
		if header_panel is PanelContainer:
			update_section_header_color(section_name, header_panel)


func ensure_add_button_visible(add_button: Button):
	yield(get_tree(), 'idle_frame')
	if add_button:
		scroll_container.ensure_control_visible(add_button)


func find_section_vbox(section_name: String) -> VBoxContainer:
	return section_vboxes.get(section_name, null)


func _on_panel_cfg_comment_mouse_entered():
	if oPanelCfgComment.get_v_size_flags() == Control.SIZE_SHRINK_END:
		oPanelCfgComment.set_v_size_flags(0)
	else:
		oPanelCfgComment.set_v_size_flags(Control.SIZE_SHRINK_END)


func rebuild_ui():
	control_references.clear()
	section_vboxes.clear()
	item_panels.clear()
	oRulesSacrifices.control_references.clear()
	oRulesResearch.control_references.clear()
	build_rules_editor()
	call_deferred("_update_scrollbars")


func _update_scrollbars():
	if scroll_container:
		scroll_container.get_v_scrollbar().visible = false
		scroll_container.get_h_scrollbar().visible = false
		yield(get_tree(),'idle_frame')
		scroll_container.get_v_scrollbar().visible = true
		scroll_container.get_h_scrollbar().visible = true


func _on_selection_item_pressed(selected_item: String):
	if current_selection_callback != null and current_selection_callback.is_valid():
		current_selection_callback.call_funcv([selected_item])
	if popup_selection != null:
		popup_selection.hide()


func _on_popup_selection_closed():
	current_selection_callback = null
	if popup_selection != null:
		popup_selection.queue_free()
		popup_selection = null


func _on_link_button_pressed(selected_item: String):
	if current_selection_callback == null or not current_selection_callback.is_valid():
		return
	
	var callback = current_selection_callback.get_meta("callback")
	var metadata = current_selection_callback.get_meta("metadata")
	
	if callback != null and callback.is_valid():
		callback.call_funcv([selected_item, metadata])


func _on_config_status_changed():
	update_rules_paths_label()


func get_meaningful_file_path(fileName):
	for cfg_type in [oConfigFileManager.LOAD_CFG_CURRENT_MAP, oConfigFileManager.LOAD_CFG_CAMPAIGN]:
		if oConfigFileManager.paths_loaded.has(cfg_type):
			for path in oConfigFileManager.paths_loaded[cfg_type]:
				if path and path.to_lower().ends_with(fileName):
					return path
	return ""


func update_rules_paths_label():
	var file_path = get_meaningful_file_path("rules.cfg")
	var final_text = ""
	var tooltip_text = ""
	
	if file_path != "":
		var filename = file_path.get_file()
		if filename == "rules.cfg":
			final_text = "/" + file_path.get_base_dir().get_file() + "/" + filename
		else:
			final_text = filename
		tooltip_text = file_path
	else:
		final_text = "No saved file"
		tooltip_text = "No saved file"
	
	oCurrentlyOpenRules.text = final_text
	oCurrentlyOpenRules.hint_tooltip = tooltip_text
