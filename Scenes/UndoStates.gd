extends Node

onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oMessage = Nodelist.list["oMessage"]

var undo_states = []
#var redo_states = []
var max_undo_states = 256

#func _process(delta):
#	set_process(false)
#	for i in 50:
#		yield(get_tree(),'idle_frame')
#	oMessage.quick("saved state")
#	save_current_state()
#	set_process(true)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		oMessage.quick("saved state")
		save_current_state()
	if event.is_action_pressed("undo"):
		undo()
#	elif event.is_action_pressed("redo"):
#		redo()

func save_current_state():
	var current_state = {}

	for EXT in oBuffers.FILE_TYPES:
		if not oBuffers.should_process_file_type(EXT):
			continue
		current_state[EXT] = oBuffers.get_buffer_for_extension(EXT, oCurrentMap.path)

	undo_states.push_front(current_state)

	if undo_states.size() > max_undo_states:
		undo_states.pop_back()

	#redo_states.clear()


func undo():
	if undo_states.empty():
		oMessage.quick("No more undo states available.")
		return

	var previous_state = undo_states.pop_front()
	
	oCurrentMap.clear_map()
	
	for EXT in previous_state:
		var buffer = previous_state[EXT]
		oBuffers.read_buffer_for_extension(buffer, EXT)

	oOpenMap.finish_opening_map(oCurrentMap.path)
	oMessage.quick("Undo performed.")


#func redo():
#	if redo_states.empty():
#		oMessage.quick("No more redo states available.")
#		return
#
#	var next_state = redo_states.pop_front()
#
#	for EXT in next_state:
#		var buffer = next_state[EXT]
#		oBuffers.read_buffer_for_extension(buffer, EXT)
#
#	undo_states.push_front(next_state)
#
#	if undo_states.size() > max_undo_states:
#		undo_states.pop_back()
#
#	oOpenMap.finish_opening_map(oCurrentMap.path)
#	oMessage.quick("Redo performed.")
