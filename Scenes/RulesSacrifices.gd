extends Node
onready var oCfgEditor = Nodelist.list["oCfgEditor"]
onready var oTabRules = Nodelist.list["oTabRules"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oCustomTooltip = Nodelist.list["oCustomTooltip"]

var control_references: Dictionary = {}
var add_button: Button = null

func create_sacrifice_control(parent: VBoxContainer, array_index, value, section_name: String, itemIndex: int, revert_button_scene, editor_context):
	var sacrifice_data = parse_sacrifice_string(value)
	
	var item_panel = PanelContainer.new()
	item_panel.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	item_panel.add_stylebox_override("panel", oCfgEditor.create_darker_border_stylebox())
	item_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	
	parent.add_child(item_panel)
	
	var control_container = VBoxContainer.new()
	control_container.add_constant_override("separation", 5)
	item_panel.add_child(control_container)
	
	var header_container = HBoxContainer.new()
	header_container.add_constant_override("separation", 30)
	header_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	control_container.add_child(header_container)
	
	
	var reward_row_container = HBoxContainer.new()
	reward_row_container.add_constant_override("separation", 20)
	reward_row_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	header_container.add_child(reward_row_container)
	
	
	var type_items = ["MkCreature", "MkGoodHero", "NegSpellAll", "PosSpellAll", "NegUniqFunc", "PosUniqFunc"]
	var type_label = Label.new()
	type_label.text = sacrifice_data.type
	type_label.rect_min_size.x = 0
	type_label.mouse_filter = Control.MOUSE_FILTER_STOP
	type_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	editor_context.setup_script_editor_font(type_label)
	type_label.connect("gui_input", self, "_on_type_label_clicked", [array_index, type_items, editor_context])
	type_label.connect("mouse_entered", self, "_on_sacrifice_label_mouse_entered", [type_label, section_name, array_index])
	type_label.connect("mouse_exited", self, "_on_sacrifice_label_mouse_exited", [type_label, section_name, array_index])
	reward_row_container.add_child(type_label)
	
	var reward_items = get_sacrifice_reward_items(sacrifice_data.type)
	var reward_label = Label.new()
	reward_label.text = sacrifice_data.reward if sacrifice_data.reward != "" else "Select..."
	reward_label.mouse_filter = Control.MOUSE_FILTER_STOP
	reward_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	editor_context.setup_script_editor_font(reward_label)
	reward_label.connect("gui_input", self, "_on_reward_label_clicked", [array_index, reward_items, editor_context])
	reward_label.connect("mouse_entered", self, "_on_sacrifice_label_mouse_entered", [reward_label, section_name, array_index])
	reward_label.connect("mouse_exited", self, "_on_sacrifice_label_mouse_exited", [reward_label, section_name, array_index])
	reward_row_container.add_child(reward_label)
	
	var reward_spacer = Control.new()
	reward_spacer.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	reward_row_container.add_child(reward_spacer)
	
	var remove_button = Button.new()
	remove_button.text = "-"
	remove_button.hint_tooltip = "Remove"
	remove_button.rect_min_size.x = 30
	editor_context.setup_script_editor_font(remove_button)
	remove_button.connect("pressed", self, "_on_remove_sacrifice_pressed", [section_name, array_index])
	reward_row_container.add_child(remove_button)
	
	var ingredients_row_container = HBoxContainer.new()
	ingredients_row_container.add_constant_override("separation", 5)
	ingredients_row_container.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	control_container.add_child(ingredients_row_container)
	
	if sacrifice_data.ingredients.size() < 6:
		var add_ingredient_button = Button.new()
		add_ingredient_button.text = "+"
		add_ingredient_button.hint_tooltip = "Add ingredient"
		add_ingredient_button.rect_min_size.x = 30
		editor_context.setup_script_editor_font(add_ingredient_button)
		add_ingredient_button.connect("pressed", self, "_on_add_ingredient_pressed", [array_index])
		ingredients_row_container.add_child(add_ingredient_button)
	
	var spacer = Control.new()
	spacer.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	ingredients_row_container.add_child(spacer)
	
	var ingredients_container = HBoxContainer.new()
	ingredients_container.add_constant_override("separation", 10)
	ingredients_row_container.add_child(ingredients_container)
	
	var ingredient_labels = []
	var ingredient_items = get_ingredient_items()
	for i in range(sacrifice_data.ingredients.size()):
		var ingredient_value = sacrifice_data.ingredients[i]
		
		var ingredient_label = Label.new()
		ingredient_label.text = ingredient_value
		ingredient_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		ingredient_label.mouse_filter = Control.MOUSE_FILTER_STOP
		ingredient_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		editor_context.setup_script_editor_font(ingredient_label)
		ingredient_label.connect("gui_input", self, "_on_ingredient_label_clicked", [array_index, i, ingredient_items, editor_context])
		ingredient_label.connect("mouse_entered", self, "_on_sacrifice_label_mouse_entered", [ingredient_label, section_name, array_index])
		ingredient_label.connect("mouse_exited", self, "_on_sacrifice_label_mouse_exited", [ingredient_label, section_name, array_index])
		ingredients_container.add_child(ingredient_label)
		ingredient_labels.append(ingredient_label)
	
	
	var revert_button = revert_button_scene.instance()
	revert_button.connect("pressed", self, "_on_sacrifice_revert_pressed", [section_name, array_index])
	if not has_sacrifice_default_value(array_index):
		revert_button.disabled = true
		revert_button.modulate.a = 0
	ingredients_row_container.add_child(revert_button)
	
	var refs = {
		"type_label": type_label,
		"reward_label": reward_label,
		"ingredient_labels": ingredient_labels,
		"ingredients_container": ingredients_container,
		"sacrifice_data": sacrifice_data,
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
		"control": reward_label
	}
	
	update_all_sacrifice_labels_color()
	editor_context.update_panel_color(section_name, array_index, item_panel)


func parse_sacrifice_string(value) -> Dictionary:
	var result = {"type": "", "reward": "", "ingredients": []}
	if value is Array and value.size() >= 2:
		result.type = str(value[0])
		result.reward = str(value[1])
		for i in range(2, value.size()):
			var ingredient_str = str(value[i]).strip_edges()
			if ingredient_str != "":
				result.ingredients.append(ingredient_str)
	return result


func get_sacrifice_reward_items(type_name: String) -> Array:
	match type_name:
		"MkCreature", "MkGoodHero":
			var items = []
			for item in Things.DATA_CREATURE:
				if item != 0:
					items.append(Things.DATA_CREATURE[item][Things.NAME_ID])
			return items
		"NegSpellAll", "PosSpellAll":
			return ["SPELL_DISEASE", "SPELL_CHICKEN", "SPELL_SPEED", "SPELL_INVISIBILITY", "SPELL_HEAL", "SPELL_REBOUND", "SPELL_ARMOUR", "SPELL_FLIGHT", "SPELL_FREEZE", "SPELL_SLOW"]
		"NegUniqFunc", "PosUniqFunc":
			return ["COMPLETE_RESEARCH", "COMPLETE_MANUFACTR", "CHEAPER_IMPS", "ALL_CREATRS_ANGRY", "KILL_ALL_CHICKENS", "COSTLIER_IMPS", "ALL_CREATRS_VER_ANGRY", "ALL_CREATRS_HAPPY"]
		_:
			return []


func get_ingredient_items() -> Array:
	var items = ["(Remove)"]
	for item in Things.DATA_CREATURE:
		if item != 0:
			items.append(Things.DATA_CREATURE[item][Things.NAME_ID])
	return items


func update_sacrifice_value(section_name: String, array_index: int, sacrifice_data: Dictionary):
	var sacrifice_array = [sacrifice_data.type, sacrifice_data.reward] + sacrifice_data.ingredients
	var sacrifices_list = oConfigFileManager.DATA_RULES[section_name]
	if array_index >= 0 and array_index < sacrifices_list.size():
		sacrifices_list[array_index] = sacrifice_array


func add_sacrifice_data():
	oConfigFileManager.DATA_RULES["sacrifices"].append(["MkCreature", "BILE_DEMON", "SPIDER", "SPIDER", "SPIDER"])


func remove_sacrifice_data(section_name: String, array_index: int):
	var sacrifices_list = oConfigFileManager.DATA_RULES[section_name]
	if array_index >= 0 and array_index < sacrifices_list.size():
		sacrifices_list.remove(array_index)
		cleanup_control_references(array_index)
		oCfgEditor.update_colors_after_change(section_name, array_index)


func cleanup_control_references(array_index: int):
	if control_references.has(array_index):
		control_references.erase(array_index)
	if oCfgEditor.control_references.has(array_index):
		oCfgEditor.control_references.erase(array_index)


func remove_ingredient_at_index(refs: Dictionary, ingredient_index: int):
	if ingredient_index >= refs["ingredient_labels"].size():
		return
	
	var ingredients_container = refs["ingredients_container"]
	var label_to_remove = refs["ingredient_labels"][ingredient_index]
	
	var plus_button = null
	var ingredients_row_container = ingredients_container.get_parent()
	for child in ingredients_row_container.get_children():
		if child is Button and child.text == "+":
			plus_button = child
			break
	if plus_button:
		ingredients_row_container.remove_child(plus_button)
		plus_button.queue_free()
	
	ingredients_container.remove_child(label_to_remove)
	label_to_remove.queue_free()
	refs["ingredient_labels"].erase(label_to_remove)
	refs["sacrifice_data"].ingredients.remove(ingredient_index)
	
	for i in range(ingredient_index, refs["ingredient_labels"].size()):
		var label = refs["ingredient_labels"][i]
		label.disconnect("gui_input", self, "_on_ingredient_label_clicked")
		label.connect("gui_input", self, "_on_ingredient_label_clicked", [refs["array_index"], i, get_ingredient_items(), oCfgEditor])
	
	if refs["sacrifice_data"].ingredients.size() < 6:
		var add_ingredient_button = Button.new()
		add_ingredient_button.text = "+"
		add_ingredient_button.hint_tooltip = "Add ingredient"
		add_ingredient_button.rect_min_size.x = 30
		oCfgEditor.setup_script_editor_font(add_ingredient_button)
		add_ingredient_button.connect("pressed", self, "_on_add_ingredient_pressed", [refs["array_index"]])
		ingredients_row_container.add_child(add_ingredient_button)
		ingredients_row_container.move_child(add_ingredient_button, 0)
	
	update_sacrifice_value(refs["section_name"], refs["array_index"], refs["sacrifice_data"])
	oCfgEditor.update_colors_after_change(refs["section_name"], refs["array_index"])


func _on_ingredient_selected(ingredient_name: String, metadata: Dictionary):
	var array_index = metadata.get("array_index")
	if not control_references.has(array_index):
		return
	var refs = control_references[array_index]
	var ingredient_index = metadata.get("ingredient_index", 0)
	if ingredient_name == "(Remove)":
		remove_ingredient_at_index(refs, ingredient_index)
	else:
		while refs["sacrifice_data"].ingredients.size() <= ingredient_index:
			refs["sacrifice_data"].ingredients.append("")
		refs["sacrifice_data"].ingredients[ingredient_index] = ingredient_name
		refs["ingredient_labels"][ingredient_index].text = ingredient_name
	update_sacrifice_value(refs["section_name"], array_index, refs["sacrifice_data"])
	oCfgEditor.update_colors_after_change(refs["section_name"], array_index)


func _on_sacrifice_reward_selected(reward_name: String, metadata: Dictionary):
	var array_index = metadata.get("array_index")
	if not control_references.has(array_index):
		return
	var refs = control_references[array_index]
	refs["sacrifice_data"].reward = reward_name
	refs["reward_label"].text = reward_name
	update_sacrifice_value(refs["section_name"], array_index, refs["sacrifice_data"])
	oCfgEditor.update_colors_after_change(refs["section_name"], array_index)


func _on_sacrifice_type_selected(type_name: String, metadata: Dictionary):
	var array_index = metadata.get("array_index")
	if not control_references.has(array_index):
		return
	var refs = control_references[array_index]
	refs["sacrifice_data"].type = type_name
	refs["sacrifice_data"].reward = ""
	refs["type_label"].text = type_name
	refs["reward_label"].text = "Select..."
	var reward_items = get_sacrifice_reward_items(type_name)
	refs["reward_items"] = reward_items
	yield(oCfgEditor.get_tree().create_timer(0.1), "timeout")
	oTabRules.create_selection_popup("Select Sacrifice Reward", reward_items, funcref(self, "_on_sacrifice_reward_selected"), array_index)


func _on_add_ingredient_pressed(array_index: int):
	if not control_references.has(array_index):
		return
	
	var refs = control_references[array_index]
	if refs["sacrifice_data"].ingredients.size() < 6:
		var ingredient_index = refs["sacrifice_data"].ingredients.size()
		var ingredient_items = get_ingredient_items()
		
		var callback_data = {"array_index": array_index, "ingredient_index": ingredient_index}
		create_ingredient_selection_popup("Select Ingredient " + str(ingredient_index + 1), ingredient_items, funcref(self, "_on_add_ingredient_selected"), callback_data)


func _on_add_ingredient_selected(ingredient_name: String, metadata: Dictionary):
	if ingredient_name == "(Remove)":
		return
	var array_index = metadata.get("array_index")
	if not control_references.has(array_index):
		return
	var refs = control_references[array_index]
	var ingredient_index = metadata.get("ingredient_index", 0)
	
	refs["sacrifice_data"].ingredients.append(ingredient_name)
	
	var ingredient_items = get_ingredient_items()
	var ingredient_label = Label.new()
	ingredient_label.text = ingredient_name
	ingredient_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
	ingredient_label.mouse_filter = Control.MOUSE_FILTER_STOP
	ingredient_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	oCfgEditor.setup_script_editor_font(ingredient_label)
	ingredient_label.connect("gui_input", self, "_on_ingredient_label_clicked", [metadata.get("array_index"), ingredient_index, ingredient_items, oCfgEditor])
	ingredient_label.connect("mouse_entered", self, "_on_sacrifice_label_mouse_entered", [ingredient_label, refs["section_name"], metadata.get("array_index")])
	ingredient_label.connect("mouse_exited", self, "_on_sacrifice_label_mouse_exited", [ingredient_label, refs["section_name"], metadata.get("array_index")])
	
	var ingredients_container = refs["ingredients_container"]
	
	var plus_button = null
	var ingredients_row_container = ingredients_container.get_parent()
	for child in ingredients_row_container.get_children():
		if child is Button and child.text == "+":
			plus_button = child
			break
	
	if plus_button:
		ingredients_row_container.remove_child(plus_button)
		plus_button.queue_free()
	
	ingredients_container.add_child(ingredient_label)
	refs["ingredient_labels"].append(ingredient_label)
	
	if refs["sacrifice_data"].ingredients.size() < 6:
		var add_ingredient_button = Button.new()
		add_ingredient_button.text = "+"
		add_ingredient_button.hint_tooltip = "Add ingredient"
		add_ingredient_button.rect_min_size.x = 30
		oCfgEditor.setup_script_editor_font(add_ingredient_button)
		add_ingredient_button.connect("pressed", self, "_on_add_ingredient_pressed", [metadata.get("array_index")])
		ingredients_row_container.add_child(add_ingredient_button)
		ingredients_row_container.move_child(add_ingredient_button, 0)
	
	update_sacrifice_value(refs["section_name"], refs["array_index"], refs["sacrifice_data"])
	oCfgEditor.update_colors_after_change(refs["section_name"], refs["array_index"])


func _on_add_sacrifice_pressed(section_name: String):
	add_sacrifice_data()
	oCfgEditor.rebuild_ui()
	yield(oCfgEditor.ensure_add_button_visible(add_button), "completed")



func update_all_sacrifice_labels_color():
	for key in control_references:
		var refs = control_references[key]
		var array_index = refs["array_index"]
		var is_item_modified = is_sacrifice_item_different(array_index)
		var target_color = oCfgEditor.UI_TEXT_MODIFIED if is_item_modified else oCfgEditor.UI_TEXT_NORMAL
		
		refs["type_label"].add_color_override("font_color", target_color)
		refs["reward_label"].add_color_override("font_color", target_color)
		for ingredient_label in refs["ingredient_labels"]:
			ingredient_label.add_color_override("font_color", target_color)


func get_tooltip_text_for_label(label: Label, array_index: int) -> String:
	if not control_references.has(array_index):
		return ""
	var refs = control_references[array_index]
	if label == refs["type_label"]:
		return "Type"
	elif label == refs["reward_label"]:
		return "Reward"
	for ingredient_label in refs["ingredient_labels"]:
		if label == ingredient_label:
			return "Ingredient"
	return ""


func _on_sacrifice_label_mouse_entered(label: Label, section_name: String, array_index: int):
	oTabRules.handle_label_mouse_entered(label, get_tooltip_text_for_label(label, array_index))


func _on_sacrifice_label_mouse_exited(label: Label, section_name: String, array_index: int):
	oTabRules.handle_label_mouse_exited(label, array_index, section_name)


func _on_remove_sacrifice_pressed(section_name: String, array_index: int):
	remove_sacrifice_data(section_name, array_index)
	oCfgEditor.rebuild_ui()


func _on_type_label_clicked(event: InputEvent, array_index: int, type_items: Array, editor_context):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		oTabRules.create_selection_popup("Select Sacrifice Type", type_items, funcref(self, "_on_sacrifice_type_selected"), array_index)


func create_ingredient_selection_popup(title: String, items: Array, callback: FuncRef, metadata: Dictionary):
	var wrapped_callback = funcref(oCfgEditor, "_on_link_button_pressed")
	wrapped_callback.set_meta("title", title)
	wrapped_callback.set_meta("items", items)
	wrapped_callback.set_meta("callback", callback)
	wrapped_callback.set_meta("metadata", metadata)
	oTabRules.create_popup_selection(title, items, wrapped_callback, oCfgEditor)


func _on_reward_label_clicked(event: InputEvent, array_index: int, reward_items: Array, editor_context):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var current_reward_items = reward_items
		if control_references.has(array_index) and control_references[array_index].has("reward_items"):
			current_reward_items = control_references[array_index]["reward_items"]
		oTabRules.create_selection_popup("Select Sacrifice Reward", current_reward_items, funcref(self, "_on_sacrifice_reward_selected"), array_index)


func _on_ingredient_label_clicked(event: InputEvent, array_index: int, ingredient_index: int, ingredient_items: Array, editor_context):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_RIGHT:
			if control_references.has(array_index):
				remove_ingredient_at_index(control_references[array_index], ingredient_index)
		elif event.button_index == BUTTON_LEFT:
			var callback_data = {"array_index": array_index, "ingredient_index": ingredient_index}
			create_ingredient_selection_popup("Select Ingredient " + str(ingredient_index + 1), ingredient_items, funcref(self, "_on_ingredient_selected"), callback_data)


func has_sacrifice_default_value(array_index: int) -> bool:
	return oTabRules.check_default_value_exists("sacrifices", array_index)


func is_sacrifice_item_different(array_index: int) -> bool:
	return oTabRules.check_item_difference("sacrifices", array_index)


func update_sacrifice_ui_after_revert(array_index: int, default_data):
	if control_references.has(array_index):
		var refs = control_references[array_index]
		var sacrifice_data = parse_sacrifice_string(default_data)
		refs["sacrifice_data"] = sacrifice_data
		refs["type_label"].text = sacrifice_data.type
		refs["reward_label"].text = sacrifice_data.reward
		
		# Clear and rebuild ingredient container completely
		var ingredients_container = refs["ingredients_container"]
		for child in ingredients_container.get_children():
			child.queue_free()
		refs["ingredient_labels"].clear()
		
		# Remove existing + button if it exists
		var row_container = ingredients_container.get_parent()
		for child in row_container.get_children():
			if child is Button and child.text == "+":
				row_container.remove_child(child)
				child.queue_free()
				break
		
		# Add new ingredient labels
		var ingredient_items = get_ingredient_items()
		for i in range(sacrifice_data.ingredients.size()):
			var ingredient_value = sacrifice_data.ingredients[i]
			var ingredient_label = Label.new()
			ingredient_label.text = ingredient_value
			ingredient_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
			ingredient_label.mouse_filter = Control.MOUSE_FILTER_STOP
			ingredient_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			oCfgEditor.setup_script_editor_font(ingredient_label)
			ingredient_label.connect("gui_input", self, "_on_ingredient_label_clicked", [array_index, i, ingredient_items, oCfgEditor])
			ingredient_label.connect("mouse_entered", self, "_on_sacrifice_label_mouse_entered", [ingredient_label, "sacrifices", array_index])
			ingredient_label.connect("mouse_exited", self, "_on_sacrifice_label_mouse_exited", [ingredient_label, "sacrifices", array_index])
			ingredients_container.add_child(ingredient_label)
			refs["ingredient_labels"].append(ingredient_label)
		
		# Add the + button if needed
		if sacrifice_data.ingredients.size() < 6:
			var add_ingredient_button = Button.new()
			add_ingredient_button.text = "+"
			add_ingredient_button.hint_tooltip = "Add ingredient"
			add_ingredient_button.rect_min_size.x = 30
			oCfgEditor.setup_script_editor_font(add_ingredient_button)
			add_ingredient_button.connect("pressed", self, "_on_add_ingredient_pressed", [array_index])
			var ingredients_row_container = ingredients_container.get_parent()
			ingredients_row_container.add_child(add_ingredient_button)
			ingredients_row_container.move_child(add_ingredient_button, 0)
	
	update_all_sacrifice_labels_color()
	
	if oCfgEditor.item_panels.has("sacrifices") and oCfgEditor.item_panels["sacrifices"].has(array_index):
		var item_panel = oCfgEditor.item_panels["sacrifices"][array_index]["panel"]
		oCfgEditor.update_panel_color("sacrifices", array_index, item_panel)


func _on_sacrifice_revert_pressed(section_name: String, array_index: int):
	sacrifice_item_revert(array_index)


func sacrifice_item_revert(array_index: int):
	var section_name = "sacrifices"
	if oTabRules.perform_item_revert(section_name, array_index):
		update_sacrifice_ui_after_revert(array_index, oConfigFileManager.default_data[section_name][array_index])
		oCfgEditor.update_colors_after_change(section_name, array_index)
