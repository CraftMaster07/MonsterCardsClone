class_name Board
extends Control

@onready var sfx_place: AudioStreamPlayer = $sfx_place
@onready var sfx_select: AudioStreamPlayer = $sfx_select
@onready var sfx_deselect: AudioStreamPlayer = $sfx_deselect
@onready var sfx_spin: AudioStreamPlayer = $sfx_spin
@onready var sfx_wrong: AudioStreamPlayer = $sfx_wrong

@export var table: Table
@export var player_area_spawner_pivot: ObjectPivot
@export var turn_pointer: ObjectPivot

@export var next_player_button: Button
@export var prev_player_button: Button

@export var current_player_label: Label
@export var round_number_label: Label

@export var round_manager: Node
@export var player_manager: PlayerManager

@onready var your_id = player_manager.your_id

var selected_card: HandCard = null
var phase: Phase = Phase.PREP

var player_ids_without_deck_blueprint: Array
var unassigned_area_player_ids: Array

var deck_file: DeckFile

const MIN_TABLE_RADIUS: float = 250.0
const CAMERA_ADDITIONAL_RADIUS: float = -100.0
const PLAYER_AREA_SPAWNER_ADDITIONAL_RADIUS: float = -100.0

const INITIAL_HAND_CARD_COUNT: int = 3
const INITIAL_DECK_CARD_COUNT: int = 5 + INITIAL_HAND_CARD_COUNT

signal send_placed_card(serialized_card: Dictionary, slot_id: int)
signal send_end_turn()
signal send_player_attacked(attacked_id: int)

enum ValidationResponses {
		INVALID = -1,
		OK = 0,
		NOT_YOUR_TURN,
		SLOT_TAKEN,
		NOT_IN_PREP,
		NOT_ENOUGH_MANA
	}
enum CombatValidationResponses {
		INVALID = -1,
		OK = 0,
		NOT_YOUR_TURN,
		NOT_IN_COMBAT,
		ATTACK_FAILED,
		MUST_ATTACK_LAST_PLAYER
}
enum Phase {PREP, COMBAT}

func _ready():
	var table_radius: float = calculate_table_radius(player_manager.get_player_count())
	set_radii(table_radius)
	spawn_player_areas(player_manager.get_player_count())


func connect_card(card: HandCard):
	card.card_placed.connect(_place_card_into_slot)
	card.card_selected.connect(select_card)
	card.card_deselected.connect(deselect_card)


func slot_clicked(slot: CardSlot):
	if selected_card != null:
		print("placing card")
		_place_card_into_slot(selected_card, slot)


func _place_card_into_slot(card: HandCard, slot: CardSlot):
	"""
	Marks the slot as taken, and starts the animation to move the card into the slot
	"""
	var status = verify_card_placement(your_id, player_manager.get_slot_id(your_id, slot), card.card_data)

	if status != ValidationResponses.OK:
		slot.flash_color()
		sfx_wrong.play()
		card.go_back_to_hand()
		print("invalid placement, status code:", status)
		return

	player_manager.spend_mana(your_id, card.get_cost())
	slot.take()
	card.goto_slot(slot)
	card.tween.tween_callback(_replace_handcard_with_boardcard.bind(card, slot))
	print("card placed")


func _replace_handcard_with_boardcard(card: HandCard, slot: CardSlot):
	"""
	Replaces the HandCard with a BoardCard object
	This should be done after the card is moved into a slot
	"""
	var new_board_card := BoardCard.create(card.card_data)
	slot.place_card(new_board_card)
	card.queue_free() # might replace with remove_child
	sfx_place.play()
	send_placed_card.emit(new_board_card.serialize(), player_manager.get_slot_id(your_id, slot))


func select_card(card: HandCard):
	if selected_card != null and selected_card != card:
		var old_card = selected_card
		selected_card = null
		old_card.deselect()

	selected_card = card
	sfx_select.play()


func deselect_card():
	if selected_card != null:
		selected_card = null
		sfx_deselect.play()


func _on_next_player_button_pressed() -> void:
	table.rotate_by(TAU / player_manager.get_original_player_count())
	sfx_spin.play()


func _on_prev_player_button_pressed() -> void:
	table.rotate_by(-TAU / player_manager.get_original_player_count())
	sfx_spin.play()


func calculate_table_radius(players_count: int) -> float:
	return max(MIN_TABLE_RADIUS, players_count * 70.0)


func set_radii(radius: float):
	table.global_position.y -= radius + CAMERA_ADDITIONAL_RADIUS
	table.set_radius(radius)
	player_area_spawner_pivot.set_radius(radius + PLAYER_AREA_SPAWNER_ADDITIONAL_RADIUS)


func _on_end_turn_pressed() -> void:
	if phase != Phase.PREP:
		return

	if round_manager.is_player_turn(your_id):
		send_end_turn.emit()

func spawn_player_areas(players_count: int):
	unassigned_area_player_ids = player_manager.get_unassigned_area_player_ids()
	player_area_spawner_pivot.spawn_player_areas(players_count)


func _on_player_area_spawner_pivot_new_area_spawned(new_player_area: PlayerArea) -> void:
	table.add_child(new_player_area)

	if is_instance_of(new_player_area, YourPlayerArea):
		print("your area spawned, id: ", your_id)
		set_your_area(new_player_area)
	else:
		set_first_player_area(new_player_area)


