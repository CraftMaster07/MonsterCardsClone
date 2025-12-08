class_name Client
extends Node

var peer = ENetMultiplayerPeer.new()
var my_name: String

signal new_player(id: int, name: String)

func _ready():
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_to_server)

func join_game(server_ip: String, port: int, player_name: String) -> void:
    my_name = player_name
    peer.create_client(server_ip, port)
    multiplayer.multiplayer_peer = peer

func _on_peer_connected(id: int):
    """
    Initializes enemy scene on client connect.
    @param id: The unique network ID of the connected peer.
    """
    print("peer connected: ", id)

    send_player_data.rpc_id(id, my_name)


func _on_player_disconnected(id: int):
    """
    @param id: The unique network ID of the disconnected peer.
    """
    print("peer disconnected: ", id)

func _on_connected_to_server():
    new_player.emit(multiplayer.get_unique_id(), my_name)


@rpc("any_peer", "call_local", "reliable", 0)
func send_player_data(player_name: String):
    new_player.emit(multiplayer.get_remote_sender_id(), player_name)