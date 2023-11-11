extends ScrollContainer
onready var oAutoWallArtButton = Nodelist.list["oAutoWallArtButton"]
onready var oDamagedWallLineEdit = Nodelist.list["oDamagedWallLineEdit"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oRoundPathNearLiquid = Nodelist.list["oRoundPathNearLiquid"]
onready var oRoundEarthNearPath = Nodelist.list["oRoundEarthNearPath"]
onready var oRoundEarthNearLiquid = Nodelist.list["oRoundEarthNearLiquid"]
onready var oRoundRockNearPath = Nodelist.list["oRoundRockNearPath"]
onready var oRoundRockNearLiquid = Nodelist.list["oRoundRockNearLiquid"]
onready var oRoundGoldNearPath = Nodelist.list["oRoundGoldNearPath"]
onready var oRoundGoldNearLiquid = Nodelist.list["oRoundGoldNearLiquid"]
onready var oRoundWaterNearLava = Nodelist.list["oRoundWaterNearLava"]

func _ready():
	oRoundPathNearLiquid.connect("toggled", self, "toggled_frail_checkbox", ["round_path_near_liquid"])
	oRoundEarthNearPath.connect("toggled", self, "toggled_frail_checkbox", ["round_earth_near_path"])
	oRoundEarthNearLiquid.connect("toggled", self, "toggled_frail_checkbox", ["round_earth_near_liquid"])
	oRoundRockNearPath.connect("toggled", self, "toggled_frail_checkbox", ["round_rock_near_path"])
	oRoundRockNearLiquid.connect("toggled", self, "toggled_frail_checkbox", ["round_rock_near_liquid"])
	oRoundGoldNearPath.connect("toggled", self, "toggled_frail_checkbox", ["round_gold_near_path"])
	oRoundGoldNearLiquid.connect("toggled", self, "toggled_frail_checkbox", ["round_gold_near_liquid"])
	oRoundWaterNearLava.connect("toggled", self, "toggled_frail_checkbox", ["round_water_near_lava"])

func toggled_frail_checkbox(button_pressed, settingString):
	Settings.set_setting(settingString, button_pressed)

func _on_EditableBordersCheckbox_toggled(button_pressed):
	Settings.set_setting("editable_borders", button_pressed)
	oEditor.update_boundaries()

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


func _on_LavaEffectPercent_value_changed(value):
	Settings.set_setting("chance_effect_lava", value)

func _on_WaterEffectPercent_value_changed(value):
	Settings.set_setting("chance_effect_water", value)

func _on_PlaceThingsAnywhere_toggled(value):
	Settings.set_setting("place_things_anywhere", value)


func _on_AutomaticTorchSlabsCheckbox_toggled(value):
	Settings.set_setting("automatic_torch_slabs", value)
