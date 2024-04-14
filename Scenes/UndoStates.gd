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
	
	if undo_history.size() >= 2 and new_state == undo_history[1]:
		oMessage.quick("Didn't add undo state as it is the same as the previous undo-state")
		is_saving_state = false
		return
	if undo_history.size() >= max_undo_states:
		undo_history.pop_back()
	undo_history.push_front(new_state)
	oMessage.quick("Added undo state. Array size: " + str(undo_history.size()))
	is_saving_state = false

func perform_undo():
	if performing_undo or undo_history.size() <= 1:
		return

	performing_undo = true

	var previous_state = undo_history[1]
	oCurrentMap.clear_map()

	if typeof(previous_state) != TYPE_DICTIONARY:
		print("Error: previous_state is not a dictionary")
		oMessage.quick("Error: previous_state is not a dictionary")
		performing_undo = false
		return
	
	for EXT in previous_state:
		var buffer = previous_state[EXT]
		if buffer == null or !(buffer is StreamPeerBuffer):
			print("Error: buffer for EXT '%s' is not a valid StreamPeerBuffer!" % EXT)
			oMessage.quick("Error: buffer for EXT '%s' is not a valid StreamPeerBuffer!" % EXT)
			continue
		oBuffers.read_buffer_for_extension(buffer, EXT)

	oOpenMap.continue_load(oCurrentMap.path)
	undo_history.pop_front()
	oMessage.quick("Undo performed")

	if undo_history.size() <= 1:
		oEditor.mapHasBeenEdited = false

	yield(get_tree(), 'idle_frame')
	performing_undo = false
