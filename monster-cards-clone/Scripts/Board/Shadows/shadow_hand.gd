class_name ShadowHand
extends CardDatasManager


func shadow_serialize() -> Dictionary:
	var serialized_card_datas: Array[Dictionary] = []

	for card_data in card_datas.values():
		serialized_card_datas.append(card_data.serialize())

	return {"card_datas": serialized_card_datas}
