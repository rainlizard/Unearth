extends PanelContainer
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oScriptEditorStatusLabel = Nodelist.list["oScriptEditorStatusLabel"]
onready var oScriptHelpers = Nodelist.list["oScriptHelpers"]
onready var oUi = Nodelist.list["oUi"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oScriptEditorWindow = Nodelist.list["oScriptEditorWindow"]

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
	update_empty_script_status()
	
	var updateHelpers = false
	var line = oScriptTextEdit.get_line(oScriptTextEdit.cursor_get_line())
	for i in oScriptHelpers.commandsWithPositions.size():
		if oScriptHelpers.commandsWithPositions[i][0] in line.to_upper():
			updateHelpers = true
	if updateHelpers == true:
		oScriptHelpers.start() # in the case of updating a line (with coords) in the built-in Script Editor


func set_script_as_edited(edited):
	scriptHasBeenEditedInUnearth = edited
	match edited:
		true:
			oScriptEditorWindow.window_title = "Edit DKScript *"
			oEditor.mapHasBeenEdited = true
		false:
			oScriptEditorWindow.window_title = "Edit DKScript"


func set_script_data(value):
	value = value.replace(char(0x200B), "") # Remove Zero Width Spaces
	oDataScript.data = value


func update_empty_script_status():
	if oScriptTextEdit.text == "":
		oScriptEditorStatusLabel.text = "Your script file is empty!"
	else:
		var script_file_path = "No script file loaded"
		if oCurrentMap.currentFilePaths.has("TXT"):
			script_file_path = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
		else:
			script_file_path = oCurrentMap.path + '.txt'
		oScriptEditorStatusLabel.text = script_file_path


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
	
	update_empty_script_status()
	oScriptHelpers.start() # in the case of editing text file outside of Unearth


func _on_ScriptTextEdit_visibility_changed():
	if visible == false:
		# When you close the window, update script helpers. This is important to update here in case you remove any lines (helper related) in the script editor
		oScriptHelpers.start()


func _on_ScriptHelpButton_pressed():
	oMessage.big("Help","Changes made to the script in this window are only committed to file upon saving the map. Changes made to the script externally using a text editor such as Notepad are instantly reloaded into Unearth, replacing any work done in this window. \nUse Google to learn more about Dungeon Keeper Script Commands.")


func _input(event):
	if event is InputEventMouseButton and (event.is_pressed()):
		if Rect2( oScriptTextEdit.rect_global_position, oScriptTextEdit.rect_size ).has_point(oScriptTextEdit.get_global_mouse_position()) == false:
			oScriptTextEdit.release_focus()


func _on_ScriptEditorCloseButton_pressed():
	oScriptEditorWindow.hide()


func _on_ScriptEditorStatusLabel_pressed():
	var err = OS.shell_open(oScriptEditorStatusLabel.text)
	if err != OK:
		oMessage.quick("Error: " + str(err))
