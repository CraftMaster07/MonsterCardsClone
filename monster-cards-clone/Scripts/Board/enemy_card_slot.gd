class_name EnemyCardSlot
extends Control

@export var board_card_scene: PackedScene

@onready var slot_area = $SlotArea
var card: BoardCard


func place_card(new_card: BoardCard):
	card = new_card
	add_child(card)
	card.position = Vector2.ZERO


func serialize():
	return {
		"card": card.serialise() if card else null
	}


func deserialise(serialised_slot: Dictionary):
	if serialised_slot['card'] and card:
		card.deserialise(serialised_slot['card'])
	elif serialised_slot['card']:
		place_card(board_card_scene.instantiate())
	
	_deserialise(serialised_slot)


func _deserialise(_serialised_slot: Dictionary):
	# Implement this in child classes
	pass
