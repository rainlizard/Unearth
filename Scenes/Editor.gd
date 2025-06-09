extends Node
onready var oUi3D = Nodelist.list["oUi3D"]
onready var oGame2D = Nodelist.list["oGame2D"]
onready var oGame3D = Nodelist.list["oGame3D"]
onready var oCamera2D = Nodelist.list["oCamera2D"]
onready var oCamera3D = Nodelist.list["oCamera3D"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]
onready var oConfirmQuit = Nodelist.list["oConfirmQuit"]
onready var oUi = Nodelist.list["oUi"]
onready var oTerrainMesh = Nodelist.list["oTerrainMesh"]
onready var oEditingMode = Nodelist.list["oEditingMode"]
onready var oEditableBordersCheckbox = Nodelist.list["oEditableBordersCheckbox"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oConfirmSaveBeforeQuit = Nodelist.list["oConfirmSaveBeforeQuit"]
onready var oExportPreview = Nodelist.list["oExportPreview"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oEditor = Nodelist.list["oEditor"]

enum {
	VIEW_2D = 0
	VIEW_3D = 1
	SET_EDITED_WITHOUT_SAVING_STATE = 777
}

var currentView = VIEW_2D
var fieldBoundary = Rect2()
var mapHasBeenEdited = false setget set_map_has_been_edited
var framerate_limit = 120 setget set_framerate_limit
var ssaa_level = 4 setget set_ssaa_level

func set_map_has_been_edited(setVal):
	if int(setVal) == oEditor.SET_EDITED_WITHOUT_SAVING_STATE: #If you save, then click Undo, it should mark as not saved but not create a new undo state when marking as edited.
		mapHasBeenEdited = true
		return
	elif setVal == true:
		oUndoStates.call_deferred("attempt_to_save_new_undo_state")
	mapHasBeenEdited = setVal


func _ready():
	get_viewport().msaa = Viewport.MSAA_4X # default setting
	get_tree().set_auto_accept_quit(false)
	just_opened_editor()

func _unhandled_input(event):
	# Needs to be in _unhandled_input otherwise pressing ESC closes the popup instantly
	if Input.is_action_just_pressed('ui_cancel'):
		match currentView:
			VIEW_2D:
				for i in oUi.listOfWindowDialogs:
					if is_instance_valid(i) == true:
						if i.visible == true:
							if i.get_close_button().visible == true:
								i.visible = false
			VIEW_3D:
				if oExportPreview.visible == true:
					oExportPreview.hide()
				set_view_2d()
	
	if currentView == VIEW_3D:
		if event.is_action_pressed("mouse_right"):
			if oMenu.visible == false:
				set_view_2d()

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		Settings.write_cfg("editor_window_position", OS.window_position)
		Settings.write_cfg("editor_window_maximized_state", OS.window_maximized)
		Settings.write_cfg("editor_window_fullscreen_state", OS.window_fullscreen)
		Settings.write_cfg("editor_window_size", OS.window_size)
		
		#if OS.has_feature("standalone") == true:
		if mapHasBeenEdited == true:
			Utils.popup_centered(oConfirmSaveBeforeQuit)
		else:
			get_tree().quit()
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		Engine.target_fps = framerate_limit
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		Engine.target_fps = int(min(12, framerate_limit))

func just_opened_editor():
	yield(get_tree(),'idle_frame')
	set_view_2d() # For when you load up the program and don't load a map

func set_view_2d():
	currentView = VIEW_2D
	oGame2D.visible = true
	oGame3D.visible = false
	oCamera2D.current = true
	oCamera3D.current = false
	oUi.switch_to_2D()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_view_3d():
	currentView = VIEW_3D
	oGame2D.visible = false
	oGame3D.visible = true
	oCamera2D.current = false
	oCamera3D.current = true

func _on_ConfirmQuit_confirmed():
	get_tree().quit()

func update_boundaries():
	fieldBoundary = Rect2(Vector2(1,1), Vector2(M.xSize-2,M.ySize-2)) # Position, Size
	if oEditableBordersCheckbox.pressed == true:
		fieldBoundary = Rect2(Vector2(0,0), Vector2(M.xSize,M.ySize))

func set_framerate_limit(val):
	Engine.target_fps = val
	framerate_limit = val

func set_ssaa_level(val):
	ssaa_level = val
	var oOverheadGraphics = Nodelist.list["oOverheadGraphics"]
	var oGame3D = Nodelist.list["oGame3D"]
	if oOverheadGraphics != null:
		oOverheadGraphics.update_ssaa_level(val)
	if oGame3D != null:
		oGame3D.update_ssaa_level(val)
