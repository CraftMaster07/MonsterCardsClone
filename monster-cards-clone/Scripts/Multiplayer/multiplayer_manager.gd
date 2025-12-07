extends Node
"""
Manages the multiplayer setup for hosting or joining a network game using ENet.
This script is responsible for initializing the ENet peer (as a server or client),
connecting signals, and instantiating the necessary game scenes (fields)
based on the player's role (host or joiner).
"""

signal start_game()
signal new_player(name: String)

@export var client_scene: PackedScene
@export var server_scene: PackedScene

const PORT = 59009

var active_child: Client

"""
READ THIS
We can maybe change 'players' later to an array of player objects? right now there already is a player class
But I'm not sure if we're still using that one,so I'm not making a new one yet.
"""
var players: Array[Dictionary] = []

func host_game(player_name) -> void:
	"""
	Hosts a game as a server.
	"""
	var server = server_scene.instantiate()
	add_child(server)
	server.host_game(PORT, player_name)
	active_child = server


func join_game(player_name, ip) -> void:
	"""
	Joins a game as a client.
	"""
	var client = client_scene.instantiate()
	add_child(client)
	client.join_game(ip, PORT, player_name)
	active_child = client

func connect_active_child_signals():
	active_child.new_player.connect(add_new_player)

func add_new_player(player_name: String, id: int):
	players.append({"name": player_name, "id": id})
	new_player.emit(player_name)

func signal_start_game():
	start_game.emit()
