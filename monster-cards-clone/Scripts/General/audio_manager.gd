extends Node

var save_timer: Timer
var pending_save := false

func _ready() -> void:
	save_timer = Timer.new()
	save_timer.one_shot = true
	save_timer.timeout.connect(_save_now)
	add_child(save_timer)
	
	load_audio_settings()

func load_audio_settings() -> void:
	var save = SaveGame.load_or_create()
	
	apply_volume("Master", save.master_volume)
	apply_volume("Sound", save.sfx_volume)
	apply_volume("Music", save.music_volume)



func apply_volume(bus_name: String, volume: int) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var linear_value = volume / 100.0
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))


func set_volume(bus_name: String, volume: int) -> void:
	apply_volume(bus_name, volume)
	# Debounce file writing - wait 0.5s after last change
	pending_save = true
	save_timer.start(0.5)


func get_volume(bus_name: String) -> int:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var linear_value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
		return int(round(linear_value * 100))
	return 100


func _save_now() -> void:
	if not pending_save:
		return
	
	var save = SaveGame.load_or_create()
	
	save.master_volume = get_volume("Master")
	save.sfx_volume = get_volume("Sound")
	save.music_volume = get_volume("Music")
	
	save.write_savegame()
	pending_save = false


func force_save() -> void:
	if pending_save:
		save_timer.stop()
		_save_now()
