class_name ShadowPlayerManager
extends Node


var players: Dictionary[int, ShadowPlayer] = {}


func add_player(player: ShadowPlayer):
	players[player.player_id] = player


func get_player_ids() -> Array[int]:
	return players.keys()


func get_player(player_id: int) -> ShadowPlayer:
	return players[player_id]


func create_player_deck(serialized_deck_blueprint: Dictionary, player_id: int):
	get_player(player_id).create_player_deck(serialized_deck_blueprint)


func draw_card(player_id: int) -> bool:
	return get_player(player_id).draw_card()


func shadow_serialize_player(player_id: int) -> Dictionary:
	return get_player(player_id).shadow_serialize()


func remove_serialized_card_from_hand(player_id: int, serialized_card: Dictionary):
	get_player(player_id).remove_serialized_card_from_hand(serialized_card)


func get_deck_card_data_count(player_id: int) -> int:
	return get_player(player_id).get_deck_card_data_count()


func get_hand_card_data_count(player_id: int) -> int:
	return get_player(player_id).get_hand_card_data_count()
