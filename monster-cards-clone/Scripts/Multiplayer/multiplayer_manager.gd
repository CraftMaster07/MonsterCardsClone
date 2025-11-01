extends Node
"""
Manages the multiplayer setup for hosting or joining a network game using ENet.
This script is responsible for initializing the ENet peer (as a server or client),
connecting signals, and instantiating the necessary game scenes (fields)
based on the player's role (host or joiner).
"""

signal start_game()

# Scene to instantiate for the local player's game area (e.g., your board).
@export var your_field_scene: PackedScene
# Scene to instantiate for the remote player's game area (e.g., the enemy board).
@export var enemy_field_scene: PackedScene
@export var client_scene: PackedScene
@export var server_scene: PackedScene

var peer = ENetMultiplayerPeer.new()
# The hardcoded IP address of the server/host.
const SERVER_IP = "147.235.201.54"
# The network port used for communication.
const PORT = 59009

@onready var host_button = get_parent().get_node("HostButton")
@onready var join_button = get_parent().get_node("JoinButton")


func _on_host_button_pressed() -> void:
	"""
	Hosts a game as a server.
	"""
	disable_buttons()
	var server = server_scene.instantiate()
	add_child(server)

	server.start_server()

	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

	var your_player_scene = your_field_scene.instantiate()
	add_child(your_player_scene)


func _on_join_button_pressed() -> void:
	"""
	Joins a game as a client.
	"""
	disable_buttons()
	var client = client_scene.instantiate()
	add_child(client)

	peer.create_client(SERVER_IP, PORT)
	multiplayer.multiplayer_peer = peer

	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)


func _on_peer_connected(id):
	"""
	Initializes enemy scene on client connect.
	@param id: The unique network ID of the connected peer.
	"""
	print("peer connected: ", id)
	# The host instantiates the enemy field for the newly connected client
	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)


func _on_player_disconnected(id):
	"""
	@param id: The unique network ID of the disconnected peer.
	"""
	print("peer disconnected: ", id)


func disable_buttons():
	"""
	Disables the host and join buttons.
	"""
	host_button.disabled = true
	host_button.visible = false
	join_button.disabled = true
	join_button.visible = false


func start_game():
	start_game.emit()
