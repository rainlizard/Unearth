extends HBoxContainer
onready var oOwnershipGridContainer = Nodelist.list["oOwnershipGridContainer"]
onready var oMirrorPlacementCheckBox = Nodelist.list["oMirrorPlacementCheckBox"]
onready var oMirrorSplitTextureRect = Nodelist.list["oMirrorSplitTextureRect"]
onready var splitNS = preload('res://Art/SplitNS.png')
onready var splitEW = preload('res://Art/SplitEW.png')
onready var splitAll = preload('res://Art/SplitAll.png')
onready var oMirrorColorContainer = Nodelist.list["oMirrorColorContainer"]
onready var oMirrorColor0 = Nodelist.list["oMirrorColor0"]
onready var oMirrorColor1 = Nodelist.list["oMirrorColor1"]
onready var oMirrorColor2 = Nodelist.list["oMirrorColor2"]
onready var oMirrorColor3 = Nodelist.list["oMirrorColor3"]
onready var oMirrorFlipCheckBox = Nodelist.list["oMirrorFlipCheckBox"]

var splitType = 2
var ownerValue = [0,1,2,3]

func _ready():
	oMirrorColor0.color = Constants.ownerRoomCol[ownerValue[0]]
	oMirrorColor1.color = Constants.ownerRoomCol[ownerValue[1]]
	oMirrorColor2.color = Constants.ownerRoomCol[ownerValue[2]]
	oMirrorColor3.color = Constants.ownerRoomCol[ownerValue[3]]
	establish_type()
	_on_MirrorPlacementCheckBox_pressed()
	oMirrorColor0.connect("mouse_entered", self, "mouse_entered_color_node", [oMirrorColor0])
	oMirrorColor1.connect("mouse_entered", self, "mouse_entered_color_node", [oMirrorColor1])
	oMirrorColor2.connect("mouse_entered", self, "mouse_entered_color_node", [oMirrorColor2])
	oMirrorColor3.connect("mouse_entered", self, "mouse_entered_color_node", [oMirrorColor3])
	oMirrorColor0.connect("mouse_exited", self, "mouse_exited_color_node", [oMirrorColor0])
	oMirrorColor1.connect("mouse_exited", self, "mouse_exited_color_node", [oMirrorColor1])
	oMirrorColor2.connect("mouse_exited", self, "mouse_exited_color_node", [oMirrorColor2])
	oMirrorColor3.connect("mouse_exited", self, "mouse_exited_color_node", [oMirrorColor3])

var flashNode
var flashTimer = 0

func mouse_entered_color_node(colorNode):
	flashNode = colorNode
	colorNode.modulate = Color(1,1,1,1)

func mouse_exited_color_node(colorNode):
	flashNode = null
	colorNode.modulate = Color(1,1,1,1)

func _process(delta):
	if is_instance_valid(flashNode):
		flashTimer += delta
		if flashTimer < 0.125:
			flashNode.modulate.a = lerp(flashNode.modulate.a, 2.0, 0.2)
		else:
			flashNode.modulate.a = lerp(flashNode.modulate.a, 1.0, 0.2)
			if flashTimer >= 0.25:
				flashTimer = 0


func _on_SplitDirectionButton_pressed():
	splitType += 1
	if splitType >= 3:
		splitType = 0
	establish_type()

func establish_type():
	match splitType:
		0:
			oMirrorSplitTextureRect.texture = splitNS
			oMirrorColor2.visible = false
			oMirrorColor3.visible = false
			oMirrorColorContainer.columns = 1
			oMirrorFlipCheckBox.visible = true
		1:
			oMirrorSplitTextureRect.texture = splitEW
			oMirrorColor2.visible = false
			oMirrorColor3.visible = false
			oMirrorColorContainer.columns = 2
			oMirrorFlipCheckBox.visible = true
		2:
			oMirrorSplitTextureRect.texture = splitAll
			oMirrorColor2.visible = true
			oMirrorColor3.visible = true
			oMirrorColorContainer.columns = 2
			oMirrorFlipCheckBox.visible = false


func _on_MirrorColor0_gui_input(event):
	gui_input_on_color_fields(event, 0, oMirrorColor0)
func _on_MirrorColor1_gui_input(event):
	gui_input_on_color_fields(event, 1, oMirrorColor1)
func _on_MirrorColor2_gui_input(event):
	gui_input_on_color_fields(event, 2, oMirrorColor2)
func _on_MirrorColor3_gui_input(event):
	gui_input_on_color_fields(event, 3, oMirrorColor3)

func gui_input_on_color_fields(event, buttonIndex, buttonNode):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:
			var colorIndex = Constants.ownerRoomCol.find(buttonNode.color)
			if colorIndex != -1:
				var newIdx
				match event.button_index:
					BUTTON_LEFT:
						newIdx = colorIndex+1
						if newIdx >= Constants.ownerRoomCol.size():
							newIdx = 0
					BUTTON_RIGHT:
						newIdx = colorIndex-1
						if newIdx < 0:
							newIdx = Constants.ownerRoomCol.size()-1
				
				buttonNode.color = Constants.ownerRoomCol[newIdx]
				ownerValue[buttonIndex] = newIdx


func _on_MirrorPlacementCheckBox_pressed():
	visible = oMirrorPlacementCheckBox.pressed

func get_quadrant(pos, fieldX, fieldY):
	match splitType:
		0:
			if pos.y < floor(fieldY*0.5):
				return 0
			else:
				return 1
		1:
			if pos.x < floor(fieldX*0.5):
				return 0
			else:
				return 1
		2:
			if pos.y < floor(fieldY*0.5):
				if pos.x < floor(fieldX*0.5):
					return 0
				else:
					return 1
			else:
				if pos.x < floor(fieldX*0.5):
					return 2
				else:
					return 3


func mirror_calculation(performAction, flip, fromPos, fieldX, fieldY):
	match performAction:
		0: # Other vertical
			if flip == true and splitType == 0:
				return Vector2(fieldX - fromPos.x - 1, fieldY - fromPos.y - 1)
			else:
				return Vector2(fromPos.x, fieldY - fromPos.y - 1)
		1: # Other horizontal
			if flip == true and splitType == 1:
				return Vector2(fieldX - fromPos.x - 1, fieldY - fromPos.y - 1)
			else:
				return Vector2(fieldX - fromPos.x - 1, fromPos.y)
		2: # Other diagonal
			return Vector2(fieldX - fromPos.x - 1, fieldY - fromPos.y - 1)
