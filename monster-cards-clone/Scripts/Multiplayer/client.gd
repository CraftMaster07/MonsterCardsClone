class_name Client
extends Node

var peer = ENetMultiplayerPeer.new()


func join_game(server_ip: String, port: int) -> void:
	peer.create_client(server_ip, port)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)


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
