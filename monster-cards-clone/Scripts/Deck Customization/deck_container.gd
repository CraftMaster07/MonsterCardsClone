class_name DeckContainer
extends HBoxContainer


func add_card(card: EditorCard) -> void:
	add_child(card)
	card.card_selected.connect(remove_card)


func remove_card(card: EditorCard) -> void:
	remove_child(card)
	card.queue_free()
