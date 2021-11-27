extends Control
onready var oUiMessages = Nodelist.list["oUiMessages"]

var scnQuickMsg = preload('res://Scenes/QuickMsgInstance.tscn')
var scnBigMsg = preload('res://Scenes/BigMessageInstance.tscn')

func quick(string):
	var id = scnQuickMsg.instance()
	id.show_then_fade(string)
	$VBoxContainer.add_child(id)

func big(windowTitle,dialogText):
	yield(get_tree(),'idle_frame')
	var id = scnBigMsg.instance()
	id.window_title = windowTitle
	id.dialog_text = dialogText
	oUiMessages.add_child(id)
	Utils.popup_centered(id)
