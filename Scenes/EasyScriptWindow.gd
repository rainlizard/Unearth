extends WindowDialog
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]


func _on_ScriptTextEdit_text_changed():
	oDataScript.data = oScriptTextEdit.text


func _on_EasyScriptWindow_about_to_show():
	reload_script_into_window()

func reload_script_into_window(): # Called from oDataScript
	oScriptTextEdit.text = oDataScript.data
