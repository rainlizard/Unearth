extends Node

func _ready():
	print('Running GitAutoCommit.bat...')
	OS.execute("GitAutoCommit.bat",[],false)

