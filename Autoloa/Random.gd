extends Node2D

#randi_range has been added to global functions in Godot version 4.00
#so this won't be necessary in the future.

var rng = RandomNumberGenerator.new()

#func randomize():
#	rng.randomize()

func randi_range(from,to):
	return rng.randi_range(from,to)

func choose(array): # Usage: Random.choose([thing,thing,thing])
	return array[randi() % array.size()]

func chance_int(value):
	if rng.randi_range(0,99) < value:
		return true
	else:
		return false
