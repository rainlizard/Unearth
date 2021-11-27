extends FileDialog
onready var oGame = Nodelist.list["oGame"]
onready var oMapBrowser = Nodelist.list["oMapBrowser"]
onready var oUi = Nodelist.list["oUi"]

func _on_FileDialogOpen_about_to_show():
	var path = oGame.EXECUTABLE_PATH
	#if path != "":
	current_path = path.get_base_dir().plus_file("")
	current_dir = path.get_base_dir().plus_file("")

#func _ready():
#	Utils.popup_centered(self)
	#print(get_vbox().get_children())
	
	#var optionButton = get_vbox().get_child(3).get_child(2)
	#optionButton.remove_item(1)
	#optionButton.select(0)
	#optionButton.set_item_text(0,"*.slb")
	#filters
	
	#clear_filters()
	
	#add_filter("aaa ; aaa")
	
	
#	optionButton.set_item_id(0,10)
#	optionButton.set_item_id(1,0)


func _on_FileDialogOpen_visibility_changed():
	if is_instance_valid(oUi) == false: return
	if visible == true:
		oUi.hide_tools()
	else:
		oUi.show_tools()
