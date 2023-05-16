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

func add_item(leftText, rightText):
	# Left column item
	var nameDesc = Label.new()
	nameDesc.align = HALIGN_LEFT
	nameDesc.text = leftText
	nameDesc.autowrap = true
	nameDesc.rect_min_size.x = columnLeftSize # minimum text width based on the word: "Floor texture"
	nameDesc.valign = VALIGN_TOP
	nameDesc.size_flags_vertical = Control.SIZE_FILL # To handle the other side's autowrap text
	
	add_child(nameDesc)
	
	# Right column item
	var nodeRightColumn
	match leftText:
		"Door locked":
			nodeRightColumn = OptionButton.new()
			nodeRightColumn.add_item("False")
			nodeRightColumn.add_item("True")
			
			nodeRightColumn.connect("item_selected",self,"_on_optionbutton_item_selected", [leftText])
			for i in nodeRightColumn.get_item_count():
				if nodeRightColumn.get_item_text(nodeRightColumn.get_item_index(i)) == rightText:
					nodeRightColumn.selected = i
		"Ownership":
			nodeRightColumn = OptionButton.new()
			nodeRightColumn.focus_mode = 0 # I don't know whether I need this
			nodeRightColumn.get_popup().focus_mode = 0
			nodeRightColumn.add_item("Red")
			nodeRightColumn.add_item("Blue")
			nodeRightColumn.add_item("Green")
			nodeRightColumn.add_item("Yellow")
			nodeRightColumn.add_item("White")
			nodeRightColumn.add_item("None")
			
#			print(nodeRightColumn.get_popup().mouse_filter)
			
			nodeRightColumn.connect("item_selected",self,"_on_optionbutton_item_selected", [leftText])
			nodeRightColumn.connect("toggled",self,"_on_optionbutton_toggled", [nodeRightColumn])
			# Select the correct option
			for i in nodeRightColumn.get_item_count():
				if nodeRightColumn.get_item_text(nodeRightColumn.get_item_index(i)) == rightText:
					nodeRightColumn.selected = i
		"Level":
			nodeRightColumn = scnLevelChanger.instance()
			#nodeRightColumn.expand_to_text_length = true
			nodeRightColumn.theme = thinLineEditTheme #!!!!!!!!!!!!!
			nodeRightColumn.connect("value_changed", self, "_on_property_value_changed", [nodeRightColumn, leftText])
			nodeRightColumn.get_line_edit().connect("text_changed", self, "_on_property_value_typed_in_manually", [nodeRightColumn, leftText])
			nodeRightColumn.value = float(rightText)
		"Effect range","Light range","Intensity","Gate #","Point range","Point #","Custom box","Unknown 9","Unknown 10","Unknown 11-12","Unknown 13","Unknown 14","Unknown 15","Unknown 16","Unknown 17","Unknown 18","Unknown 19","Unknown 20","Gold held","Health %":
			nodeRightColumn = scnSpinBoxPropertiesValue.instance()
			#nodeRightColumn.expand_to_text_length = true
			nodeRightColumn.theme = thinLineEditTheme #!!!!!!!!!!!!!
			nodeRightColumn.connect("value_changed", self, "_on_property_value_changed", [nodeRightColumn, leftText])
			nodeRightColumn.get_line_edit().connect("text_changed", self, "_on_property_value_typed_in_manually", [nodeRightColumn, leftText])
			nodeRightColumn.value = int(rightText)
			
			match leftText:
				"Gold held":
					nodeRightColumn.min_value = 0
					nodeRightColumn.max_value = 1000000
					nodeRightColumn.get_line_edit().placeholder_text = "0"
					nodeRightColumn.get_line_edit().placeholder_alpha = 0.33
				"Health %":
					nodeRightColumn.min_value = 0
					nodeRightColumn.max_value = 100
					nodeRightColumn.get_line_edit().placeholder_text = "100"
					nodeRightColumn.get_line_edit().placeholder_alpha = 0.33
		"Position":
			var scn = preload('res://Scenes/PositionEditor.tscn')
			nodeRightColumn = scn.instance()
			nodeRightColumn.set_txt(rightText.split(' '))
			nodeRightColumn.connect("position_editor_text_entered", self, "_on_property_value_entered", [nodeRightColumn])
			nodeRightColumn.connect("position_editor_text_changed", self, "_on_property_value_typed_in_manually", [nodeRightColumn, leftText])
			nodeRightColumn.connect("position_editor_focus_exited", self, "_on_property_value_focus_exited", [nodeRightColumn,leftText])
			
			nodeRightColumn.text = rightText
			nodeRightColumn.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_END # To handle the other side's autowrap text
			nodeRightColumn.align = HALIGN_LEFT
		"Facing":
			nodeRightColumn = OptionButton.new()
			nodeRightColumn.add_item("North")
			nodeRightColumn.add_item("NorthEast")
			nodeRightColumn.add_item("East")
			nodeRightColumn.add_item("SouthEast")
			nodeRightColumn.add_item("South")
			nodeRightColumn.add_item("SouthWest")
			nodeRightColumn.add_item("West")
			nodeRightColumn.add_item("NorthWest")
		"Name": #Creature name
			nodeRightColumn = LineEdit.new()
			nodeRightColumn.placeholder_text = "Default"
			nodeRightColumn.placeholder_alpha = 0.33
			nodeRightColumn.text = rightText #Utils.strip_special_chars_from_string(rightText)
			nodeRightColumn.connect("text_changed", self, "_on_property_value_changed", [nodeRightColumn, leftText])
		_:
			nodeRightColumn = Label.new()
			nodeRightColumn.autowrap = true
			nodeRightColumn.rect_min_size.x = columnRightSize
			#if name == "ColumnListData": nodeRightColumn.rect_min_size.x = columnRightSize-50
			# This is for when highlighting something in the Thing Window
			if rightText == "":
				nodeRightColumn.rect_min_size.x = 0
				nameDesc.autowrap = false
			
			nodeRightColumn.text = rightText
			nodeRightColumn.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_END # To handle the other side's autowrap text
			nodeRightColumn.align = HALIGN_LEFT
	
	add_child(nodeRightColumn)

