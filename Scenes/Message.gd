extends Control
onready var oUiMessages = Nodelist.list["oUiMessages"]

var scnQuickMsg = preload('res://Scenes/QuickMsgInstance.tscn')
var scnBigMsg = preload('res://Scenes/BigMessageInstance.tscn')

func quick(string):
	var id = scnQuickMsg.instance()
	id.show_then_fade(string)
	$VBoxContainer.add_child(id)

func big(windowTitle, dialogText):
	
	# Do not show big message if one already exists (which has the same message)
	for i in oUiMessages.get_children():
		if i is AcceptDialog:
			if i.window_title == windowTitle and i.dialog_text == dialogText:
				return
	
	var id = scnBigMsg.instance()
	# Don't go smaller than 250 pixels wide
	# For longer lines, put message on two lines
	id.rect_size.x = (dialogText.length()*11) * 0.5
	id.rect_size.x = clamp(id.rect_size.x, 240, 1280)
	id.rect_size.y = 0
	id.window_title = windowTitle
	id.dialog_text = dialogText
	
	id.get_label().margin_left = 20
	
	oUiMessages.add_child(id)
	Utils.popup_centered(id)
