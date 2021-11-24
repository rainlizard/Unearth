extends Node

func popup_centered(node):
	node.popup_centered()
	# Switching visibility off then on fixes a "popup" bug which interferes with how the mouse is detected over UI.
	node.visible = false
	node.visible = true

func _input(_event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
