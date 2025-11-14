extends Node
"""
Manages the multiplayer setup for hosting or joining a network game using ENet.
This script is responsible for initializing the ENet peer (as a server or client),
connecting signals, and instantiating the necessary game scenes (fields)
based on the player's role (host or joiner).
"""

signal start_game()


@export var client_scene: PackedScene
@export var server_scene: PackedScene

var peer = ENetMultiplayerPeer.new()

const SERVER_IP = "147.235.201.54"
const PORT = 59009


func host_game() -> void:
	"""
	Hosts a game as a server.
	"""
	var server = server_scene.instantiate()
	add_child(server)
	server.host_game(PORT)


func join_game() -> void:
	"""
	Joins a game as a client.
	"""
	var client = client_scene.instantiate()
	add_child(client)
	client.join_game(SERVER_IP, PORT)


func signal_start_game():
	start_game.emit()
