extends WindowDialog
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oUniversalDetails = Nodelist.list["oUniversalDetails"]
onready var oGridFunctions = Nodelist.list["oGridFunctions"]
onready var oSelectionStatus = Nodelist.list["oSelectionStatus"]
onready var oUi = Nodelist.list["oUi"]
onready var vboxContainer = $VBoxContainer

var rectChangedTimer = Timer.new()

func _ready():
	get_close_button().expand = true
	get_close_button().hide()
	connect("item_rect_changed",self,"rect_changed_start_timer")
	rectChangedTimer.connect("timeout", oUi, "_on_any_window_was_modified", [self])
	rectChangedTimer.one_shot = true
	add_child(rectChangedTimer)
	
	connect("gui_input",oGridFunctions,"_on_GridWindow_gui_input",[self])
	
	oPropertiesTabs.current_tab = 0
	oSelectionStatus.visible = false

func _on_PropertiesTabs_item_rect_changed():
	# Deferred because this fires mid-sort of vboxContainer, where resizing would drop its re-sort and leave children at a stale width
	call_deferred("fit_to_content")

func fit_to_content():
	rect_size = vboxContainer.get_minimum_size() + Vector2(0,12)

#func _on_PropertiesTabs_tab_changed(tab):
#	pass # Replace with function body.

func rect_changed_start_timer():
	rectChangedTimer.start(0.2)
