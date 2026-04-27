class_name ShadowHand
extends CardDatasManager


func shadow_serialize() -> Dictionary:
	var serialized_card_datas: Array[Dictionary] = []

	for card_data in card_datas.values():
		serialized_card_datas.append(card_data.serialize())

	return {"card_datas": serialized_card_datas}


func remove_serialized_card_data(serialized_card_data: Dictionary):
	var temp_card_data = CardData.new(serialized_card_data)

	if temp_card_data.uuid not in card_datas:
		push_error(("server: " if multiplayer.is_server() else "client: "), "card not in hand")
		return

	remove_card_data(temp_card_data.uuid, true)
	temp_card_data.free()
