extends KinematicBody
onready var oCamera3D = Nodelist.list["oCamera3D"]
onready var oGame3D = Nodelist.list["oGame3D"]
onready var oRayCastBlockMap = Nodelist.list["oRayCastBlockMap"]
onready var oHead = Nodelist.list["oHead"]
onready var oEditor = Nodelist.list["oEditor"]
onready var oPropertiesWindow = Nodelist.list["oPropertiesWindow"]
onready var oUi = Nodelist.list["oUi"]
onready var oMenu = Nodelist.list["oMenu"]
onready var oGenerateTerrain = Nodelist.list["oGenerateTerrain"]

var mouseSensitivity = 0.1
var direction = Vector3()
var velocity = Vector3()
var acceleration = 10
var speed = 0.5
var speed_multiplier = 1
var movement = Vector3()

var rememberPerspective = [null,null,null]
var rememberOrthogonal = [null,null,null]

#var scnProjectile = preload("res://Scenes/Projectile.tscn")

onready var oCamera2D = $'../../Game2D/Camera2D'

#func _ready():
#	rememberOrthogonal = [transform, oHead.transform, oCamera3D.transform]
	#rememberOrthogonal.transform

func switch_camera_type(type):
	velocity = Vector3(0,0,0) # stop moving
	if type == 1: # 3D 1st person perspective
		if rememberPerspective == [null,null,null]:
			oHead.rotation_degrees = Vector3(0,0,0)
		else:
			transform = rememberPerspective[0]
			oHead.transform = rememberPerspective[1]
			oCamera3D.transform = rememberPerspective[2]

		oCamera3D.set_perspective(oCamera3D.fov, 0.01, 8192)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if oEditor.currentView != oEditor.VIEW_3D: return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and oCamera3D.projection == Camera.PROJECTION_PERSPECTIVE:
		rotation_degrees.y -= event.relative.x * mouseSensitivity
		oHead.rotation_degrees.x = clamp(oHead.rotation_degrees.x - event.relative.y * mouseSensitivity, -90, 90)
	
	if oCamera3D.projection == Camera.PROJECTION_PERSPECTIVE:
		speed_multiplier = 1
	else:
		speed_multiplier = 2
	if Input.is_key_pressed(KEY_SHIFT):
		speed_multiplier = 10
	
	if Input.is_action_just_pressed("change_3d_mouse_mode") and oCamera3D.projection == Camera.PROJECTION_PERSPECTIVE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_pressed("zoom_in"):
		if oCamera3D.projection == Camera.PROJECTION_PERSPECTIVE:
			translation.y -= 3
		else: #Camera.PROJECTION_ORTHOGONAL
			pass
			#translation.y -= 9
			#oCamera3D.size = translation.y
	if Input.is_action_just_pressed("zoom_out"):
		if oCamera3D.projection == Camera.PROJECTION_PERSPECTIVE:
			translation.y += 3
		else: #Camera.PROJECTION_ORTHOGONAL
			pass
			#translation.y += 9
			#oCamera3D.size = translation.y

func _process(delta):
	if oEditor.currentView != oEditor.VIEW_3D: return
	
	direction = Vector3(0,0,0)
	if oUi.mouseOnUi == false:
		keyboard_pan()
	else:
		direction = Vector3(0,0,0)

func keyboard_pan():
	if oCamera3D.projection == Camera.PROJECTION_ORTHOGONAL: return
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.z = -1
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.z = 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x = -1
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x = 1
	direction = direction.normalized()
	direction = direction.rotated(Vector3.UP, rotation.y)

func _physics_process(delta):
	if oEditor.currentView != oEditor.VIEW_3D: return
	
	velocity = velocity.linear_interpolate(direction * speed * speed_multiplier, acceleration * delta)
	movement = velocity
	#movement = move_and_slide(movement, Vector3.UP)
	movement = move_and_collide(movement)
