extends Node


func popup_centered(node):
	node.popup_centered()
	
	# Switching visibility off then on fixes a "popup" bug which interferes with how the mouse is detected over UI.
	node.visible = false
	node.visible = true


func _input(_event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


var regex = RegEx.new()
var noSpecialCharsRegex = RegEx.new()
func _ready():
	regex.compile("^[0-9]*$")
	noSpecialCharsRegex.compile("[^a-zA-Z0-9]")

func strip_special_chars_from_string(input_string: String) -> String:
	var output_string = noSpecialCharsRegex.sub(input_string, "", true)
	return output_string

func strip_letters_from_string(string):
	for character in string:
		if regex.search(character) == null:
			string = string.replace(character,"")
	return string

func string_has_letters(string):
	if regex.search(string) == null:
		return true
	return false

func load_external_texture(path):
	var img = Image.new()
	img.load(path)
	var texture = ImageTexture.new()
	texture.create_from_image(img, Texture.FLAG_MIPMAPS+Texture.FLAG_ANISOTROPIC_FILTER)
	return texture

func get_filetype_in_directory(directory_path: String, file_extension: String) -> Array:
	var files = []
	var directory = Directory.new()
	if directory.open(directory_path) == OK:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			if not directory.current_is_dir() and file_name.get_extension().to_lower() == file_extension.to_lower():
				files.append(directory_path.plus_file(file_name))
			file_name = directory.get_next()
		directory.list_dir_end()
	else:
		print("Failed to open directory: ", directory_path)
	return files

func read_dkcfg_file(file_path) -> Dictionary:
	var config = {}
	var current_section = ""
	
	var file = File.new()
	if not file.file_exists(file_path):
		return config
	
	var CODETIME_START = OS.get_ticks_msec()
	
	file.open(file_path, File.READ)
	var lines = file.get_as_text().split("\n")
	file.close()
	
	for line in lines:
		line = line.strip_edges()
		
		if line.begins_with(";") or line.empty():
			continue
		
		if line.begins_with("[") and line.ends_with("]"):
			current_section = line.substr(1, line.length() - 2)
			config[current_section] = {}
		else:
			var delimiter_pos = line.find("=") # Splits by equals sign with substr()
			if delimiter_pos != -1:
				var key = line.substr(0, delimiter_pos).strip_edges()
				var value = line.substr(delimiter_pos + 1).strip_edges()
				
				var items = value.split(" ")
				if items.size() > 1:
					var construct_new_value_array = []
					for item in items:
						item = item.strip_edges()
						if not item.empty(): # This handles having multiple spaces in a row
							if item.is_valid_integer():
								construct_new_value_array.append(int(item))
							else:
								construct_new_value_array.append(item)
					config[current_section][key] = construct_new_value_array
				else:
					if value.is_valid_integer():
						config[current_section][key] = int(value)
					else:
						config[current_section][key] = value
	
	print('Read ' + file_path.get_file() + ' dkcfg in : ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	return config

func super_merge(dict1, dict2):
	var merged = {}
	for key in dict1:
		merged[key] = dict1[key]
	for key in dict2:
		if key in merged and typeof(merged[key]) == TYPE_DICTIONARY and typeof(dict2[key]) == TYPE_DICTIONARY:
			merged[key] = super_merge(merged[key], dict2[key])
		else:
			merged[key] = dict2[key]
	return merged

func _escape_text_for_display(text_string: String) -> String:
	return text_string.replace("\n", "\\n").replace("\"", "\\\"")

func _get_node_display_details(targetNode) -> String:
	var baseName = targetNode.name
	if baseName.begins_with("@@"):
		baseName = targetNode.get_class()

	var additionalInfo = ""
	var nodeTextValue = ""

	if targetNode is Label:
		nodeTextValue = targetNode.text
		if nodeTextValue != "":
			additionalInfo = ".text = \"" + _escape_text_for_display(nodeTextValue) + "\""
	elif targetNode is OptionButton: # Check before BaseButton
		if targetNode.get_item_count() > 0 and targetNode.selected >= 0:
			var selectedItemText = targetNode.get_item_text(targetNode.selected)
			additionalInfo = ".selected = \"" + _escape_text_for_display(selectedItemText) + "\""
		elif "text" in targetNode and targetNode.text != "": # Fallback to OptionButton's own .text
			nodeTextValue = targetNode.text
			additionalInfo = ".text = \"" + _escape_text_for_display(nodeTextValue) + "\""

	elif targetNode is TextureButton:
		# TextureButton uses textures, not text. No text property to display.
		pass

	elif targetNode is BaseButton: # Covers Button, CheckBox, LinkButton, ToolButton, MenuButton etc.
									# OptionButton and TextureButton are handled above.
		if "text" in targetNode: # Safely check for 'text' property
			nodeTextValue = targetNode.text
			if nodeTextValue != "":
				additionalInfo = ".text = \"" + _escape_text_for_display(nodeTextValue) + "\""
	elif targetNode is LineEdit:
		nodeTextValue = targetNode.text
		var placeholderText = targetNode.placeholder_text
		if nodeTextValue != "":
			additionalInfo = ".text = \"" + _escape_text_for_display(nodeTextValue) + "\""
		elif placeholderText != "":
			additionalInfo = ".placeholder = \"" + _escape_text_for_display(placeholderText) + "\""
	elif targetNode is TextEdit:
		nodeTextValue = targetNode.text
		if nodeTextValue != "":
			var preview = nodeTextValue.substr(0, 30)
			if nodeTextValue.length() > 30:
				preview += "..."
			additionalInfo = ".text = \"" + _escape_text_for_display(preview) + "\""
	elif targetNode is RichTextLabel:
		nodeTextValue = targetNode.text # Gets the plain text content
		if nodeTextValue != "":
			var preview = nodeTextValue.substr(0, 30)
			if nodeTextValue.length() > 30:
				preview += "..."
			additionalInfo = ".text = \"" + _escape_text_for_display(preview) + "\""
	# Add more 'elif' conditions here for other node types and their relevant properties if needed

	return baseName + additionalInfo

func log_named_tree(startNode = null):
	var actualStartNode = startNode
	if actualStartNode == null:
		actualStartNode = get_tree().get_root()
		if actualStartNode == null: # Should not happen in a running scene
			print("Error: Could not get scene root to log tree.")
			return

	var rootNodeDisplayName = _get_node_display_details(actualStartNode)
	print(" ┖╴" + rootNodeDisplayName) # Note: initial space for alignment
	
	var nodeChildren = actualStartNode.get_children()
	var childCount = nodeChildren.size()
	var initialChildPrefix = "   " # Consistent with example output for first-level children
	for index in range(childCount):
		var currentChild = nodeChildren[index]
		_recursive_log_named_nodes(currentChild, initialChildPrefix, index == childCount - 1)

func _recursive_log_named_nodes(targetNode, linePrefix, isLastSibling):
	var currentLine = linePrefix
	if isLastSibling:
		currentLine += "┖╴"
	else:
		currentLine += "┠╴"
	
	var nodeDisplayName = _get_node_display_details(targetNode)
	print(currentLine + nodeDisplayName)
	
	var nodeChildren = targetNode.get_children()
	var childCount = nodeChildren.size()
	for index in range(childCount):
		var currentChild = nodeChildren[index]
		var childRecursivePrefix = linePrefix
		if isLastSibling:
			childRecursivePrefix += "   " # Align with parent's "┖╴"
		else:
			childRecursivePrefix += "┃  " # Align with parent's "┠╴"
		_recursive_log_named_nodes(currentChild, childRecursivePrefix, index == childCount - 1)
