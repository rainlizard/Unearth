extends Node
onready var oCfgEditor = Nodelist.list["oCfgEditor"]
onready var oTabRules = Nodelist.list["oTabRules"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]

var control_references: Dictionary = {}
var add_button: Button = null

func parse_research_array(value) -> Dictionary:
	var result = {"type": "", "kind": "", "points": 0}
	if value is Array and value.size() >= 3:
		result.type = str(value[0])
		result.kind = str(value[1])
		result.points = int(value[2]) if str(value[2]).is_valid_integer() else 0
	return result


func create_research_control(parent: VBoxContainer, array_index, value, section_name: String, itemIndex: int, revert_button_scene, editor_context):
	var research_data = parse_research_array(value)
	
	var item_panel = PanelContainer.new()
	item_panel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	item_panel.add_stylebox_override("panel", oCfgEditor.create_darker_border_stylebox())
	item_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	parent.add_child(item_panel)
	
	var control_container = HBoxContainer.new()
	control_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	item_panel.add_child(control_container)
	
	var type_items = ["MAGIC", "ROOM", "CREATURE"]
	var type_label = Label.new()
	type_label.text = research_data.type
	type_label.rect_min_size.x = 80
	type_label.mouse_filter = Control.MOUSE_FILTER_STOP
	type_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	editor_context.setup_script_editor_font(type_label)
	type_label.connect("gui_input", self, "_on_type_label_clicked", [array_index, type_items, editor_context])
	type_label.connect("mouse_entered", self, "_on_research_label_mouse_entered", [type_label, section_name, array_index])
	type_label.connect("mouse_exited", self, "_on_research_label_mouse_exited", [type_label, section_name, array_index])
	control_container.add_child(type_label)
	
	var kind_items = get_research_kind_items(research_data.type)
	var kind_label = Label.new()
	kind_label.text = research_data.kind if research_data.kind != "" else "Select..."
	kind_label.rect_min_size.x = 150
	kind_label.mouse_filter = Control.MOUSE_FILTER_STOP
	kind_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	editor_context.setup_script_editor_font(kind_label)
	kind_label.connect("gui_input", self, "_on_kind_label_clicked", [array_index, kind_items, editor_context])
	kind_label.connect("mouse_entered", self, "_on_research_label_mouse_entered", [kind_label, section_name, array_index])
	kind_label.connect("mouse_exited", self, "_on_research_label_mouse_exited", [kind_label, section_name, array_index])
	control_container.add_child(kind_label)
	
	var spacer = Control.new()
	spacer.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	control_container.add_child(spacer)
	
	var points_spinbox = CustomSpinBox.new()
	points_spinbox.min_value = 0
	points_spinbox.max_value = 999999999
	points_spinbox.step = 1
	points_spinbox.value = research_data.points
	points_spinbox.rect_min_size.x = 0
	editor_context.setup_script_editor_font(points_spinbox)
	points_spinbox.get_line_edit().add_color_override("font_color", oCfgEditor.UI_TEXT_NORMAL)
	points_spinbox.connect("value_changed", self, "_on_points_changed", [array_index])
	points_spinbox.get_line_edit().connect("focus_entered", editor_context, "_on_spinbox_focus_entered", [points_spinbox])
	points_spinbox.get_line_edit().connect("focus_exited", editor_context, "_on_spinbox_focus_exited", [points_spinbox, section_name, str(array_index)])
	points_spinbox.connect("mouse_entered", editor_context, "_on_control_mouse_entered", [type_label, points_spinbox, section_name, str(array_index)])
	points_spinbox.connect("mouse_exited", editor_context, "_on_control_mouse_exited", [type_label, points_spinbox, section_name, str(array_index)])
	control_container.add_child(points_spinbox)
	
	var revert_button = revert_button_scene.instance()
	revert_button.connect("pressed", self, "_on_research_revert_pressed", [section_name, array_index])
	if not has_research_default_value(array_index):
		revert_button.disabled = true
		revert_button.modulate.a = 0
	control_container.add_child(revert_button)
	
	var move_button_container = HBoxContainer.new()
	move_button_container.add_constant_override("separation", 2)
	control_container.add_child(move_button_container)
	
	var move_up_button = Button.new()
	move_up_button.text = "↑"
	move_up_button.hint_tooltip = "Move Up"
	editor_context.setup_script_editor_font(move_up_button)
	move_up_button.connect("pressed", self, "_on_move_research_up_pressed", [section_name, array_index])
	move_button_container.add_child(move_up_button)
	
	var move_down_button = Button.new()
	move_down_button.text = "↓"
	move_down_button.hint_tooltip = "Move Down"
	editor_context.setup_script_editor_font(move_down_button)
	move_down_button.connect("pressed", self, "_on_move_research_down_pressed", [section_name, array_index])
	move_button_container.add_child(move_down_button)
	
	var remove_button = Button.new()
	remove_button.text = "-"
	remove_button.hint_tooltip = "Delete entry"
	remove_button.rect_min_size.x = 30
	editor_context.setup_script_editor_font(remove_button)
	remove_button.connect("pressed", self, "_on_remove_research_pressed", [section_name, array_index])
	control_container.add_child(remove_button)
	
	var refs = {
		"type_label": type_label,
		"kind_label": kind_label,
		"points_spinbox": points_spinbox,
		"research_data": research_data,
		"section_name": section_name,
		"array_index": array_index
	}
	control_references[array_index] = refs
	editor_context.control_references[array_index] = refs
	
	if not editor_context.item_panels.has(section_name):
		editor_context.item_panels[section_name] = {}
	editor_context.item_panels[section_name][array_index] = {
		"panel": item_panel,
		"label": type_label,
		"control": points_spinbox
	}
	
	update_all_research_labels_color()
	editor_context.update_panel_color(section_name, array_index, item_panel)


