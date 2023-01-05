extends FileDialog
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]

func _on_ChooseDkExe_file_selected(path):
	Settings.set_setting("executable_path", path) # Do this first so running_keeperfx() works
	if oGame.running_keeperfx() == false:
		oMessage.big("Warning", "It seems you didn't select keeperfx.exe, it is recommended that you install and use KeeperFX to take advantage of new features.")
	
	var err = oGame.test_write_permissions()
	if err == OK:
		oTextureCache.start() # Run this again, important for first-time users, because the path has now been set.
