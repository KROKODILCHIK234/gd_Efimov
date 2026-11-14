extends StaticBody2D

@onready var sprite = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var collision = $Area2D/CollisionShape2D
@onready var particles = $GPUParticles2D
@onready var fan_player = $FanPlayer

func turn_on():
	sprite.play("on")
	fan_player.play()
	collision.disabled = false
	particles.emitting = true

func turn_off():
	sprite.play("off")
	fan_player.stop()
	collision.disabled = true
	particles.emitting = false
	
