class_name Client
extends Node

var peer: ENetMultiplayerPeer
var my_name: String

signal new_player(id: int, name: String)
signal player_left(id: int)
signal server_disconnected()

signal connection_success()
signal connection_failure()

signal host_started_game()

signal sync_game(game_state: Dictionary)
signal shadow_sync(serialized_shadow_player_data: Dictionary)
signal get_deck_blueprint()

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
	print("Peer connected: ", id)

	send_player_data.rpc_id(id, my_name)


func _on_player_disconnected(id: int):
	"""
	@param id: The unique network ID of the disconnected peer.
	"""
	print("Peer disconnected: ", id)

	player_left.emit(id)


func _on_connected_to_server():
	connection_success.emit()
	new_player.emit(multiplayer.get_unique_id(), my_name)


func _on_connection_failed():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	connection_failure.emit()


func _on_server_disconnected():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	server_disconnected.emit()


@rpc("any_peer", "call_local", "reliable", 0)
func send_player_data(player_name: String):
	new_player.emit(multiplayer.get_remote_sender_id(), player_name)


func leave_game():
	multiplayer.multiplayer_peer.disconnect_peer(1)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


@rpc("authority", "call_local", "reliable", 0)
func send_host_started_game():
	host_started_game.emit()


@rpc("authority", "call_local", "reliable", 0)
func receive_sync_game(game_state: Dictionary):
	sync_game.emit(game_state)


func send_placed_card(serialized_card: Dictionary, slot_id: int):
	receive_client_placed_card.rpc_id(1, serialized_card, slot_id)


@rpc("any_peer", "call_remote", "reliable", 0)
func receive_client_placed_card(_serialized_cardcard: Dictionary, _slot_id: int):
	# server side function
	pass

func send_end_turn():
	receive_end_turn.rpc_id(1)

@rpc("any_peer", "call_remote", "reliable", 0)
func receive_end_turn():
	# server side function
	pass

func send_player_attacked(attacked_id: int):
	receive_player_attacked.rpc_id(1, attacked_id)

@rpc("any_peer", "call_remote", "reliable", 0)
func receive_player_attacked(_attacked_id: int):
	# server side function
	pass

@rpc("authority", "call_local", "reliable", 0)
func receive_request_deck_blueprint():
	get_deck_blueprint.emit()


func send_deck_blueprint(deck_blueprint: Dictionary):
	receive_deck_blueprint.rpc_id(1, deck_blueprint)


@rpc("any_peer", "call_local", "reliable", 0)
func receive_deck_blueprint(_serialized_deck_blueprint: Dictionary):
	# server side function
	pass


@rpc("authority", "call_local", "reliable", 0)
func receive_shadow_sync(serialized_shadow_player_data: Dictionary):
	shadow_sync.emit(serialized_shadow_player_data)
