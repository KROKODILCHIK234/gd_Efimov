extends Node2D

@export_range(0.1, 20.0) var burn_duration: float = 3.0
@export_range(0.1, 10.0) var cooldown_duration: float = 1.0
@export var knockback_force: Vector2 = Vector2(300.0, -420.0)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var trigger: Area2D = $Trigger
@onready var fire_area: Area2D = $FireArea
@onready var sparks: CPUParticles2D = $Sparks
@onready var timer: Timer = $Timer

var burning: bool = false
var cooling_down: bool = false
var hit_bodies: Array[Node2D] = []


func _physics_process(_delta: float) -> void:
	if burning:
		for body in fire_area.get_overlapping_bodies():
			_hit(body)
	elif not cooling_down:
		for body in trigger.get_overlapping_bodies():
			# Only a character landing on the plate can ignite the trap.
			if body.has_method("apply_knockback") and body is CharacterBody2D:
				if body.velocity.y >= 0.0 and body.global_position.y < global_position.y - 26.0:
					_ignite()
					_hit(body)
					break


func _ignite() -> void:
	burning = true
	hit_bodies.clear()
	sprite.play("ignite")
	sparks.emitting = true
	timer.start(burn_duration)


func _hit(body: Node2D) -> void:
	if not body.has_method("apply_knockback") or body in hit_bodies:
		return
	hit_bodies.append(body)
	var direction: float = signf(body.global_position.x - global_position.x)
	if is_zero_approx(direction):
		direction = -1.0 if body.velocity.x > 0.0 else 1.0
	body.apply_knockback(Vector2(absf(knockback_force.x) * direction, knockback_force.y))


func _on_animation_finished() -> void:
	if burning and sprite.animation == &"ignite":
		sprite.play("burn")


func _on_timer_timeout() -> void:
	if burning:
		burning = false
		cooling_down = true
		sprite.play("off")
		sparks.emitting = false
		hit_bodies.clear()
		timer.start(cooldown_duration)
	else:
		cooling_down = false
