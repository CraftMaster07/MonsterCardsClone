extends Node

@onready var host_button = get_parent().get_node("HostButton")
@onready var join_button = get_parent().get_node("JoinButton")


var peer = ENetMultiplayerPeer.new()
var PORT = 59009

@export var player_field_scene: PackedScene


func _on_host_button_pressed() -> void:
	disable_buttons()

	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

	var your_player_scene = player_field_scene.instantiate()
	add_child(your_player_scene)


func disable_buttons():
	host_button.disabled = true
	host_button.visible = false
	join_button.disabled = true
	join_button.visible = false
	
