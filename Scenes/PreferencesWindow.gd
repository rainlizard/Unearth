extends WindowDialog
onready var oGame = Nodelist.list["oGame"]
onready var oSetDirPath = Nodelist.list["oSetDirPath"]
onready var oCheckBoxVsync = Nodelist.list["oCheckBoxVsync"]
onready var oMSAA = Nodelist.list["oMSAA"]
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
onready var oSciptIconScale = Nodelist.list["oSciptIconScale"]
onready var oSciptIconMaxZoom = Nodelist.list["oSciptIconMaxZoom"]
onready var oFacingArrowScale = Nodelist.list["oFacingArrowScale"]
onready var oFacingArrowMaxZoom = Nodelist.list["oFacingArrowMaxZoom"]
onready var oPickSlabWindow = Nodelist.list["oPickSlabWindow"]
onready var oPickThingWindow = Nodelist.list["oPickThingWindow"]
onready var oUiScale = Nodelist.list["oUiScale"]
onready var oFramerateLimit = Nodelist.list["oFramerateLimit"]
onready var oSSAA = Nodelist.list["oSSAA"]
onready var oOwnerAlpha = Nodelist.list["oOwnerAlpha"]
onready var oScriptEditorFontSize = Nodelist.list["oScriptEditorFontSize"]
onready var oEditorFontSize = Nodelist.list["oEditorFontSize"]
onready var oCheckBoxNewMapAutoOpensMapSettings = Nodelist.list["oCheckBoxNewMapAutoOpensMapSettings"]
onready var oShowCLMDataTabCheckbox = Nodelist.list["oShowCLMDataTabCheckbox"]
onready var oAllowReservedIdEditingCheckbox = Nodelist.list["oAllowReservedIdEditingCheckbox"]
onready var oPauseWhenMinimizedCheckbox = Nodelist.list["oPauseWhenMinimizedCheckbox"]
onready var oInputsUpdateScreenCheckbox = Nodelist.list["oInputsUpdateScreenCheckbox"]
onready var oRenderingRateSpinBox = Nodelist.list["oRenderingRateSpinBox"]
onready var oLowProcessorModeSleepUsec = Nodelist.list["oLowProcessorModeSleepUsec"]
onready var oSymmetryGuidelinesSetting = Nodelist.list["oSymmetryGuidelinesSetting"]

#onready var oTabEditor = Nodelist.list["oTabEditor"]
#onready var oTabGraphics = Nodelist.list["oTabGraphics"]
#onready var oGeneralView = Nodelist.list["oGeneralView"]
#onready var oTab2DView = Nodelist.list["oTab2DView"]
#onready var oTab3DView = Nodelist.list["oTab3DView"]

func _ready():
	oTabSettings.set_tab_title(0,"Files")
	oTabSettings.set_tab_title(1,"Placements")
	oTabSettings.set_tab_title(2,"UI")
	oTabSettings.set_tab_title(3,"Camera")
	oTabSettings.set_tab_title(4,"Graphics")

func _on_ButtonSettings_pressed():
	Utils.popup_centered(self)

#const marginBorder = 12

#func _process(delta):
	#rect_size = $VBoxContainer.rect_size + Vector2(marginBorder*2,marginBorder*2)
	#$VBoxContainer.rect_size = Vector2(0,0)
	#$VBoxContainer.rect_position = Vector2(marginBorder,marginBorder)

