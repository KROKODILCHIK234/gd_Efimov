extends Node2D

signal level_changed(value)

@onready var level_options: OptionButton = $CenterContainer/MenuContainer/OptionButton



func _unpause():
	get_tree().paused = false
	hide()
	
func _on_exit():
	get_tree().quit()
	
func _on_volume_change(value: float):
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))	

func get_settings():
	var slider: HSlider = $CenterContainer/MenuContainer/VolumeContainer/VolumeSlider
	var settings: Dictionary = {"volume": slider.value}
	return settings
	
func update_levels(levels: Array):
	for level in levels:
		level_options.add_item(level)

func on_level_button(value):
	_unpause()
	level_changed.emit(level_options.get_item_text(value))
