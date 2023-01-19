extends GridContainer

const scnSpinBoxPropertiesValue = preload("res://Scenes/SpinBoxPropertiesValue.tscn")
const scnLevelChanger = preload("res://Scenes/LevelChanger.tscn")

const thinLineEditTheme = preload("res://Theme/ThinLineEdit.tres")
onready var oInspector = Nodelist.list["oInspector"]
onready var oSelection = Nodelist.list["oSelection"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oUi = Nodelist.list["oUi"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]


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
	var nameValue
	match leftText:
		"Door locked":
			nameValue = OptionButton.new()
			nameValue.add_item("False")
			nameValue.add_item("True")
			
			nameValue.connect("item_selected",self,"_on_optionbutton_item_selected", [leftText])
			for i in nameValue.get_item_count():
				if nameValue.get_item_text(nameValue.get_item_index(i)) == rightText:
					nameValue.selected = i
		"Ownership":
			nameValue = OptionButton.new()
			nameValue.focus_mode = 0 # I don't know whether I need this
			nameValue.get_popup().focus_mode = 0
			nameValue.add_item("Red")
			nameValue.add_item("Blue")
			nameValue.add_item("Green")
			nameValue.add_item("Yellow")
			nameValue.add_item("White")
			nameValue.add_item("None")
			
#			print(nameValue.get_popup().mouse_filter)
			
			nameValue.connect("item_selected",self,"_on_optionbutton_item_selected", [leftText])
			nameValue.connect("toggled",self,"_on_optionbutton_toggled", [nameValue])
			# Select the correct option
			for i in nameValue.get_item_count():
				if nameValue.get_item_text(nameValue.get_item_index(i)) == rightText:
					nameValue.selected = i
		"Level":
			nameValue = scnLevelChanger.instance()
			#nameValue.expand_to_text_length = true
			nameValue.theme = thinLineEditTheme #!!!!!!!!!!!!!
			nameValue.connect("value_changed", self, "_on_property_value_changed", [nameValue, leftText])
			nameValue.get_line_edit().connect("text_changed", self, "_on_property_value_typed_in_manually", [nameValue, leftText])
			nameValue.value = float(rightText)
		"Effect range","Light range","Intensity","Gate #","Point range","Point #","Custom box","Unknown 9","Unknown 10","Unknown 11-12","Unknown 13","Unknown 14","Unknown 15","Unknown 16","Unknown 17","Unknown 18","Unknown 19","Unknown 20":
			nameValue = scnSpinBoxPropertiesValue.instance()
			#nameValue.expand_to_text_length = true
			nameValue.theme = thinLineEditTheme #!!!!!!!!!!!!!
			nameValue.connect("value_changed", self, "_on_property_value_changed", [nameValue, leftText])
			nameValue.get_line_edit().connect("text_changed", self, "_on_property_value_typed_in_manually", [nameValue, leftText])
			nameValue.value = float(rightText)
		"Position":
			var scn = preload('res://Scenes/PositionEditor.tscn')
			nameValue = scn.instance()
			nameValue.set_txt(rightText.split(' '))
			nameValue.connect("position_editor_text_entered", self, "_on_property_value_entered", [nameValue])
			nameValue.connect("position_editor_text_changed", self, "_on_property_value_typed_in_manually", [nameValue, leftText])
			nameValue.connect("position_editor_focus_exited", self, "_on_property_value_focus_exited", [nameValue,leftText])
			
			nameValue.text = rightText
			nameValue.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_END # To handle the other side's autowrap text
			nameValue.align = HALIGN_LEFT
		_:
			nameValue = Label.new()
			nameValue.autowrap = true
			nameValue.rect_min_size.x = columnRightSize
			#if name == "ColumnListData": nameValue.rect_min_size.x = columnRightSize-50
			# This is for when highlighting something in the Thing Window
			if rightText == "":
				nameValue.rect_min_size.x = 0
				nameDesc.autowrap = false
			
			nameValue.text = rightText
			nameValue.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_END # To handle the other side's autowrap text
			nameValue.align = HALIGN_LEFT
	
	add_child(nameValue)

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
	#if callingNode is LineEdit: callingNode.text = float(new_text)
	if callingNode is SpinBox:  callingNode.value = float(new_text)
	update_property_value(callingNode, leftText)

func _on_property_value_changed(new_val, callingNode, leftText):
	update_property_value(callingNode, leftText)

func update_property_value(callingNode, leftText): # This signal will go off first even if you click the "Deselect" button.
	oEditor.mapHasBeenEdited = true
	var inst = oInspector.inspectingInstance
	
	var valueNumber
	#if callingNode is LineEdit: valueNumber = callingNode.text
	if callingNode is SpinBox:
		valueNumber = callingNode.value
	
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
		"Custom box":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.boxNumber = valueNumber
				"PlacingListData":
					oPlacingSettings.boxNumber = valueNumber
		"Level":
			valueNumber = clamp(int(valueNumber), 1, 10)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.creatureLevel = valueNumber
				"PlacingListData":
					oPlacingSettings.creatureLevel = valueNumber
		"Point #":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.pointNumber = valueNumber
				"PlacingListData":
					oPlacingSettings.pointNumber = valueNumber
		"Gate #":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.herogateNumber = valueNumber
				"PlacingListData":
					oPlacingSettings.herogateNumber = valueNumber
		"Intensity":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.lightIntensity = valueNumber
				"PlacingListData":
					oPlacingSettings.lightIntensity = valueNumber
		"Effect range":
			valueNumber = clamp(float(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.effectRange = valueNumber
				"PlacingListData":
					oPlacingSettings.effectRange = valueNumber
		"Light range":
			valueNumber = clamp(float(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.lightRange = valueNumber
				"PlacingListData":
					oPlacingSettings.lightRange = valueNumber
		"Point range":
			valueNumber = clamp(float(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.pointRange = valueNumber
				"PlacingListData":
					oPlacingSettings.pointRange = valueNumber
		"Unknown 9":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data9 = valueNumber
		"Unknown 10":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data10 = valueNumber
		"Unknown 11-12":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data11_12 = valueNumber
		"Unknown 13":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data13 = valueNumber
		"Unknown 14":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data14 = valueNumber
		"Unknown 15":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data15 = valueNumber
		"Unknown 16":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data16 = valueNumber
		"Unknown 17":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data17 = valueNumber
		"Unknown 18":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data18 = valueNumber
		"Unknown 19":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data19 = valueNumber
		"Unknown 20":
			valueNumber = clamp(int(valueNumber), 0, 255)
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.data20 = valueNumber
	
	#if callingNode is LineEdit: callingNode.text = String(valueNumber)
	if callingNode is SpinBox:
		callingNode.value = float(valueNumber)


func _on_optionbutton_toggled(state,nameValue):
	oUi.optionButtonIsOpened = state

func _on_optionbutton_item_selected(indexSelected, leftText): # When pressing Enter on LineEdit, lose focus
	oEditor.mapHasBeenEdited = true
	
	var inst = oInspector.inspectingInstance
	
	match leftText:
		"Ownership":
			oSelection.paintOwnership = indexSelected
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.ownership = oSelection.paintOwnership
				"PlacingListData":
					oPlacingSettings.ownership = oSelection.paintOwnership
		"Door locked":
			match name:
				"ThingListData":
					if is_instance_valid(inst):
						inst.doorLocked = indexSelected
						inst.toggle_spinning_key()
				"PlacingListData":
					oPlacingSettings.doorLocked = indexSelected

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



