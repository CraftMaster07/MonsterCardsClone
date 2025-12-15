class_name Client
extends Node

var peer: ENetMultiplayerPeer
var my_name: String

signal new_player(id: int, name: String)
signal player_left(id: int)
signal server_disconnected()

func join_game(server_ip: String, port: int) -> void:
	peer.create_client(server_ip, port)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func join_game(server_ip: String, port: int, player_name: String) -> void:
	my_name = player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_client(server_ip, port)
	if peer.get_peer(1):
		peer.get_peer(1).set_timeout(0, 0, 2000)
	else:
		_on_connection_failed()
		return
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id: int):
	"""
	Initializes enemy scene on client connect.
	@param id: The unique network ID of the connected peer.
	"""
	print("peer connected: ", id)
	# var enemy_scene = enemy_field_scene.instantiate()
	# add_child(enemy_scene)


func _on_player_disconnected(id: int):
	"""
	@param id: The unique network ID of the disconnected peer.
	"""
	print("peer disconnected: ", id)
