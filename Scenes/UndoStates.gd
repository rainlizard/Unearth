extends Node
onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oThreadedSaveUndo = Nodelist.list["oThreadedSaveUndo"]

var is_saving_state = false
var undo_states = []
var max_undo_states = 256

func _input(event):
	if event.is_action_pressed("undo"):
		undo()

func attempt_to_save_new_undo_state(): # called by oEditor
	if is_saving_state == false:
		is_saving_state = true
		while Input.is_mouse_button_pressed(BUTTON_LEFT):
			yield(get_tree(), "idle_frame")
		oThreadedSaveUndo.semaphore.post()

func save_completed(new_state_saved):
	if undo_states.size() >= max_undo_states:
		undo_states.pop_back()
	
	if undo_states.empty() or new_state_saved != undo_states[0]:
		undo_states.push_front(new_state_saved)
		oMessage.quick("Added undo-state")
	
	is_saving_state = false

func undo():
	if undo_states.empty():
		oMessage.quick("No more undo states available")
		return
	var previous_state = undo_states.pop_front()
	oCurrentMap.clear_map()
	for EXT in previous_state:
		var buffer = previous_state[EXT]
		oBuffers.read_buffer_for_extension(buffer, EXT)
	oOpenMap.load_complete(oCurrentMap.path)
	oMessage.quick("Undo performed")

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
