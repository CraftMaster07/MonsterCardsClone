class_name Hand
extends Node


func serialize():
	return {
		"cards_count": get_cards_count()
	}


func get_cards_count():
	push_error("get_cards_count not implemented")
