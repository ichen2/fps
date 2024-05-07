extends CharacterBody3D

@export var speed = 4
@export var fall_acceleration = 75
var target_velocity = Vector3.ZERO
var alive = true
@onready var camera: Camera3D = $Camera
@onready var raycast: RayCast3D = $Camera/RayCast
@onready var gameOver: Sprite2D = $Camera/GameOver
var look_dir: Vector2
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens, -1.5, 1.5)

func _input(event: InputEvent) -> void:
	if not alive:
		return
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.005
		_rotate_camera()
	if Input.is_action_pressed("fire"):
		print("bang?")
		var collider = raycast.get_collider()
		print(str(collider))
		if collider != null:
			print("bang!")
			if collider.has_method("die"):
				print("ow")
				collider.die()
			# can add other stuff here
			# e.g. if we want to create an exploding barrel, add
			# if collider.has_method("explode"):
			# 	collider.explode()

func _handle_joypad_camera_rotation(delta: float) -> void:
	if not alive:
		return
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera()
		look_dir = Vector2.ZERO

func _process(delta):
	Signals.player_position.emit(global_position)

func _physics_process(delta):
	if not alive:
		return
	var count = get_slide_collision_count()
	for index in range(count):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
		var collider = collision.get_collider()
		# If the collision is with ground
		if collider == null:
			continue

		# If the collider is with a mob
		if collider.is_in_group("enemies"):
			die()
			break
	
	var direction = Vector2.ZERO
	_handle_joypad_camera_rotation(delta)
	# Ground Velocity
	#var rotationInRadians = camera.rotation.y / (2 * PI) 
	#var rotationInWholeRadians = floor(rotationInRadians)
	#var rotationInRadiansTruncated = camera.rotation.y - (rotationInWholeRadians * 2 * PI) + PI / 2
	#print(rotationInRadiansTruncated)
	var cameraRotation = camera.rotation.y + PI / 2
	if Input.is_action_pressed("move_right"):
		cameraRotation -= PI / 2
	elif Input.is_action_pressed("move_left"):
		cameraRotation += PI / 2
	elif Input.is_action_pressed("move_backward"):
		cameraRotation += PI
	elif Input.is_action_pressed("move_forward"):
		cameraRotation += 0
	else:
		return
	var cameraOffsetX = cos(cameraRotation)
	var cameraOffsetY = -sin(cameraRotation)
	target_velocity.x = (cameraOffsetX) * speed
	target_velocity.z = (cameraOffsetY) * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

func die():
	alive = false
	gameOver.visible = true
	print("you died")