func _on_SettingsWindow_about_to_show():
	oSetDirPath.text = Settings.get_setting("executable_path")
	oCheckBoxVsync.pressed = Settings.get_setting("vsync")
	var msaa_enum = Settings.get_setting("msaa")
	var msaa_slider_value = msaa_enum_to_slider_value(msaa_enum)
	oMSAA.update_appearance(msaa_slider_value)
	oCheckBoxAlwaysDecompress.pressed = Settings.get_setting("always_decompress")
	oCmdLineDkCommands.text = Settings.get_setting("dk_commands")
	
	oCheckBoxMouseEdgePanning.pressed = Settings.get_setting("mouse_edge_panning")
	oCheckBoxSmoothPan.pressed = Settings.get_setting("smooth_pan_enabled")
	oCheckBoxDisplayFPS.pressed = Settings.get_setting("display_fps")
	oDirectionalPanSpeed.update_appearance(Settings.get_setting("pan_speed"))
	oZoomStep.update_appearance(Settings.get_setting("zoom_step"))
	oSmoothingRate.update_appearance(Settings.get_setting("smoothing_rate"))
	oMouseSensitivity.update_appearance(Settings.get_setting("mouse_sensitivity"))
	oFieldOfView.update_appearance(Settings.get_setting("fov"))
	oFramerateLimit.update_appearance(Settings.get_setting("framerate_limit"))
	oSSAA.update_appearance(Settings.get_setting("ssaa"))
	oCheckBoxDisplay3dInfo.pressed = Settings.get_setting("display_3d_info")
	oUiScale.update_appearance(Settings.get_setting("ui_scale"))
	oSlabWindowScale.update_appearance(Settings.get_setting("slab_window_scale"))
	oThingWindowScale.update_appearance(Settings.get_setting("thing_window_scale"))
	oOwnerAlpha.update_appearance(Settings.get_setting("graphics_ownership_alpha"))
	oSymmetryGuidelinesSetting.update_appearance(Settings.get_setting("symmetry_guidelines"))
	oCreatureLevelFontSizeScale.update_appearance(Settings.get_setting("font_size_creature_level_scale"))
	oCreatureLevelFontSizeMaxZoom.update_appearance(Settings.get_setting("font_size_creature_level_max"))
	oSciptIconScale.update_appearance(Settings.get_setting("script_icon_scale"))
	oSciptIconMaxZoom.update_appearance(Settings.get_setting("script_icon_max"))
	oFacingArrowScale.update_appearance(Settings.get_setting("facing_arrow_scale"))
	oFacingArrowMaxZoom.update_appearance(Settings.get_setting("facing_arrow_max"))
	oEditorFontSize.update_appearance(Settings.get_setting("editor_font_size"))
	oScriptEditorFontSize.update_appearance(Settings.get_setting("script_editor_font_size"))
	oCheckBoxNewMapAutoOpensMapSettings.pressed = Settings.get_setting("auto_open_map_settings")
	oShowCLMDataTabCheckbox.pressed = Settings.get_setting("show_clm_data_tab")
	oAllowReservedIdEditingCheckbox.pressed = Settings.get_setting("allow_reserved_id_editing")
	oPauseWhenMinimizedCheckbox.pressed = Settings.get_setting("pause_when_minimized")
	oInputsUpdateScreenCheckbox.pressed = Settings.get_setting("inputs_update_screen")
	oRenderingRateSpinBox.update_appearance(Settings.get_setting("rendering_rate"))
	oLowProcessorModeSleepUsec.update_appearance(Settings.get_setting("low_processor_mode_sleep_usec"))

func _on_CheckBoxVsync_toggled(button_pressed):
	Settings.set_setting("vsync", button_pressed)

func _on_CheckBoxAlwaysDecompress_toggled(button_pressed):
	Settings.set_setting("always_decompress", button_pressed)

func _on_SetDirButton_pressed():
	Utils.popup_centered(oChooseDkExe)

func _on_ChooseDkExe_file_selected(path):
	oSetDirPath.text = path

func _on_CloseButton_pressed():
	hide()

func restart_application():
	var executable_path = OS.get_executable_path()
	OS.execute(executable_path, [], false)
	get_tree().quit()


func _on_ResetToDefault_pressed():
	Settings.delete_settings()
	restart_application()

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

func edited_MouseSensitivity(new_text):
	Settings.set_setting("mouse_sensitivity", float(new_text))

func edited_FieldOfView(new_text):
	Settings.set_setting("fov", float(new_text))

func edited_FramerateLimit(new_text):
	Settings.set_setting("framerate_limit", int(new_text))

func edited_SSAA(new_text):
	Settings.set_setting("ssaa", int(new_text))

func edited_UiScale(new_text):
	if float(new_text) < 0.5: return # don't allow, otherwise you can't navigate
	
	Settings.set_setting("ui_scale", float(new_text))
	
	# Fix to Slab/Thing window position going off screen when changing UI scale
	oPickSlabWindow.rect_position.x -= 1 # This will trigger the signal that keeps the window on screen
	oPickThingWindow.rect_position.x -= 1
	
	rect_position.x -= 1 # Settings window too

