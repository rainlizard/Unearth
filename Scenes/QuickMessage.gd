extends Control

var scnMsgInst = preload('res://Scenes/MessageInstance.tscn')

func message(string):
	var id = scnMsgInst.instance()
	id.show_then_fade(string)
	$VBoxContainer.add_child(id)
