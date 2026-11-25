extends AnimatableBody2D

var origin := Vector2.ZERO
var amplitude: float = 0.0
var frequency: float = 1.0
var elapsed: float = 0.0

func _ready() -> void:
	origin = position

func _physics_process(delta: float) -> void:
	elapsed += delta
	position = origin + Vector2(0, sin(elapsed * frequency) * amplitude)
