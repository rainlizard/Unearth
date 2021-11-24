extends AcceptDialog

func _ready():
	pass # Replace with function body.

func give_warning(string):
	get_label().text = string
	Utils.popup_centered(self)
