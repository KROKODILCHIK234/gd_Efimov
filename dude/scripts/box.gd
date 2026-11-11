extends RigidBody2D

@onready var collision = $CollisionShape2D
var holder:Node2D = null

func hold(character:Node2D):
	holder = character
	collision.disabled = true
	freeze = true
	lock_rotation = true
	
func release(throw_force:Vector2 = Vector2.ZERO):
	holder = null
	collision.disabled = false
	freeze = false
	lock_rotation = false
	apply_central_impulse(throw_force)
	
