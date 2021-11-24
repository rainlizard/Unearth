extends ConfirmationDialog

var checkbox

func _ready():
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	var hbox = get_ok().get_parent()
	remove_child(hbox)
	vbox.add_child(hbox)
	
	checkbox = $CheckBox
	remove_child(checkbox)
	vbox.add_child(checkbox)
	vbox.move_child(checkbox,0)
	
	get_ok().text = "Yes"
	get_cancel().text = "No"

func _on_ConfirmDecompression_item_rect_changed():
	disconnect("item_rect_changed",self,"_on_ConfirmDecompression_item_rect_changed")
	rect_size.y += 10
	connect("item_rect_changed",self,"_on_ConfirmDecompression_item_rect_changed")


func _on_ConfirmDecompression_about_to_show():
	checkbox.pressed = false

func _on_ConfirmDecompression_confirmed():
	Settings.set_setting("always_decompress", checkbox.pressed)
