extends Node

var current_player_index: int = -1
var current_player_id: int
var turn_order: Array[int]

signal started_turn(player_id: int)
signal round_ended()


func start_turn(player_id: int):
	current_player_id = player_id
	started_turn.emit(current_player_id)


func next_turn():
	current_player_index = calculate_next_player_index()
	start_turn(turn_order[current_player_index])


func client_ended_turn(player_id: int):
	if player_id != current_player_id:
		return

	if calculate_next_player_index() == 0:
		round_ended.emit()

	next_turn()


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
	var old_current_player_id = current_player_id
	current_player_index = data["current_player_index"]
	current_player_id = data["current_player_id"]
	turn_order = data["turn_order"]

	if old_current_player_id != current_player_id:
		start_turn(current_player_id)


func remove_player(player_id: int):
	turn_order.erase(player_id)

	if current_player_id == player_id:
		current_player_index -= 1
		next_turn()


func calculate_next_player_index():
	return (current_player_index + 1) % len(turn_order)
