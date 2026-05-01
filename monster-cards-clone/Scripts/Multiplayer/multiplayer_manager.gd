class_name MultiplayerManager
extends Node
"""
Manages the multiplayer setup for hosting or joining a network game using ENet.
This script is responsible for initializing the ENet peer (as a server or client),
connecting signals, and instantiating the necessary game scenes (fields)
based on the player's role (host or joiner).
"""

signal start_game()
signal new_player(id: int, name: String)
signal player_left(id: int)

signal connection_success()
signal connection_failure()
signal server_disconnected()

signal sync_game(game_state: Dictionary)
signal shadow_sync(serialized_shadow_player_data: Dictionary)
signal client_placed_card(player_id: int, serialized_card: Dictionary, slot_id: int)
signal client_ended_turn(player_id: int)
signal client_attacked(player_id: int, attacked_id: int)

signal received_deck_blueprint(player_id: int, deck_blueprint: Dictionary)
signal get_deck_blueprint()

signal select_card()

@export var server_script: Script
@export var client_script: Script

const PORT = 59009

@export var multiplayer_interface: Client = null

"""
READ THIS
We can maybe change 'players' later to an array of player objects? right now there
already is a player class. But I'm not sure if we're still using that one,
so I'm not making a new one yet.
"""
var players: Dictionary = {}
var your_id: int


func host_game(player_name) -> void:
	"""
	Hosts a game as a server.
	"""
	multiplayer_interface.set_script(server_script)
	multiplayer_interface.client_placed_card.connect(_on_multiplayer_interface_client_placed_card)
	multiplayer_interface.client_ended_turn.connect(_on_multiplayer_interface_client_ended_turn)
	multiplayer_interface.client_attacked.connect(_on_multiplayer_interface_client_attacked)
	multiplayer_interface.received_deck_blueprint.connect(_on_multiplayer_interface_received_deck)

	multiplayer_interface.host_game(PORT, player_name)
	your_id = multiplayer.get_unique_id()


func join_game(player_name, ip) -> void:
	"""
	Joins a game as a client.
	"""
	if not is_valid_ipv4(ip):
		print("Invalid IP address.")
		return
	multiplayer_interface.join_game(ip, PORT, player_name)
	your_id = multiplayer.get_unique_id()


func leave_game() -> void:
	players.clear()
	multiplayer_interface.leave_game()
	multiplayer_interface.set_script(client_script)


func add_new_player(id: int, player_name: String):
	players[id] = MultiplayerPlayer.new(id, player_name)
	new_player.emit(id, player_name)


func signal_start_game():
	start_game.emit()


func _on_connection_success() -> void:
	connection_success.emit()


func _on_connection_failure() -> void:
	connection_failure.emit()


func is_valid_ipv4(addr: String) -> bool:
	var parts := addr.split(".")
	if parts.size() != 4:
		return false

	for part in parts:
		# empty part not allowed
		if part == "":
			return false

		if not part.is_valid_int():
			return false

		var n := part.to_int()
		if n < 0 or n > 255:
			return false

	return true


func _on_multiplayer_interface_player_left(id: int) -> void:
	players.erase(id)
	player_left.emit(id)


func _on_multiplayer_interface_server_disconnected() -> void:
	players.clear()
	server_disconnected.emit()


func start_game_as_host() -> void:
	multiplayer_interface.start_game()


func set_your_id(id: int) -> void:
	your_id = id


func call_sync_game(game_state: Dictionary) -> void:
	if not multiplayer.is_server(): return

	multiplayer_interface.send_sync_game(game_state)


func _on_multiplayer_interface_sync_game(game_state: Dictionary) -> void:
	sync_game.emit(game_state)


func send_placed_card(serialized_card: Dictionary, slot_id: int) -> void:
	multiplayer_interface.send_placed_card(serialized_card, slot_id)


func _on_multiplayer_interface_client_placed_card(
	player_id: int, serialized_card: Dictionary, slot_id: int
) -> void:
	client_placed_card.emit(player_id, serialized_card, slot_id)


func send_end_turn() -> void:
	multiplayer_interface.send_end_turn()


func _on_multiplayer_interface_client_ended_turn(player_id: int) -> void:
	client_ended_turn.emit(player_id)


func send_player_attacked(attacked_id: int) -> void:
	multiplayer_interface.send_player_attacked(attacked_id)


func _on_multiplayer_interface_client_attacked(player_id, attacked_id: int) -> void:
	client_attacked.emit(player_id, attacked_id)


func request_deck_blueprints() -> void:
	multiplayer_interface.request_deck_blueprints()


func _on_multiplayer_interface_received_deck(player_id: int, deck_blueprint: Dictionary) -> void:
	received_deck_blueprint.emit(player_id, deck_blueprint)


func _on_multiplayer_interface_get_deck_blueprint() -> void:
	get_deck_blueprint.emit()


func send_deck_blueprint(deck_blueprint: Dictionary):
	multiplayer_interface.send_deck_blueprint(deck_blueprint)


func send_shadow_sync(player_id: int, serialized_shadow_player_data: Dictionary) -> void:
	multiplayer_interface.send_shadow_sync(player_id, serialized_shadow_player_data)


func _on_multiplayer_interface_shadow_sync(serialized_shadow_player_data: Dictionary) -> void:
	shadow_sync.emit(serialized_shadow_player_data)


func request_card_selection(player_id: int) -> void:
	multiplayer_interface.request_card_selection(player_id)

func _on_multiplayer_interface_select_card() -> void:
	select_card.emit()
