extends Label
onready var oSelector = Nodelist.list["oSelector"]
onready var oSelection = Nodelist.list["oSelection"]

var display_id_name = false

func _ready():
	connect("gui_input", self, "_on_gui_input")


func update_text_with_id(slabID, forceUpdate):
	if slabID == null or slabID == -1 or slabID == Slabs.WALL_AUTOMATIC:
		return
	if oSelector.visible == false and forceUpdate == false: return
	
	var slabName
	
	if display_id_name == false:
		slabName = Slabs.fetch_name(slabID)
	else:
		var slabData = Slabs.data.get(slabID)
		if slabData:
			slabName = slabData[Slabs.NAME]
	
	text = slabName + ' : ' + str(slabID)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			display_id_name = !display_id_name
			update_text_with_id(oSelection.cursorOverSlab, true)
