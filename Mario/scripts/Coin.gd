extends Area2D

signal collected
var taken = false
var animation_time = 0.0

func _ready():
	body_entered.connect(on_body_entered)

func _process(delta):
	animation_time += delta
	$Sprite.position.y = -3.0 + sin(animation_time * 5.0) * 3.0

func on_body_entered(body):
	if taken:
		return
	if not body.has_method("collect_power_up"):
		return
	taken = true
	collected.emit()
	queue_free()
