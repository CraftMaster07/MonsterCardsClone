class_name Hand
extends MarginContainer

@onready var cards_container := $HBoxContainer

func get_cards() -> Array[HandCard]:
	var children = cards_container.get_children()
	var cards: Array[HandCard] = []
	for child in children:
		cards.append(child as HandCard)
	return cards

func set_camera_rotation(camera_rotation: float):
	for card in get_cards():
		card.update_drag_offset(camera_rotation)