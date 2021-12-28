extends Control
onready var oScriptGenerator = Nodelist.list["oScriptGenerator"]
onready var oRoomsAvailable = Nodelist.list["oRoomsAvailable"]
onready var oMagicAvailable = Nodelist.list["oMagicAvailable"]
onready var oResearchables = Nodelist.list["oResearchables"]
onready var oSGRectHighlighter = Nodelist.list["oSGRectHighlighter"]
onready var oKeeperFXScriptCheckBox = Nodelist.list["oKeeperFXScriptCheckBox"]
onready var oMessage = Nodelist.list["oMessage"]


onready var oColorRect = $"HBoxContainer/TextureRectIcon/ColorRect"
onready var oEstimatedTime = $"HBoxContainer/EstimatedTime"
onready var oEstimatedTimeTotal = $"HBoxContainer/EstimatedTimeTotal"

enum {
	MAGIC
	ROOM
}
var type = ROOM

func _ready():
	pass # Replace with function body.


func set_research_required(value):
	var oResearchRequired = $"HBoxContainer/ResearchRequired"
	oResearchRequired.value = value

func get_research_required():
	var oResearchRequired = $"HBoxContainer/ResearchRequired"
	return oResearchRequired.value

func set_label_number(setText):
	var oOrderNumberLabel = $"HBoxContainer/VBoxContainer/OrderNumberLabel"
	oOrderNumberLabel.text = str(setText)

func set_magic_texture(thingID):
	var oTextureRectIcon = $"HBoxContainer/TextureRectIcon"
	oTextureRectIcon.texture = Things.DATA_OBJECT[thingID][Things.TEXTURE]

func set_room_texture(slabID):
	var oTextureRectIcon = $"HBoxContainer/TextureRectIcon"
	oTextureRectIcon.texture = Slabs.icons[slabID]

func _on_ResearchableItem_mouse_entered():
	var highlightedID = get_currently_dragging()
	if highlightedID != null and highlightedID != self:
		# Move highlighted to current's position
		get_parent().move_child(highlightedID, get_index())
		oScriptGenerator.adjust_estimated_time()
		if oKeeperFXScriptCheckBox.pressed == false:
			oMessage.quick("'KeeperFX script' must be enabled for order rearrangement to take effect")

func _on_ResearchableItem_mouse_exited():
	pass

var storeSeconds = 0 # used for caculating total time of all nodes

func set_estimated_time(speedNumber):
	var oResearchRequired = $"HBoxContainer/ResearchRequired"
	
	if check_if_researchable() == false:
		
		#$EstimatedTime.text = ""
		#$EstimatedTimeTotal.text = ""
		return
	
	var time = 0
	if speedNumber > 0:
		time = oResearchRequired.value/speedNumber
	var seconds = int(round(time / 20))
	storeSeconds = seconds
	var minutes = seconds / 60
	seconds = seconds % 60
	
	if minutes == 0:
		oEstimatedTime.text = str(seconds)+ " seconds"
	else:
		oEstimatedTime.text = str(minutes)+ " min " + str(seconds)+ " sec"
	
	yield(get_tree(),'idle_frame')
	
	var totalSeconds = storeSeconds
	for id in get_tree().get_nodes_in_group("ResearchableItem"):
		if id.get_index() < get_index():
			totalSeconds += id.storeSeconds
	
	var totalMinutes = totalSeconds / 60
	totalSeconds = totalSeconds % 60
	
	if totalMinutes == 0:
		oEstimatedTimeTotal.text = str(totalSeconds)+ " seconds"
	else:
		oEstimatedTimeTotal.text = str(totalMinutes)+ " min " + str(totalSeconds)+ " sec"

func _on_ResearchableItem_gui_input(event):
	# pressed
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed == true:
		var highlightedID = get_currently_dragging()
		if highlightedID != self:
			oSGRectHighlighter.clingTo = null
			
			# Highlight current
			oSGRectHighlighter.clingTo = self
			oSGRectHighlighter.highlight(self)
		else:
			oSGRectHighlighter.clingTo = null
			oSGRectHighlighter.visible = false

func get_currently_dragging():
	return oSGRectHighlighter.clingTo

var flashPercent = 0.0

#func _process(delta):
#	print(flashPercent)
	#print(flashPercent)
	#if draggingThisItem == true:
	#tween.interpolate_property(self, self, 0.0, 1.0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	#print(flashPercent)
#	material.set_shader_param("flashPercent", flashPercent)

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

#func get_drag_data(position):
#	var preview = $"TextureRect".duplicate()
#	preview.modulate.a = 0.5
#	set_drag_preview(preview)
#	return self

#func can_drop_data(position, data):
#    return data

#func drop_data(position, data):
#	#get_parent().move_child(self, data.get_index())
#	get_parent().move_child(data, self.get_index())
#	oScriptGenerator.adjust_estimated_time()

func _on_ResearchRequired_value_changed(value):
	oScriptGenerator.adjust_estimated_time()

func check_if_researchable():
	if type == ROOM:
		for i in oRoomsAvailable.get_children():
			if i.get_meta("ID") == get_meta("ID"):
				match i.availabilityState:
					i.OPTION_RESEARCH:
						oColorRect.color = Color("#3f3745")
						visible = true
						return true
					i.OPTION_DISABLED:
						oColorRect.color = Color("#212025")
						visible = false
						return false
					i.OPTION_START:
						oColorRect.color = Color("#383745")
						visible = false
						return false
	elif type == MAGIC:
		for i in oMagicAvailable.get_children():
			if i.get_meta("ID") == get_meta("ID"):
				match i.availabilityState:
					i.OPTION_RESEARCH:
						oColorRect.color = Color("#3f3745")
						visible = true
						return true
					i.OPTION_DISABLED:
						oColorRect.color = Color("#212025")
						visible = false
						return false
					i.OPTION_START:
						oColorRect.color = Color("#383745")
						visible = false
						return false
	return false
