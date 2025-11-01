class_name Board
extends Control

@onready var hand := $Hand
@onready var card_slot_container := $CardSlotContainer
@export var card_board_scene: PackedScene
@onready var sfx_place: AudioStreamPlayer = $sfx_place
@onready var sfx_select: AudioStreamPlayer = $sfx_select
@onready var sfx_deselect: AudioStreamPlayer = $sfx_deselect

var selected_card: HandCard = null

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
	"""Marks the slot as taken, and starts the animation to move the card into the slot"""
	slot.take()
	card.goto_slot(slot)
	card.tween.tween_callback(_replace_handcard_with_boardcard.bind(card))
	sfx_place.play()
	print("card placed")


func _replace_handcard_with_boardcard(card: HandCard):
	"""
	Replaces the HandCard with a BoardCard object
	This should be done after the card is moved into a slot
	"""
	var new_card_board := card_board_scene.instantiate()
	add_child(new_card_board) #temporary, should add underneath some container and not directly
	new_card_board.global_position = card.card_front.global_position
	card.queue_free()


func select_card(card: HandCard):
	if selected_card != null and selected_card != card:
		var old_card = selected_card
		selected_card = null
		old_card.deselect()
	selected_card = card
	sfx_select.play()
	print("card selected")


func deselect_card():
	if selected_card != null:
		sfx_deselect.play()
		selected_card = null
		print("card deselected")
