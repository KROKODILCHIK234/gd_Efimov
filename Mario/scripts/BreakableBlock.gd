extends StaticBody2D

var broken := false
var pieces: Array[Sprite2D] = []
var speeds: Array[Vector2] = []
var elapsed := 0.0

func break_block() -> void:
	if broken:
		return
	broken = true
	$Sprite.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	for i in range(4):
		var piece := Sprite2D.new()
		piece.texture = $Sprite.texture
		piece.region_enabled = true
		piece.region_rect = Rect2((i % 2) * 20, (i / 2) * 12, 20, 12)
		piece.position = Vector2((i % 2) * 20 - 10, (i / 2) * 12 - 6)
		add_child(piece)
		pieces.append(piece)
		var horizontal := -100.0 if i % 2 == 0 else 100.0
		speeds.append(Vector2(horizontal, -230.0 + (i / 2) * 70.0))

func _process(delta: float) -> void:
	if not broken:
		return
	elapsed += delta
	for i in range(pieces.size()):
		speeds[i].y += 700.0 * delta
		pieces[i].position += speeds[i] * delta
		pieces[i].rotation += speeds[i].x * 0.04 * delta
		pieces[i].modulate.a = maxf(0.0, 1.0 - elapsed)
	if elapsed >= 1.0:
		queue_free()
