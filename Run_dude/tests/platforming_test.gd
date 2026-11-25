extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func wait_frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func run_checks() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await wait_frames(5)
	var level = game.current_level
	var player = game.player
	assert(level.health == 3 and level.spawned.size() > 1)
	await wait_frames(30)
	assert(player.is_on_floor(), "Spawn must be above a safe platform")
	var stationary_time: float = level.running_time
	await wait_frames(10)
	assert(is_equal_approx(level.running_time, stationary_time), "Standing must not increase difficulty")
	player.global_position.y = 850
	await wait_frames(4)
	assert(level.health == 2, "One fall must cost one life")
	assert(player.position.y < 500 and player.velocity.y < 100)
	assert(game.get_node("UI/Hud").current_health == 2)
	level.running_time = 75.0
	var difficulty_before: float = level.get_difficulty()
	while level.generated < level.PLATFORMS_PER_ROUND:
		level._create_next_platform()
	var moving = null
	var last_x: float = 0.0
	for platform in level.spawned:
		assert(platform.position.x > last_x)
		last_x = platform.position.x
		if platform.amplitude > 0.0:
			moving = platform
	assert(moving != null)
	var previous_position: Vector2 = moving.position
	await wait_frames(8)
	assert(moving.position != previous_position, "Platforms must move")
	var fruit = level.spawned.back().get_node("FinishFruit")
	player.position = fruit.global_position
	player.velocity = Vector2.ZERO
	await wait_frames(6)
	assert(level.round_number == 2, "Fruit overlap must complete the round once")
	assert(player.position.x < 200 and level.health == 2)
	assert(level.get_difficulty() > difficulty_before, "Completion must preserve and increase difficulty")
	await wait_frames(10)
	game.pause()
	var paused_time: float = level.running_time
	var paused_position: Vector2 = player.position
	await create_timer(0.15, true).timeout
	assert(player.position == paused_position and level.running_time == paused_time)
	game.pause()
	for i in range(2):
		player.position.y = 850
		await wait_frames(4)
	assert(level.health == 3 and level.round_number == 1 and level.running_time == 0.0,
		"Exhausting lives must reset the run")
	level.running_time = 10000
	assert(level.get_difficulty() == 1.0, "Difficulty must be capped to remain playable")
	game.load_level("Training")
	await wait_frames(3)
	game.load_level("Infinity")
	await wait_frames(4)
	assert(game.current_level.health == 3)
	print("PASS: safe spawn, fall damage, HUD, moving platforms, fruit overlap, increasing difficulty, pause, game over and level switching")
	quit()
