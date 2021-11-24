extends WindowDialog
onready var oPropertiesTabs = Nodelist.list["oPropertiesTabs"]
onready var oUniversalDetails = Nodelist.list["oUniversalDetails"]
onready var oGridFunctions = Nodelist.list["oGridFunctions"]
onready var oSelectionStatus = Nodelist.list["oSelectionStatus"]

const bottomMargin = 17

func _ready():
	$VBoxContainer.margin_left = 6
	$VBoxContainer.margin_top = 6
	$VBoxContainer.margin_bottom = -6
	$VBoxContainer.margin_right = -6
	rect_min_size.x = 311
	
	get_close_button().expand = true
	get_close_button().hide()
	connect("item_rect_changed",oGridFunctions,"_on_GridWindow_item_rect_changed", [self])
	connect("gui_input",oGridFunctions,"_on_GridWindow_gui_input",[self])
	
	oPropertiesTabs.current_tab = 0
	oSelectionStatus.visible = false

func _on_PropertiesTabs_item_rect_changed():
	# Very good code to adjust the window size based on the contents
	oPropertiesTabs.disconnect("item_rect_changed",self,"_on_PropertiesTabs_item_rect_changed")
	rect_size = oPropertiesTabs.rect_size + Vector2(0,bottomMargin+oUniversalDetails.rect_size.y) #25+
	oPropertiesTabs.connect("item_rect_changed",self,"_on_PropertiesTabs_item_rect_changed")


func _on_PropertiesTabs_tab_changed(tab):
	pass # Replace with function body.
