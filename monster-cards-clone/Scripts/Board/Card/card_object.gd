class_name CardObject
extends Control
# The reason this exists is because both hand card and board card share the same serialize and deserialize methods


@export var card_front: CardFront

var card_data: CardData


func serialize() -> Dictionary:
	# If we ever need to change that, mind the shadow_deserialize too.
	return card_data.serialize()


func deserialize(data: Dictionary):
	card_data.deserialize(data)


func set_card_data(new_card_data: CardData):
	card_data = new_card_data
	card_data.updated_stats.connect(update_labels)
	add_child(card_data)


func get_card_data() -> CardData:
	return card_data


func update_labels():
	card_front.update_labels(card_data)


func release_card_data():
	remove_child(card_data)
	card_data.updated_stats.disconnect(update_labels)


func set_owner_id(new_owner_id: int):
	card_data.owner_id = new_owner_id


func get_owner_id() -> int:
	return card_data.owner_id


func get_uuid() -> String:
	return card_data.uuid
