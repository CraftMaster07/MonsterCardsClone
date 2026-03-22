extends Node

var current_player_index: int = -1
var current_player_id: int
var turn_order: Array[int]

var round_number: int = 0

signal started_turn(player_id: int)
signal round_ended()
signal round_number_changed(new_round_number: int)


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
	shuffle_turn_order()


func shuffle_turn_order():
	randomize()
	turn_order.shuffle()


func is_player_turn(player_id: int):
	return current_player_id == player_id


func serialize():
	return {
		"current_player_index": current_player_index,
		"current_player_id": current_player_id,
		"turn_order": turn_order,
		"round_number": round_number
	}


func deserialize(data: Dictionary):
	var old_current_player_id = current_player_id
	current_player_index = data["current_player_index"]
	current_player_id = data["current_player_id"]
	turn_order = data["turn_order"]
	update_round_number(data["round_number"])

	if old_current_player_id != current_player_id:
		start_turn(current_player_id)


func remove_player(player_id: int):
	turn_order.erase(player_id)

	if current_player_id == player_id:
		current_player_index -= 1
		next_turn()


func calculate_next_player_index():
	return (current_player_index + 1) % len(turn_order)


func advance_round_number():
	update_round_number(round_number + 1)


func update_round_number(new_round_number: int):
	if new_round_number != round_number:
		round_number = new_round_number
		round_number_changed.emit(round_number)


func get_round_number():
	return round_number


func move_first_player_to_last():
	var first_player_id = turn_order[0]
	turn_order.remove_at(0)
	turn_order.append(first_player_id)


func is_last_2_players() -> bool:
	return len(turn_order) - current_player_index == 2


func get_last_player_id() -> int:
	return turn_order[-1]