func _on_property_value_entered(new_val, callingNode): # When pressing Enter on LineEdit, lose focus
	oEditor.mapHasBeenEdited = true
	callingNode.release_focus()

func _on_property_value_focus_exited(callingNode, leftText):
	match leftText:
		"Position":
			callingNode.oLineEditX.text = str(clamp(float(callingNode.oLineEditX.text), 0.0, M.xSize*3))
			callingNode.oLineEditY.text = str(clamp(float(callingNode.oLineEditY.text), 0.0, M.xSize*3))
			if callingNode.oLineEditZ.visible == true: # For the sake of ActionPoint
				callingNode.oLineEditZ.text = str(clamp(float(callingNode.oLineEditZ.text), 0.0, M.xSize*3))
#	if callingNode is SpinBox:
#		callingNode.value = float(callingNode.value)
	update_property_value(callingNode, leftText)

func _on_property_value_typed_in_manually(new_text, callingNode, leftText):
	if callingNode is LineEdit: callingNode.text = new_text
	if callingNode is SpinBox:  callingNode.value = float(new_text)
	update_property_value(callingNode, leftText)

func _on_property_value_changed(new_val, callingNode, leftText):
	update_property_value(callingNode, leftText)

func update_property_value(callingNode, leftText): # This signal will go off first even if you click the "Deselect" button.
	oEditor.mapHasBeenEdited = true
	var inst = oInspector.inspectingInstance
	
	var value
	
	if callingNode is SpinBox:
		value = callingNode.value
	elif callingNode is LineEdit:
		value = callingNode.text
	
	var aValueWasAdjustedSoMirrorIt = ""
	
	match leftText:
		"Position":
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.locationX = clamp(float(callingNode.oLineEditX.text), 0.0, M.xSize*3)
						inst.locationY = clamp(float(callingNode.oLineEditY.text), 0.0, M.xSize*3)
						if callingNode.oLineEditZ.visible == true: # For the sake of ActionPoint
							inst.locationZ = clamp(float(callingNode.oLineEditZ.text), 0.0, M.xSize*3)
						oInspector.set_inspector_subtile(Vector2(inst.locationX,inst.locationY))
						
						if oMirrorPlacementCheckBox.pressed == true:
							oMessage.quick("Note: Position adjustments are not made symmetrical.")
		"Custom box":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.boxNumber = value
						aValueWasAdjustedSoMirrorIt = "boxNumber"
				"PlacingListData":
					oPlacingSettings.boxNumber = value
		"Level":
			value = clamp(int(value), 1, 10)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.creatureLevel = value
						aValueWasAdjustedSoMirrorIt = "creatureLevel"
				"PlacingListData":
					oPlacingSettings.creatureLevel = value
		"Point #":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.pointNumber = value
				"PlacingListData":
					oPlacingSettings.pointNumber = value
		"Gate #":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.herogateNumber = value
				"PlacingListData":
					oPlacingSettings.herogateNumber = value
		"Intensity":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.lightIntensity = value
						aValueWasAdjustedSoMirrorIt = "lightIntensity"
				"PlacingListData":
					oPlacingSettings.lightIntensity = value
		"Effect range":
			value = clamp(float(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.effectRange = value
						aValueWasAdjustedSoMirrorIt = "effectRange"
				"PlacingListData":
					oPlacingSettings.effectRange = value
		"Light range":
			value = clamp(float(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.lightRange = value
						aValueWasAdjustedSoMirrorIt = "lightRange"
				"PlacingListData":
					oPlacingSettings.lightRange = value
		"Point range":
			value = clamp(float(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.pointRange = value
						aValueWasAdjustedSoMirrorIt = "pointRange"
				"PlacingListData":
					oPlacingSettings.pointRange = value
		"Unknown 9":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data9 = value
		"Unknown 10":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data10 = value
		"Unknown 11-12":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data11_12 = value
		"Unknown 13":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data13 = value
		"Unknown 14":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data14 = value
		"Unknown 15":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data15 = value
		"Unknown 16":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data16 = value
		"Unknown 17":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data17 = value
		"Unknown 18":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data18 = value
		"Unknown 19":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data19 = value
		"Unknown 20":
			value = clamp(int(value), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data20 = value
		"Name": #Creature name
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.creatureName = value
						aValueWasAdjustedSoMirrorIt = "creatureLevel"
				"PlacingListData":
					oPlacingSettings.creatureName = value
		"Gold held":
			value = clamp(int(value), 0, 1000000)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.goldHeld = value
						aValueWasAdjustedSoMirrorIt = "goldHeld"
				"PlacingListData":
					oPlacingSettings.goldHeld = value
		"Health %":
			value = clamp(int(value), 0, 100)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.initialHealth = value
						aValueWasAdjustedSoMirrorIt = "initialHealth"
				"PlacingListData":
					oPlacingSettings.initialHealth = value
		"Facing":
			value = clamp(int(value), 0, 2047)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.facingDirection = value
						aValueWasAdjustedSoMirrorIt = "facingDirection"
				"PlacingListData":
					oPlacingSettings.facingDirection = value
	
	if callingNode is SpinBox:
		callingNode.value = float(value)
		callingNode.get_line_edit().caret_position = callingNode.get_line_edit().text.length()
	
	if oMirrorPlacementCheckBox.pressed == true:
		if aValueWasAdjustedSoMirrorIt != "":
			oInstances.mirror_adjusted_value(inst, aValueWasAdjustedSoMirrorIt)

func _on_optionbutton_toggled(state,nodeRightColumn):
	oUi.optionButtonIsOpened = state

func _on_optionbutton_item_selected(indexSelected, leftText): # When pressing Enter on LineEdit, lose focus
	oEditor.mapHasBeenEdited = true
	
	var inst = oInspector.inspectingInstance
	
	var aValueWasAdjustedSoMirrorIt = ""
	
	match leftText:
		"Ownership":
			oSelection.paintOwnership = indexSelected
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.ownership = oSelection.paintOwnership
						aValueWasAdjustedSoMirrorIt = "ownership"
				"PlacingListData":
					oPlacingSettings.ownership = oSelection.paintOwnership
		"Door locked":
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.doorLocked = indexSelected
						inst.update_spinning_key()
						aValueWasAdjustedSoMirrorIt = "doorLocked"
				"PlacingListData":
					oPlacingSettings.doorLocked = indexSelected
	
	if oMirrorPlacementCheckBox.pressed == true:
		if aValueWasAdjustedSoMirrorIt != "":
			oInstances.mirror_adjusted_value(inst, aValueWasAdjustedSoMirrorIt)

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



