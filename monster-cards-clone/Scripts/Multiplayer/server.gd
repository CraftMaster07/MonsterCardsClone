extends Client

signal upnp_completed(error: UPNP.UPNPResult)

signal client_placed_card(player_id: int, serialized_card: Dictionary, slot_id: int)
signal client_ended_turn(player_id: int)
signal client_attacked(player_id: int, attacked_id: int)

signal received_deck_blueprint(player_id: int, deck: Array)

var thread = null


func _upnp_setup(server_port: int) -> void:
	# UPNP queries take some time.
	var upnp = UPNP.new()
	print("UPNP discover")
	var err = upnp.discover()

	if err == UPNP.UPNP_RESULT_SUCCESS:
		print("UPNP gateway found")
		var gateway = upnp.get_device(0)
		print("UPNP 'gateway': ", gateway)
		print("UPNP device count: ", upnp.get_device_count())
		if gateway and gateway.is_valid_gateway():
			print("UPNP success")
			var app_name = ProjectSettings.get_setting("application/config/name")
			upnp.add_port_mapping(server_port, server_port, app_name, "UDP")
			upnp.add_port_mapping(server_port, server_port, app_name, "TCP")
			upnp_completed.emit.call_deferred(err)
	else:
		push_error("UPNP error: ", error_string(err))
		upnp_completed.emit.call_deferred(err)
		return


func host_game(port: int, player_name: String) -> void:
	"""
	Hosts a game as a server.
	"""
	my_name = player_name
	start_server(port)


func start_server(port: int):
	if thread:
		thread.wait_to_finish()
	thread = Thread.new()
	thread.start(_upnp_setup.bind(port))

	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	new_player.emit(multiplayer.get_unique_id(), my_name)


func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()


func leave_game():
	if thread:
		thread.wait_to_finish()
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func start_game():
	send_host_started_game.rpc()


func send_sync_game(game_state: Dictionary):
	receive_sync_game.rpc(game_state)


@rpc("any_peer", "call_remote", "reliable", 0)
func receive_client_placed_card(serialized_cardcard: Dictionary, slot_id: int):
	var sender := multiplayer.get_remote_sender_id()
	sender = sender if sender else 1
	print("received card from ", sender)
	client_placed_card.emit(sender, serialized_cardcard, slot_id)

func send_placed_card(serialized_card: Dictionary, slot_id: int):
	receive_client_placed_card(serialized_card, slot_id)

func send_end_turn():
	receive_end_turn()


@rpc("any_peer", "call_remote", "reliable", 0)
func receive_end_turn():
	var sender := multiplayer.get_remote_sender_id()
	sender = sender if sender else 1
	print("received end turn from ", sender)
	client_ended_turn.emit(sender)

func send_player_attacked(attacked_id: int):
	receive_player_attacked(attacked_id)


@rpc("any_peer", "call_remote", "reliable", 0)
func receive_player_attacked(attacked_id: int):
	var sender := multiplayer.get_remote_sender_id()
	sender = sender if sender else 1
	print("received attack from ", sender)
	client_attacked.emit(sender, attacked_id)


func request_deck_blueprints():
	# NOTE: can request from specific player if needed
	receive_request_deck_blueprint.rpc()


@rpc("any_peer", "call_local", "reliable", 0)
func receive_deck_blueprint(serialized_deck_blueprint: Dictionary):
	received_deck_blueprint.emit(multiplayer.get_remote_sender_id(), serialized_deck_blueprint)


func send_shadow_sync(player_id: int, serialized_shadow_player_data: Dictionary):
	receive_shadow_sync.rpc_id(player_id, serialized_shadow_player_data)
