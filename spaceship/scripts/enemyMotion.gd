extends Node2D

@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var size = $EnemySprite.texture.get_size()

var acceleration: Vector2 = Vector2(0, 0)
var velocity: Vector2 = Vector2(0, 0)

var max_force: float = 10
const max_speed: float = 6
var max_distance: int = 200
var min_distance: int = 30

var orbit_target: Node2D = null
var orbit_radius: float = 150
var orbit_angle: float = 0

func _ready() -> void:
	var x = randi_range(0 + size.x, screen_size.x - size.x)
	var y = randi_range(0 + size.y, screen_size.y - size.y)
	position = Vector2(x,y)
	velocity = Vector2(randf(),randf())



func _process(delta: float) -> void:
	if orbit_target:
		orbit_angle += 2 * delta
		position = orbit_target.position + Vector2.from_angle(orbit_angle) * orbit_radius
		rotation = orbit_angle + PI/2
		return
	
	velocity += acceleration * delta
	velocity = velocity.limit_length(max_speed)
	position += velocity
	acceleration *= 0
	rotation = velocity.angle()
	
	wrap_position()
	
func apply_force(force: Vector2):
	acceleration = force
	
func seek(target: Vector2):
	var direction = target - position
	var desired_velocity = direction.normalized() * max_speed
	
	#if direction.length() > max_distance: return
	
	#if direction.length() <= min_distance: 
		#velocity *= 0
		#return
	
	var steering = (desired_velocity - velocity)
	steering = steering.limit_length(max_force)
	apply_force(steering)
	
func flee(target: Vector2):
	var direction = position - target
	if direction.length() > max_distance/2: return
	var desired_velocity = direction.normalized() * max_speed
	var steering = (desired_velocity - velocity)
	steering = steering.limit_length(max_force)
	apply_force(steering)

func pursue(target: Vector2, target_velocity: Vector2):
	var direction = target - position
	var speed: float = velocity.length()
	if speed == 0: speed = max_speed
	var ahead_time: float = direction.length() / speed
	
	var predict = target + target_velocity * ahead_time
	
	seek(predict)

func evade(target: Vector2, target_velocity: Vector2):
	var direction = target - position
	var speed: float = velocity.length()
	if direction.length() > max_distance: return
	if speed == 0: speed = max_speed
	var ahead_time: float = direction.length() / speed
	
	var predict = target + target_velocity * ahead_time
	
	flee(predict)

func separate(group: Node2D):
	var steering: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child : continue
		
		var direction: Vector2 = child.position - position
		var distance: float = direction.length()
		
		if distance >= 0 and distance < max_distance:
			var away: Vector2 = -direction.normalized()
			away *= (1 / distance)
			steering += away
			count += 1
	
	if count: 
		steering /= count
		steering = steering.normalized() * max_speed
		steering -= velocity
		steering = steering.limit_length(max_force)
		apply_force(steering)

func cohesion(group: Node2D):
	var com: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child : continue
		
		var direction: Vector2 = child.position - position
		var distance: float = direction.length()
		if distance >= 0 and distance < max_distance:
			com += child.position
			count += 1
			
	if count:
		com /= count
		seek(com)

func align(group: Node2D):
	var mean_velocity: Vector2 = Vector2.ZERO
	var count: int = 0
	for child in group.get_children():
		if self == child : continue
		
		var direction: Vector2 = child.position - position
		var distance: float = direction.length()
		if distance >= 0 and distance < max_distance:
			mean_velocity += child.velocity
			count+=1
			
	if count:
		mean_velocity/=count
		mean_velocity = mean_velocity.normalized() * max_speed
		mean_velocity -= velocity
		var steering = mean_velocity - velocity
		apply_force(steering.limit_length(max_force))
		

func wrap_position() -> void:
	if position.x < 0:
		position.x = screen_size.x
	elif position.x > screen_size.x:
		position.x = 0
	
	if position.y < 0:
		position.y = screen_size.y
	elif position.y > screen_size.y:
		position.y = 0
