extends Area2D

@export_enum("mushroom", "star") var kind := "mushroom"
var collected := false

func _ready() -> void:
	$Sprite.texture = load("res://assets/bonuses/" + kind + ".svg")
	body_entered.connect(_on_body_entered)
	var tween := create_tween().set_loops()
	tween.tween_property($Sprite, "position:y", -5.0, 0.6)
	tween.tween_property($Sprite, "position:y", 0.0, 0.6)

func _on_body_entered(body: Node2D) -> void:
	if collected or not body.has_method("collect_power_up"):
		return
	collected = true
	body.collect_power_up(kind)
	queue_free()
