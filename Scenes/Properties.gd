extends MarginContainer
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oDungeonStyleList = Nodelist.list["oDungeonStyleList"]
onready var oDataLif = Nodelist.list["oDataLif"]
onready var oDataKeeperFxLof = Nodelist.list["oDataKeeperFxLof"]

onready var oAdvancedMapProperties = Nodelist.list["oAdvancedMapProperties"]

onready var oMapNameLineEdit = Nodelist.list["oMapNameLineEdit"]
onready var oNameIDLineEdit = Nodelist.list["oNameIDLineEdit"]
onready var oKindLineEdit = Nodelist.list["oKindLineEdit"]
onready var oEnsignPositionLineEdit = Nodelist.list["oEnsignPositionLineEdit"]
onready var oEnsignZoomLineEdit = Nodelist.list["oEnsignZoomLineEdit"]
onready var oPlayersLineEdit = Nodelist.list["oPlayersLineEdit"]
onready var oOptionsLineEdit = Nodelist.list["oOptionsLineEdit"]
onready var oSpeechLineEdit = Nodelist.list["oSpeechLineEdit"]
onready var oLandViewLineEdit = Nodelist.list["oLandViewLineEdit"]
onready var oAuthorLineEdit = Nodelist.list["oAuthorLineEdit"]
onready var oDescriptionLineEdit = Nodelist.list["oDescriptionLineEdit"]



func _on_MapProperties_visibility_changed():
	if is_instance_valid(oDungeonStyleList) == false: return
	
	if visible == true:
		refresh_dungeon_style_options()
		oMapNameLineEdit.text = oDataLif.data
		oNameIDLineEdit.text = oDataKeeperFxLof.NAME_ID
		oKindLineEdit.text = oDataKeeperFxLof.KIND
		oEnsignPositionLineEdit.text = oDataKeeperFxLof.ENSIGN_POS
		oEnsignZoomLineEdit.text = oDataKeeperFxLof.ENSIGN_ZOOM
		oPlayersLineEdit.text = oDataKeeperFxLof.PLAYERS
		oOptionsLineEdit.text = oDataKeeperFxLof.OPTIONS
		oSpeechLineEdit.text = oDataKeeperFxLof.SPEECH
		oLandViewLineEdit.text = oDataKeeperFxLof.LAND_VIEW
		oAuthorLineEdit.text = oDataKeeperFxLof.AUTHOR
		oDescriptionLineEdit.text = oDataKeeperFxLof.DESCRIPTION

func refresh_dungeon_style_options():
	for i in oDungeonStyleList.get_children():
		i.queue_free()
	
	for i in oTextureCache.cachedTextures.size():
		var aaa = CheckBox.new()
		aaa.align = Button.ALIGN_LEFT
		if i == oDataLevelStyle.data:
			aaa.pressed = true
		aaa.group = load("res://Theme/ButtonGroupDungeonStyle.tres")
		if Constants.TEXTURE_MAP_NAMES.has(i) == true:
			aaa.text = Constants.TEXTURE_MAP_NAMES[i]
		else:
			aaa.text = "Untitled"
		aaa.size_flags_vertical = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_CENTER
		aaa.size_flags_horizontal = Control.SIZE_EXPAND# + Control.SIZE_SHRINK_CENTER
		aaa.connect("pressed",self,"_on_DungeonStyleButtonPressed",[i])
		oDungeonStyleList.add_child(aaa)
		
		var bbb = Label.new()
		bbb.text = "tmapa" + str(i).pad_zeros(3) + ".dat"
		oDungeonStyleList.add_child(bbb)
	
#	disconnect("visibility_changed", self, "_on_MapProperties_visibility_changed")
#	hide()
#	yield(get_tree(),'idle_frame')
	#rect_min_size = $VBoxContainer.rect_size + Vector2(80,40)
#	Utils.popup_centered(self)
#	connect("visibility_changed", self, "_on_MapProperties_visibility_changed")

func _on_DungeonStyleButtonPressed(value):
	oEditor.mapHasBeenEdited = true
	oDataLevelStyle.data = value
	oTextureCache.set_current_texture_pack()


func _on_AdvancedMapPropertiesCheckBox_pressed():
	oAdvancedMapProperties.visible = !oAdvancedMapProperties.visible

func _on_MapNameLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLif.set_map_name(new_text)
func _on_AuthorLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.AUTHOR = new_text
func _on_DescriptionLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.DESCRIPTION = new_text
func _on_NameIDLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.NAME_ID = new_text
func _on_KindLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.KIND = new_text
func _on_EnsignPositionLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.ENSIGN_POS = new_text
func _on_EnsignZoomLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.ENSIGN_ZOOM = new_text
func _on_PlayersLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.PLAYERS = new_text
func _on_OptionsLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.OPTIONS = new_text
func _on_SpeechLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.SPEECH = new_text
func _on_LandViewLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataKeeperFxLof.LAND_VIEW = new_text
