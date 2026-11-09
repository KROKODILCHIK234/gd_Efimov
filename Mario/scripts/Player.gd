extends CharacterBody2D

const SPEED = 250.0
const RUN_SPEED = 400.0
const JUMP_VELOCITY = -520.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_running := false
var animation_time := 0.0
var walk_frames: Array[Texture2D] = []
var idle_texture: Texture2D
var jump_texture: Texture2D

func _ready() -> void:
	idle_texture = load("res://assets/hero/idle.svg")
	jump_texture = load("res://assets/hero/jump.svg")
	for i in range(8):
		walk_frames.append(load("res://assets/hero/walk_%d.svg" % i))
	$Visual/Sprite.texture = idle_texture

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	is_running = Input.is_physical_key_pressed(KEY_SHIFT)
	var speed = RUN_SPEED if is_running else SPEED
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * speed
		$Visual.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 2)

	move_and_slide()

	position.x = clampf(position.x, 24.0, 3976.0)
	if position.y > 850:
		position = Vector2(200, 620)
		velocity = Vector2.ZERO
	_update_animation(delta)

func _update_animation(delta: float) -> void:
	if not is_on_floor():
		$Visual/Sprite.texture = jump_texture
		$Visual.position.y = 0.0
		$Visual.rotation = -0.06 if velocity.y < 0.0 else 0.06
	elif absf(velocity.x) > 1.0:
		# Match stride cadence to actual movement speed, including running.
		animation_time += delta * absf(velocity.x) / SPEED * 12.0
		$Visual/Sprite.texture = walk_frames[int(animation_time) % walk_frames.size()]
		$Visual.position.y = -absf(sin(animation_time * PI / 4.0)) * 2.0
		$Visual.rotation = 0.0
	else:
		animation_time = 0.0
		$Visual/Sprite.texture = idle_texture
		$Visual.position.y = 0.0
		$Visual.rotation = 0.0
