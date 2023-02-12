extends ScrollContainer
onready var oAutoWallArtButton = Nodelist.list["oAutoWallArtButton"]
onready var oDamagedWallLineEdit = Nodelist.list["oDamagedWallLineEdit"]

func _ready():
	pass

func _on_EditableBordersCheckbox_toggled(button_pressed):
	Settings.set_setting("editable_borders", button_pressed)

func _on_OwnableNaturalTerrain_toggled(button_pressed):
	Settings.set_setting("ownable_natural_terrain", button_pressed)

func _on_AutoWallArtButton_pressed():
	if oAutoWallArtButton.text == "Grouped":
		oAutoWallArtButton.text = "Random"
	else:
		oAutoWallArtButton.text = "Grouped"
	Settings.set_setting("wallauto_art", oAutoWallArtButton.text)

func _on_DamagedWallLineEdit_focus_exited():
	var val = int(oDamagedWallLineEdit.text)
	val = clamp(val, 0, 100)
	oDamagedWallLineEdit.text = String(val)
	Settings.set_setting("wallauto_damaged", oDamagedWallLineEdit.text)

func _on_BridgesOnlyOnLiquidCheckbox_toggled(button_pressed):
	Settings.set_setting("bridges_only_on_liquid", button_pressed)

func _on_FrailColumnsCheckbox_toggled(button_pressed):
	Settings.set_setting("frail_columns", button_pressed)


func _on_LavaEffectPercent_value_changed(value):
	Settings.set_setting("chance_effect_lava", value)


func _on_WaterEffectPercent_value_changed(value):
	Settings.set_setting("chance_effect_water", value)
