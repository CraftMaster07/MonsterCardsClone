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
signal client_placed_card(player_id: int, serialized_card: Dictionary, slot_id: int)

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


func _ready() -> void:
	multiplayer_interface.host_started_game.connect(signal_start_game)


func host_game(player_name) -> void:
	"""
	Hosts a game as a server.
	"""
	multiplayer_interface.set_script(server_script)
	multiplayer_interface.client_placed_card.connect(_on_multiplayer_interface_client_placed_card)

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


func _on_multiplayer_interface_client_placed_card(player_id: int, serialized_card: Dictionary, slot_id: int) -> void:
	client_placed_card.emit(player_id, serialized_card, slot_id)
