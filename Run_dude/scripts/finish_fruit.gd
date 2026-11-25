extends Area2D

signal collected
var taken := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	$Sprite2D.frame = (int(Time.get_ticks_msec() / 70.0) % 17)

func _on_body_entered(body: Node2D) -> void:
	if not taken and body is CharacterBody2D:
		taken = true
		collected.emit()
