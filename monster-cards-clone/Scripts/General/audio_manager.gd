extends Node


func _ready() -> void:
	load_audio_settings()


func load_audio_settings() -> void:
	var save = SaveGame.load_or_create()
	
	set_volume("Master", save.master_volume)
	set_volume("Sound", save.sfx_volume)
	set_volume("Music", save.music_volume)


func set_volume(bus_name: String, volume: int) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var linear_value = volume / 100.0
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))


func get_volume(bus_name: String) -> int:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var linear_value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
		return int(round(linear_value * 100))
	return 100


func save_volume() -> void:
	var save = SaveGame.load_or_create()
	
	save.master_volume = get_volume("Master")
	save.sfx_volume = get_volume("Sound")
	save.music_volume = get_volume("Music")
	
	save.write_savegame()
