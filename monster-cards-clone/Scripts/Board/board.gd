class_name Board
extends Control

@onready var sfx_place: AudioStreamPlayer = $sfx_place
@onready var sfx_select: AudioStreamPlayer = $sfx_select
@onready var sfx_deselect: AudioStreamPlayer = $sfx_deselect
@onready var sfx_spin: AudioStreamPlayer = $sfx_spin

@export var table: Table
@export var field_spawner_pivot: Control
@export var hand: MarginContainer

@export var next_player_button: Button
@export var prev_player_button: Button

@export var board_card_scene: PackedScene
@export var your_player_scene: PackedScene
@export var enemy_player_scene: PackedScene

const DEFAULT_TABLE_RADIUS: float = 500.0
const CAMERA_ADDITIONAL_RADIUS: float = -100.0
const FIELD_SPAWNER_ADDITIONAL_RADIUS: float = -100.0

signal call_sync_game(game_state: Dictionary)

var selected_card: HandCard = null

var players := {}
var your_id: int

var unassigned_field_players: Array

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


func slot_clicked(slot: EnemyCardSlot):
	print("slot clicked")

	if selected_card != null:
		print("placing card")
		_place_card_into_slot(selected_card, slot)


func _place_card_into_slot(card: HandCard, slot: EnemyCardSlot):
	"""
	Marks the slot as taken, and starts the animation to move the card into the slot
	"""
	slot.take()
	card.goto_slot(slot)
	card.tween.tween_callback(_replace_handcard_with_boardcard.bind(card, slot))
	print("card placed")


func _replace_handcard_with_boardcard(card: HandCard, slot: EnemyCardSlot):
	"""
	Replaces the HandCard with a BoardCard object
	This should be done after the card is moved into a slot
	"""
	var new_board_card := board_card_scene.instantiate()
	slot.add_child(new_board_card) # probably shouldnt add as child of slot itself
	new_board_card.global_position = card.card_front.global_position
	card.queue_free()
	sfx_place.play()


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


func init_players(multiplayer_players: Array):
	for player_data in multiplayer_players:
		if player_data['id'] == your_id:
			init_your_player(player_data)
		else:
			init_enemy_player(player_data)

	print("players initialized", players)


func init_enemy_player(player_data: Dictionary):
	var new_player: Player = enemy_player_scene.instantiate()
	new_player.init(player_data['id'], player_data['name'])
	add_child(new_player)
	players[player_data['id']] = new_player


func init_your_player(player_data: Dictionary):
	var new_player: Player = your_player_scene.instantiate()
	new_player.init(player_data['id'], player_data['name'])
	add_child(new_player)
	players[player_data['id']] = new_player


func set_your_id(id: int):
	your_id = id


func remove_player(id: int):
	remove_child(players[id])
	players[id].queue_free()
	players.erase(id)


func _on_next_player_button_pressed() -> void:
	table.rotate(TAU / len(players))
	sfx_spin.play()


func _on_prev_player_button_pressed() -> void:
	table.rotate(-TAU / len(players))
	sfx_spin.play()


func set_your_field(your_field: YourField):
	set_player_field(your_field, players[your_id])

	for slot in your_field.get_slots():
		slot.clicked.connect(slot_clicked)


func spawn_fields(players_count: int):
	init_unassigned_field_players()
	field_spawner_pivot.spawn_fields(players_count)


func calculate_table_radius(players_count: int) -> float:
	return DEFAULT_TABLE_RADIUS if players_count < 3 else players_count * 100.0


func set_radii(radius: float):
	table.global_position.y -= radius + CAMERA_ADDITIONAL_RADIUS
	table.set_radius(radius)
	field_spawner_pivot.set_radius(radius + FIELD_SPAWNER_ADDITIONAL_RADIUS)


func _on_field_spawner_pivot_spawning_finished() -> void:
	#field_spawner_pivot.queue_free()
	pass


func send_game_state():
	call_sync_game.emit(get_game_state())


func get_game_state() -> Dictionary:
	return {"players": players, }


func set_game_state(game_state: Dictionary):
	# TODO: finish TS
	players = game_state['players']
	print("players set", players)


func _on_sync_button_pressed() -> void:
	send_game_state()


func get_fields_data():
	for player in players.values():
		return player.get_fields_data()


func init_unassigned_field_players():
	for player in players.values():
		if player.player_id == your_id:
			continue

		if player.get_field() == null:
			unassigned_field_players.append(player)


func set_player_field(field: Field, player: Player):
	player.set_field(field)


func set_first_player_field(field: Field):
	"""
	Sets field to the first player in the list which doesn't have one.
	"""
	set_player_field(field, unassigned_field_players[0])
	unassigned_field_players.remove_at(0)


func _on_field_spawner_pivot_new_field_spawned(field: Field) -> void:
	table.add_child(field)
	print("New field added at pos ", field.global_position)

	if is_instance_of(field, YourField):
		set_your_field(field)
	else:
		set_first_player_field(field)
