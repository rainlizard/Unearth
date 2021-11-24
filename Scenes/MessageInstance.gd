extends Control

func _ready():
	set_process(false)

func show_then_fade(string):
	$"HBoxContainer/Label".text = string

func _process(delta):
	modulate.a = lerp(modulate.a, 0.0, 5.00*delta)

	if modulate.a <= 0.01:
		modulate.a = 0
		set_process(false)
		queue_free()

func _on_Timer_timeout():
	set_process(true)
