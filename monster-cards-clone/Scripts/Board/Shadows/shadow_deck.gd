class_name ShadowDeck
extends CardDatasManager


func draw_card_data() -> CardData:
	if card_datas.is_empty():
		return null

	var card_data_values = card_datas.values()
	var drawn_card_data = card_data_values[randi_range(0, card_data_values.size() - 1)]
	remove_card_data(drawn_card_data.uuid)
	return drawn_card_data


func create_deck(serialized_deck_blueprint: Dictionary, owner_id: int):
	card_datas = {}

	for serialized_card_data in serialized_deck_blueprint["card_datas"]:
		var new_card_data = CardData.new(serialized_card_data, owner_id)
		new_card_data.recalculate_cost()
		add_card_data(new_card_data)
