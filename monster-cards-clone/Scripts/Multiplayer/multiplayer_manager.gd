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

	server.start_server()

	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)



func join_game() -> void:
	"""
	Joins a game as a client.
	"""
	var client = client_scene.instantiate()
	add_child(client)

	peer.create_client(SERVER_IP, PORT)
	multiplayer.multiplayer_peer = peer


func _on_peer_connected(id):
	"""
	Initializes enemy scene on client connect.
	@param id: The unique network ID of the connected peer.
	"""
	print("peer connected: ", id)
	# var enemy_scene = enemy_field_scene.instantiate()
	# add_child(enemy_scene)


func _on_player_disconnected(id):
	"""
	@param id: The unique network ID of the disconnected peer.
	"""
	print("peer disconnected: ", id)


func signal_start_game():
	start_game.emit()
