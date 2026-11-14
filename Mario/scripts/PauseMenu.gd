extends CanvasLayer

@onready var overlay: Control = $Overlay
@onready var resume_button: Button = $Overlay/Center/Panel/Margin/Buttons/Resume

func _ready() -> void:
	# Меню продолжает получать ввод, даже когда игровой мир на паузе.
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.hide()
	resume_button.pressed.connect(func(): set_paused(false))
	$Overlay/Center/Panel/Margin/Buttons/Restart.pressed.connect(restart)
	$Overlay/Center/Panel/Margin/Buttons/Quit.pressed.connect(func(): get_tree().quit())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()

func set_paused(value: bool) -> void:
	get_tree().paused = value
	overlay.visible = value
	if value:
		resume_button.grab_focus()
	else:
		get_viewport().gui_release_focus()

func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
