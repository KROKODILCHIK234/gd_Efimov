extends Node2D

@export var max_health: int = 3
var current_health: int = 3

func show_stats(health: int, difficulty: int, round_number: int, distance: int, message: String) -> void:
	current_health = health
	$Panel/Margin/VBox/Health.text = "Жизни: " + "● ".repeat(health) + "○ ".repeat(max_health - health)
	$Panel/Margin/VBox/Stats.text = "Участок %d   |   Сложность %d/10   |   %d м" % [round_number, difficulty, distance]
	$Panel/Margin/VBox/Message.text = message

func show_training() -> void:
	show_stats(max_health, 1, 1, 0, "Тренировка. Esc — меню и выбор уровня")
