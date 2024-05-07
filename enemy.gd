extends CharacterBody3D

# Minimum speed of the mob in meters per second.
@export var min_speed = 1
# Maximum speed of the mob in meters per second.
@export var max_speed = 4
var speed = randi_range(min_speed, max_speed)
var player_position = Vector3.ZERO

func _ready():
	Signals.player_position.connect(_on_position_change)

func _on_position_change(player_position: Vector3):
	self.player_position = player_position

# This function will be called from the Main scene.
func initialize(start_position, player_position):
	self.player_position = player_position
	start_position = Vector3(start_position.x, -1, start_position.z)
	transform = transform.translated(start_position)

func _physics_process(delta):
	look_at(player_position, Vector3.UP)
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	move_and_slide()

func die():
	queue_free()
