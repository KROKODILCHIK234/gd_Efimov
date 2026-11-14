extends CharacterBody2D

const SPEED = 250.0
const RUN_SPEED = 400.0
const JUMP_VELOCITY = -520.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_running := false
var big := false
var star_time := 0.0
var hurt_time := 0.0
var animation_time := 0.0
var walk_frames: Array[Texture2D] = []
var idle_texture: Texture2D
var jump_texture: Texture2D

func _ready() -> void:
	# Физические клавиши работают и при русской раскладке.
	var movement_keys := {"ui_left": KEY_A, "ui_right": KEY_D, "ui_up": KEY_W, "ui_down": KEY_S}
	for action in movement_keys:
		var key := InputEventKey.new()
		key.physical_keycode = movement_keys[action]
		if not InputMap.action_has_event(action, key):
			InputMap.action_add_event(action, key)
	idle_texture = load("res://assets/hero/idle.svg")
	jump_texture = load("res://assets/hero/jump.svg")
	for i in range(8):
		walk_frames.append(load("res://assets/hero/walk_%d.svg" % i))
	$Visual/Sprite.texture = idle_texture

func _physics_process(delta: float) -> void:
	star_time = maxf(0.0, star_time - delta)
	hurt_time = maxf(0.0, hurt_time - delta)
	# После получения урона можно пройти сквозь врага и отойти.
	set_collision_mask_value(2, hurt_time <= 0.0)
	if star_time > 0.0:
		$Visual.modulate = Color.from_hsv(fmod(star_time * 0.8, 1.0), 0.5, 1.0)
	else:
		$Visual.modulate = Color.WHITE
		if hurt_time > 0.0:
			$Visual.modulate.a = 0.35 if int(hurt_time * 12) % 2 == 0 else 1.0
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

	# Сохраняем скорость падения: move_and_slide обнулит её при приземлении.
	var falling_speed := velocity.y
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var enemy := collision.get_collider()
		# Нормаль вниз и движение вверх означают удар головой снизу.
		if enemy is Node and enemy.is_in_group("breakable_blocks"):
			if collision.get_normal().y > 0.5 and falling_speed < 0.0:
				enemy.break_block()
		if enemy is Node and enemy.is_in_group("enemies") and not enemy.dead:
			if star_time > 0.0:
				enemy.defeat()
			elif collision.get_normal().y < -0.5 and falling_speed > 0.0:
				if enemy.has_method("stomp"):
					enemy.stomp(global_position.x)
				else:
					enemy.defeat()
				velocity.y = -350.0
			elif enemy.has_method("is_stationary_shell") and enemy.is_stationary_shell():
				enemy.kick(global_position.x)
			elif hurt_time > 0.0:
				continue
			elif big:
				set_big(false)
				hurt_time = 2.0
			else:
				get_tree().reload_current_scene()
				return

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

func collect_power_up(kind: String) -> void:
	if kind == "star":
		star_time = 10.0
	elif kind == "mushroom":
		set_big(true)

func set_big(value: bool) -> void:
	big = value
	# Увеличиваем рисунок, сохраняя положение ног и простую физику героя.
	$Visual/Sprite.scale = Vector2(1.4, 1.4) if big else Vector2.ONE
	$Visual/Sprite.position.y = -20.8 if big else -8.0
