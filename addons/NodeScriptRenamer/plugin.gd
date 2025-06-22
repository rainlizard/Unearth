tool
extends EditorPlugin

var scene_change_timer
var node_tracker = {}

func _enter_tree():
	scene_change_timer = Timer.new()
	scene_change_timer.wait_time = 0.1
	scene_change_timer.connect("timeout", self, "_check_node_changes")
	add_child(scene_change_timer)
	scene_change_timer.start()

func _exit_tree():
	if scene_change_timer:
		scene_change_timer.queue_free()

func _check_node_changes():
	var edited_scene = get_editor_interface().get_edited_scene_root()
	if not edited_scene:
		return
	
	_scan_nodes(edited_scene)

func _scan_nodes(node):
	var node_id = node.get_instance_id()
	var current_name = node.name
	
	if node_tracker.has(node_id):
		var stored_name = node_tracker[node_id]
		if stored_name != current_name and node.get_script():
			_handle_node_rename(node, stored_name, current_name)
	
	node_tracker[node_id] = current_name
	
	for child in node.get_children():
		_scan_nodes(child)

func _handle_node_rename(node, old_name, new_name):
	var script = node.get_script()
	if not script:
		return
	
	var script_path = script.resource_path
	if script_path.empty():
		return
	
	var script_filename = script_path.get_file().get_basename()
	
	if script_filename == old_name:
		_show_rename_dialog(node, script_path, old_name, new_name)

func _show_rename_dialog(node, script_path, old_name, new_name):
	var dialog = ConfirmationDialog.new()
	dialog.window_title = "Rename Script File?"
	var script_open_warning = ""
	if _is_script_open(script_path):
		script_open_warning = "\n\nNote: Please close the script tab before confirming."
	dialog.dialog_text = "Node '%s' was renamed to '%s'.\n\nDo you want to rename the script file from '%s.gd' to '%s.gd'?%s" % [old_name, new_name, old_name, new_name, script_open_warning]
	dialog.popup_exclusive = true
	
	get_editor_interface().get_base_control().add_child(dialog)
	dialog.popup_centered(Vector2(450, 180))
	
	dialog.connect("confirmed", self, "_on_rename_confirmed", [node, script_path, new_name], CONNECT_ONESHOT)
	dialog.connect("popup_hide", self, "_on_dialog_closed", [dialog], CONNECT_ONESHOT)

func _on_rename_confirmed(node, old_script_path, new_name):
	_rename_script_file(node, old_script_path, new_name)

func _on_dialog_closed(dialog):
	dialog.queue_free()

func _rename_script_file(node, old_script_path, new_name):
	var file_system = get_editor_interface().get_resource_filesystem()
	var file = File.new()
	
	if not file.file_exists(old_script_path):
		_show_error_dialog("Script file not found: " + old_script_path)
		return
	
	# Check if script is currently open and close it
	var was_script_open = _is_script_open(old_script_path)
	if was_script_open:
		_close_script_if_open(old_script_path)
	
	var directory = old_script_path.get_base_dir()
	var new_script_path = directory + "/" + new_name + ".gd"
	
	if file.file_exists(new_script_path):
		_show_error_dialog("File '%s' already exists!" % new_script_path)
		return
	
	var dir = Directory.new()
	var error = dir.copy(old_script_path, new_script_path)
	
	if error != OK:
		_show_error_dialog("Failed to copy script file. Error: " + str(error))
		return
	
	error = dir.remove(old_script_path)
	if error != OK:
		_show_error_dialog("Failed to remove old script file. Error: " + str(error))
		return
	
	var new_script = load(new_script_path)
	if new_script:
		node.set_script(new_script)
		_update_scene_references(old_script_path, new_script_path)
		file_system.scan()
		
		# Reopen the script if it was previously open
		if was_script_open:
			_open_script_in_editor(new_script_path)
		
		print("Script renamed: '%s' -> '%s'" % [old_script_path.get_file(), new_script_path.get_file()])
	else:
		_show_error_dialog("Failed to load new script file")

func _update_scene_references(old_path, new_path):
	var current_scene_path = get_editor_interface().get_edited_scene_root().filename
	if current_scene_path.empty():
		return
	
	var file = File.new()
	if file.open(current_scene_path, File.READ) != OK:
		return
	
	var content = file.get_as_text()
	file.close()
	
	var old_resource_ref = 'path="' + old_path + '"'
	var new_resource_ref = 'path="' + new_path + '"'
	
	if old_resource_ref in content:
		content = content.replace(old_resource_ref, new_resource_ref)
		
		if file.open(current_scene_path, File.WRITE) == OK:
			file.store_string(content)
			file.close()
			print("Updated scene references")

func _is_script_open(script_path):
	var script_editor = get_editor_interface().get_script_editor()
	if not script_editor:
		return false
	
	var open_scripts = script_editor.get_open_scripts()
	for script in open_scripts:
		if script.resource_path == script_path:
			return true
	return false

func _close_script_if_open(script_path):
	var script_editor = get_editor_interface().get_script_editor()
	if not script_editor:
		return
	
	# Check if the script is currently open
	var open_scripts = script_editor.get_open_scripts()
	var script_found = false
	
	for script in open_scripts:
		if script.resource_path == script_path:
			script_found = true
			break
	
	if script_found:
		# In Godot 3.5, we close all script tabs to avoid broken references
		# This ensures the file rename operation proceeds cleanly
		script_editor.call("_close_all_tabs")
		print("Closed all script tabs to prevent broken references during rename")

func _open_script_in_editor(script_path):
	# In Godot 3.5, let the user know they can reopen the script with its new name
	print("✓ Script renamed successfully! You can reopen it from the FileSystem dock: " + script_path.get_file())

func _show_error_dialog(message):
	var dialog = AcceptDialog.new()
	dialog.window_title = "Script Rename Error"
	dialog.dialog_text = message
	
	get_editor_interface().get_base_control().add_child(dialog)
	dialog.popup_centered(Vector2(400, 120))
	dialog.connect("popup_hide", self, "_on_dialog_closed", [dialog], CONNECT_ONESHOT) 