func _on_player_area_spawner_pivot_spawning_finished() -> void:
	player_area_spawner_pivot.queue_free()


func set_first_player_area(player_area: PlayerArea):
	var player_id = unassigned_area_player_ids[0]
	
	set_player_area(player_area, player_id)
	set_player_field(player_area.get_field(), player_id)
	set_player_deck(player_area.get_deck(), player_id)
	set_player_hand(player_area.get_hand(), player_id)

	unassigned_area_player_ids.remove_at(0)


func set_your_id(id: int):
	player_manager.set_your_id(id)
	your_id = id


func set_your_field(your_field: YourField):
	set_player_field(your_field, your_id)

	for slot in your_field.get_slots():
		slot.clicked.connect(slot_clicked)


func set_your_hand(your_hand: YourHand):
	set_player_hand(your_hand, your_id)
	your_hand.new_card_added.connect(connect_card)


func set_your_area(player_area: PlayerArea):
	set_player_area(player_area, your_id)
	set_your_field(player_area.get_field())
	set_player_deck(player_area.get_deck(), your_id)
	set_your_hand(player_area.get_hand())


func set_player_area(area: PlayerArea, player_id: int):
	player_manager.set_player_area(area, player_id)


func set_player_field(field: Field, player_id: int):
	player_manager.set_player_field(field, player_id)


func set_player_deck(deck: Deck, player_id: int):
	player_manager.set_player_deck(deck, player_id)


func set_player_hand(hand: Hand, player_id: int):
	player_manager.set_player_hand(hand, player_id)


func verify_card_placement(
		player_id: int,
		slot_id: int,
		card_data: CardData
	) -> ValidationResponses:
	if not round_manager.is_player_turn(player_id):
		return ValidationResponses.NOT_YOUR_TURN

	if player_manager.get_player(player_id).is_slot_taken(slot_id):
		return ValidationResponses.SLOT_TAKEN

	if phase != Phase.PREP:
		return ValidationResponses.NOT_IN_PREP
	
	if not player_manager.can_spend_mana(player_id, card_data.cost):
		return ValidationResponses.NOT_ENOUGH_MANA

	return ValidationResponses.OK


func set_game_state(game_state: Dictionary):
	# TODO: finish TS
	player_manager.deserialize(game_state['players'])
	round_manager.deserialize(game_state['round_manager'])
	phase = game_state['phase']


func _on_round_manager_started_turn(player_id: int) -> void:
	current_player_label.text = player_manager.get_player(player_id).player_name + "'s turn"
	turn_pointer.animate_rotation_to(player_manager.get_area_rotation(player_id))


func init_players(multiplayer_players: Array):
	player_manager.init_players(multiplayer_players)
	round_manager.init_turn_order(player_manager.get_player_ids())


func _on_round_manager_round_ended() -> void:
	if phase == Phase.COMBAT:
		player_manager.reset_attack_history()
		exorcise()
		phase = Phase.PREP
		round_manager.advance_round_number()
	else:
		phase = Phase.COMBAT


func _on_player_manager_player_attacked(player_id: int) -> void:
	if phase != Phase.COMBAT:
		return
	send_player_attacked.emit(player_id)


func verify_attack(attacker_id: int, attacked_id: int) -> CombatValidationResponses:
	if phase != Phase.COMBAT:
		return CombatValidationResponses.NOT_IN_COMBAT

	if attacker_id != round_manager.current_player_id:
		return CombatValidationResponses.NOT_YOUR_TURN
	
	var last_player_id: int = round_manager.get_last_player_id()

	if check_must_attack_last_player(last_player_id) and attacked_id != last_player_id:
		return CombatValidationResponses.MUST_ATTACK_LAST_PLAYER

	var err: Error = player_manager.record_player_attack(attacker_id, attacked_id)
	if err != Error.OK:
		return CombatValidationResponses.ATTACK_FAILED

	return CombatValidationResponses.OK


func check_must_attack_last_player(last_player_id: int) -> bool:
	"""
	Checks that there are only 2 players left and that the last player was not attacked.
	"""
	return round_manager.is_last_2_players() and not check_last_player_was_attacked(last_player_id)


func check_last_player_was_attacked(last_player_id: int) -> bool:
	return player_manager.check_was_attacked(last_player_id)


func exorcise():
	player_manager.exorcise()


func remove_player(player_id: int):
	player_manager.remove_player(player_id)
	round_manager.remove_player(player_id)


func get_deck_blueprint() -> Dictionary:
	var serialized_card_datas = []

	for file_name in deck_file.cards:
		var path = PathConstants.CARD_SAVE_PATH + file_name + ".json"
		var card_file = CardFile.new()
		card_file.load(path)
		for i in range(deck_file.cards[file_name]):
			var card_data = CardData.create_from_card_file(card_file)
			serialized_card_datas.append(card_data.serialize())

	return {"card_datas": serialized_card_datas}


func shadow_sync(serialized_shadow_player_data: Dictionary):
	player_manager.shadow_deserialize(serialized_shadow_player_data)


func _on_round_manager_round_number_changed(new_round_number: int) -> void:
	round_number_label.text = "Round " + str(new_round_number)


func set_deck_file(deck: DeckFile):
	deck_file = deck