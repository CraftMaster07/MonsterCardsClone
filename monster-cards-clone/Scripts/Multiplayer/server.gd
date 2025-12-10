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


func host_game(port: int) -> void:
	"""
	Hosts a game as a server.
	"""
	start_server(port)

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)


func start_server(port: int):
	thread = Thread.new()
	thread.start(_upnp_setup.bind(SERVER_PORT))

	peer.create_server(port)
	multiplayer.multiplayer_peer = peer


func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()
