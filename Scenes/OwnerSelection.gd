extends VBoxContainer
onready var oSelection = Nodelist.list["oSelection"]
onready var oOnlyOwnership = Nodelist.list["oOnlyOwnership"]
onready var oUseSlabOwnerCheckBox = Nodelist.list["oUseSlabOwnerCheckBox"]
onready var oOwnershipGridContainer = Nodelist.list["oOwnershipGridContainer"]
onready var oMirrorOptions = Nodelist.list["oMirrorOptions"]
onready var oCollectibleLabel = Nodelist.list["oCollectibleLabel"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var gridItemScene = preload("res://Scenes/GenericGridItem.tscn")
onready var oSelectedRect = $Control/SelectedRect
onready var oCenteredLabel = $Control/CenteredLabel

var ownership_available = true


func update_ownership_head_icons():
	for i in oOwnershipGridContainer.get_children():
		i.free()
	
	var iconSize
	var owner_order
	if oCurrentFormat.selected == 0: # Classic format
		owner_order = [0,1,2,3,4,5]
		oOwnershipGridContainer.columns = 6
		iconSize = Vector2(42, 42)
	else:
		owner_order = [0,1,2,3,6,7,8,4,5]
		oOwnershipGridContainer.columns = 5
		iconSize = Vector2(51, 51)
	
	oOwnershipGridContainer.visible = false
	oOwnershipGridContainer.visible = true
	
	for i in owner_order:
		var id = gridItemScene.instance()
		
		id.set_meta("grid_value", i)
		
		var setText = ""
		match i:
			0: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_red_std.png")
			1: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_blue_std.png")
			2: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_green_std.png")
			3: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_yellow_std.png")
			4: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_white_std.png")
			5: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_any_dis.png")
			6: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_purple_std.png")
			7: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_black_std.png")
			8: id.texture_normal = preload("res://edited_images/plyrsym_32/symbol_player_orange_std.png")
		setText = Constants.ownershipNames[i]
	
		add_child_to_grid(id, setText, iconSize)
	
	set_selection(oSelection.paintOwnership) # Default initial selection


func add_child_to_grid(id, set_text, icon_size):
	oOwnershipGridContainer.add_child(id)
	set_text = set_text.replace(" ","\n") # Use "New lines" wherever there was a space.
	id.set_meta("grid_item_text", set_text)
	id.connect("mouse_entered", self, "_on_hovered_over_item", [id])
	id.connect("mouse_exited", self, "_on_hovered_none")
	id.connect("pressed",self,"pressed",[id])
	id.rect_min_size = icon_size


func pressed(id):
	var setValue = id.get_meta("grid_value")
	if oCollectibleLabel.visible == true:
		return
	elif oUseSlabOwnerCheckBox.pressed == true and oUseSlabOwnerCheckBox.visible == true:
		oUseSlabOwnerCheckBox.pressed = false
	oSelection.paintOwnership = setValue
	set_selection(setValue)
	oOnlyOwnership.select_appropriate_button()


func _process(delta): # It's necessary to use _process to update selection, because ScrollContainer won't fire a signal while you're scrolling.
	update_selection()


func update_selection():
	if oSelectedRect == null: return
	if is_instance_valid(oSelectedRect.boundToItem) == false: return
	
	# If greyed out then don't do anything
	if ownership_available == false:
		oSelectedRect.visible = false
		return
	
	oSelectedRect.visible = true
	oSelectedRect.rect_global_position = oSelectedRect.boundToItem.rect_global_position
	oSelectedRect.rect_size = oSelectedRect.boundToItem.rect_size


func _on_hovered_none():
	oCenteredLabel.get_node("Label").text = ""


func _on_hovered_over_item(id):
	var offset = Vector2(id.rect_size.x * 0.5, id.rect_size.y * 0.5)
	oCenteredLabel.rect_global_position = id.rect_global_position + offset
	oCenteredLabel.get_node("Label").text = id.get_meta("grid_item_text")


func set_selection(value):
	oSelectedRect.visible = false
	
	if value == null:
		oSelectedRect.boundToItem = null
		oSelectedRect.visible = false
		return

	for id in oOwnershipGridContainer.get_children():
		if id.get_meta("grid_value") == value:
			oSelectedRect.boundToItem = id


func collectible_ownership_mode(collMode):
	if collMode == true:
		oCollectibleLabel.visible = true
		oUseSlabOwnerCheckBox.visible = false
	else:
		oCollectibleLabel.visible = false
		oUseSlabOwnerCheckBox.visible = true
	update_ownership_available()


func update_ownership_available():
	ownership_available = true
	oOwnershipGridContainer.modulate.a = 1.00
	
	if oCollectibleLabel.visible == true:
		ownership_available = false
		oOwnershipGridContainer.modulate.a = 0.25
	elif oUseSlabOwnerCheckBox.visible == true and oUseSlabOwnerCheckBox.pressed == true:
		ownership_available = false
		oOwnershipGridContainer.modulate.a = 0.25


#
#func clear_grid():
#	for i in $GridContainer.get_children():
#		$GridContainer.remove_child(i) # Necessary because queue_free() isn't fast enough.
#		i.queue_free()
#
