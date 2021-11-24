extends HBoxContainer
onready var oSelection = Nodelist.list["oSelection"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]

var scnOwnerButton = preload("res://Scenes/OnlyOwnershipButton.tscn")
onready var oSelectedRect = get_node("../../Clippy/SelectedRect")

func initialize_grid_items():
	var oGridContainer = currentGridContainer()
#	# Add children
	for i in 6: # +1 is for "Default"
		var id = scnOwnerButton.instance()
		id.connect("pressed", self, "_on_OwnerButtonPressed", [id])
		
		id.connect("mouse_entered", oPickSlabWindow, "_on_hovered_over_item", [id])
		id.connect("mouse_exited", oPickSlabWindow, "_on_hovered_none")
		
		id.set_meta("ownershipID",i)
		id.set_meta("grid_item_text",Constants.ownershipNames[i])
		
		#var col = Constants.ownershipColors[i]
		if i == oSelection.paintOwnership:
			id.pressed = true
		
		#var textLabel = id.get_node("Label")
		
		var keeperColourIconPic = id.get_node("TextureRect")
		match i:
			0: keeperColourIconPic.texture = load("res://edited_images/plyrsym_32/symbol_player_red_std.png")
			1: keeperColourIconPic.texture = load("res://edited_images/plyrsym_32/symbol_player_blue_std.png")
			2: keeperColourIconPic.texture = load("res://edited_images/plyrsym_32/symbol_player_green_std.png")
			3: keeperColourIconPic.texture = load("res://edited_images/plyrsym_32/symbol_player_yellow_std.png")
			4: keeperColourIconPic.texture = load("res://edited_images/plyrsym_32/symbol_player_white_2.png")
			5: keeperColourIconPic.texture = load("res://edited_images/plyrsym_32/symbol_player_any_dis.png")
		
		oGridContainer.add_child(id)

func _on_OwnerButtonPressed(id):
	
	oSelectedRect.boundToItem = id
	oSelectedRect.visible = true
	oSelection.newOwnership(id.get_meta("ownershipID"))

func select_appropriate_button():
	if visible == false: return # Needed because this function can be called when tab isn't visible
	# Select grid item in window
	for id in currentGridContainer().get_children():
		if id is Button:
			if id.get_meta("ownershipID") == oSelection.paintOwnership:
				oSelectedRect.boundToItem = id
				oSelectedRect.visible = true
				id.pressed = true
				# highlight i here


func currentGridContainer():
	return $"ScrollContainer/GridContainer"


func _on_OnlyOwnership_visibility_changed():
	if visible == true:
		select_appropriate_button()
