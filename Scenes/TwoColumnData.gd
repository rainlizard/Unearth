extends GridContainer

const scnSpinBoxPropertiesValue = preload("res://Scenes/SpinBoxPropertiesValue.tscn")
const scnLevelChanger = preload("res://Scenes/LevelChanger.tscn")

const thinLineEditTheme = preload("res://Theme/ThinLineEdit.tres")
onready var oInspector = Nodelist.list["oInspector"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oUi = Nodelist.list["oUi"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oMirrorOptions = Nodelist.list["oMirrorOptions"]
onready var oMirrorPlacementCheckBox = Nodelist.list["oMirrorPlacementCheckBox"]
onready var oInstances = Nodelist.list["oInstances"]
onready var oMessage = Nodelist.list["oMessage"]


const columnLeftSize = 120
const columnRightSize = 150

func _ready():
	columns = 2

func add_item(leftString, rightString):
	# Left column item
	var nameDesc = Label.new()
	nameDesc.align = HALIGN_LEFT
	nameDesc.text = leftString
	nameDesc.autowrap = true
	nameDesc.rect_min_size.x = columnLeftSize # minimum text width based on the word: "Floor texture"
	nameDesc.valign = VALIGN_TOP
	nameDesc.size_flags_vertical = Control.SIZE_FILL # To handle the other side's autowrap text
	
	add_child(nameDesc)
	
	# Right column item
	var nodeRightColumn
	match leftString:
		"Door locked":
			nodeRightColumn = OptionButton.new()
			nodeRightColumn.add_item("False")
			nodeRightColumn.add_item("True")
			
			nodeRightColumn.connect("item_selected",self,"_on_optionbutton_item_selected", [leftString])
			nodeRightColumn.connect("toggled",self,"_on_optionbutton_toggled", [nodeRightColumn])
			for i in nodeRightColumn.get_item_count():
				if nodeRightColumn.get_item_text(nodeRightColumn.get_item_index(i)) == rightString:
					nodeRightColumn.selected = i
		"Ownership":
			nodeRightColumn = OptionButton.new()
			nodeRightColumn.focus_mode = 0 # Fixes clicking on the menu
			nodeRightColumn.get_popup().focus_mode = 0 # Fixes clicking on the menu
			nodeRightColumn.add_item("Red")
			nodeRightColumn.add_item("Blue")
			nodeRightColumn.add_item("Green")
			nodeRightColumn.add_item("Yellow")
			nodeRightColumn.add_item("White")
			nodeRightColumn.add_item("None")
			
#			print(nodeRightColumn.get_popup().mouse_filter)
			
			nodeRightColumn.connect("item_selected",self,"_on_optionbutton_item_selected", [leftString])
			nodeRightColumn.connect("toggled",self,"_on_optionbutton_toggled", [nodeRightColumn])
			# Select the correct option
			for i in nodeRightColumn.get_item_count():
				if nodeRightColumn.get_item_text(nodeRightColumn.get_item_index(i)) == rightString:
					nodeRightColumn.selected = i
		"Level":
			nodeRightColumn = scnLevelChanger.instance()
			#nodeRightColumn.expand_to_text_length = true
			nodeRightColumn.theme = thinLineEditTheme #!!!!!!!!!!!!!
			nodeRightColumn.connect("value_changed", self, "_on_property_value_changed", [nodeRightColumn, leftString])
			nodeRightColumn.get_line_edit().connect("text_changed", self, "_on_property_value_typed_in_manually", [nodeRightColumn, leftString])
			nodeRightColumn.value = float(rightString)
		"Effect range","Light range","Intensity","Gate #","Point range","Point #","Custom box","Unknown 9","Unknown 10","Unknown 11-12","Unknown 13","Unknown 14","Unknown 15","Unknown 16","Unknown 17","Unknown 18","Unknown 19","Unknown 20","Gold held","Health %","Gold value":
			nodeRightColumn = scnSpinBoxPropertiesValue.instance()
			#nodeRightColumn.expand_to_text_length = true
			nodeRightColumn.theme = thinLineEditTheme #!!!!!!!!!!!!!
			nodeRightColumn.connect("value_changed", self, "_on_property_value_changed", [nodeRightColumn, leftString])
			nodeRightColumn.get_line_edit().connect("text_changed", self, "_on_property_value_typed_in_manually", [nodeRightColumn, leftString])
			
			match leftString:
				"Gold held","Gold value":
					nodeRightColumn.min_value = 0
					nodeRightColumn.max_value = 1000000000
					nodeRightColumn.get_line_edit().placeholder_text = "0"
					nodeRightColumn.get_line_edit().placeholder_alpha = 0.33
				"Health %":
					nodeRightColumn.min_value = 0
					nodeRightColumn.max_value = 100
					nodeRightColumn.get_line_edit().placeholder_text = "100"
					nodeRightColumn.get_line_edit().placeholder_alpha = 0.33
			
			nodeRightColumn.value = int(rightString)
		"Position":
			var scn = preload('res://Scenes/PositionEditor.tscn')
			nodeRightColumn = scn.instance()
			nodeRightColumn.set_txt(rightString.split(' '))
			nodeRightColumn.connect("position_editor_text_entered", self, "_on_property_value_entered", [nodeRightColumn])
			nodeRightColumn.connect("position_editor_text_changed", self, "_on_property_value_typed_in_manually", [nodeRightColumn, leftString])
			nodeRightColumn.connect("position_editor_focus_exited", self, "_on_property_value_focus_exited", [nodeRightColumn,leftString])
			
			nodeRightColumn.text = rightString
			nodeRightColumn.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_END # To handle the other side's autowrap text
			nodeRightColumn.align = HALIGN_LEFT
		"Orientation":
			nodeRightColumn = OptionButton.new()
			nodeRightColumn.focus_mode = 0 # Fixes clicking on the menu
			nodeRightColumn.get_popup().focus_mode = 0 # Fixes clicking on the menu
			
			# The order of this list must match the listOrientations array in Constants
			nodeRightColumn.add_item("North")
			nodeRightColumn.add_item("NorthEast")
			nodeRightColumn.add_item("East")
			nodeRightColumn.add_item("SouthEast")
			nodeRightColumn.add_item("South")
			nodeRightColumn.add_item("SouthWest")
			nodeRightColumn.add_item("West")
			nodeRightColumn.add_item("NorthWest")
			
			nodeRightColumn.connect("item_selected",self,"_on_optionbutton_item_selected", [leftString])
			nodeRightColumn.connect("toggled",self,"_on_optionbutton_toggled", [nodeRightColumn])
			# Select the correct option
			var orientIndex = Constants.listOrientations.find(int(rightString))
			if orientIndex != -1:
				nodeRightColumn.selected = orientIndex
		"Name": #Creature name
			nodeRightColumn = LineEdit.new()
			nodeRightColumn.placeholder_text = "Default"
			nodeRightColumn.placeholder_alpha = 0.33
			nodeRightColumn.text = rightString #Utils.strip_special_chars_from_string(rightString)
			nodeRightColumn.connect("text_changed", self, "_on_property_value_changed", [nodeRightColumn, leftString])
		_:
			nodeRightColumn = Label.new()
			nodeRightColumn.autowrap = true
			nodeRightColumn.rect_min_size.x = columnRightSize
			#if name == "ColumnListData": nodeRightColumn.rect_min_size.x = columnRightSize-50
			# This is for when highlighting something in the Thing Window
			if rightString == "":
				nodeRightColumn.rect_min_size.x = 0
				nameDesc.autowrap = false
			
			nodeRightColumn.text = rightString
			nodeRightColumn.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_END # To handle the other side's autowrap text
			nodeRightColumn.align = HALIGN_LEFT
	
	add_child(nodeRightColumn)

func _on_property_value_entered(new_val, callingNode): # When pressing Enter on LineEdit, lose focus
	oEditor.mapHasBeenEdited = true
	callingNode.release_focus()

func _on_property_value_focus_exited(callingNode, leftString):
	match leftString:
		"Position":
			callingNode.oLineEditX.text = str(clamp(float(callingNode.oLineEditX.text), 0.0, M.xSize*3))
			callingNode.oLineEditY.text = str(clamp(float(callingNode.oLineEditY.text), 0.0, M.ySize*3))
			if callingNode.oLineEditZ.visible == true: # For the sake of ActionPoint
				callingNode.oLineEditZ.text = str(clamp(float(callingNode.oLineEditZ.text), 0.0, 255.0))
#	if callingNode is SpinBox:
#		callingNode.value = float(callingNode.value)
	update_property_value(callingNode, leftString)

func _on_property_value_typed_in_manually(new_text, callingNode, leftString):
	if callingNode is LineEdit: callingNode.text = new_text
	if callingNode is SpinBox:  callingNode.value = float(new_text)
	update_property_value(callingNode, leftString)

func _on_property_value_changed(new_val, callingNode, leftString):
	update_property_value(callingNode, leftString)

func update_property_value(callingNode, leftString):
	oEditor.mapHasBeenEdited = true
	var inst = oInspector.inspectingInstance
	
	var property_name
	var value
	# Extract value from the calling node
	if callingNode is SpinBox: value = callingNode.value
	elif callingNode is LineEdit: value = callingNode.text
	
	# Adjustments based on the property
	match leftString:
		"Position":
			if is_instance_valid(inst):
				var originalLocation = Vector2(inst.locationX,inst.locationY)
				inst.locationX = clamp(float(callingNode.oLineEditX.text), 0.0, M.xSize*3)
				inst.locationY = clamp(float(callingNode.oLineEditY.text), 0.0, M.xSize*3)
				if callingNode.oLineEditZ.visible == true: # For the sake of ActionPoint
					inst.locationZ = clamp(float(callingNode.oLineEditZ.text), 0.0, M.xSize*3)
				oInstances.mirror_adjusted_value(inst, "locationXYZ", originalLocation)
				oInspector.set_inspector_subtile(Vector2(inst.locationX,inst.locationY))
			return # Exit after handling "Position"
		"Custom box":
			property_name = "boxNumber"
			value = clamp(int(value), 0, 255)
		"Level":
			property_name = "creatureLevel"
			value = clamp(int(value), 1, 10)
		"Point #":
			property_name = "pointNumber"
			value = clamp(int(value), 0, 255)
		"Gate #":
			property_name = "herogateNumber"
			value = clamp(int(value), 0, 255)
		"Intensity":
			property_name = "lightIntensity"
			value = clamp(float(value), 0, 255)
		"Effect range":
			property_name = "effectRange"
			value = clamp(float(value), 0, 255)
		"Light range":
			property_name = "lightRange"
			value = clamp(float(value), 0, 255)
		"Point range":
			property_name = "pointRange"
			value = clamp(float(value), 0, 255)
		"Name":
			property_name = "creatureName"
			# String, so no clamping
		"Gold held":
			property_name = "creatureGold"
			value = clamp(int(value), 0, 1000000000)
		"Health %":
			property_name = "creatureInitialHealth"
			value = clamp(int(value), 0, 100)
		"Orientation":
			property_name = "orientation"
			value = clamp(int(value), 0, 2047)
		"Gold value":
			property_name = "goldValue"
			value = clamp(int(value), 0, 1000000000)
		"Unknown 9":
			property_name = "data9"
			value = clamp(int(value), 0, 255)
		"Unknown 10":
			property_name = "data10"
			value = clamp(int(value), 0, 255)
		"Unknown 11-12":
			property_name = "data11_12"
			value = clamp(int(value), 0, 255)
		"Unknown 13":
			property_name = "data13"
			value = clamp(int(value), 0, 255)
		"Unknown 14":
			property_name = "data14"
			value = clamp(int(value), 0, 255)
		"Unknown 15":
			property_name = "data15"
			value = clamp(int(value), 0, 255)
		"Unknown 16":
			property_name = "data16"
			value = clamp(int(value), 0, 255)
		"Unknown 17":
			property_name = "data17"
			value = clamp(int(value), 0, 255)
		"Unknown 18-19":
			property_name = "data18_19"
			value = clamp(int(value), 0, 1000000000)
		"Unknown 20":
			property_name = "data20"
			value = clamp(int(value), 0, 255)
		"_":
			print("Warning: Property leftString isn't recognized.")
			return # Exit if the property isn't recognized
	
	# Adjust SpinBox if applicable
	if callingNode is SpinBox:
		callingNode.value = float(value)
		callingNode.get_line_edit().caret_position = callingNode.get_line_edit().text.length()
	
	# Determine whether if we're adjusting an inspected instance (ThingListData) or the Placing Settings (PlacingListData)
	match name:
		"ThingListData":
			if is_instance_valid(inst):
				inst.set(property_name, value)
				oInstances.mirror_adjusted_value(inst, property_name, Vector2(inst.locationX, inst.locationY))
		"PlacingListData":
			oPlacingSettings.set(property_name, value)

func _on_optionbutton_item_selected(indexSelected, leftString):
	oEditor.mapHasBeenEdited = true
	var inst = oInspector.inspectingInstance
	var property_name = ""
	var value
	
	match leftString:
		"Ownership":
			oSelection.paintOwnership = indexSelected
			property_name = "ownership"
			value = indexSelected
		"Orientation":
			property_name = "orientation"
			value = Constants.listOrientations[indexSelected]
		"Door locked":
			property_name = "doorLocked"
			value = indexSelected
			if name == "ThingListData":
				if is_instance_valid(inst):
					inst.set(property_name, value) # Must be set before update_spinning_key()
					inst.update_spinning_key()
	
	# Determine whether if we're adjusting an inspected instance (ThingListData) or the Placing Settings (PlacingListData)
	match name:
		"ThingListData":
			if is_instance_valid(inst):
				inst.set(property_name, value)
				oInstances.mirror_adjusted_value(inst, property_name, Vector2(inst.locationX, inst.locationY))
		"PlacingListData":
			oPlacingSettings.set(property_name, value)

func _on_optionbutton_toggled(state,nodeRightColumn):
	oUi.optionButtonIsOpened = state

#func _on_lineedit_focus_entered(lineEditId): # When pressing Enter on LineEdit, lose focus
#	for i in 1:
#		yield(get_tree(),'idle_frame')
#
#	lineEditId.select_all()

func clear():
	delete_children(self)

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n) #important to do this otherwise the margins get messed up
		n.queue_free()