func get_research_kind_items(type_name: String) -> Array:
	match type_name:
		"MAGIC":
			var items = []
			for section_key in oConfigFileManager.DATA_MAGIC:
				if section_key.begins_with("power"):
					var power_data = oConfigFileManager.DATA_MAGIC[section_key]
					if power_data.has("Name"):
						items.append(power_data["Name"])
			return items
		"ROOM":
			var items = []
			for room_id in oConfigFileManager.DATA_ROOMS:
				var room_data = oConfigFileManager.DATA_ROOMS[room_id]
				if room_data.has("Name"):
					items.append(room_data["Name"])
			return items
		"CREATURE":
			var items = []
			for item in Things.DATA_CREATURE:
				if item != 0:
					items.append(Things.DATA_CREATURE[item][Things.NAME_ID])
			return items
		_:
			return []


func update_research_value(section_name: String, array_index: int, research_data: Dictionary):
	var research_list = oConfigFileManager.DATA_RULES[section_name]
	if array_index >= 0 and array_index < research_list.size():
		research_list[array_index] = [research_data.type, research_data.kind, research_data.points]


func add_research_data():
	oConfigFileManager.DATA_RULES["research"].append(["MAGIC", "POWER_SIGHT", 1])


func remove_research_data(section_name: String, array_index: int):
	var research_list = oConfigFileManager.DATA_RULES[section_name]
	if array_index >= 0 and array_index < research_list.size():
		research_list.remove(array_index)
		cleanup_control_references(array_index)
		oCfgEditor.update_colors_after_change(section_name, array_index)


func cleanup_control_references(array_index: int):
	if control_references.has(array_index):
		control_references.erase(array_index)
	if oCfgEditor.control_references.has(array_index):
		oCfgEditor.control_references.erase(array_index)


func has_research_default_value(array_index: int) -> bool:
	return oTabRules.check_default_value_exists("research", array_index)


func is_research_item_different(array_index: int) -> bool:
	return oTabRules.check_item_difference("research", array_index)


func update_all_research_labels_color():
	for key in control_references:
		var refs = control_references[key]
		var array_index = refs["array_index"]
		var is_item_modified = is_research_item_different(array_index)
		var target_color = oCfgEditor.UI_TEXT_MODIFIED if is_item_modified else oCfgEditor.UI_TEXT_NORMAL
		
		refs["type_label"].add_color_override("font_color", target_color)
		refs["kind_label"].add_color_override("font_color", target_color)
		refs["points_spinbox"].get_line_edit().add_color_override("font_color", target_color)


func _on_add_research_pressed(section_name: String):
	add_research_data()
	oCfgEditor.rebuild_ui()
	yield(oCfgEditor.ensure_add_button_visible(add_button), "completed")


func _on_remove_research_pressed(section_name: String, array_index: int):
	remove_research_data(section_name, array_index)
	oCfgEditor.rebuild_ui()


func _on_points_changed(new_value: float, array_index: int):
	if not control_references.has(array_index):
		return
	
	var refs = control_references[array_index]
	refs["research_data"].points = int(new_value)
	update_research_value(refs["section_name"], refs["array_index"], refs["research_data"])
	oCfgEditor.update_colors_after_change(refs["section_name"], refs["array_index"])


