extends CharacterBody2D

# Каждый экземпляр ходит вокруг своей начальной позиции.
@export var patrol_distance := 120.0
@export var speed := 65.0
var start_x := 0.0
var direction := -1.0
var animation_time := 0.0
var dead := false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	start_x = position.x

func _physics_process(delta: float) -> void:
	if dead:
		return
	if position.x <= start_x - patrol_distance:
		direction = 1.0
	elif position.x >= start_x + patrol_distance:
		direction = -1.0
	velocity.x = direction * speed
	velocity.y += gravity * delta
	move_and_slide()
	if is_on_wall():
		direction *= -1.0
	# Простое покачивание при ходьбе, без сложной системы анимаций.
	animation_time += delta * 10.0
	$Sprite.rotation = sin(animation_time) * 0.1
	$Sprite.scale.y = 1.0 + sin(animation_time * 2.0) * 0.05

func defeat() -> void:
	if dead:
		return
	dead = true
	collision_layer = 0
	collision_mask = 0
	$Sprite.rotation = 0.0
	var tween := create_tween()
	tween.tween_property($Sprite, "scale", Vector2(1.2, 0.25), 0.15)
	tween.tween_interval(0.2)
	tween.tween_property($Sprite, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
