extends MarginContainer
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oDataLevelStyle = Nodelist.list["oDataLevelStyle"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oDungeonStyleList = Nodelist.list["oDungeonStyleList"]
onready var oDataMapName = Nodelist.list["oDataMapName"]
onready var oDataLof = Nodelist.list["oDataLof"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oPlacingSettings = Nodelist.list["oPlacingSettings"]
onready var oInspector = Nodelist.list["oInspector"]
onready var oAdvancedMapProperties = Nodelist.list["oAdvancedMapProperties"]
onready var oMapSizeTextLabel = Nodelist.list["oMapSizeTextLabel"]
onready var oMapNameLineEdit = Nodelist.list["oMapNameLineEdit"]
onready var oNameIDLineEdit = Nodelist.list["oNameIDLineEdit"]
onready var oEnsignPositionLineEdit = Nodelist.list["oEnsignPositionLineEdit"]
onready var oSpeechLineEdit = Nodelist.list["oSpeechLineEdit"]
onready var oLandViewLineEdit = Nodelist.list["oLandViewLineEdit"]
onready var oAuthorLineEdit = Nodelist.list["oAuthorLineEdit"]
onready var oDescriptionLineEdit = Nodelist.list["oDescriptionLineEdit"]
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oKindOptionButton = Nodelist.list["oKindOptionButton"]
onready var oPlayersSpinBox = Nodelist.list["oPlayersSpinBox"]
onready var oOptionsOptionButton = Nodelist.list["oOptionsOptionButton"]

onready var oHBoxPlayers = Nodelist.list["oHBoxPlayers"]
onready var oHBoxSpeech = Nodelist.list["oHBoxSpeech"]
onready var oHBoxEnsignPosition = Nodelist.list["oHBoxEnsignPosition"]
onready var oHBoxOptions = Nodelist.list["oHBoxOptions"]
onready var oHBoxLandView = Nodelist.list["oHBoxLandView"]
onready var oHBoxNameID = Nodelist.list["oHBoxNameID"]

const kind_options = {
	"Solo" : "FREE",
	"Multiplayer" : "MULTI",
	"Campaign" : "SINGLE",
	"Secret" : "BONUS",
	"Moon" : "EXTRA",
}

const options_options = {
	"Standard" : "",
	"Tutorial" : "TUTORIAL",
}


func _ready():
	var tooltip_text = ""
	for key in kind_options.keys():
		tooltip_text += key + " = " + kind_options[key] + "\n"
	oKindOptionButton.hint_tooltip = tooltip_text.strip_edges(true)
	
	# Default to hiding ONCE, when you start the editor.
	oAdvancedMapProperties.visible = false
	
	# Construct oKindOptionButton
	for stringKind in kind_options.keys():
		oKindOptionButton.add_item(stringKind)
		oKindOptionButton.selected = 0
	

func _on_MapProperties_visibility_changed():
	if is_instance_valid(oDungeonStyleList) == false: return
	if visible == true:
		refresh_dungeon_style_options()
		oMapNameLineEdit.text = oDataMapName.data
		oNameIDLineEdit.text = oDataLof.NAME_ID
		oKindOptionButton.selected = kind_text_to_button_id()
		oOptionsOptionButton.selected = options_text_to_button_id()
		oEnsignPositionLineEdit.text = oDataLof.ENSIGN_POS
		oPlayersSpinBox.value = int(oDataLof.PLAYERS)
		oSpeechLineEdit.text = oDataLof.SPEECH
		oLandViewLineEdit.text = oDataLof.LAND_VIEW
		oAuthorLineEdit.text = oDataLof.AUTHOR
		oDescriptionLineEdit.text = oDataLof.DESCRIPTION
		oMapSizeTextLabel.text = str(M.xSize) + " x " + str(M.ySize)
		
		# Resizing feature isn't implemented, so do not allow changing map format back if you've adjusted size
		if M.xSize != 85 or M.ySize != 85:
			oCurrentFormat.selected = 1
			oCurrentFormat.disabled = true
		else:
			oCurrentFormat.disabled = false
		
		set_format_selection(oCurrentFormat.selected)
		
		update_section_visibility()

func _on_MapFormatSetting_item_selected(index):
	# Clicked using mouse
	oEditor.mapHasBeenEdited = true
	
	set_format_selection(index)

func set_format_selection(setFormat):
	match setFormat:
		0: # Classic format
			oAdvancedMapProperties.visible = false
		1: # KFX format
			oAdvancedMapProperties.visible = true
	
	# When you change format, the object settings that are available also change
	oPlacingSettings.update_placing_tab()
	oInspector.deselect()

func refresh_dungeon_style_options():
	oDungeonStyleList.clear()
	for i in oTextureCache.cachedTextures.size():
		var aaa
		if Constants.TEXTURE_MAP_NAMES.has(i) == true:
			aaa = Constants.TEXTURE_MAP_NAMES[i]
		else:
			aaa = "Untitled"
		oDungeonStyleList.add_item(aaa,i)
	
	# Select the correct one when loading map
	if oDataLevelStyle.data <= oTextureCache.cachedTextures.size():
		oDungeonStyleList.selected = oDataLevelStyle.data

func _on_DungeonStyleList_item_selected(value):
	oEditor.mapHasBeenEdited = true
	oDataLevelStyle.data = value
	oTextureCache.set_current_texture_pack()
	oMessage.quick("Loaded : ".plus_file("unearthdata").plus_file("tmapa" + str(value).pad_zeros(3) + ".png"))

func _on_MapNameLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataMapName.set_map_name(new_text)
func _on_AuthorLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.AUTHOR = new_text
func _on_DescriptionLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.DESCRIPTION = new_text
func _on_NameIDLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.NAME_ID = new_text

func _on_EnsignPositionLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.ENSIGN_POS = new_text
	oDataLof.ENSIGN_ZOOM = new_text

func _on_OptionsLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.OPTIONS = new_text
func _on_SpeechLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.SPEECH = new_text
func _on_LandViewLineEdit_text_changed(new_text):
	oEditor.mapHasBeenEdited = true
	oDataLof.LAND_VIEW = new_text

func _on_PlayersSpinBox_value_changed(value):
	oEditor.mapHasBeenEdited = true
	oDataLof.PLAYERS = str(value)


func _on_KindOptionButton_item_selected(index):
	oEditor.mapHasBeenEdited = true
	oDataLof.KIND = kind_options[oKindOptionButton.text]
	update_section_visibility()


func _on_OptionsOptionButton_item_selected(index):
	oEditor.mapHasBeenEdited = true
	oDataLof.OPTIONS = options_options[oOptionsOptionButton.text]


func options_text_to_button_id():
	var button_id = 0
	for i in range(oOptionsOptionButton.get_item_count()):
		if options_options[oOptionsOptionButton.get_item_text(i)] == oDataLof.OPTIONS:
			button_id = i
			break
	return button_id

func kind_text_to_button_id():
	var button_id = 0
	for i in range(oKindOptionButton.get_item_count()):
		if kind_options[oKindOptionButton.get_item_text(i)] == oDataLof.KIND:
			button_id = i
			break
	return button_id


func update_section_visibility():
	oHBoxPlayers.visible = false
	oHBoxSpeech.visible = false
	oHBoxEnsignPosition.visible = false
	#oHBoxEnsignZoom.visible = false
	oHBoxOptions.visible = false
	oHBoxLandView.visible = false
	oHBoxNameID.visible = false
	match oKindOptionButton.get_item_text(oKindOptionButton.selected):
		"Solo":
			pass
		"Multiplayer":
			oHBoxPlayers.visible = true
			
			oHBoxEnsignPosition.visible = true
			#oHBoxEnsignZoom.visible = true
			oHBoxOptions.visible = true
			oHBoxLandView.visible = true
			oHBoxNameID.visible = true
		"Campaign", "Secret", "Moon":
			oHBoxSpeech.visible = true
			
			oHBoxEnsignPosition.visible = true
			#oHBoxEnsignZoom.visible = true
			oHBoxOptions.visible = true
			oHBoxLandView.visible = true
			oHBoxNameID.visible = true
	
	if oHBoxPlayers.visible == false:
		oPlayersSpinBox.value = 2
		oDataLof.PLAYERS = ""
	
	if oHBoxSpeech.visible == false:
		oSpeechLineEdit.text = ""
		oDataLof.SPEECH = ""
	
	if oHBoxEnsignPosition.visible == false:
		oEnsignPositionLineEdit.text = ""
		oDataLof.ENSIGN_POS = ""
		oDataLof.ENSIGN_ZOOM = ""
	
	if oHBoxOptions.visible == false:
		oOptionsOptionButton.selected = 0
		oDataLof.OPTIONS = ""
	
	if oHBoxLandView.visible == false:
		oLandViewLineEdit.text = ""
		oDataLof.LAND_VIEW = ""
	
	if oHBoxNameID.visible == false:
		oNameIDLineEdit.text = ""
		oDataLof.NAME_ID = ""
