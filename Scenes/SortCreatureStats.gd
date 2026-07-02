extends WindowDialog
onready var oSortCreaStatsGrid = Nodelist.list["oSortCreaStatsGrid"]
onready var oStatsOptionButton = Nodelist.list["oStatsOptionButton"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]

var name_type = 0

var all_creature_data = {}

var selected_labels = []
func _on_SortCreatureStats_visibility_changed():
	if visible == true:
		start()

func start():
	all_creature_data = oConfigFileManager.current_data.get("creature_stats", {})
	selected_labels.clear()
	oStatsOptionButton.clear()
	
	populate_optionbutton()
	
	var default_index = min(2, oStatsOptionButton.get_item_count() - 1)
	if default_index >= 0:
		oStatsOptionButton.select(default_index)
		_on_StatsOptionButton_item_selected(default_index)

func _on_StatsOptionButton_item_selected(optionButtonIndex):
	update_list(optionButtonIndex)

func update_list(optionButtonIndex):
	
	var list_data = []
	for i in oSortCreaStatsGrid.get_children():
		i.free()
	
	var optionButtonMeta = oStatsOptionButton.get_item_metadata(optionButtonIndex)
	
	for file in all_creature_data:
		var getName = figure_out_name(file)
		
		for section in all_creature_data[file]:
			if section == optionButtonMeta[0]:
				
				var getValue = all_creature_data[file][section].get(optionButtonMeta[1])
				list_data.append([getName, getValue])
	
	list_data.sort_custom(self, "sort_list")
	for i in list_data:
		var col = Color(0.5,0.5,0.5)
		var label_text = str(i[0])  # Create a single string with a separator
		if label_text in selected_labels:
			col = Color(1.0,1.0,1.0)
		
		
		if i[1] is Array:
			i[1] = str(i[1]).replace("[", "").replace("]", "").replace(",", "").replace(" ", "  ")
		
		add_entry(i[0], i[1], col)

func figure_out_name(file):
	var subtype = Things.find_subtype_by_name(Things.TYPE.CREATURE, file.get_basename().to_upper())
	match name_type:
		0:
			return file.get_basename().capitalize() if subtype == null else Things.fetch_name(Things.TYPE.CREATURE, subtype)
		1:
			return file.get_basename().to_upper() if subtype == null else Things.fetch_id_string(Things.TYPE.CREATURE, subtype)
		2: 
			return file


func sort_list(a, b):
	return sort_value(a[1]) < sort_value(b[1])

func sort_value(value):
	if value is int:
		return value
	if value is String:
		return value.length()
	if value is Array:
		return int(value[0])
	return 0

func add_entry(string1, value, fontColor):
	var addLabel1 = Label.new()
	addLabel1.text = str(string1)
	oSortCreaStatsGrid.add_child(addLabel1)
	addLabel1.set("custom_colors/font_color", fontColor)
	addLabel1.mouse_filter = Control.MOUSE_FILTER_PASS
	
	var addLabel2 = Label.new()
	addLabel2.text = str(value)
	oSortCreaStatsGrid.add_child(addLabel2)
	addLabel2.set("custom_colors/font_color", fontColor)
	addLabel2.mouse_filter = Control.MOUSE_FILTER_PASS
	
	addLabel1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	addLabel2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	addLabel1.connect("mouse_entered", self, "_on_label_mouse_entered", [addLabel1, addLabel2])
	addLabel2.connect("mouse_entered", self, "_on_label_mouse_entered", [addLabel1, addLabel2])
	
	addLabel1.connect("mouse_exited", self, "_on_label_mouse_exited", [addLabel1, addLabel2])
	addLabel2.connect("mouse_exited", self, "_on_label_mouse_exited", [addLabel1, addLabel2])
	
	addLabel1.connect("gui_input", self, "_on_label_gui_input", [addLabel1, addLabel2])
	addLabel2.connect("gui_input", self, "_on_label_gui_input", [addLabel1, addLabel2])

func _on_label_mouse_entered(l1,l2):
	if l1.text in selected_labels:
		pass
	else:
		l1.set("custom_colors/font_color", Color(1,1,1))
		l2.set("custom_colors/font_color", Color(1,1,1))

func _on_label_mouse_exited(l1,l2):
	if l1.text in selected_labels:
		pass
	else:
		l1.set("custom_colors/font_color", Color(0.5,0.5,0.5))
		l2.set("custom_colors/font_color", Color(0.5,0.5,0.5))

func _on_label_gui_input(event, l1, l2):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		var label_text = l1.text
		if label_text in selected_labels:
			selected_labels.erase(label_text)
			l1.set("custom_colors/font_color", Color(0.5,0.5,0.5))
			l2.set("custom_colors/font_color", Color(0.5,0.5,0.5))
		else:
			selected_labels.append(label_text)
			l1.set("custom_colors/font_color", Color(1, 1, 1))
			l2.set("custom_colors/font_color", Color(1, 1, 1))

func _on_NameStatsButton_pressed():
	selected_labels.clear()
	name_type += 1
	if name_type >= 3: name_type = 0
	update_list(oStatsOptionButton.selected)


func _on_RightStatsButton_pressed():
	var next_index = oStatsOptionButton.selected + 1
	while next_index < oStatsOptionButton.get_item_count() and oStatsOptionButton.get_item_text(next_index) == "":
		next_index += 1
	if next_index >= oStatsOptionButton.get_item_count():
		next_index = 0
		while next_index < oStatsOptionButton.selected and oStatsOptionButton.get_item_text(next_index) == "":
			next_index += 1
	oStatsOptionButton.selected = next_index
	_on_StatsOptionButton_item_selected(next_index)

func _on_LeftStatsButton_pressed():
	var prev_index = oStatsOptionButton.selected - 1
	while prev_index >= 0 and oStatsOptionButton.get_item_text(prev_index) == "":
		prev_index -= 1
	if prev_index < 0:
		prev_index = oStatsOptionButton.get_item_count() - 1
		while prev_index > oStatsOptionButton.selected and oStatsOptionButton.get_item_text(prev_index) == "":
			prev_index -= 1
	oStatsOptionButton.selected = prev_index
	_on_StatsOptionButton_item_selected(prev_index)


func populate_optionbutton():
	var added_options = {}
	for file in all_creature_data:
		for section in all_creature_data[file]:
			var item_count = oStatsOptionButton.get_item_count()
			for key in all_creature_data[file][section].keys():
				var option_key = section + "." + key
				if added_options.has(option_key):
					continue
				var idx = oStatsOptionButton.get_item_count()
				oStatsOptionButton.add_item(key)
				oStatsOptionButton.set_item_metadata(idx, [section, key])
				added_options[option_key] = true
			if oStatsOptionButton.get_item_count() > item_count:
				oStatsOptionButton.add_separator()


func _on_CCStatsHelpButton_pressed():
	var helptxt = ""
	helptxt += "Creature stats are loaded with map configs from /creatrs/, campaign CREATURES_LOCATION, and map-local creature files."
	oMessage.big("Help",helptxt)
