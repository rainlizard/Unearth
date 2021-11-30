extends WindowDialog
onready var oGame = Nodelist.list["oGame"]
onready var oSetDirPath = Nodelist.list["oSetDirPath"]
onready var oCheckBoxVsync = Nodelist.list["oCheckBoxVsync"]
onready var oMenuMSAA = Nodelist.list["oMenuMSAA"]
onready var oCheckBoxAlwaysDecompress = Nodelist.list["oCheckBoxAlwaysDecompress"]
onready var oChooseDkExe = Nodelist.list["oChooseDkExe"]
onready var oCmdLineDkCommands = Nodelist.list["oCmdLineDkCommands"]
onready var oCheckBoxMouseEdgePanning = Nodelist.list["oCheckBoxMouseEdgePanning"]
onready var oCheckBoxSmoothPan = Nodelist.list["oCheckBoxSmoothPan"]
onready var oCheckBoxDisplayFPS = Nodelist.list["oCheckBoxDisplayFPS"]
onready var oZoomStep = Nodelist.list["oZoomStep"]
onready var oSmoothingRate = Nodelist.list["oSmoothingRate"]
onready var oDirectionalPanSpeed = Nodelist.list["oDirectionalPanSpeed"]
onready var oMouseSensitivity = Nodelist.list["oMouseSensitivity"]
onready var oFieldOfView = Nodelist.list["oFieldOfView"]
onready var oCheckBoxDisplay3dInfo = Nodelist.list["oCheckBoxDisplay3dInfo"]
onready var oSlabWindowScale = Nodelist.list["oSlabWindowScale"]
onready var oThingWindowScale = Nodelist.list["oThingWindowScale"]
onready var oTabSettings = Nodelist.list["oTabSettings"]
onready var oCreatureLevelFontSizeScale = Nodelist.list["oCreatureLevelFontSizeScale"]
onready var oCreatureLevelFontSizeMaxZoom = Nodelist.list["oCreatureLevelFontSizeMaxZoom"]

#onready var oTabEditor = Nodelist.list["oTabEditor"]
#onready var oTabGraphics = Nodelist.list["oTabGraphics"]
#onready var oGeneralView = Nodelist.list["oGeneralView"]
#onready var oTab2DView = Nodelist.list["oTab2DView"]
#onready var oTab3DView = Nodelist.list["oTab3DView"]

onready var oCheckBoxHideUnknown = Nodelist.list["oCheckBoxHideUnknown"]
onready var oOwnerAlphaSlider = Nodelist.list["oOwnerAlphaSlider"]
onready var oFontSize = Nodelist.list["oFontSize"]

func _ready():
	oTabSettings.set_tab_title(0,"Editor")
	oTabSettings.set_tab_title(1,"Graphics")
	oTabSettings.set_tab_title(2,"General view")
	oTabSettings.set_tab_title(3,"2D view")
	oTabSettings.set_tab_title(4,"3D view")

func _on_ButtonSettings_pressed():
	Utils.popup_centered(self)

const marginBorder = 12

func _process(delta):
	rect_size = $VBoxContainer.rect_size + Vector2(marginBorder*2,marginBorder*2)
	$VBoxContainer.rect_size = Vector2(0,0)
	$VBoxContainer.rect_position = Vector2(marginBorder,marginBorder)

