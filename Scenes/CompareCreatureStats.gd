extends WindowDialog
onready var oGame = Nodelist.list["oGame"]
onready var oSortCreaStatsGrid = Nodelist.list["oSortCreaStatsGrid"]
onready var oStatsOptionButton = Nodelist.list["oStatsOptionButton"]


var all_creature_data = {}

var selected_labels = []

func _ready():
	for i in 10:
		yield(get_tree(),'idle_frame')
	
	var CODETIME_START = OS.get_ticks_msec()
	var listOfCfgs = Utils.get_filetype_in_directory(oGame.GAME_DIRECTORY.plus_file("creatrs"), "CFG")
	for path in listOfCfgs:
		var aaa = Utils.read_dkcfg_file(path)
		all_creature_data[path.get_file()] = aaa
	
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	populate_optionbutton()
	
	
	# Default selection
	oStatsOptionButton.select(2)
	_on_StatsOptionButton_item_selected(2)
	
	Utils.popup_centered(self)

func _on_StatsOptionButton_item_selected(optionButtonIndex):
	update_list(optionButtonIndex)

func update_list(optionButtonIndex):
	
	var list_data = []
	for i in oSortCreaStatsGrid.get_children():
		i.free()
	
	var optionButtonMeta = oStatsOptionButton.get_item_metadata(optionButtonIndex)
	
	for file in all_creature_data:
		var getName = all_creature_data[file].get("attributes").get("Name")
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
		add_entry(i[0], i[1], col)


func sort_list(a, b):
	
	var compareA
	var compareB
	
	if a[1] is int:
		compareA = a[1]
	elif a[1] is String:
		compareA = a[1].length()
	elif a[1] is Array:
		compareA = int(a[1][0])
	else:
		compareA = 0
	
	if b[1] is int:
		compareB = b[1]
	elif b[1] is String:
		compareB = b[1].length()
	elif b[1] is Array:
		compareB = int(b[1][0])
	else:
		compareB = 0
	return compareA < compareB

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
	var items_checked = 0
	for file in all_creature_data:
		items_checked += 1
		for section in all_creature_data[file]:
			if items_checked == 1:
				for key in all_creature_data[file][section].keys():
					var idx = oStatsOptionButton.get_item_count()
					oStatsOptionButton.add_item(key)
					oStatsOptionButton.set_item_metadata(idx, [section, key])
				oStatsOptionButton.add_separator()
