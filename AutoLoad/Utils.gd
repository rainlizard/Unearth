extends Node


func popup_centered(node):
	node.popup_centered()
	
	# Switching visibility off then on fixes a "popup" bug which interferes with how the mouse is detected over UI.
	node.visible = false
	node.visible = true


func _input(_event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


var regex = RegEx.new()
func _ready():
	regex.compile("^[0-9]*$")

func strip_letters_from_string(string):
	for character in string:
		if regex.search(character) == null:
			string = string.replace(character,"")
	return string

func string_has_letters(string):
	if regex.search(string) == null:
		return true
	return false
