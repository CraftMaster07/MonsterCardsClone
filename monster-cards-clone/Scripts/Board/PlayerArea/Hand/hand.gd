class_name Hand
extends Node


func serialize():
	return {
		"cards_count": get_cards_count()
	}


func get_cards_count():
	push_error("get_cards_count not implemented")


func discard_all_cards():
	push_error("discard_all_cards not implemented")


func disable_functionality():
	discard_all_cards()
