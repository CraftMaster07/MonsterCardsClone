class_name ShadowDeck
extends CardDatasManager


func shuffle() -> void:
	var card_data_values = card_datas.values()
	card_datas.clear()
	card_data_values.shuffle()

	for card_data in card_data_values:
		add_card_data(card_data)


func draw_card_data() -> CardData:
	if card_datas.is_empty():
		return null

	var drawn_card_data = card_datas.values()[0]
	remove_card_data(drawn_card_data.uuid)
	return drawn_card_data


func create_deck(serialized_deck_blueprint: Dictionary):
	card_datas = {}

	for serialized_card_data in serialized_deck_blueprint["card_datas"]:
		var new_card_data = CardData.new(serialized_card_data)
		add_card_data(new_card_data)
 
