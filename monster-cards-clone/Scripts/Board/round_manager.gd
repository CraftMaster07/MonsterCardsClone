extends Node

var current_player_index: int = 0
var current_player_id: int
var turn_order: Array[int]

signal started_turn(player_id: int)
signal send_started_turn()
signal round_ended()


func start_turn(player_id: int):
	current_player_id = player_id
	print("turn: ", current_player_id)
	started_turn.emit(current_player_id)


func next_turn():
	print("turn order: ", turn_order)
	start_turn(turn_order[current_player_index])
	current_player_index = (current_player_index + 1) % len(turn_order)


func client_ended_turn(player_id: int):
	if player_id != current_player_id:
		return

	if current_player_index == 0:
		round_ended.emit()
	else:
		next_turn()
		send_started_turn.emit()


func init_turn_order(player_ids: Array[int]):
	turn_order = player_ids


func is_player_turn(player_id: int):
	return current_player_id == player_id


func serialize():
	return {
		"current_player_index": current_player_index,
		"current_player_id": current_player_id,
		"turn_order": turn_order
	}


func deserialize(data: Dictionary):
	current_player_index = data["current_player_index"]
	current_player_id = data["current_player_id"]
	turn_order = data["turn_order"]
	start_turn(current_player_id)
