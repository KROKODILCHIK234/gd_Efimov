extends Node2D

signal collided

var velocity: Vector2 = Vector2(0,0)
var angular_speed: float = 0.1

@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var size = get_node("asteroidSprite").texture.get_size()

func _ready() -> void:
	velocity = Vector2(randi_range(-100,100), randi_range(-100,100))
	
	angular_speed = randf_range(0.1, 0.5)


func _process(delta: float) -> void:
	position += velocity * delta * 2
	rotation += angular_speed * delta * 2
	
	if position.x < 0 + size.x/2:
		velocity.x *= -1
	elif position.x > screen_size.x - size.x/2:
		velocity.x *= -1
	
	if position.y < 0 + size.y/2:
		velocity.y *= -1
	elif position.y > screen_size.y - size.y/2:
		velocity.y *= -1


func _on_asteroid_area_entered(area: Area2D) -> void:
	print(area)
	collided.emit()
