extends Node


var save_game: SaveGame = SaveGame.load_or_create()


func write_savegame() -> void:
	save_game.write_savegame()


func get_master_volume():
	return save_game.master_volume


func set_master_volume(new_master_volume, write_to_disk = true):
	save_game.master_volume = new_master_volume
	
	if write_to_disk:
		write_savegame()


func get_sfx_volume():
	return save_game.sfx_volume


func set_sfx_volume(new_sfx_volume, write_to_disk = true):
	save_game.sfx_volume = new_sfx_volume
	
	if write_to_disk:
		write_savegame()


func get_music_volume():
	return save_game.music_volume


func set_music_volume(new_music_volume, write_to_disk = true):
	save_game.music_volume = new_music_volume
	
	if write_to_disk:
		write_savegame()


func get_selected_deck_path():
	return save_game.selected_deck_path


func set_selected_deck_path(new_selected_deck_path, write_to_disk = true):
	save_game.selected_deck_path = new_selected_deck_path
	
	if write_to_disk:
		write_savegame()


func set_volumes(master_volume, sfx_volume, music_volume):
	set_master_volume(master_volume, false)
	set_sfx_volume(sfx_volume, false)
	set_music_volume(music_volume)
