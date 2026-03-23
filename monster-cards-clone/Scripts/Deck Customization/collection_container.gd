class_name CollectionContainer
extends HBoxContainer


@export var card_fron_scene: PackedScene


signal card_selected(card: CardFront)


func add_card(card: EditorCard) -> void:
	add_child(card)
	card.pressed.connect(send_card_to_deck.bind(card))


func send_card_to_deck(card):
	card_selected.emit(card)
