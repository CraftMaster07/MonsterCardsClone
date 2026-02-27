extends Node

signal player_attacked(player_id: int)

@export var your_player_scene: PackedScene
@export var enemy_player_scene: PackedScene
@export var player_container: VBoxContainer

var players: Dictionary[int, Player] = {}
var your_id: int

func get_player_count():
	return len(players)


func get_player_ids():
	return players.keys()


func get_player(player_id: int) -> Player:
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
	player_container.add_child(new_player)
	players[player_data['id']] = new_player

	new_player.attacked.connect(on_enemy_player_attacked)


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


func on_enemy_player_attacked(player_id: int):
	player_attacked.emit(player_id)


func do_player_attack(attacker_id: int, attacked_id: int) -> Error:
	var attacker := get_player(attacker_id)
	var attacked := get_player(attacked_id)
	if attacker.attacking_id != 0 or attacked.attacked_by_id != 0:
		print("invalid attack")
		return FAILED

	print("Player ", attacker_id, " attacks Player ", attacked_id)
	attacker.attacking_id = attacked_id
	attacked.attacked_by_id = attacker_id
	return OK


func reset_attack_history():
	for player in players.values():
		player.attacking_id = 0
		player.attacked_by_id = 0
