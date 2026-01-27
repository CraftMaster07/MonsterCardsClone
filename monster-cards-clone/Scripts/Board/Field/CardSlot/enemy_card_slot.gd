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
		"card": card.serialize() if card else {}
	}


func deserialize(serialized_slot: Dictionary):
	if serialized_slot['card'] and card:
		card.deserialize(serialized_slot['card'])
	elif serialized_slot['card']:
		place_card(board_card_scene.instantiate())


func place_serialized_card(serialized_card: Dictionary):
	if card:
		card.deserialize(serialized_card)
	else:
		var new_card := board_card_scene.instantiate()
		new_card.deserialize(serialized_card)
		place_card(new_card)
