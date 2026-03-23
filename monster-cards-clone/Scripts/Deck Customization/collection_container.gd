class_name CollectionContainer
extends HBoxContainer


@export var card_fron_scene: PackedScene


signal card_selected(card: EditorCard)


func add_card(card: EditorCard) -> void:
	add_child(card)
	card.card_selected.connect(send_card_to_deck)


func send_card_to_deck(card):
	card_selected.emit(card)
