extends ConfirmationDialog

func _ready():
	get_ok().text = "Yes"
	get_cancel().text = "No"
