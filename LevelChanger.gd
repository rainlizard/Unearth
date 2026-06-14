extends SpinBoxPropertiesValue
onready var oInspector = Nodelist.list["oInspector"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oSelector = Nodelist.list["oSelector"]
var zero_key_value = 10
var shortcut_tooltip = "You can also use keyboard keys 0-9 as a shortcut for setting levels"


func _ready():
	get_line_edit().expand_to_text_length = true
	set_tooltip(shortcut_tooltip)

func _input(event):
	if visible == false: return
	if event is InputEventKey and event.pressed == true:
		
		if get_focus_owner() is LineEdit and get_focus_owner() != self:
			return
		if oMapSettingsWindow.visible == true: return
		if oMapBrowser.visible == true: return
		if oTabClmEditor.visible == true: return
		if oSlabsetWindow.visible == true: return
		
		if oSelector.mode == oSelector.MODE_TILE: return
		
		var allowKeyShortcuts = false
		match get_parent().name:
			"PlacingListData": # Placing
				if get_focus_owner() == null or get_focus_owner().get_parent() == self:
					allowKeyShortcuts = true
			"ThingListData": # Hover
				if oInspector.inspectingInstance != null:
					allowKeyShortcuts = true
		
		yield(get_tree(),'idle_frame')
		if allowKeyShortcuts == true:
			var setVal = get_number_key(event.scancode)
			if setVal == null: return
			value = setVal
			get_line_edit().modulate = Color(2,2,2,1)
			for i in 10:
				yield(get_tree(),'idle_frame')
			get_line_edit().modulate = Color(1,1,1,1)


func get_number_key(scancode):
	match scancode:
		KEY_1, KEY_KP_1: return 1
		KEY_2, KEY_KP_2: return 2
		KEY_3, KEY_KP_3: return 3
		KEY_4, KEY_KP_4: return 4
		KEY_5, KEY_KP_5: return 5
		KEY_6, KEY_KP_6: return 6
		KEY_7, KEY_KP_7: return 7
		KEY_8, KEY_KP_8: return 8
		KEY_9, KEY_KP_9: return 9
		KEY_0, KEY_KP_0: return zero_key_value
	return null