func edited_SlabWindowScale(new_text):
	Settings.set_setting("slab_window_scale", float(new_text))

func edited_EditorFontSize(new_text):
	Settings.set_setting("editor_font_size", int(new_text))

func edited_ScriptEditorFontSize(new_text):
	Settings.set_setting("script_editor_font_size", int(new_text))

func edited_CreatureLevelFontSizeScale(new_text):
	Settings.set_setting("font_size_creature_level_scale", float(new_text))

func edited_CreatureLevelFontSizeMaxZoom(new_text):
	Settings.set_setting("font_size_creature_level_max", float(new_text))

func edited_SciptIconScale(new_text):
	Settings.set_setting("script_icon_scale", float(new_text))

func edited_SciptIconMaxZoom(new_text):
	Settings.set_setting("script_icon_max", float(new_text))

func edited_FacingArrowScale(new_text):
	Settings.set_setting("facing_arrow_scale", float(new_text))

func edited_FacingArrowMaxZoom(new_text):
	Settings.set_setting("facing_arrow_max", float(new_text))

func edited_ThingWindowScale(new_text):
	Settings.set_setting("thing_window_scale", float(new_text))

func edited_OwnerWindowScale(new_text):
	Settings.set_setting("owner_window_scale", float(new_text))

func edited_OwnerAlpha(new_text):
	Settings.set_setting("graphics_ownership_alpha", float(new_text))

func edited_SymmetryGuidelinesSetting(new_text):
	Settings.set_setting("symmetry_guidelines", float(new_text))

func _on_CheckBoxDisplay3dInfo_toggled(button_pressed):
	Settings.set_setting("display_3d_info", button_pressed)

func _on_CheckBoxNewMapAutoOpensMapSettings_toggled(button_pressed):
	Settings.set_setting("auto_open_map_settings", button_pressed)

func _on_ShowCLMDataTabCheckbox_toggled(button_pressed):
	Settings.set_setting("show_clm_data_tab", button_pressed)
	var oSlabsetTabs = Nodelist.list["oSlabsetTabs"]
	oSlabsetTabs.set_tab_hidden(2, !button_pressed)

func _on_AllowReservedIdEditingCheckbox_toggled(button_pressed):
	Settings.set_setting("allow_reserved_id_editing", button_pressed)

func _on_PauseWhenMinimizedCheckbox_toggled(button_pressed):
	Settings.set_setting("pause_when_minimized", button_pressed)

func _on_InputsUpdateScreenCheckbox_toggled(button_pressed):
	Settings.set_setting("inputs_update_screen", button_pressed)
	yield(get_tree(),'idle_frame')
	VisualServer.render_loop_enabled = true # Just here to fix a brief 1 frame visual bug


func edited_RenderingRateSpinBox(new_text):
	Settings.set_setting("rendering_rate", float(new_text))

func edited_LowProcessorModeSleepUsec(new_text):
	Settings.set_setting("low_processor_mode_sleep_usec", int(new_text))

func edited_MSAA(new_text):
	var slider_value = int(new_text)
	var snapped_slider_value = snap_msaa_slider_value(slider_value)
	var msaa_enum_value = slider_value_to_msaa_enum(snapped_slider_value)
	
	if snapped_slider_value != slider_value:
		oMSAA.update_appearance(snapped_slider_value)
	
	Settings.set_setting("msaa", msaa_enum_value)

func snap_msaa_slider_value(value):
	var valid_slider_values = [1, 2, 4, 8, 16]
	var closest_value = valid_slider_values[0]
	var min_distance = abs(value - closest_value)
	
	for valid_value in valid_slider_values:
		var distance = abs(value - valid_value)
		if distance < min_distance:
			min_distance = distance
			closest_value = valid_value
	
	return closest_value

func slider_value_to_msaa_enum(slider_value):
	match slider_value:
		1: return 0
		2: return 1
		4: return 2
		8: return 3
		16: return 4
		_: return 0

func msaa_enum_to_slider_value(enum_value):
	match enum_value:
		0: return 1
		1: return 2
		2: return 4
		3: return 8
		4: return 16
		_: return 1
