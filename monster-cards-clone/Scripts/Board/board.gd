class_name Board
extends Control

@onready var sfx_place: AudioStreamPlayer = $sfx_place
@onready var sfx_select: AudioStreamPlayer = $sfx_select
@onready var sfx_deselect: AudioStreamPlayer = $sfx_deselect

@export var camera_pivot: Control
@export var table: Control
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

var selected_card: HandCard = null

var players := {}
var your_id: int


func _ready() -> void:
	var table_radius: float = calculate_table_radius(len(players))
	set_radii(table_radius)

	for card in hand.get_cards():
		card.card_placed.connect(_place_card_into_slot)
		card.card_selected.connect(select_card)
		card.card_deselected.connect(deselect_card)
	
	# for slot in your_field.get_slots():
	# 	slot.clicked.connect(slot_clicked)


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
	card.tween.tween_callback(_replace_handcard_with_boardcard.bind(card))
	print("card placed")


func _replace_handcard_with_boardcard(card: HandCard):
	"""
	Replaces the HandCard with a BoardCard object
	This should be done after the card is moved into a slot
	"""
	var new_board_card := board_card_scene.instantiate()
	add_child(new_board_card) # temporary, should add underneath some container and not directly
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
		sfx_deselect.play()
		selected_card = null


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
	camera_pivot.rotate_by(TAU / len(players))


func _on_prev_player_button_pressed() -> void:
	camera_pivot.rotate_by(-TAU / len(players))


func calculate_table_radius(players_count: int) -> float:
	return DEFAULT_TABLE_RADIUS if players_count < 3 else players_count * 100.0


func set_radii(radius: float):
	table.set_radius(radius)
	camera_pivot.update_camera_radius(radius + CAMERA_ADDITIONAL_RADIUS)
	field_spawner_pivot.set_radius_and_spawn_fields(radius + FIELD_SPAWNER_ADDITIONAL_RADIUS, len(players))


func _on_field_spawner_pivot_spawning_finished() -> void:
	remove_child(field_spawner_pivot)
	field_spawner_pivot.queue_free()
