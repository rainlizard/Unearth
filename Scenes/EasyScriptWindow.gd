extends WindowDialog
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]


func _on_ScriptTextEdit_text_changed():
	oDataScript.data = oScriptTextEdit.text


func _on_EasyScriptWindow_about_to_show():
	oScriptTextEdit.text = oDataScript.data
