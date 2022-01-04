extends WindowDialog
#onready var oUnearthVerLabel = Nodelist.list["oUnearthVerLabel"]
onready var oMain = Nodelist.list["oMain"]
onready var oAboutGridContainer = Nodelist.list["oAboutGridContainer"]

func _ready():
	for i in oAboutGridContainer.get_children():
		if i is LinkButton:
			i.connect("pressed",self,"on_link_clicked",[i])

func on_link_clicked(id):
	OS.shell_open(id.text)


func _on_AboutWindow_about_to_show():
	#if is_instance_valid(oMain) == false: return
	#oUnearthVerLabel.text = 
	window_title = 'Unearth v'+Constants.VERSION

