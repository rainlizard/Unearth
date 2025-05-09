extends WindowDialog
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oMessage = Nodelist.list["oMessage"]

func _ready():
	connect("about_to_show", self, "_on_about_to_show")

func try_open(ext):
	var pathToTryAndOpen = oCurrentMap.path + ext
	var err = OS.shell_open(pathToTryAndOpen)
	if err != OK:
		oMessage.quick("Could not open: " + pathToTryAndOpen)

func _on_ButtonConfirmOpenDKScript_pressed():
	try_open(".txt")
	hide()

func _on_ButtonConfirmOpenLuaScript_pressed():
	try_open(".lua")
	hide()

func _on_ButtonConfirmCancelOpenScript_pressed():
	hide()
