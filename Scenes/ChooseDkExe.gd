extends FileDialog
onready var oTMapLoader = Nodelist.list["oTMapLoader"]
onready var oGame = Nodelist.list["oGame"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oKeeperFXDetection = Nodelist.list["oKeeperFXDetection"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]

func _ready():
	# On Linux the native KeeperFX binary ("keeperfx") has no .exe extension, so the
	# scene's "*.exe" filter would hide it. Show all files so it can be selected.
	if OS.get_name() == "X11":
		clear_filters()

func _on_ChooseDkExe_file_selected(path):
	Settings.set_setting("executable_path", path) # Do this first so keeperfx_is_installed() works
	if oGame.keeperfx_is_installed() == false:
		oMessage.big("Warning", "It seems you didn't select the keeperfx executable, it is recommended that you install and use KeeperFX to take advantage of new features.")
	
	var err = oGame.test_write_permissions()
	if err == OK:
		oTMapLoader.start() # Run this again, important for first-time users, because the path has now been set.
	
	oMapBrowser.popup()
