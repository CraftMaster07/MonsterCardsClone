class_name SaveGame
extends Resource

const SAVE_GAME_PATH := "user://save.tres"

@export var master_volume: int = 100
@export var music_volume: int = 100
@export var sfx_volume: int = 100

func write_savegame() -> void:
	var err = ResourceSaver.save(self, SAVE_GAME_PATH)
	if err != OK:
		push_error("Failed to save game: " + error_string(err))


static func load_savegame() -> SaveGame:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return load(SAVE_GAME_PATH) as SaveGame
	return null


static func load_or_create() -> SaveGame:
	var save = load_savegame()
	if save == null:
		save = SaveGame.new()
	return save
