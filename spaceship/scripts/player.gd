extends Node2D

var speed: float = 0
const max_speed: float = 1000
var velocity: Vector2 = Vector2(0, 0)

const speed_step := 100.0
const speed_damping := speed_step/2

@onready var speed_label:Label = get_node("speedometer")
@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var sprite: Sprite2D = get_node("shipSprite/shieldSprite")

var shield_restoration: float = 0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		speed = min(max_speed, speed + speed_step * delta)
	
	if Input.is_action_pressed("ui_down"):
		speed = max(0, speed - speed_step * delta)
	
	else: speed = min(max_speed, max(0, speed - speed_damping * delta))
	
	if Input.is_action_pressed("ui_left"):
		rotation -= 5 * delta
		
	if Input.is_action_pressed("ui_right"):
		rotation += 5 * delta
		
	var x = 0.1 * cos(rotation + PI/2)
	var y = 0.1 * sin(rotation + PI/2)
	
	velocity = speed*delta*Vector2(x,y).normalized()
	speed_label.text = "%d" % velocity.length()
	speed_label.rotation = velocity.angle_to(Vector2(0,1))
	position+=velocity
	
	if  shield_restoration > 0:
		shield_restoration = max(0, shield_restoration - delta)
	
	if shield_restoration <= 0 :
		sprite.visible = true
	
	wrap_position()

func wrap_position() -> void:
	if position.x < 0:
		position.x = screen_size.x
	elif position.x > screen_size.x:
		position.x = 0
	
	if position.y < 0:
		position.y = screen_size.y
	elif position.y > screen_size.y:
		position.y = 0
		
func disable_shield() -> void:
	sprite.visible = false
	shield_restoration = 1
	
