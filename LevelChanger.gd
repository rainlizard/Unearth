extends SpinBoxPropertiesValue
onready var oInspector = Nodelist.list["oInspector"]
onready var oMapSettingsWindow = Nodelist.list["oMapSettingsWindow"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]
onready var oTabClmEditor = Nodelist.list["oTabClmEditor"]
onready var oSlabsetWindow = Nodelist.list["oSlabsetWindow"]
onready var oSelector = Nodelist.list["oSelector"]


func _ready():
	get_line_edit().expand_to_text_length = true
	set_tooltip("You can also use keyboard keys 0-9 as a shortcut for setting levels")

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
			var setVal
			match event.scancode:
				KEY_1, KEY_KP_1: setVal = 1
				KEY_2, KEY_KP_2: setVal = 2
				KEY_3, KEY_KP_3: setVal = 3
				KEY_4, KEY_KP_4: setVal = 4
				KEY_5, KEY_KP_5: setVal = 5
				KEY_6, KEY_KP_6: setVal = 6
				KEY_7, KEY_KP_7: setVal = 7
				KEY_8, KEY_KP_8: setVal = 8
				KEY_9, KEY_KP_9: setVal = 9
				KEY_0, KEY_KP_0:
					setVal = 10
					get_line_edit().text = "10"
			
			if setVal != null:
				value = setVal
				get_line_edit().modulate = Color(2,2,2,1)
				for i in 10:
					yield(get_tree(),'idle_frame')
				get_line_edit().modulate = Color(1,1,1,1)
