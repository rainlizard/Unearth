extends PanelContainer
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oScriptEditorEditButton = Nodelist.list["oScriptEditorEditButton"]
onready var oScriptMarkers = Nodelist.list["oScriptMarkers"]
onready var oScriptGenerator = Nodelist.list["oScriptGenerator"]
onready var oScriptPathLinkButton = Nodelist.list["oScriptPathLinkButton"]
onready var oConfirmScriptDeletion = Nodelist.list["oConfirmScriptDeletion"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oMenu = Nodelist.list["oMenu"]

var scriptHasBeenEditedInUnearth = false

var SCRIPT_EDITOR_FONT_SIZE = 20 setget set_SCRIPT_EDITOR_FONT_SIZE, get_SCRIPT_EDITOR_FONT_SIZE


func set_SCRIPT_EDITOR_FONT_SIZE(setVal):
	SCRIPT_EDITOR_FONT_SIZE = setVal
	var current_font = oScriptTextEdit.get_font("font").duplicate()
	current_font.size = SCRIPT_EDITOR_FONT_SIZE
	oScriptTextEdit.add_font_override("font", current_font)


func get_SCRIPT_EDITOR_FONT_SIZE():
	return SCRIPT_EDITOR_FONT_SIZE


func initialize_for_new_map():
	update_texteditor()
	set_script_as_edited(false)
	oScriptTextEdit.clear_undo_history() # Important so the 1st undo state is the loaded script


func _on_ScriptTextEdit_text_changed():
	set_script_as_edited(true)
	set_script_data(oScriptTextEdit.text)


func set_script_as_edited(edited):
	scriptHasBeenEditedInUnearth = edited
	if edited:
		oEditor.mapHasBeenEdited = true


func set_script_data(value):
	value = value.replace(char(0x200B), "") # Remove Zero Width Spaces
	oDataScript.data = value
	oCurrentMap.DKScript_enabled = true # Editing the script creates its file on save


func load_generated_text(setWithString):
	set_script_as_edited(true)
	set_script_data(setWithString)
	update_texteditor()


func update_texteditor():
	# This is for when pressing Undo
	var scroll = oScriptTextEdit.scroll_vertical
	var lineNumber = oScriptTextEdit.cursor_get_line()
	var columnNumber = oScriptTextEdit.cursor_get_column()

	oScriptTextEdit.text = oDataScript.data # This resets a bunch of stuff in TextEdit like cursor line.

	oScriptTextEdit.cursor_set_line(lineNumber)
	oScriptTextEdit.scroll_vertical = scroll
	oScriptTextEdit.cursor_set_column(columnNumber)

	oScriptMarkers.start() # in the case of editing text file outside of Unearth


func _on_ScriptTextEdit_visibility_changed():
	if is_instance_valid(oScriptTextEdit) and oScriptTextEdit.is_visible_in_tree() == false:
		set_editing(false)


func _on_ScriptEditorEditButton_pressed():
	set_editing(oScriptTextEdit.readonly)


func set_editing(enabled):
	if enabled != oScriptTextEdit.readonly: # Already in this mode
		return
	oScriptEditorEditButton.text = "Close" if enabled else "Edit" # Editing hides the basic options, filling the window with the script
	oScriptTextEdit.readonly = enabled == false
	if enabled:
		oScriptTextEdit.deselect() # Hovering basic options selects lines, typing shouldn't replace them
		oScriptTextEdit.grab_focus()
	else:
		oScriptMarkers.start() # Update script helpers in case lines related to them were changed in the source editor.
	oScriptGenerator.refresh()


func _on_ScriptPathLinkButton_pressed():
	oMenu.open_externally(oScriptPathLinkButton.hint_tooltip, "Save the map to write the DKScript file.")


func _on_DeleteScriptButton_pressed():
	Utils.popup_centered(oConfirmScriptDeletion)


func _on_ConfirmScriptDeletion_confirmed():
	oCurrentMap.DKScript_enabled = false
	oDataScript.data = "" # Editing the script recreates it, so don't leave the deleted text in the script editor
	update_texteditor()
	oEditor.mapHasBeenEdited = true
	oMessage.quick("DKScript file will be removed on next save.")
	oScriptGenerator.refresh()


func _input(event):
	if event is InputEventMouseButton and (event.is_pressed()):
		if Rect2( oScriptTextEdit.rect_global_position, oScriptTextEdit.rect_size ).has_point(oScriptTextEdit.get_global_mouse_position()) == false:
			oScriptTextEdit.release_focus()
