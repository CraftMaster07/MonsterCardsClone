extends MarginContainer

@onready var cards_container := $HBoxContainer

func get_cards():
	return cards_container.get_children()
