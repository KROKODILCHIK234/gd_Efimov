extends RigidBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
var random = RandomNumberGenerator.new()

func _ready() -> void:
	animation.play("idle")
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var click_pos = get_global_mouse_position()
		var space_state = get_world_2d().direct_space_state
		var point = PhysicsPointQueryParameters2D.new()
		point.position = click_pos
		var result = space_state.intersect_point(point,32)
		for hit in result:
			var collider = hit.collider
			if collider is RigidBody2D:
				if event.button_index == MOUSE_BUTTON_LEFT:
					apply_impulse(Vector2.UP*1000)
				if event.button_index == MOUSE_BUTTON_RIGHT:
					var vector = Vector2(random.randf_range(-1,1),random.randf_range(-1,1))
					apply_impulse(vector*1000)
	
func _physics_process(delta: float) -> void:
	pass
