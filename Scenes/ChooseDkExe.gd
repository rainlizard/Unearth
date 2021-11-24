extends FileDialog
onready var oTextureCache = Nodelist.list["oTextureCache"]

func _on_ChooseDkExe_file_selected(path):
	Settings.set_setting("executable_path", path)
	oTextureCache.start() # Run this again, important for first-time users, because the path has now been set.
