extends Node2D

var coins := 0
var counter: Label

func sprite(asset: String, parent: Node, pos: Vector2) -> Sprite2D:
	var art := Sprite2D.new()
	art.texture = load("res://assets/" + asset + ".svg")
	art.position = pos
	parent.add_child(art)
	return art

func _ready() -> void:
	for child in $ParallaxBackground/Mountains.get_children():
		child.hide()
	for child in $ParallaxBackground/Bushes.get_children():
		child.hide()
	for i in range(10):
		sprite("hill", $ParallaxBackground/Mountains, Vector2(i * 350, 510))
		sprite("cloud", $ParallaxBackground/Sky, Vector2(i * 370 + 100, 130 + (i % 3) * 45))
	$Ground/Visual.hide()
	$Ground/GroundTop.hide()
	for i in range(50):
		sprite("ground", self, Vector2(i * 80 + 40, 760))
	for i in range(1, 8):
		var platform := get_node("Platform" + str(i))
		platform.get_node("Visual").hide()
		for j in range(5):
			sprite("brick", platform, Vector2(j * 40 - 80, 0))
		for j in range(3):
			add_coin(platform.position + Vector2(j * 50 - 50, -50))
	for i in range(8):
		add_coin(Vector2(2600 + i * 90, 620))
	$UI/Controls.text = "ЛУГОВЫЕ ОСТРОВА   /   1–1\n← →  движение    Shift  бег    Space / ↑  прыжок"
	$UI/Controls.position = Vector2(28, 22)
	counter = Label.new()
	counter.position = Vector2(1020, 24)
	counter.add_theme_font_size_override("font_size", 24)
	counter.add_theme_color_override("font_color", Color("29334b"))
	$UI.add_child(counter)
	update_counter()

func add_coin(pos: Vector2) -> void:
	var area := Area2D.new()
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 1
	add_child(area)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16
	shape.shape = circle
	area.add_child(shape)
	var art := sprite("coin", area, Vector2.ZERO)
	var tween := art.create_tween().set_loops()
	tween.tween_property(art, "position:y", -6.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(art, "position:y", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
	area.body_entered.connect(func(body: Node2D):
		if body != $Player or area.is_queued_for_deletion():
			return
		coins += 1
		update_counter()
		area.queue_free()
	)

func update_counter() -> void:
	counter.text = "МОНЕТЫ  %02d / 29" % coins
	if coins == 29:
		counter.text = "ВСЕ МОНЕТЫ!"
