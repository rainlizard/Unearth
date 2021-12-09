extends VBoxContainer
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oDungeonStyleList = Nodelist.list["oDungeonStyleList"]
onready var oMapNameLineEdit = Nodelist.list["oMapNameLineEdit"]
onready var oDataLif = Nodelist.list["oDataLif"]

func _on_MapProperties_visibility_changed():
	if is_instance_valid(oDungeonStyleList) == false: return
	
	for i in oDungeonStyleList.get_children():
		i.queue_free()
	
	if visible == true:
		initialize_dungeon_style_options()
		oMapNameLineEdit.text = oDataLif.data

func _on_MapNameLineEdit_text_changed(new_text):
	oDataLif.data = new_text
	oEditor.mapHasBeenEdited = true
#	yield(get_tree(),'idle_frame')
#	rect_size.x = oMapNameLineEdit.rect_size.x+50

func initialize_dungeon_style_options():
	for i in oTextureCache.cachedTextures.size():
		var aaa = CheckBox.new()
		if i == oDataLevelStyle.data:
			aaa.pressed = true
		aaa.group = load("res://Theme/ButtonGroupDungeonStyle.tres")
		#aaa.text = "tmapa" + str(i).pad_zeros(3) + ".dat"
		if Constants.TEXTURE_MAP_NAMES.has(i) == true:
			aaa.text = Constants.TEXTURE_MAP_NAMES[i]
		else:
			aaa.text = 'Texture map ' + str(i)
		aaa.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_CENTER
		aaa.size_flags_horizontal = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_CENTER
		aaa.connect("pressed",self,"_on_DungeonStyleButtonPressed",[i])
		oDungeonStyleList.add_child(aaa)
	
#	disconnect("visibility_changed", self, "_on_MapProperties_visibility_changed")
#	hide()
#	yield(get_tree(),'idle_frame')
	#rect_min_size = $VBoxContainer.rect_size + Vector2(80,40)
#	Utils.popup_centered(self)
#	connect("visibility_changed", self, "_on_MapProperties_visibility_changed")

func _on_DungeonStyleButtonPressed(value):
	oEditor.mapHasBeenEdited = true
	oDataLevelStyle.data = value
	oTextureCache.set_default_texture_pack(oDataLevelStyle.data)
