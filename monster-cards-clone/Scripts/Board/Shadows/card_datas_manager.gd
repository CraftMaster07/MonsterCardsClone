class_name CardDatasManager
extends Node


var card_datas: Dictionary[String, CardData]


func add_card_data(card_data: CardData) -> void:
	card_datas[card_data.uuid] = card_data


func remove_card_data(uuid: String) -> void:
	card_datas.erase(uuid)


func get_card_data_count() -> int:
	return card_datas.size()
