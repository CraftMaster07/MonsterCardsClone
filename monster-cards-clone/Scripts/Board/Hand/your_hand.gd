class_name YourHand
extends Hand


@onready var cards_container := $HBoxContainer


signal new_card_added(card: HandCard)


func deserialize(_serialized: Dictionary):
	pass


func shadow_deserialize(serialized: Dictionary):
	var uuid_to_cards = get_uuid_to_cards_dict()

	for serialized_card_data in serialized['card_datas']:
		if serialized_card_data["uuid"] in uuid_to_cards.keys():
			uuid_to_cards[serialized_card_data["uuid"]].deserialize(serialized_card_data)
			uuid_to_cards.erase(serialized_card_data["uuid"])
		else:
			var new_card_data = CardData.new(serialized_card_data)
			var new_card = HandCard.create(new_card_data)
			add_card(new_card)

	if not uuid_to_cards.is_empty():
		for card in uuid_to_cards.values():
			remove_card(card)


func get_cards() -> Array[HandCard]:
	var children = cards_container.get_children()
	var cards: Array[HandCard] = []

	for child in children:
		cards.append(child as HandCard)

	return cards


func get_uuid_to_cards_dict() -> Dictionary:
	var cards: Array[HandCard] = get_cards()
	var cards_dict: Dictionary = {}

	for card in cards:
		cards_dict[card.get_uuid()] = card

	return cards_dict


func add_card(card: HandCard):
	cards_container.add_child(card)
	new_card_added.emit(card)


func get_cards_count():
	return cards_container.get_child_count()


func serialize():
	return super.serialize()


func remove_card(card: HandCard):
	cards_container.remove_child(card)
	card.queue_free()