extends Node

onready var oBuffers = Nodelist.list["oBuffers"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oMessage = Nodelist.list["oMessage"]

var semaphore = Semaphore.new()
var thread = Thread.new()

func _enter_tree():
	thread.start(self, "run_threaded_undo_save")

func run_threaded_undo_save(_userdata):
	while true:
		semaphore.wait()
		print("Start multi-threaded save undo state")
		var CODETIME_START = OS.get_ticks_msec()
		
		var consistent_state = {}
		# Repeat the data capture until the captured state is consistent
		while true:
			consistent_state = create_state()
			var compare_state = create_state()
			
			# For some reason TNGFX occasionally breaks
			if compare_state.has("TNGFX") == false:
				oMessage.big("Undo state error 1", "TNGFX buffer broke")
				continue
			elif compare_state["TNGFX"] == null:
				oMessage.big("Undo state error 2", "TNGFX buffer broke")
				continue
			
			if oUndoStates.are_states_equal(consistent_state, compare_state):
				break
		
		# The captured state is consistent, save it as the undo state
		oUndoStates.call_deferred("on_undo_state_saved", consistent_state)
		print("End multi-threaded save undo state: " + str(OS.get_ticks_msec() - CODETIME_START) + "ms")


func create_state():
	var new_state = {}
	for EXT in oBuffers.FILE_TYPES:
		#print("Undo processing: ", EXT)
		if oBuffers.should_process_file_type(EXT) == false:
			continue
		new_state[EXT] = oBuffers.get_buffer_for_extension(EXT, oCurrentMap.path)
	return new_state
