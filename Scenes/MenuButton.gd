extends MenuButton

var popup

func _ready():
	popup = get_popup()
	popup.add_item("item a")
	popup.add_item("item b")
	popup.add_item("item c")
	popup.connect("id_pressed", self, "_on_item_pressed")

func _on_item_pressed(ID):
	print(popup.get_item_text(ID), " pressed")

func _on_Button_pressed():
	print('button pressed')
