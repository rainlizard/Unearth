extends Control
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oScriptEmptyStatus = Nodelist.list["oScriptEmptyStatus"]

func _ready():
	loop_check_if_txt_file_has_been_modified()

func loop_check_if_txt_file_has_been_modified():
	if oCurrentMap.currentFilePaths.has("TXT"):
		var filePath = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
		var getModifiedTime = File.new().get_modified_time(filePath)
		if oCurrentMap.currentFilePaths["TXT"][oCurrentMap.MODIFIED_DATE] != getModifiedTime:
			oMessage.quick("Script reloaded from file.") #"Script was reloaded from file."
			oCurrentMap.currentFilePaths["TXT"][oCurrentMap.MODIFIED_DATE] = getModifiedTime
			# Reload
			Filetypes.read(filePath, "TXT")
			reload_script_into_textedit()
	
	yield(get_tree().create_timer(1.0), "timeout")
	loop_check_if_txt_file_has_been_modified()

func set_text(setWithString):
	oEditor.mapHasBeenEdited = true
	oDataScript.data = setWithString
	reload_script_into_textedit()

func _on_ScriptTextEdit_visibility_changed():
	if visible == true:
		reload_script_into_textedit()

func reload_script_into_textedit():
	oScriptTextEdit.text = oDataScript.data
	update_empty_script_status()

func _on_ScriptTextEdit_text_changed():
	oEditor.mapHasBeenEdited = true
	oDataScript.data = oScriptTextEdit.text
	update_empty_script_status()

func update_empty_script_status():
	if oScriptTextEdit.text == "":
		oScriptEmptyStatus.visible = true
	else:
		oScriptEmptyStatus.visible = false


#	if oCurrentMap.currentFilePaths.has("TXT"):
#		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]

#func place_text(insertString):
#	insertString =
	
	#oScriptTextEdit.cursor_set_line(lineNumber, txt)
#	var lineNumber = oScriptTextEdit.cursor_get_line()
#	var existingLineString = oScriptTextEdit.get_line(lineNumber)
#
#	if oScriptTextEdit.get_line(lineNumber).length() > 0: #If line contains stuff
#		oScriptTextEdit.set_line(lineNumber, existingLineString + '\n')
#		oScriptTextEdit.set_line(lineNumber+1, insertString)
#
#		oScriptTextEdit.cursor_set_line(oScriptTextEdit.cursor_get_line()+1)
#	else:
#		oScriptTextEdit.set_line(lineNumber, insertString)
#	oScriptTextEdit.update()


#func reload_script_into_window(): # Called from oDataScript
#	oScriptTextEdit.text = oDataScript.data
	
#	if oCurrentMap.currentFilePaths.has("TXT"):
#		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
#	else:
#		oScriptNameLabel.text = "No script file loaded"
	
#	hide_script_side()
	
#	if oDataScript.data == "":
#		hide_script_side()
#	else:
#		show_script_side()

#func hide_script_side():
#	oScriptContainer.visible = false
	# Make scroll bar area fill the entire window
	#oGeneratorContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#yield(get_tree(),'idle_frame')
	#rect_size.x = 0

#func show_script_side():
#	oScriptContainer.visible = true
#	# Reduce scroll bar area so ScriptContainer has space
#	oGeneratorContainer.size_flags_horizontal = Control.SIZE_FILL
#	yield(get_tree(),'idle_frame')
#	if rect_size.x < 960:
#		rect_size.x = 1280




func _on_ScriptHelpButton_pressed():
	oMessage.big("Help","Changes made to the script in this window are only committed to file upon saving the map. Changes made to the script externally using a text editor such as Notepad are instantly reloaded into Unearth, replacing any work done in this window. \nUse Google to learn more about Dungeon Keeper Script Commands.")
