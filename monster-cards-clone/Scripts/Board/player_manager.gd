extends Node


@export var your_player_scene: PackedScene
@export var enemy_player_scene: PackedScene

var players: Dictionary[int, Player] = {}
var your_id: int

func get_player_count():
	return len(players)


func get_player_ids():
	return players.keys()


func get_player(player_id: int):
	return players[player_id]


func init_players(multiplayer_players: Array):
	for player_data in multiplayer_players:
		if player_data['id'] == your_id:
			init_your_player(player_data)
		else:
			init_enemy_player(player_data)


func init_enemy_player(player_data: Dictionary):
	var new_player: Player = enemy_player_scene.instantiate()
	new_player.init(player_data['id'], player_data['name'])
	add_child(new_player)
	players[player_data['id']] = new_player


func init_your_player(player_data: Dictionary):
	var new_player: Player = your_player_scene.instantiate()
	new_player.init(player_data['id'], player_data['name'])
	add_child(new_player)
	players[player_data['id']] = new_player


func remove_player(id: int):
	remove_child(players[id])
	players[id].queue_free()
	players.erase(id)


func serialize_players():
	var serialized_players := {}

	for player in players.values():
		serialized_players[player.player_id] = (player.serialize())

	return serialized_players


func deserialize_players(serialized_players: Dictionary):
	for serialized_player_id in serialized_players:
		players[serialized_player_id].deserialize(serialized_players[serialized_player_id])


func get_unassigned_field_player_ids():
	var unassigned_field_player_ids := []

	for player in players.values():
		if player.player_id == your_id:
			continue

		if player.get_field() == null:
			unassigned_field_player_ids.append(player.player_id)

	return unassigned_field_player_ids


func set_player_field(field: Field, player_id: int):
	get_player(player_id).set_field(field)


func set_your_id(id: int):
	your_id = id