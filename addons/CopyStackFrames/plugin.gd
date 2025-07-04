tool
extends EditorPlugin

var copy_button: Button


func _enter_tree() -> void:
	copy_button = Button.new()
	copy_button.text = "Copy Stack"
	add_control_to_container(CONTAINER_TOOLBAR, copy_button)
	copy_button.connect("pressed", self, "_on_copy_pressed")


func _exit_tree() -> void:
	if is_instance_valid(copy_button):
		remove_control_from_container(CONTAINER_TOOLBAR, copy_button)
		copy_button.queue_free()
		copy_button = null


func _find_node_by_class_recursive(p_node: Node, p_class: String) -> Node:
	if p_node.get_class() == p_class:
		return p_node
	for child in p_node.get_children():
		var found = _find_node_by_class_recursive(child, p_class)
		if found:
			return found
	return null


func _find_child_by_class(p_node: Node, p_class: String) -> Node:
	for child in p_node.get_children():
		if child.get_class() == p_class:
			return child
	return null


func find_stack_tree() -> Tree:
	print("Copy Stack Frames: Searching for stack tree using specific UI path...")
	var editor_base: Control = get_editor_interface().get_base_control()

	var sed: Node = _find_node_by_class_recursive(editor_base, "ScriptEditorDebugger")
	if not sed:
		print("Copy Stack Frames: Failed to find 'ScriptEditorDebugger'")
		return null
	
	var tc: Node = _find_child_by_class(sed, "TabContainer")
	if not tc:
		print("Copy Stack Frames: Failed to find 'TabContainer'")
		return null

	var dbg: Node = tc.find_node("Debugger", true, false)
	if not dbg:
		print("Copy Stack Frames: Failed to find 'Debugger' VBox")
		return null
	
	var hsc: Node = _find_child_by_class(dbg, "HSplitContainer")
	if not hsc:
		print("Copy Stack Frames: Failed to find 'HSplitContainer'")
		return null
		
	var tree: Tree = _find_child_by_class(hsc, "Tree")
	if not tree:
		print("Copy Stack Frames: Failed to find 'Tree'")
		return null

	print("Copy Stack Frames: Successfully found stack tree via specific path.")
	return tree


func _debug_find_text(node: Node, text_to_find: String) -> void:
	if node is Label and text_to_find in node.text:
		_print_node_ancestry(node, "Label")

	if node is Tree:
		var root: TreeItem = node.get_root()
		if root:
			var item: TreeItem = root.get_children()
			while item:
				for i in range(node.get_columns()):
					if text_to_find in item.get_text(i):
						_print_node_ancestry(node, "Tree (found in TreeItem)")
						return
				item = item.get_next()

	for child in node.get_children():
		_debug_find_text(child, text_to_find)


func _print_node_ancestry(node: Node, node_type: String) -> void:
	print("---- Found text in node of type: %s ----" % node_type)
	var current: Node = node
	while current:
		var parent_name: String = "null"
		if current.get_parent():
			parent_name = current.get_parent().name
		print("  Node: '%s', Class: '%s', Parent: '%s'" % [current.name, current.get_class(), parent_name])
		if current == get_editor_interface().get_base_control():
			break
		current = current.get_parent()
	print("-----------------------------------------")


func _on_copy_pressed() -> void:
	var stack_tree: Tree = find_stack_tree()
	
	if stack_tree == null:
		OS.alert("Could not find stack frames. Are you currently debugging and paused at a breakpoint?", "Copy Stack Frames")
		return

	var text: String = ""
	var root: TreeItem = stack_tree.get_root()
	if root == null:
		return

	var item: TreeItem = root.get_children()
	while item:
		var frame: String = item.get_text(0)
		var file: String = item.get_text(1)
		var line: String = item.get_text(2)
		var func_name: String = item.get_text(3)

		text += "%s - %s:%s - at function: %s\n" % [frame, file, line, func_name]
		item = item.get_next()

	if text.empty():
		OS.alert("Stack is empty.", "Copy Stack Frames")
		return
	
	OS.set_clipboard(text.strip_edges())
	print("Stack frames copied to clipboard.") 
