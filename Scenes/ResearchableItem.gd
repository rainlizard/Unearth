extends HBoxContainer
onready var oScriptGenerator = Nodelist.list["oScriptGenerator"]
onready var oRoomsAvailable = Nodelist.list["oRoomsAvailable"]
onready var oMagicAvailable = Nodelist.list["oMagicAvailable"]
onready var oColorRect = $"TextureRect/ColorRect"

enum {
	MAGIC
	ROOM
}
var type = ROOM

func _ready():
	pass # Replace with function body.

func set_research_required(value):
	$ResearchRequired.value = value

func set_label_number(setText):
	$"VBoxContainer/Label".text = str(setText)

func set_magic_texture(thingID):
	var oTextureRectTop = $"TextureRect"
	oTextureRectTop.texture = Things.DATA_OBJECT[thingID][Things.TEXTURE]

func set_room_texture(slabID):
	var oTextureRectBottom = $"TextureRect"
	oTextureRectBottom.texture = Slabs.icons[slabID]

func _on_ResearchableItem_mouse_entered():
	pass

func _on_ResearchableItem_mouse_exited():
	pass


func redo_label_text():
	for id in get_tree().get_nodes_in_group("ResearchableItem"):
		id.set_label_number(id.get_index()+1)
	
	oScriptGenerator.adjust_estimated_time()


var storeSeconds = 0 # used for caculating total time of all nodes

func set_estimated_time(speedNumber):
	
	if check_if_researchable() == false:
		$EstimatedTime.text = ""
		$EstimatedTimeTotal.text = ""
		return
	
	var time = 0
	if speedNumber > 0:
		time = $ResearchRequired.value/speedNumber
	var seconds = int(round(time / 20))
	storeSeconds = seconds
	var minutes = seconds / 60
	seconds = seconds % 60
	
	if minutes == 0:
		$EstimatedTime.text = str(seconds)+ " seconds"
	else:
		$EstimatedTime.text = str(minutes)+ " min " + str(seconds)+ " sec"
	
	yield(get_tree(),'idle_frame')
	
	var totalSeconds = storeSeconds
	for id in get_tree().get_nodes_in_group("ResearchableItem"):
		if id.get_index() < get_index():
			totalSeconds += id.storeSeconds
	
	var totalMinutes = totalSeconds / 60
	totalSeconds = totalSeconds % 60
	
	if totalMinutes == 0:
		$EstimatedTimeTotal.text = str(totalSeconds)+ " seconds"
	else:
		$EstimatedTimeTotal.text = str(totalMinutes)+ " min " + str(totalSeconds)+ " sec"

#func _on_ResearchableItem_gui_input(event):
#	if event is InputEventMouseMotion:
#		mouseHover = true
#
#	# pressed
#	if event is InputEventMouseButton and event.pressed == true and event.button_index == BUTTON_LEFT:
#		print('pressed')
#		draggingThisItem = true
#
#	# released
#	if draggingThisItem == true:
#		if event is InputEventMouseButton and event.pressed == false and event.button_index == BUTTON_LEFT:
#			print('released')
#			draggingThisItem = false
#			for id in get_tree().get_nodes_in_group("ResearchableItem"):
#				if id.mouseHover == true and id != self:
#					print(id.get_index())
#					get_parent().move_child(self, id.get_index())

func get_drag_data(position):
	var preview = $"TextureRect".duplicate()
	preview.modulate.a = 0.5
	set_drag_preview(preview)
	return self

func can_drop_data(position, data):
    return data

func drop_data(position, data):
	#get_parent().move_child(self, data.get_index())
	get_parent().move_child(data, self.get_index())
	redo_label_text()

func _on_ResearchRequired_value_changed(value):
	oScriptGenerator.adjust_estimated_time()

func check_if_researchable():
	if type == ROOM:
		for i in oRoomsAvailable.get_children():
			if i.get_meta("ID") == get_meta("ID"):
				match i.availabilityState:
					i.OPTION_RESEARCH:
						oColorRect.color = Color("#3f3745")
						return true
					i.OPTION_DISABLED:
						oColorRect.color = Color("#212025")
						return false
					i.OPTION_START:
						oColorRect.color = Color("#383745")
						return false
	elif type == MAGIC:
		for i in oMagicAvailable.get_children():
			if i.get_meta("ID") == get_meta("ID"):
				match i.availabilityState:
					i.OPTION_RESEARCH:
						oColorRect.color = Color("#3f3745")
						return true
					i.OPTION_DISABLED:
						oColorRect.color = Color("#212025")
						return false
					i.OPTION_START:
						oColorRect.color = Color("#383745")
						return false
	return false
