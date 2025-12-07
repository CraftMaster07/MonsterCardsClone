extends Node

@onready var multiplayer_manager = $MultiplayerManager
@onready var main_menu = $MainMenu
@export var waiting_room_scene: PackedScene
@export var board_scene: PackedScene

var waiting_room: WaitingRoom = null
var board: Board = null


func transition_main_menu_to_board():
	stop_main_menu()
	start_board()


func transition_board_to_main_menu():
	stop_board()
	start_main_menu()


func transition_main_menu_to_waiting_room():
	stop_main_menu()
	start_waiting_room()


func transition_waiting_room_to_board():
	stop_waiting_room()
	start_board()


func start_waiting_room():
	waiting_room = waiting_room_scene.instantiate()
	waiting_room.start_game.connect(transition_waiting_room_to_board)
	add_child(waiting_room)


func stop_waiting_room():
	remove_child(waiting_room)
	waiting_room.queue_free()


func start_board():
	board = board_scene.instantiate()
	add_child(board)


func stop_board():
	remove_child(board)
	board.queue_free()


func start_main_menu():
	add_child(main_menu)


func stop_main_menu():
	remove_child(main_menu)


func _on_main_menu_join_game(player_name: String, ip: String) -> void:
	multiplayer_manager.join_game(player_name, ip)
	transition_main_menu_to_waiting_room()


func _on_main_menu_host_game(player_name: String) -> void:
	multiplayer_manager.host_game(player_name)
	transition_main_menu_to_waiting_room()


func _on_multiplayer_manager_new_player(player_name: String) -> void:
	if waiting_room:
		waiting_room.add_player(player_name)
