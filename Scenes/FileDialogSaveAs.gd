extends FileDialog
onready var oGame = Nodelist.list["oGame"]
onready var oUi = Nodelist.list["oUi"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oSaveMap = Nodelist.list["oSaveMap"]

var saveInstruction = Label.new()
var lineEdit
var lineEditPreviousText = "sadfdfgfdhgfds" # this should be something that won't be initially written in linedit

func _ready():
	# Get rid of filetypes dropdown
	var fileTypeOptionButton = get_vbox().get_child(3).get_child(2)
	fileTypeOptionButton.visible = false
	
	# Remove 'File:'
	get_line_edit().get_parent().get_child(0).text = ""
	
	lineEdit = get_line_edit()
	get_vbox().add_child(saveInstruction)
	get_vbox().move_child(saveInstruction,3)
	lineEdit.connect('focus_exited',self, 'line_edit_focus_exited')

func line_edit_focus_exited():
	if int(lineEdit.text) == 0:
		lineEdit.text = "1"
	while lineEdit.text.length() < 8:
		lineEdit.text = lineEdit.text.insert(3,"0")

func _on_FileDialogSaveAs_about_to_show():
	
	var path
	if oCurrentMap.path == "":
		var personalFolder = oGame.DK_LEVELS_DIRECTORY.plus_file("personal")
		if Directory.new().dir_exists(personalFolder) and oGame.running_keeperfx() == true:
			path = personalFolder # KeeperFX has personal folder
		else:
			path = oGame.DK_LEVELS_DIRECTORY # Old DK does not have personal folder
	else:
		path = oCurrentMap.path
	
	
	current_path = path
	current_dir = path
	
	if oCurrentMap.path == "":
		# New number
		#var newMapNum = Random.randi_range(1,32767)
		#lineEdit.text = str(newMapNum)
		working_directory_was_changed()
	else:
		# Use existing number
		var currentMapNumber = oCurrentMap.path.get_file().to_upper().trim_prefix("MAP")
		lineEdit.text = str(currentMapNumber)
	
	yield(get_tree(),'idle_frame')
	lineEdit.caret_position = lineEdit.text.length()
	lineEdit.grab_focus()
	deselect_items()

var previousCurrentDir = ""

func _process(delta):
	if visible == false: return
	
	# This is better than a signal because it covers more cases, such as when clicking on a file in the dialog
	if lineEditPreviousText != lineEdit.text:
		linedit_was_changed()
		lineEditPreviousText = lineEdit.text
	
	if previousCurrentDir != current_dir:
		previousCurrentDir = current_dir
		working_directory_was_changed()
	
	saveInstruction.set("custom_colors/font_color", Color(1,0.5,0.5,1))
	
	var dir = current_dir.to_upper()
	if oGame.running_keeperfx() == true:
		saveInstruction.text = "Map not playable from this directory. (KeeperFX)"
		if dir.ends_with("/LEVELS"):
			saveInstruction.text = "Must save in a sub directory. (KeeperFX)"
		if dir.ends_with("/CAMPGNS"):
			saveInstruction.text = "Must save in a sub directory. (KeeperFX)"
		if dir.get_base_dir().ends_with("/LEVELS") or dir.get_base_dir().ends_with("/CAMPGNS"):
			saveInstruction.text = "Map playable from this directory. (KeeperFX)"
			saveInstruction.set("custom_colors/font_color", Color(0.5,1.0,0.5,1))
	else:
		saveInstruction.text = "Map not playable from this directory. (Original DK)"
		# Original DK
		if dir.ends_with("/LEVELS"):
			saveInstruction.text = "Map playable from this directory. (Original DK)"
			saveInstruction.set("custom_colors/font_color", Color(0.5,1.0,0.5,1))

func working_directory_was_changed():
	if oCurrentMap.path == "":
		var newMapNumber = determine_next_available_map_number_in_dir(current_dir)
		lineEdit.text = 'map' + str(newMapNumber)
		line_edit_focus_exited()
		

func linedit_was_changed():
	var rememberCaretPos = lineEdit.caret_position
	lineEdit.text = lineEdit.text.trim_prefix("map")
	
	# remove the letters "m-a-p" when checking whether the string has letters. removing the prefix isn't good enough here.
	if Utils.string_has_letters(lineEdit.text.to_lower().replace("m","").replace("a","").replace("p","").trim_suffix(".slb")) == true:
		oMessage.quick("Use only digits in map name")
	
	var numberString = Utils.strip_letters_from_string(lineEdit.text)
	
	lineEdit.text = numberString
	
	while lineEdit.text.length() > 5:
		var eraseTxt = lineEdit.text
		eraseTxt.erase(0, 1)
		lineEdit.text = eraseTxt
	if lineEdit.text == "00000":
		lineEdit.text = "00001"
	if int(lineEdit.text) > 32767:
		lineEdit.text = "32767"
		oMessage.quick("Map number cannot be larger than 32767")
	
	lineEdit.text = "map"+lineEdit.text
	lineEdit.caret_position = rememberCaretPos+3

func _on_FileDialogSaveAs_visibility_changed():
	if is_instance_valid(oUi) == false: return
	if visible == true:
		oUi.hide_tools()
	else:
		oUi.show_tools()

func determine_next_available_map_number_in_dir(path):
	path = get_drive().plus_file(path)
	var mapFileNumbers = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.to_upper().ends_with(".SLB"):
					mapFileNumbers.append(file_name.get_file().to_int())
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	if mapFileNumbers.empty() == true:
		return 1
	else:
		mapFileNumbers.sort()
		for i in mapFileNumbers:
			if i < 0:
				continue
			if mapFileNumbers.has(i+1) == false:
				return i+1
		return 1

func get_drive(): # This may have problems in Linux
	var driveOptionButton = get_vbox().get_child(0).get_child(2).get_child(0)
	return driveOptionButton.get_item_text(driveOptionButton.selected)


func _on_FileDialogSaveAs_file_selected(filePath):
	filePath = filePath.get_basename()
	oSaveMap.save_map(filePath)
