class_name EnemyHand
extends Hand

@onready var cards_container := $HBoxContainer
@export var dummy_card_scene: PackedScene


func deserialize(serialized: Dictionary):
	var card_diff: int = serialized['cards_count'] - get_cards_count()

	if card_diff > 0:
		add_cards(card_diff)
	elif card_diff < 0:
		remove_cards(-card_diff)


func get_cards_count():
	return cards_container.get_child_count()


func add_cards(amount: int):
	for i in range(amount):
		add_card()


func remove_cards(amount: int):
	for i in range(amount):
		remove_card()


func add_card():
	var card = dummy_card_scene.instantiate()
	cards_container.add_child(card)


func remove_card():
	if cards_container.get_child_count() == 0: return
	cards_container.get_child(0).queue_free()