func _on_research_type_selected(type_name: String, metadata: Dictionary):
	var array_index = metadata.get("array_index")
	if not control_references.has(array_index):
		return
	var refs = control_references[array_index]
	refs["research_data"].type = type_name
	refs["research_data"].kind = ""
	refs["type_label"].text = type_name
	refs["kind_label"].text = "Select..."
	var kind_items = get_research_kind_items(type_name)
	refs["kind_items"] = kind_items
	yield(oCfgEditor.get_tree().create_timer(0.1), "timeout")
	oTabRules.create_selection_popup("Select Research Kind", kind_items, funcref(self, "_on_research_kind_selected"), array_index)


func _on_research_kind_selected(kind_name: String, metadata: Dictionary):
	var array_index = metadata.get("array_index")
	if not control_references.has(array_index):
		return
	var refs = control_references[array_index]
	refs["research_data"].kind = kind_name
	refs["kind_label"].text = kind_name
	update_research_value(refs["section_name"], array_index, refs["research_data"])
	oCfgEditor.update_colors_after_change(refs["section_name"], array_index)


func _on_type_label_clicked(event: InputEvent, array_index: int, type_items: Array, editor_context):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		oTabRules.create_selection_popup("Select Research Type", type_items, funcref(self, "_on_research_type_selected"), array_index)


func _on_kind_label_clicked(event: InputEvent, array_index: int, kind_items: Array, editor_context):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var current_kind_items = kind_items
		if control_references.has(array_index) and control_references[array_index].has("kind_items"):
			current_kind_items = control_references[array_index]["kind_items"]
		oTabRules.create_selection_popup("Select Research Kind", current_kind_items, funcref(self, "_on_research_kind_selected"), array_index)


func _on_research_label_mouse_entered(label: Label, section_name: String, array_index: int):
	oTabRules.handle_label_mouse_entered(label, get_tooltip_text_for_label(label, array_index))


func _on_research_label_mouse_exited(label: Label, section_name: String, array_index: int):
	oTabRules.handle_label_mouse_exited(label, array_index, section_name)


func get_tooltip_text_for_label(label: Label, array_index: int) -> String:
	if not control_references.has(array_index):
		return ""
	var refs = control_references[array_index]
	if label == refs["type_label"]:
		return "Research Type"
	elif label == refs["kind_label"]:
		return "Research Kind"
	return ""


func move_research_item(section_name: String, from_index: int, to_index: int):
	var research_list = oConfigFileManager.DATA_RULES[section_name]
	if from_index >= 0 and from_index < research_list.size() and to_index >= 0 and to_index < research_list.size():
		var item = research_list[from_index]
		research_list.remove(from_index)
		research_list.insert(to_index, item)


func _on_move_research_up_pressed(section_name: String, array_index: int):
	if try_move_research(section_name, array_index, array_index - 1):
		oCfgEditor.rebuild_ui()


func _on_move_research_down_pressed(section_name: String, array_index: int):
	if try_move_research(section_name, array_index, array_index + 1):
		oCfgEditor.rebuild_ui()


func try_move_research(section_name: String, from_index: int, to_index: int) -> bool:
	var research_list = oConfigFileManager.DATA_RULES[section_name]
	if from_index >= 0 and to_index >= 0 and from_index < research_list.size() and to_index < research_list.size() and from_index != to_index:
		move_research_item(section_name, from_index, to_index)
		return true
	return false


func update_research_ui_after_revert(array_index: int, default_data):
	if control_references.has(array_index):
		var refs = control_references[array_index]
		var research_data = parse_research_array(default_data)
		refs["research_data"] = research_data
		refs["type_label"].text = research_data.type
		refs["kind_label"].text = research_data.kind
		refs["points_spinbox"].value = research_data.points
	
	update_all_research_labels_color()
	
	if oCfgEditor.item_panels.has("research") and oCfgEditor.item_panels["research"].has(array_index):
		var item_panel = oCfgEditor.item_panels["research"][array_index]["panel"]
		oCfgEditor.update_panel_color("research", array_index, item_panel)


func _on_research_revert_pressed(section_name: String, array_index: int):
	research_item_revert(array_index)


func research_item_revert(array_index: int):
	var section_name = "research"
	if oTabRules.perform_item_revert(section_name, array_index):
		update_research_ui_after_revert(array_index, oConfigFileManager.default_data[section_name][array_index])
		oCfgEditor.update_colors_after_change(section_name, array_index)
