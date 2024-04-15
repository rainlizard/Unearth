extends Node

onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oOpenMap = Nodelist.list["oOpenMap"]
onready var oMessage = Nodelist.list["oMessage"]
onready var oThreadedSaveUndo = Nodelist.list["oThreadedSaveUndo"]
onready var oLoadingBar = Nodelist.list["oLoadingBar"]
onready var oNewMapWindow = Nodelist.list["oNewMapWindow"]
onready var oEditor = Nodelist.list["oEditor"]

var is_saving_state = false
var undo_history = []
var max_undo_states = 256
var performing_undo = false

func _input(event):
	if event.is_action_pressed("undo"):
		perform_undo()


func clear_history():
	oMessage.quick("Undo history cleared")
	undo_history.clear()
	is_saving_state = false # To be sure it's executed
	call_deferred("attempt_to_save_new_undo_state")


func attempt_to_save_new_undo_state(): # called by oEditor
	if is_saving_state == false:
		is_saving_state = true
		while Input.is_mouse_button_pressed(BUTTON_LEFT) or oLoadingBar.visible == true or oNewMapWindow.currently_creating_new_map == true:
			yield(get_tree(), "idle_frame")
		oThreadedSaveUndo.semaphore.post()


func on_undo_state_saved(new_state):
	if undo_history.size() >= 2 and are_states_equal(new_state, undo_history[1]):
		oMessage.quick("Didn't add undo state as it is the same as the previous undo-state")
		is_saving_state = false
		return
	if undo_history.size() >= max_undo_states:
		undo_history.pop_back()
	undo_history.push_front(new_state)
	oMessage.quick("Added undo state. Array size: " + str(undo_history.size()))
	is_saving_state = false

func perform_undo():
	print("perform_undo")
	if performing_undo == true or undo_history.size() <= 1:
		return
	var previous_state = undo_history[1]
	if typeof(previous_state) != TYPE_DICTIONARY:
		print("Error: previous_state is not a dictionary")
		oMessage.big("Undo state error", "previous_state is not a dictionary")
		return
	
	var CODETIME_START = OS.get_ticks_msec()
	performing_undo = true
	
	oCurrentMap.clear_map()
	
	for EXT in previous_state:
		var buffer = previous_state[EXT]
		if buffer == null or !(buffer is StreamPeerBuffer):
			print("Undo state error: buffer '%s' is not a valid StreamPeerBuffer" % EXT)
			oMessage.big("Undo state error", "Buffer '%s' is not a valid StreamPeerBuffer" % EXT)
			continue
		var undotimeExt = OS.get_ticks_msec()
		oBuffers.read_buffer_for_extension(buffer, EXT)
		print(str(EXT) + ' Undotime: ' + str(OS.get_ticks_msec() - undotimeExt) + 'ms')

	oOpenMap.continue_load(oCurrentMap.path)
	undo_history.pop_front()
	oMessage.quick("Undo performed")

	if undo_history.size() <= 1:
		oEditor.mapHasBeenEdited = false

	yield(get_tree(), 'idle_frame')
	performing_undo = false
	print('perform_undo: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')


func are_states_equal(state1, state2): # (0ms or 1ms)
	for EXT in state1.keys():
		var buffer1 = state1[EXT]
		var buffer2 = state2.get(EXT)
		if buffer1 is StreamPeerBuffer and buffer2 is StreamPeerBuffer:
			if buffer1.data_array != buffer2.data_array:
				return false
		
		if buffer1 == null and buffer2 != null:
			return false
		if buffer1 != null and buffer2 == null:
			return false
	return true
