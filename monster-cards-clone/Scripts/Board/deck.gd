class_name Deck
extends Control

@export var deck_card_scene: PackedScene
@export var cards_container: Control
@export var card_count_label: RichTextLabel

var card_amount: int = 0


func _ready():
	update_cards_count_label()


func draw_card() -> bool:
	if get_child_count() > 0:
		remove_card()
		return true
	return false


func add_cards(cards_count: int):
	for i in range(cards_count):
		add_card()


func add_card():
	if get_card_count() < 1:
		var new_card = deck_card_scene.instantiate()
		cards_container.add_child(new_card)

	card_amount += 1
	update_cards_count_label()


func remove_cards(cards_count: int):
	for i in range(cards_count):
		remove_card()


func remove_card():
	if get_card_count() == 0:
		push_error("There are no cards in the deck")
	elif get_card_count() == 1:
		var drawn_card = cards_container.get_child(0)
		cards_container.remove_child(drawn_card)
		drawn_card.queue_free()
	
	card_amount -= 1
	update_cards_count_label()


func serialize():
	return {"cards_count": get_card_count()}


func deserialize(data: Dictionary):
	var card_diff = data["cards_count"] - get_card_count()

	if card_diff > 0:
		add_cards(card_diff)
	elif card_diff < 0:
		remove_cards(-card_diff)


func get_card_count():
	return card_amount


func update_cards_count_label():
	card_count_label.text = str(get_card_count())
