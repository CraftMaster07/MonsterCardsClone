class_name CardDetails
extends Control

@export var card_front: CardFront


func set_card_data(card_data: CardData):
	card_front.set_initial_values(card_data)
