extends Node

var data = {
	
}
enum {
	SLAB_COLUMNS
	GENERAL
	RECOGNIZED_AS
}

func add_custom_slab(newID, slabColumns, general, recognizedAs):
	data[newID] = [slabColumns, general, recognizedAs]
	Slabs.data[newID] = general
