extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $dude_sprite
@onready var step_player: AudioStreamPlayer = $StepAudioPlayer

const SPEED = 200.0
const JUMP_SPEED = -400.0
const GRAVITY = 800
var DOUBLE_JUMP = true
const BOUNCE_DELAY = 0.4
var bounce_delay = 0.0
var bounce_count = 0
const bounce_max = 4

const PICKUP_DISTANCE = 40
const THROW_FORCE = 400
var held_box: RigidBody2D = null


var knockback_remaining: float = 0.0

var state = "idle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play(state)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	knockback_remaining = maxf(0.0, knockback_remaining - delta)
	if bounce_delay > 0 and is_on_floor():
		bounce_delay -= delta
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	var direction = Input.get_axis("left", "right")
	if bounce_delay <= 0 and knockback_remaining <= 0.0:
		velocity.x = direction * SPEED	
	
	if Input.is_action_just_pressed("jump") and knockback_remaining <= 0.0:
		if is_on_floor():
			DOUBLE_JUMP = true
			bounce_count = 0
			velocity.y = JUMP_SPEED
		elif not is_on_floor() and DOUBLE_JUMP:
			velocity.y = JUMP_SPEED
			DOUBLE_JUMP = false
	
	if Input.is_action_pressed("left"):
		state = "walk"
		sprite.flip_h = true
	elif Input.is_action_pressed("right"):
		state = "walk"
		sprite.flip_h = false
	elif Input.is_action_pressed("jump"):
		state = "jump"
	else:
		state = "idle"
	
	if not is_on_floor():
		animation.play("jump")
	elif direction != 0:
		sprite.flip_h = direction < 0
		animation.play("walk")
		if not step_player.playing:
			step_player.play()
	else:
		animation.play("idle")
		step_player.stop()
		
	move_and_slide()

	var collision_count = get_slide_collision_count()
	for i in collision_count:
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		var collider = collision.get_collider()
		if "box" in collider.name.to_lower():
			if normal.y > 0.8 : velocity += normal * SPEED * 1.1
		if "wall" in collider.name.to_lower():
			if abs(normal.x) > 0.8: velocity += normal * SPEED
			bounce_delay = BOUNCE_DELAY
		if "jumpbox" in collider.name.to_lower():
			if normal.y < -0.8:
				bounce_count = min(bounce_max, bounce_count + 1)
				velocity.y = normal.y * SPEED * bounce_count
				print(bounce_count)
		if "rock" in collider.name.to_lower():
			collider.apply_impulse(normal*10)
			
	if held_box:
		held_box.global_transform.origin = global_position + Vector2(0,-70)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and not held_box:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		var shape = CircleShape2D.new()
		shape.radius = PICKUP_DISTANCE
		query.shape = shape
		query.transform = Transform2D(0, global_position)
		query.collide_with_areas = true
		query.exclude = [self]
		var results = space_state.intersect_shape(query)
		for result in results:
			if "box" in result.collider.name.to_lower():
				held_box = result.collider
				held_box.hold(self)
				break
			if result.collider is Area2D:
				if result.collider.has_method("activate"):
					result.collider.activate()
	if event.is_action_released("pickup") and held_box:
		var direction = Vector2.RIGHT if velocity.x >= 0 else Vector2.LEFT
		direction.y = -0.5
		var impulse = direction * THROW_FORCE
		held_box.release(impulse*10)
		held_box = null


# Keep movement input from cancelling a trap impulse immediately.
func apply_knockback(impulse: Vector2, duration: float = 0.4) -> void:
	velocity = impulse
	knockback_remaining = duration
	step_player.stop()
