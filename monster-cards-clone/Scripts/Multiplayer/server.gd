extends Client

signal upnp_completed(error: UPNP.UPNPResult)

# Replace this with your own server port number between 1024 and 65535.
const SERVER_PORT = 59009
var thread = null


func _upnp_setup(server_port: int) -> void:
	# UPNP queries take some time.
	var upnp = UPNP.new()
	print("UPNP discover")
	var err = upnp.discover()
	printerr("UPNP error: ", err)
	

	if err != OK:
		printerr("UPNP error: ", err)
		push_error(str(err))
		upnp_completed.emit.call_deferred(err)
		return

	if err == UPNP.UPNP_RESULT_SUCCESS:
		print("UPNP gateway found")
		var gateway = upnp.get_device(0)
		print("UPNP 'gateway': ", gateway)
		print("UPNP device count: ", upnp.get_device_count())
		if gateway and gateway.is_valid_gateway():
			print("UPNP success")
			upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
			upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
			upnp_completed.emit.call_deferred(err)


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
	thread.start(_upnp_setup.bind(SERVER_PORT))

	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	new_player.emit(multiplayer.get_unique_id(), my_name)


func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()

func leave_game():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func start_game():
	send_host_started_game.rpc()
