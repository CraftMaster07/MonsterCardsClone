extends Client

signal upnp_completed(error)

# Replace this with your own server port number between 1024 and 65535.
const SERVER_PORT = 59009
var thread = null

func _upnp_setup(server_port):
	# UPNP queries take some time.
	print("UPNP start")
	var upnp = UPNP.new()
	print("UPNP discover")
	var err = upnp.discover()
	print("UPNP error: ", err)
	

	if err != OK:
		print("UPNP error: ", err)
		push_error(str(err))
		upnp_completed.emit(err)
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
			upnp_completed.emit(OK)

func start_server():
	thread = Thread.new()
	thread.start(_upnp_setup.bind(SERVER_PORT))

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	thread.wait_to_finish()