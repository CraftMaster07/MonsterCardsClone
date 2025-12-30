class_name Board
extends Control

@onready var camera_pivot: Control = $Table/CameraPivot
@onready var card_slot_container: MarginContainer = $Table/CardSlotContainer
@export var board_card_scene: PackedScene
@onready var hand: MarginContainer = $Table/CameraPivot/CanvasLayer/Hand

@onready var next_player_button: Button = $Table/CameraPivot/CanvasLayer/NextPlayerButton
@onready var prev_player_button: Button = $Table/CameraPivot/CanvasLayer/PrevPlayerButton

@onready var sfx_place: AudioStreamPlayer = $sfx_place
@onready var sfx_select: AudioStreamPlayer = $sfx_select
@onready var sfx_deselect: AudioStreamPlayer = $sfx_deselect

var selected_card: HandCard = null

var players := {}

func _ready() -> void:
	for card in hand.get_cards():
		card.card_placed.connect(_place_card_into_slot)
		card.card_selected.connect(select_card)
		card.card_deselected.connect(deselect_card)
	
	for slot in card_slot_container.get_slots():
		slot.clicked.connect(slot_clicked)


func slot_clicked(slot: CardSlot):
	if selected_card != null:
		_place_card_into_slot(selected_card, slot)


func _place_card_into_slot(card: HandCard, slot: CardSlot):
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
	add_child(new_board_card) #temporary, should add underneath some container and not directly
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
	for multiplayer_player in multiplayer_players:
		init_player(multiplayer_player)
	print("players initialized", players)


func init_player(multiplayer_player: Dictionary):
	players[multiplayer_player['id']] = Player.new(
		multiplayer_player['id'],
		multiplayer_player['name'],
	)


func _on_next_player_button_pressed() -> void:
	camera_pivot.rotate_by(TAU / 2)


func _on_prev_player_button_pressed() -> void:
	camera_pivot.rotate_by(-TAU / 2)
