extends Node

@onready var multiplayer_manager = $MultiplayerManager
@onready var main_menu = $MainMenu
@export var board_scene: PackedScene

var board: Board = null


func transition_main_menu_to_board():
	stop_main_menu()
	start_board()


func transition_board_to_main_menu():
	stop_board()
	start_main_menu()


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


func _on_main_menu_join_game() -> void:
	multiplayer_manager.join_game()
	transition_main_menu_to_board()


func _on_main_menu_host_game() -> void:
	multiplayer_manager.host_game()
	transition_main_menu_to_board()
