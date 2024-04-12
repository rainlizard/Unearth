extends Node

onready var oCurrentFormat = Nodelist.list["oCurrentFormat"]
onready var oBuffers = Nodelist.list["oBuffers"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]

var undo_buffers = {}

func save_current_state():
	undo_buffers.clear()
	for EXT in oBuffers.FILE_TYPES:
		if not oBuffers.should_process_file_type(EXT):
			continue
		undo_buffers[EXT] = oBuffers.get_buffer_for_extension(EXT, oCurrentMap.path)

func undo():
	for EXT in undo_buffers:
		var buffer = undo_buffers[EXT]
		oBuffers.read_buffer_for_extension(buffer, EXT)
