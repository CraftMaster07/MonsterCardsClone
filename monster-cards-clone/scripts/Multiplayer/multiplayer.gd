extends Node

@onready var host_button = get_parent().get_node("HostButton")
@onready var join_button = get_parent().get_node("JoinButton")


var peer = ENetMultiplayerPeer.new()
const SERVER_IP = "147.235.201.54"
const PORT = 59009

@export var your_field_scene: PackedScene
@export var enemy_field_scene: PackedScene
@onready var server = get_node("Server")

func _on_host_button_pressed() -> void:
	disable_buttons()
	server.start_server()

	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

	var your_player_scene = your_field_scene.instantiate()
	add_child(your_player_scene)


func _on_join_button_pressed() -> void:
	disable_buttons()

	peer.create_client(SERVER_IP, PORT)
	multiplayer.multiplayer_peer = peer

	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)


func _on_peer_connected(id):
	print("peer connected: ", id)
	var enemy_scene = enemy_field_scene.instantiate()
	add_child(enemy_scene)


func _on_player_disconnected(id):
	print("peer disconnected: ", id)


func disable_buttons():
	host_button.disabled = true
	host_button.visible = false
	join_button.disabled = true
	join_button.visible = false
