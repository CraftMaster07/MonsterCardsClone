class_name EnemyCardSlot
extends Control

@export var board_card_scene: PackedScene

var card: BoardCard


func take():
	push_error("take() not implemented")


func is_taken():
	return card != null


func place_card(new_card: BoardCard):
	card = new_card
	add_child(card)
	card.position = Vector2.ZERO


func serialize():
	return {
		"card": card.serialise() if card else {}
	}


func deserialise(serialised_slot: Dictionary):
	if serialised_slot['card'] and card:
		card.deserialise(serialised_slot['card'])
	elif serialised_slot['card']:
		place_card(board_card_scene.instantiate())


func place_serialised_card(serialised_card: Dictionary):
	if card:
		card.deserialise(serialised_card)
	else:
		var new_card := board_card_scene.instantiate()
		new_card.deserialise(serialised_card)
		place_card(new_card)
