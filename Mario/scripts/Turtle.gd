extends "res://scripts/Enemy.gd"

enum State { WALK, SHELL, SLIDE }
var state := State.WALK
var shell_texture := preload("res://assets/enemies/shell.svg")

func _physics_process(delta: float) -> void:
	if dead:
		return
	if state == State.WALK:
		super._physics_process(delta)
		$Sprite.flip_h = direction < 0.0
		return
	velocity.x = 0.0
	if state == State.SLIDE:
		velocity.x = direction * 360.0
	velocity.y += gravity * delta
	move_and_slide()
	if state == State.SLIDE:
		for i in range(get_slide_collision_count()):
			var collision := get_slide_collision(i)
			var other := collision.get_collider()
			if other is Node and other.is_in_group("enemies"):
				other.defeat()
			elif absf(collision.get_normal().x) > 0.5:
				direction *= -1.0
		if position.x < 24.0:
			direction = 1.0
		elif position.x > 3976.0:
			direction = -1.0

func stomp(player_x: float) -> void:
	if dead:
		return
	if state == State.SHELL:
		kick(player_x)
	else:
		state = State.SHELL
		velocity.x = 0.0
		collision_mask = 1
		$Sprite.texture = shell_texture
		$Sprite.rotation = 0.0
		$Sprite.scale = Vector2.ONE
		var shape := RectangleShape2D.new()
		shape.size = Vector2(40, 24)
		$CollisionShape2D.set_deferred("shape", shape)
		$CollisionShape2D.set_deferred("position", Vector2(0, 4))

func is_stationary_shell() -> bool:
	return state == State.SHELL

func kick(player_x: float) -> void:
	state = State.SLIDE
	direction = -1.0
	if player_x <= global_position.x:
		direction = 1.0
	collision_mask = 3
