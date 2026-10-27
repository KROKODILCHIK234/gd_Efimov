extends Node2D

@onready var player = get_node("Player")
@onready var asteroid = get_node("Asteroid")
@onready var enemy = $Enemy
@onready var enemies = $enemies
@onready var enemy_scene = preload("res://scenes/enemy.tscn")
@onready var life_label: Label = $lifeLabel

var count := 10
var life_time: float = 0

func _ready() -> void:
	
	player.get_node("shipArea").area_entered.connect(_on_player_collided)
	enemy.orbit_target = player
	for i in count:
		var enemy_instance = enemy_scene.instantiate()
		enemy_instance.scale = Vector2(0.7,0.7)
		enemies.add_child(enemy_instance)


func _process(delta: float) -> void:
	life_time += delta
	life_label.text = "Время жизни: %.1f с" % life_time
	
	for child in enemies.get_children():
		child.separate(enemies)
		child.cohesion(enemies)
		child.align(enemies)

func _on_player_collided(area: Area2D) -> void:
	player.disable_shield()
	life_time = 0
