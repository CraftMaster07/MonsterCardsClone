class_name Board
extends Control

@onready var sfx_place: AudioStreamPlayer = $sfx_place
@onready var sfx_select: AudioStreamPlayer = $sfx_select
@onready var sfx_deselect: AudioStreamPlayer = $sfx_deselect
@onready var sfx_spin: AudioStreamPlayer = $sfx_spin
@onready var sfx_wrong: AudioStreamPlayer = $sfx_wrong

@export var table: Table
@export var field_spawner_pivot: Control
@export var hand: MarginContainer

@export var next_player_button: Button
@export var prev_player_button: Button
@export var spin_charge_timer: Timer

@export var board_card_scene: PackedScene
@export var your_player_scene: PackedScene
@export var enemy_player_scene: PackedScene

@export var current_player_label: Label

@export var round_manager: Node

var selected_card: HandCard = null

var players: Dictionary[int, Player] = {}
var your_id: int

var unassigned_field_players: Array

const MIN_TABLE_RADIUS: float = 400.0
const CAMERA_ADDITIONAL_RADIUS: float = -100.0
const FIELD_SPAWNER_ADDITIONAL_RADIUS: float = -100.0

signal call_sync_game(game_state: Dictionary)
signal send_placed_card(serialized_card: Dictionary, slot_id: int)
signal send_end_turn()

enum ValidationResponses {INVALID = -1, OK = 0, NOT_YOUR_TURN, SLOT_TAKEN}

func _ready() -> void:
	var table_radius: float = calculate_table_radius(len(players))
	set_radii(table_radius)
	spawn_fields(len(players))

	for card in hand.get_cards():
		card.card_placed.connect(_place_card_into_slot)
		card.card_selected.connect(select_card)
		card.card_deselected.connect(deselect_card)

	#TODO: obviously delete this when putting real syncing. WTH IS TS
	if multiplayer.is_server():
		$UI/SyncButton.visible = true
		$UI/SyncButton.process_mode = Node.PROCESS_MODE_INHERIT

	round_manager.next_turn()

#UI
func slot_clicked(slot: EnemyCardSlot):
	if selected_card != null:
		print("placing card")
		_place_card_into_slot(selected_card, slot)

#UI
func _place_card_into_slot(card: HandCard, slot: EnemyCardSlot):
	"""
	Marks the slot as taken, and starts the animation to move the card into the slot
	"""
	var status = verify_card_placement(your_id, players[your_id].get_slot_id(slot))

	if status != ValidationResponses.OK:
		slot.flash_color()
		sfx_wrong.play()
		card.go_back_to_hand()
		print("invalid placement, status code:", status)
		return

	slot.take()
	card.goto_slot(slot)
	card.tween.tween_callback(_replace_handcard_with_boardcard.bind(card, slot))
	print("card placed")

#UI
func _replace_handcard_with_boardcard(card: HandCard, slot: EnemyCardSlot):
	"""
	Replaces the HandCard with a BoardCard object
	This should be done after the card is moved into a slot
	"""
	var new_board_card := board_card_scene.instantiate()
	send_placed_card.emit(new_board_card.serialize(), players[your_id].get_slot_id(slot))
	slot.place_card(new_board_card)
	card.queue_free() # might replace with remove_child
	sfx_place.play()

#UI
func select_card(card: HandCard):
	if selected_card != null and selected_card != card:
		var old_card = selected_card
		selected_card = null
		old_card.deselect()

	selected_card = card
	sfx_select.play()

#UI
func deselect_card():
	if selected_card != null:
		selected_card = null
		sfx_deselect.play()

#UI
func _on_next_player_button_pressed() -> void:
	table.rotate_by(TAU / len(players))
	sfx_spin.play()

#UI
func _on_prev_player_button_pressed() -> void:
	table.rotate_by(-TAU / len(players))
	sfx_spin.play()

#UI?
func calculate_table_radius(players_count: int) -> float:
	return max(MIN_TABLE_RADIUS, players_count * 70.0)

#UI?
func set_radii(radius: float):
	table.global_position.y -= radius + CAMERA_ADDITIONAL_RADIUS
	table.set_radius(radius)
	field_spawner_pivot.set_radius(radius + FIELD_SPAWNER_ADDITIONAL_RADIUS)

#UI
func _on_end_turn_pressed() -> void:
	if round_manager.is_player_turn(your_id):
		print("yo I'm ending turn")
		send_end_turn.emit()

