extends Control
onready var oUiMessages = Nodelist.list["oUiMessages"]

var scnQuickMsg = preload('res://Scenes/QuickMsgInstance.tscn')
var scnBigMsg = preload('res://Scenes/BigMessageInstance.tscn')

func quick(string):
	var id = scnQuickMsg.instance()
	id.show_then_fade(string)
	$VBoxContainer.add_child(id)

func big(windowTitle,dialogText):
	var id = scnBigMsg.instance()
	# Don't go smaller than 250 pixels wide
	# For longer lines, put message on two lines
	id.rect_size.x = max(250, (dialogText.length()*11) * 0.5)
	id.rect_size.y = 0
	id.window_title = windowTitle
	id.dialog_text = dialogText
	oUiMessages.add_child(id)
	Utils.popup_centered(id)
