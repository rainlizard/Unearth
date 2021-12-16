extends HBoxContainer

func _ready():
	$LineEdit.connect("focus_exited",self,"focus_exited")

func focus_exited(newText):
	$LineEdit.text = int(newText)

func _on_TextureButtonLeft_pressed():
	$LineEdit.text = str(int($LineEdit.text)-1)

func _on_TextureButtonRight_pressed():
	$LineEdit.text = str(int($LineEdit.text)+1)


func _on_TextureButtonLeft_button_down():
	$LineEdit.text = str(int($LineEdit.text)-1)

func _on_TextureButtonLeft_button_up():
	pass # Replace with function body.
