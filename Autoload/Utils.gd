extends Node


func popup_centered(node):
	node.popup_centered()
	
	# Switching visibility off then on fixes a "popup" bug which interferes with how the mouse is detected over UI.
	# This emits popup_hide, so do not use that signal to detect cancellation with this helper.
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

func set_id_links_label(ids, rich_text_label, panel_container, empty_text):
	if ids.empty():
		panel_container.modulate = Color(1, 1, 1, 1)
		rich_text_label.rect_min_size.x = 0
		rich_text_label.bbcode_text = empty_text
		return

	panel_container.modulate = Color(1.4, 1.4, 1.7, 1.0)
	var parts = []
	for id in ids:
		parts.append("[url=" + str(id) + "]" + str(id) + "[/url]")
	rich_text_label.bbcode_text = ",".join(parts)

	parts.clear()
	for id in ids:
		parts.append(str(id))
	var font = rich_text_label.get_font("normal_font")
	rich_text_label.rect_min_size.x = ceil(font.get_string_size(",".join(parts)).x)

func string_has_letters(string):
	if regex.search(string) == null:
		return true
	return false

func strip_toml_comments(text):
	var lines = text.split("\n")
	for i in lines.size():
		lines[i] = strip_toml_comment(lines[i])
	return "\n".join(lines)

func strip_toml_comment(line):
	return "" if line.strip_edges().begins_with("#") else line

func load_toml_file(file_path):
	var file = File.new()
	if file.open(file_path, File.READ) != OK:
		return null
	var cfg = ConfigFile.new()
	var err = cfg.parse(strip_toml_comments(file.get_as_text()))
	file.close()
	return cfg if err == OK else null

func preserve_toml_comments(file_path, text):
	var file = File.new()
	if file.open(file_path, File.READ) != OK:
		return text

	var old_text = file.get_as_text()
	file.close()
	var comments_by_id = {}
	var comments = PoolStringArray()
	var state = ["", {}]
	for old_line in old_text.split("\n"):
		var line = old_line.trim_suffix("\r")
		var id = _get_toml_line_id(line, state)
		if line.strip_edges().begins_with("#"):
			comments.append(line)
		elif id != "" and comments.empty() == false:
			comments_by_id[id] = comments
			comments = PoolStringArray()
	var footer_comments = comments

	var merged = PoolStringArray()
	state = ["", {}]
	for line in text.split("\n"):
		var id = _get_toml_line_id(line, state)
		if comments_by_id.has(id):
			merged.append_array(comments_by_id[id])
			comments_by_id.erase(id)
		merged.append(line)

	if comments_by_id.empty() == false or footer_comments.empty() == false:
		if merged[merged.size() - 1] != "":
			merged.append("")
		for remaining_comments in comments_by_id.values():
			merged.append_array(remaining_comments)
		merged.append_array(footer_comments)
		merged.append("")
	return "\n".join(merged)

func get_toml_comments(file_path):
	var file = File.new()
	if file.open(file_path, File.READ) != OK:
		return PoolStringArray()

	var comments = PoolStringArray()
	for line in file.get_as_text().split("\n"):
		if line.strip_edges().begins_with("#"):
			comments.append(line.trim_suffix("\r"))
	file.close()
	return comments

func _get_toml_line_id(line, state):
	var stripped = line.strip_edges()
	var id = ""
	if stripped.begins_with("["):
		state[0] = stripped
		id = stripped
	elif "=" in stripped and stripped.begins_with("#") == false:
		id = state[0] + ":" + stripped.left(stripped.find("=")).strip_edges().to_lower()
	if id == "":
		return ""
	state[1][id] = state[1].get(id, 0) + 1
	return id + ":" + str(state[1][id])

func get_filetype_in_directory(directory_path: String, file_extension: String, include_subdirs = false) -> Array:
	var files = []
	var dirs_to_check = [directory_path]
	while dirs_to_check.empty() == false:
		var current_dir = dirs_to_check[0]
		dirs_to_check.remove(0)
		var directory = Directory.new()
		if directory.open(current_dir) != OK:
			print("Failed to open directory: ", current_dir)
			continue
		directory.list_dir_begin(true, false)
		var file_name = directory.get_next()
		while file_name != "":
			var path = current_dir.plus_file(file_name)
			if directory.current_is_dir():
				if include_subdirs:
					dirs_to_check.append(path)
			elif file_name.get_extension().to_lower() == file_extension.to_lower():
				files.append(path)
			file_name = directory.get_next()
		directory.list_dir_end()
	return files

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

func case_insensitive_file(directoryPath: String, baseFileName: String, targetExtension: String) -> String:
	var d = Directory.new()
	if d.open(directoryPath) != OK:
		printerr("Utils.case_insensitive_file: Could not open directory: ", directoryPath)
		return ""
	
	d.list_dir_begin(true, false)
	var entryName = d.get_next()

	var lowerExt = targetExtension
	if lowerExt != "" and lowerExt.begins_with(".") == false:
		lowerExt = "." + lowerExt
	lowerExt = lowerExt.to_lower()

	var lowerBaseName = baseFileName.to_lower()
	var targetFileNameLower = lowerBaseName + lowerExt

	while entryName != "":
		if d.current_is_dir() == false:
			if entryName.to_lower() == targetFileNameLower:
				d.list_dir_end()
				return directoryPath.plus_file(entryName)
		entryName = d.get_next()
	
	d.list_dir_end()
	return ""
