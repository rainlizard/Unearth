extends FileDialog
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oKeeperFXDetection = Nodelist.list["oKeeperFXDetection"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]

func _on_ChooseDkExe_file_selected(path):
	Settings.set_setting("executable_path", path) # Do this first so running_keeperfx() works
	if oGame.running_keeperfx() == false:
		oMessage.big("Warning", "It seems you didn't select the keeperfx executable, it is recommended that you install and use KeeperFX to take advantage of new features.")
	
	var err = oGame.test_write_permissions()
	if err == OK:
		oTMapLoader.start() # Run this again, important for first-time users, because the path has now been set.
	
	oMapBrowser.popup()