func _on_SettingsWindow_about_to_show():
	oSetDirPath.text = Settings.get_setting("executable_path")
	oCheckBoxVsync.pressed = Settings.get_setting("vsync")
	oMenuMSAA.text = oMenuMSAA.dropdown.get_item_text(Settings.get_setting("msaa"))
	oCheckBoxAlwaysDecompress.pressed = Settings.get_setting("always_decompress")
	oCmdLineDkCommands.text = Settings.get_setting("dk_commands")
	
	oCheckBoxMouseEdgePanning.pressed = Settings.get_setting("mouse_edge_panning")
	oCheckBoxSmoothPan.pressed = Settings.get_setting("smooth_pan_enabled")
	oCheckBoxDisplayFPS.pressed = Settings.get_setting("display_fps")
	oDirectionalPanSpeed.line.text = str(Settings.get_setting("pan_speed"))
	oZoomStep.line.text = str(Settings.get_setting("zoom_step"))
	oSmoothingRate.line.text = str(Settings.get_setting("smoothing_rate"))
	oMouseSensitivity.line.text = str(Settings.get_setting("mouse_sensitivity"))
	oFieldOfView.line.text = str(Settings.get_setting("fov"))
	oCheckBoxDisplay3dInfo.pressed = Settings.get_setting("display_3d_info")
	oSlabWindowScale.line.text = str(Settings.get_setting("slab_window_scale"))
	oThingWindowScale.line.text = str(Settings.get_setting("thing_window_scale"))
	oCheckBoxHideUnknown.pressed = Settings.get_setting("hide_unknown_data")
	oOwnerAlphaSlider.value = Settings.get_setting("graphics_ownership_alpha")
	oFontSize.line.text = str(Settings.get_setting("font_size"))
	oCreatureLevelFontSizeScale.line.text = str(Settings.get_setting("font_size_creature_level_scale"))
	oCreatureLevelFontSizeMaxZoom.line.text = str(Settings.get_setting("font_size_creature_level_max"))

func _on_CheckBoxVsync_toggled(button_pressed):
	Settings.set_setting("vsync", button_pressed)

func _on_CheckBoxAlwaysDecompress_toggled(button_pressed):
	Settings.set_setting("always_decompress", button_pressed)

func _on_SetDirButton_pressed():
	Utils.popup_centered(oChooseDkExe)

func _on_ChooseDkExe_file_selected(path):
	oSetDirPath.text = path

func menu_msaa_index_pressed(index):
	Settings.set_setting("msaa", index)

func _on_CloseButton_pressed():
	hide()

func _on_ResetToDefault_pressed():
	Settings.delete_settings()
	get_tree().quit()

func _on_CheckBoxSmoothPan_toggled(button_pressed):
	Settings.set_setting("smooth_pan_enabled", button_pressed)

func _on_CheckBoxMouseEdgePanning_toggled(button_pressed):
	Settings.set_setting("mouse_edge_panning", button_pressed)

func _on_CheckBoxDisplayFPS_toggled(button_pressed):
	Settings.set_setting("display_fps", button_pressed)

func edited_DirectionalPanSpeed(new_text):
	Settings.set_setting("pan_speed", float(new_text))

func edited_ZoomStep(new_text):
	Settings.set_setting("zoom_step", float(new_text))

func edited_SmoothingRate(new_text):
	Settings.set_setting("smoothing_rate", float(new_text))

func _on_OwnerAlphaSlider_value_changed(value):
	Settings.set_setting("graphics_ownership_alpha", float(value))

func edited_MouseSensitivity(new_text):
	Settings.set_setting("mouse_sensitivity", float(new_text))

func edited_FieldOfView(new_text):
	Settings.set_setting("fov", float(new_text))

func edited_SlabWindowScale(new_text):
	Settings.set_setting("slab_window_scale", float(new_text))

func edited_FontSize(new_text):
	Settings.set_setting("font_size", float(new_text))

func edited_CreatureLevelFontSizeScale(new_text):
	Settings.set_setting("font_size_creature_level_scale", float(new_text))

func edited_CreatureLevelFontSizeMaxZoom(new_text):
	Settings.set_setting("font_size_creature_level_max", float(new_text))

func edited_ThingWindowScale(new_text):
	Settings.set_setting("thing_window_scale", float(new_text))

func edited_OwnerWindowScale(new_text):
	Settings.set_setting("owner_window_scale", float(new_text))

func _on_CheckBoxDisplay3dInfo_toggled(button_pressed):
	Settings.set_setting("display_3d_info", button_pressed)

func _on_CheckBoxHideUnknown_toggled(button_pressed):
	Settings.set_setting("hide_unknown_data", button_pressed)

func _on_CmdLineDkCommands_text_changed(new_text):
	Settings.set_setting("dk_commands", new_text)
