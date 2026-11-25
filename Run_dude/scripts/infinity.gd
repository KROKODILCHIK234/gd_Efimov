extends Node2D

signal stats_changed(health: int, difficulty: int, round_number: int, distance: int, message: String)

const FRUIT = preload("res://scenes/items/finish_fruit.tscn")
const MAX_HEALTH = 3
const PLATFORMS_PER_ROUND = 18
const FALL_Y = 760.0

var camera: Camera2D
var player: CharacterBody2D
@onready var platforms: Node2D = $platforms
@export var platform_scene: PackedScene
@export var offscreen_distance: float = 350.0

var spawned: Array[Node2D] = []
var health: int = MAX_HEALTH
var running_time: float = 0.0
var round_number: int = 1
var generated: int = 0
var right_x: float = 100.0
var last_y: float = 460.0
var last_width: float = 160.0
var furthest_x: float = 100.0
var completed_distance: float = 0.0
var message: String = "Доберись до вишни! A/D — бег, W — двойной прыжок, Esc — пауза"
var resetting := false

func _ready() -> void:
	_start_section()

func get_difficulty() -> float:
	# Time advances only while making new forward progress; waiting is safe.
	return clampf(running_time / 150.0 + (round_number - 1) * 0.12, 0.0, 1.0)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(camera) or resetting:
		return
	if player.global_position.y > FALL_Y:
		_handle_fall()
		return
	if player.position.x > furthest_x:
		if absf(player.velocity.x) > 10.0:
			running_time += delta
		furthest_x = player.position.x
	var half_width: float = get_viewport_rect().size.x / (2.0 * camera.zoom.x)
	var right_edge: float = maxf(player.position.x, camera.get_screen_center_position().x) + half_width
	while generated < PLATFORMS_PER_ROUND and right_x < right_edge + offscreen_distance:
		_create_next_platform()
	for i in range(spawned.size() - 1, -1, -1):
		if spawned[i].position.x < player.position.x - half_width - offscreen_distance:
			spawned[i].queue_free()
			spawned.remove_at(i)
	_publish_stats()

func _start_section() -> void:
	for child in platforms.get_children():
		platforms.remove_child(child)
		child.queue_free()
	spawned.clear()
	generated = 0
	right_x = 100.0
	last_y = 460.0
	last_width = 160.0
	furthest_x = 100.0
	_add_platform(Vector2(right_x, last_y), last_width, false)
	_publish_stats()

func _add_platform(at: Vector2, width: float, moving: bool) -> Node2D:
	var platform: Node2D = platform_scene.instantiate()
	platform.position = at
	# Each instance owns its shape: resizing must not resize other platforms.
	var collision: CollisionShape2D = platform.get_node("CollisionShape2D")
	collision.shape = collision.shape.duplicate()
	collision.shape.size.x = width
	collision.position.x = 0.0
	platform.get_node("Sprite2D").scale.x = width / 48.0
	if moving:
		platform.amplitude = lerpf(10.0, 34.0, get_difficulty())
		platform.frequency = lerpf(0.8, 2.0, get_difficulty())
	platforms.add_child(platform)
	spawned.append(platform)
	return platform

func _create_next_platform() -> void:
	generated += 1
	var difficulty := get_difficulty()
	var width := lerpf(128.0, 80.0, difficulty)
	var gap := randf_range(55.0, lerpf(85.0, 130.0, difficulty))
	right_x += last_width / 2.0 + gap + width / 2.0
	last_y = clampf(last_y + randf_range(-55.0, 55.0), 310.0, 500.0)
	var finish := generated == PLATFORMS_PER_ROUND
	var moving := not finish and (generated % 3 == 0 or randf() < difficulty * 0.5)
	var platform := _add_platform(Vector2(right_x, last_y), width, moving)
	last_width = width
	if finish:
		var fruit = FRUIT.instantiate()
		fruit.position = Vector2(0, -48)
		fruit.collected.connect(_finish_round)
		platform.add_child(fruit)

func _handle_fall() -> void:
	if resetting:
		return
	resetting = true
	health -= 1
	if health <= 0:
		health = MAX_HEALTH
		running_time = 0.0
		round_number = 1
		completed_distance = 0.0
		message = "Жизни закончились. Новый забег — попробуй ещё раз!"
	else:
		message = "Падение: −1 жизнь. Осталось: %d" % health
	_restart_section.call_deferred()

func _finish_round() -> void:
	if resetting:
		return
	resetting = true
	completed_distance += furthest_x - 100.0
	round_number += 1
	message = "Вишня собрана! Участок %d — сложность растёт" % round_number
	_restart_section.call_deferred()

func _restart_section() -> void:
	_start_section()
	player.reset_for_respawn($Spawn.global_position)
	camera.reset_smoothing()
	resetting = false

func _publish_stats() -> void:
	stats_changed.emit(health, 1 + int(get_difficulty() * 9.0), round_number,
		int((completed_distance + furthest_x - 100.0) / 10.0), message)
