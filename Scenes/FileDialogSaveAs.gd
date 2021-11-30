extends FileDialog
onready var oGame = Nodelist.list["oGame"]
onready var oUi = Nodelist.list["oUi"]

var lineEdit
var regex = RegEx.new()
var oldtext = ""

func _ready():
	#print(get_vbox().get_child(3).get_children())
#	print(get_vbox().get_child(0).get_children())
#	print(get_vbox().get_child(1).get_children())
#	print(get_vbox().get_child(2).get_children())
#	print(get_vbox().get_child(3).get_children())
	var optionButton = get_vbox().get_child(3).get_child(2)
	optionButton.visible = false
	
	var tree = get_vbox().get_children()[2].get_children()[0]
	tree.connect("item_selected",self,"_on_Tree_item_selected") # File is clicked once in the window
	
	lineEdit = get_line_edit()
	lineEdit.connect("text_changed",self,"_on_LineEdit_text_changed")
	regex.compile("^[0-9]*$")

func _on_FileDialogSaveAs_about_to_show():
	
	var path = oGame.SAVE_AS_DIRECTORY
	if oGame.SAVE_AS_DIRECTORY == "":
		path = oGame.EXECUTABLE_PATH
	
	current_path = path
	current_dir = path
	
	lineEdit.placeholder_text = "(Enter numbers only)"
	lineEdit.placeholder_alpha = 0.15
	
	yield(get_tree(),'idle_frame')
	deselect_items()
	lineEdit.text = ""
	_on_LineEdit_text_changed("")

func _on_Tree_item_selected():
	# This sometimes fails the first time
	yield(get_tree(),'idle_frame')
	lineEdit.text = lineEdit.text.to_lower().trim_suffix('.slb')
	yield(get_tree(),'idle_frame')
	lineEdit.text = lineEdit.text.to_lower().trim_suffix('.slb')

func _on_LineEdit_text_changed(new_text):
	var okButton = get_ok()
	if new_text.length() < 8:
		okButton.hint_tooltip = "Map name must contain 5 numbers."
		okButton.disabled = true
	else:
		okButton.hint_tooltip = ""
		okButton.disabled = false
	
	if new_text.length() > 8:
		new_text = new_text.left(8)
	
	new_text = new_text.to_lower().trim_prefix("map")
	
	if regex.search(new_text):
		lineEdit.text = new_text
		oldtext = lineEdit.text
		lineEdit.text = 'map'+new_text
	else:
		lineEdit.text = 'map'+oldtext
	
	lineEdit.set_cursor_position(lineEdit.text.length())

#func get_value():
#	return(int(lineEdit.text))


func _on_FileDialogSaveAs_visibility_changed():
	if is_instance_valid(oUi) == false: return
	if visible == true:
		oUi.hide_tools()
	else:
		oUi.show_tools()
