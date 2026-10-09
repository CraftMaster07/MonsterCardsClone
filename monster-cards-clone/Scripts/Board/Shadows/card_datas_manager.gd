class_name CardDatasManager
extends Node


var card_datas: Dictionary[String, CardData]
var is_disabled: bool = false


func add_card_data(card_data: CardData) -> void:
	if is_disabled: return
	add_child(card_data)
	card_datas[card_data.uuid] = card_data


func remove_card_data(uuid: String, free = false) -> void:
	if is_disabled: return
	remove_child(card_datas[uuid])

	if free:
		card_datas[uuid].queue_free()

	card_datas.erase(uuid)


func get_card_data_count() -> int:
	return card_datas.size()


func get_card_data_by_uuid(uuid: String) -> CardData:
	return card_datas[uuid] if uuid in card_datas else null


func disable_functionality():
	is_disabled = true