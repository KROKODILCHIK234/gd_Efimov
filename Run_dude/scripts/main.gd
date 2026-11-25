extends Node2D

var current_level: Node2D = null
var levels: Dictionary = {
	"Training": preload("res://scenes/levels/training_level.tscn"),
	"Infinity": preload("res://scenes/levels/infinity.tscn")
}

var player = null

@onready var player_scene = preload("res://scenes/characters/physics_dude.tscn")

@onready var world = $world
@onready var menu = $UI/menu

func _ready() -> void:
	player = player_scene.instantiate()
	load_settings()
	menu.update_levels(levels.keys())
	add_child(player)
	load_level("Infinity")
	menu.level_changed.connect(load_level)
	
func load_level(name):
	menu.level_options.select(levels.keys().find(name))
	if current_level:
		current_level.queue_free()
	current_level = levels[name].instantiate()
	world.add_child(current_level)
	player.reset_for_respawn(current_level.get_node("Spawn").global_position)
	var camera: Camera2D = player.get_node("Camera2D")
	match name:
		"Training":
			camera.enabled = false
			$UI/Hud.show_training()
		"Infinity": 
			camera.enabled = true
			camera.limit_left = 0
			camera.limit_bottom = 648
			camera.limit_top = 0
			current_level.camera = camera
			current_level.player = player
			current_level.stats_changed.connect($UI/Hud.show_stats)
			current_level._publish_stats()
		
	
func pause():
	if not menu.visible:
		get_tree().paused = true
		menu.show()
	else:
		get_tree().paused = false
		menu.hide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		pause()

func save_settings():
	var config = ConfigFile.new()
	var settings = menu.get_settings()
	for key in settings:
		config.set_value("general", key, settings[key])
		config.save("user://dude.cfg")
	
func load_settings():
	var config = ConfigFile.new()
	var error = config.load("user://dude.cfg")
	if error == OK:
		var settings: Dictionary = {}
		for key in config.get_section_keys("general"):
			settings[key] = config.get_value("general", key, 1.0)
		#var volume = config.get_value("general", "volume", 1.0)
