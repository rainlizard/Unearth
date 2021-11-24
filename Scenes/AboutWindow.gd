extends WindowDialog
#onready var oUnearthVerLabel = Nodelist.list["oUnearthVerLabel"]
onready var oMain = Nodelist.list["oMain"]

func _ready():
	pass # Replace with function body.


func _on_AboutWindow_about_to_show():
	#if is_instance_valid(oMain) == false: return
	#oUnearthVerLabel.text = 
	window_title = 'Unearth v'+Constants.VERSION
