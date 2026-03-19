extends Node

@onready var multiplayer_manager: MultiplayerManager = $MultiplayerManager
@onready var main_menu = $MainMenu
@export var waiting_room_scene: PackedScene
@export var board_scene: PackedScene
@export var host_board_scene: PackedScene
@export var card_creator_scene: PackedScene

var waiting_room: WaitingRoom = null
var board: Board = null
var card_creator = null


func transition_board_to_main_menu():
	stop_board()
	start_main_menu()


func transition_main_menu_to_waiting_room():
	stop_main_menu()
	start_waiting_room()


func transition_waiting_room_to_board():
	stop_waiting_room()
	start_board()


func transition_waiting_room_to_main_menu():
	stop_waiting_room()
	start_main_menu()


func transition_main_menu_to_card_creator():
	stop_main_menu()
	start_card_creator()


func transition_card_creator_to_main_menu():
	stop_card_creator()
	start_main_menu()


func start_card_creator():
	card_creator = card_creator_scene.instantiate()
	card_creator.leave.connect(transition_card_creator_to_main_menu)
	add_child(card_creator)


func stop_card_creator():
	remove_child(card_creator)
	card_creator.queue_free()


func start_waiting_room():
	waiting_room = waiting_room_scene.instantiate()
	waiting_room.start_game.connect(start_game_as_host)
	waiting_room.new_bot.connect(add_bot)
	waiting_room.leave.connect(leave_waiting_room)
	add_child(waiting_room)


func stop_waiting_room():
	remove_child(waiting_room)
	waiting_room.queue_free()


func start_board():
	if multiplayer.is_server():
		board = host_board_scene.instantiate()
		board.call_sync_game.connect(call_sync_game)
		board.request_deck_blueprints.connect(_on_board_request_deck_blueprints)
		board.call_shadow_sync.connect(_on_board_call_shadow_sync)
	else:
		board = board_scene.instantiate()
	
	board.set_your_id(multiplayer_manager.your_id)
	board.init_players(multiplayer_players_to_dicts(multiplayer_manager.players))
	board.send_placed_card.connect(_on_board_send_placed_card)
	board.send_end_turn.connect(_on_end_turn_pressed)
	board.send_player_attacked.connect(_on_board_player_attacked)
	add_child(board)
	

func stop_board():
	remove_child(board)
	board.queue_free()


func start_main_menu():
	main_menu.reinitialize()
	add_child(main_menu)


func stop_main_menu():
	remove_child(main_menu)


func _on_main_menu_join_game(player_name: String, ip: String) -> void:
	multiplayer_manager.join_game(player_name, ip)


func _on_main_menu_host_game(player_name: String) -> void:
	transition_main_menu_to_waiting_room()
	waiting_room.allow_starting_game()
	multiplayer_manager.host_game(player_name)


func _on_multiplayer_manager_new_player(id: int, player_name: String) -> void:
	if waiting_room:
		waiting_room.add_player(id, player_name)


func _on_multiplayer_manager_connection_success() -> void:
	transition_main_menu_to_waiting_room()


func _on_multiplayer_manager_connection_failure() -> void:
	print("Cannot connect to server.")


func _on_multiplayer_manager_player_left(id: int) -> void:
	if waiting_room:
		waiting_room.remove_player(id)
	elif board:
		board.remove_player(id)


func _on_multiplayer_manager_server_disconnected() -> void:
	transition_waiting_room_to_main_menu()
	print("Host disconnected.")


func _on_multiplayer_manager_start_game() -> void:
	transition_waiting_room_to_board()


func leave_waiting_room():
	transition_waiting_room_to_main_menu()
	multiplayer_manager.leave_game()


func start_game_as_host():
	multiplayer_manager.start_game_as_host()


func add_bot(id: int, bot_name: String):
	multiplayer_manager.add_new_player(id, bot_name)


func multiplayer_players_to_dicts(
	multiplayer_players: Dictionary
) -> Array:
	# we don't want board to know what is a MultiplayerPlayer, so we convert them to dictionaries.
	var dicts := []

	for multiplayer_player in multiplayer_players.values():
		dicts.append(multiplayer_player_to_dict(multiplayer_player))

	return dicts


func multiplayer_player_to_dict(multiplayer_player: MultiplayerPlayer) -> Dictionary:
	return {
		"id": multiplayer_player.player_id,
		"name": multiplayer_player.player_name
	}


func _on_multiplayer_manager_sync_game(game_state: Dictionary) -> void:
	board.set_game_state(game_state)


func call_sync_game(game_state: Dictionary) -> void:
	multiplayer_manager.call_sync_game(game_state)


func _on_board_send_placed_card(serialized_card: Dictionary, slot_id: int) -> void:
	multiplayer_manager.send_placed_card(serialized_card, slot_id)


func _on_multiplayer_manager_client_placed_card(
	player_id: int, serialized_card: Dictionary, slot_id: int
) -> void:
	board.client_placed_card(player_id, serialized_card, slot_id)


func _on_end_turn_pressed() -> void:
	multiplayer_manager.send_end_turn()


func _on_multiplayer_manager_client_ended_turn(player_id: int) -> void:
	board.client_ended_turn(player_id)


func _on_board_player_attacked(attacked_id: int) -> void:
	multiplayer_manager.send_player_attacked(attacked_id)


func _on_multiplayer_manager_client_attacked(player_id: int, attacked_id: int) -> void:
	board.client_attacked(player_id, attacked_id)


func _on_board_request_deck_blueprints() -> void:
	multiplayer_manager.request_deck_blueprints()


func _on_multiplayer_manager_received_deck_blueprint(player_id: int, deck_blueprint: Dictionary) -> void:
	board.client_deck_blueprint_received(player_id, deck_blueprint)


func _on_multiplayer_manager_get_deck_blueprint() -> void:
	var deck_blueprint := board.get_deck_blueprint()
	multiplayer_manager.send_deck_blueprint(deck_blueprint)


func _on_board_call_shadow_sync(player_id: int, serialized_shadow_player_data: Dictionary) -> void:
	multiplayer_manager.send_shadow_sync(player_id, serialized_shadow_player_data)

func _on_multiplayer_manager_shadow_sync(serialized_shadow_player_data: Dictionary) -> void:
	board.shadow_sync(serialized_shadow_player_data)


func _on_main_menu_goto_card_creator() -> void:
	transition_main_menu_to_card_creator()
