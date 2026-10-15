extends WindowDialog
onready var oSortCreaStatsGrid = Nodelist.list["oSortCreaStatsGrid"]
onready var oStatsOptionButton = Nodelist.list["oStatsOptionButton"]
onready var oStatsSortButton = Nodelist.list["oStatsSortButton"]
onready var oShowUnlistedCreatures = Nodelist.list["oShowUnlistedCreatures"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oConfigFileManager = Nodelist.list["oConfigFileManager"]
onready var oMenu = Nodelist.list["oMenu"]

var name_type = 0
var sort_descending = false

var all_creature_data = {}
var creature_paths = {}

var selected_files = []
func _on_SortCreatureStats_visibility_changed():
	if visible == true:
		start()

func start():
	all_creature_data = oConfigFileManager.current_data.get("creature_stats", {})
	creature_paths = oConfigFileManager.current_data.get("creature_stats_paths", {})
	selected_files.clear()
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
		if oShowUnlistedCreatures.pressed == false and Things.find_subtype_by_name(Things.TYPE.CREATURE, file.get_basename().to_upper()) == null:
			continue
		var getName = figure_out_name(file)

		for section in all_creature_data[file]:
			if section == optionButtonMeta[0]:

				var getValue = all_creature_data[file][section].get(optionButtonMeta[1])
				list_data.append([getName, getValue, file])

	list_data.sort_custom(self, "sort_list")
	if sort_descending:
		list_data.invert()
	for i in list_data:
		if i[1] is Array:
			i[1] = str(i[1]).replace("[", "").replace("]", "").replace(",", "").replace(" ", "  ")

		add_entry(i[2], i[0], i[1])

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

func add_entry(file, string1, value):
	var labels = []
	for text in [string1, value]:
		var addLabel = Label.new()
		addLabel.text = str(text)
		addLabel.hint_tooltip = creature_paths.get(file, "") + "\nDouble-click to edit"
		addLabel.mouse_filter = Control.MOUSE_FILTER_PASS
		addLabel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		oSortCreaStatsGrid.add_child(addLabel)
		labels.append(addLabel)
	for addLabel in labels:
		addLabel.connect("mouse_entered", self, "set_labels_highlighted", [file, labels, true])
		addLabel.connect("mouse_exited", self, "set_labels_highlighted", [file, labels, false])
		addLabel.connect("gui_input", self, "_on_label_gui_input", [file, labels])
	set_labels_highlighted(file, labels, false)

func set_labels_highlighted(file, labels, highlighted):
	var col = Color(1,1,1) if highlighted or file in selected_files else Color(0.5,0.5,0.5)
	for l in labels:
		l.set("custom_colors/font_color", col)

func _on_label_gui_input(event, file, labels):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if file in selected_files:
			selected_files.erase(file)
		else:
			selected_files.append(file)
		set_labels_highlighted(file, labels, file in selected_files)
		if event.doubleclick: # The second toggle undoes the first click's selection change
			oMenu.open_externally(creature_paths.get(file, ""), "Could not find file path for " + file)

func _on_NameStatsButton_pressed():
	name_type += 1
	if name_type >= 3: name_type = 0
	update_list(oStatsOptionButton.selected)

func _on_StatsSortButton_pressed():
	sort_descending = not sort_descending
	oStatsSortButton.rect_rotation = 180 if sort_descending else 0
	oStatsSortButton.hint_tooltip = "Sort descending" if sort_descending else "Sort ascending"
	update_list(oStatsOptionButton.selected)

func _on_ShowUnlistedCreatures_toggled(_pressed):
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
	helptxt += "\n\nClick creatures to highlight them. Double-click a creature to open its highest priority .cfg file in your system's text editor."
	oMessage.big("Help",helptxt)
