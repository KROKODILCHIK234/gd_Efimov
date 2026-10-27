extends CharacterBody2D

const SPEED = 250.0
const RUN_SPEED = 400.0
const JUMP_VELOCITY = -520.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_running := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	is_running = Input.is_action_pressed("ui_shift")
	var speed = RUN_SPEED if is_running else SPEED
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * speed
		$Visual.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 2)

	move_and_slide()
