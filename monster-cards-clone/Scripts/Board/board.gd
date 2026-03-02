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

@export var board_card_scene: PackedScene

@export var current_player_label: Label

@export var round_manager: Node
@export var player_manager: PlayerManager

@onready var your_id = player_manager.your_id

var selected_card: HandCard = null
var phase: Phase = Phase.PREP

var unassigned_field_player_ids: Array

const MIN_TABLE_RADIUS: float = 400.0
const CAMERA_ADDITIONAL_RADIUS: float = -100.0
const FIELD_SPAWNER_ADDITIONAL_RADIUS: float = -100.0

signal call_sync_game(game_state: Dictionary)
signal send_placed_card(serialized_card: Dictionary, slot_id: int)
signal send_end_turn()
signal send_player_attacked(attacked_id: int)

enum ValidationResponses {INVALID = -1, OK = 0, NOT_YOUR_TURN, SLOT_TAKEN, NOT_IN_PREP}
enum Phase {PREP, COMBAT}

func _ready():
	var table_radius: float = calculate_table_radius(player_manager.get_player_count())
	set_radii(table_radius)
	spawn_fields(player_manager.get_player_count())

	for card in hand.get_cards():
		card.card_placed.connect(_place_card_into_slot)
		card.card_selected.connect(select_card)
		card.card_deselected.connect(deselect_card)

	round_manager.next_turn()
	send_game_state()

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
	var status = verify_card_placement(your_id, player_manager.get_player(your_id).get_slot_id(slot))

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
	slot.place_card(new_board_card)
	card.queue_free() # might replace with remove_child
	sfx_place.play()
	send_placed_card.emit(new_board_card.serialize(), player_manager.get_player(your_id).get_slot_id(slot))

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
	table.rotate_by(TAU / player_manager.get_original_player_count())
	sfx_spin.play()

#UI
func _on_prev_player_button_pressed() -> void:
	table.rotate_by(-TAU / player_manager.get_original_player_count())
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
	if phase != Phase.PREP:
		return
	if round_manager.is_player_turn(your_id):
		print("yo I'm ending turn")
		send_end_turn.emit()

#UI
func set_your_field(your_field: YourField):
	set_player_field(your_field, your_id)

	for slot in your_field.get_slots():
		slot.clicked.connect(slot_clicked)

#UI
func spawn_fields(players_count: int):
	unassigned_field_player_ids = player_manager.get_unassigned_field_player_ids()
	field_spawner_pivot.spawn_fields(players_count)

#UI
func _on_field_spawner_pivot_spawning_finished() -> void:
	field_spawner_pivot.queue_free()

#UI
func set_first_player_field(field: Field):
	"""
	Sets field to the first player in the list which doesn't have one.
	"""
	set_player_field(field, unassigned_field_player_ids[0])
	unassigned_field_player_ids.remove_at(0)

#UI
func _on_field_spawner_pivot_new_field_spawned(field: Field) -> void:
	table.add_child(field)

	if is_instance_of(field, YourField):
		set_your_field(field)
	else:
		set_first_player_field(field)

#BOARD? need to split this to rounds and players/ui
func verify_card_placement(player_id: int, slot_id: int) -> ValidationResponses:
	if not round_manager.is_player_turn(player_id):
		return ValidationResponses.NOT_YOUR_TURN

	if player_manager.get_player(player_id).is_slot_taken(slot_id):
		return ValidationResponses.SLOT_TAKEN

	if phase != Phase.PREP:
		return ValidationResponses.NOT_IN_PREP

	return ValidationResponses.OK

#BOARD
func client_placed_card(player_id: int, serialized_card: Dictionary, slot_id: int):
	var status := verify_card_placement(player_id, slot_id)
	match status:
		ValidationResponses.OK:
			if player_id != 1:
				player_manager.get_player(player_id).place_serialized_card_into_slot(serialized_card, slot_id)
		ValidationResponses.SLOT_TAKEN:
			print("slot taken: (Player: ", player_id, ", Slot: ", slot_id, ")")
		ValidationResponses.NOT_YOUR_TURN:
			print("not his turn (Player: ", player_id, ")")
		ValidationResponses.NOT_IN_PREP:
			print("not in prep phase (Player: ", player_id, ")")
		ValidationResponses.INVALID:
			print("unexpected error occured (Player: ", player_id, ", Slot: ", slot_id, ")")

	send_game_state()


#BOARD
func send_game_state():
	call_sync_game.emit(get_game_state())

#BOARD
func get_game_state() -> Dictionary:
	return {"players": player_manager.serialize_players(),
			"round_manager": round_manager.serialize(),
			"phase": phase}
	# add last_action for animations

#BOARD
func set_game_state(game_state: Dictionary):
	# TODO: finish TS
	player_manager.deserialize_players(game_state['players'])
	round_manager.deserialize(game_state['round_manager'])
	phase = game_state['phase']


func client_ended_turn(player_id: int):
	round_manager.client_ended_turn(player_id)
	send_game_state()

func _on_round_manager_started_turn(player_id: int) -> void:
	current_player_label.text = player_manager.get_player(player_id).player_name + "'s turn"


func init_players(multiplayer_players: Array):
	player_manager.init_players(multiplayer_players)
	round_manager.init_turn_order(player_manager.get_player_ids())


func set_player_field(field: Field, player_id: int):
	player_manager.set_player_field(field, player_id)


func set_your_id(id: int):
	player_manager.set_your_id(id)
	your_id = id


func _on_round_manager_round_ended() -> void:
	if phase == Phase.COMBAT:
		player_manager.reset_attack_history()
		exorcise()
		phase = Phase.PREP
	else:
		phase = Phase.COMBAT
	send_game_state()


func _on_player_manager_player_attacked(player_id: int) -> void:
	if phase != Phase.COMBAT:
		return
	send_player_attacked.emit(player_id)


func client_attacked(player_id: int, attacked_id: int):
	if phase != Phase.COMBAT:
		return
	if player_id != round_manager.current_player_id:
		return

	var err: Error = player_manager.do_player_attack(player_id, attacked_id)
	if err != Error.OK:
		return

	combat(player_id, attacked_id)

	round_manager.client_ended_turn(player_id)
	send_game_state()


func combat(attacker_id: int, attacked_id: int):
	var attacker := player_manager.get_player(attacker_id)
	var attacked := player_manager.get_player(attacked_id)

	var attacker_field := attacker.get_field()
	var attacked_field := attacked.get_field()

	for i in range(attacker_field.get_slot_count()):
		var attacker_card = attacker_field.get_card(i)
		var attacked_card = attacked_field.get_card(i)

		if not attacker_card:
			continue
		elif not attacked_card:
			attacker_card.hit(attacked)
		else:
			attacker_card.hit(attacked_card)


func exorcise():
	player_manager.exorcise()


func remove_player(player_id: int):
	player_manager.remove_player(player_id)
	round_manager.remove_player(player_id)
	send_game_state()