#UI
func set_your_field(your_field: YourField):
	set_player_field(your_field, players[your_id])

	for slot in your_field.get_slots():
		slot.clicked.connect(slot_clicked)

#UI
func spawn_fields(players_count: int):
	init_unassigned_field_players()
	field_spawner_pivot.spawn_fields(players_count)

#UI
func _on_field_spawner_pivot_spawning_finished() -> void:
	field_spawner_pivot.queue_free()

#UI
func set_first_player_field(field: Field):
	"""
	Sets field to the first player in the list which doesn't have one.
	"""
	set_player_field(field, unassigned_field_players[0])
	unassigned_field_players.remove_at(0)

#UI
func _on_field_spawner_pivot_new_field_spawned(field: Field) -> void:
	table.add_child(field)

	if is_instance_of(field, YourField):
		set_your_field(field)
	else:
		set_first_player_field(field)

#PLAYERS
func init_players(multiplayer_players: Array):
	for player_data in multiplayer_players:
		if player_data['id'] == your_id:
			init_your_player(player_data)
		else:
			init_enemy_player(player_data)

	round_manager.init_turn_order(players.keys())

#PLAYERS
func init_enemy_player(player_data: Dictionary):
	var new_player: Player = enemy_player_scene.instantiate()
	new_player.init(player_data['id'], player_data['name'])
	add_child(new_player)
	players[player_data['id']] = new_player

#PLAYERS
func init_your_player(player_data: Dictionary):
	var new_player: Player = your_player_scene.instantiate()
	new_player.init(player_data['id'], player_data['name'])
	add_child(new_player)
	players[player_data['id']] = new_player

#PLAYERS
func remove_player(id: int):
	remove_child(players[id])
	players[id].queue_free()
	players.erase(id)

#PLAYERS
func serialize_players():
	var serialized_players := {}

	for player in players.values():
		serialized_players[player.player_id] = (player.serialize())

	return serialized_players

#PLAYERS
func deserialize_players(serialized_players: Dictionary):
	for serialized_player_id in serialized_players:
		players[serialized_player_id].deserialize(serialized_players[serialized_player_id])

#PLAYERS
func init_unassigned_field_players():
	for player in players.values():
		if player.player_id == your_id:
			continue

		if player.get_field() == null:
			unassigned_field_players.append(player)

#PLAYERS
func set_player_field(field: Field, player: Player):
	player.set_field(field)

#PLAYERS
func set_your_id(id: int):
	your_id = id

#BOARD? need to split this to rounds and players/ui
func verify_card_placement(player_id: int, slot_id: int) -> ValidationResponses:
	if not round_manager.is_player_turn(player_id):
		return ValidationResponses.NOT_YOUR_TURN

	if players[player_id].is_slot_taken(slot_id):
		return ValidationResponses.SLOT_TAKEN

	return ValidationResponses.OK

#BOARD
func client_placed_card(player_id: int, serialized_card: Dictionary, slot_id: int):
	var status := verify_card_placement(player_id, slot_id)
	match status:
		ValidationResponses.OK:
			players[player_id].place_serialized_card_into_slot(serialized_card, slot_id)
		ValidationResponses.SLOT_TAKEN:
			print("slot taken: (Player: ", player_id, ", Slot: ", slot_id, ")")
		ValidationResponses.NOT_YOUR_TURN:
			print("not his turn (Player: ", player_id, ")")
		ValidationResponses.INVALID:
			print("unexpected error occured (Player: ", player_id, ", Slot: ", slot_id, ")")

	send_game_state()

#BOARD
func _on_sync_button_pressed() -> void:
	send_game_state()

#BOARD
func send_game_state():
	call_sync_game.emit(get_game_state())

#BOARD
func get_game_state() -> Dictionary:
	return {"players": serialize_players(), "round_manager": round_manager.serialize()}
	# add last_action for animations

#BOARD
func set_game_state(game_state: Dictionary):
	# TODO: finish TS
	deserialize_players(game_state['players'])
	round_manager.deserialize(game_state['round_manager'])


func _on_round_manager_send_started_turn() -> void:
	send_game_state()


func client_ended_turn(player_id: int):
	round_manager.client_ended_turn(player_id)


func _on_round_manager_started_turn(player_id: int) -> void:
	current_player_label.text = players[player_id].player_name + "'s turn"
