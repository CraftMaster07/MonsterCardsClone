class_name Field
extends MarginContainer

@onready var slot_container = $HBoxContainer
@onready var slots: Array[EnemyCardSlot]


func _ready():
	var node_slots = slot_container.get_children()
	slots = []

	for slot in node_slots:
		slots.append(slot as EnemyCardSlot)


func get_slots() -> Array[EnemyCardSlot]:
	return slots


func get_slot_count() -> int:
	return len(slots)


func is_slot_taken(slot_index: int) -> bool:
	return slots[slot_index].is_taken()


func get_card(slot_index: int) -> BoardCard:
	return slots[slot_index].get_card()


func get_slot_id(slot: EnemyCardSlot) -> int:
	return slots.find(slot)


func serialize() -> Array:
	var slots_data := []

	for slot in get_slots():
		slots_data.append(slot.serialize())

	return slots_data


func deserialize(slots_data: Array):
	for i in range(len(slots_data)):
		slots[i].deserialize(slots_data[i])


func deserialize_slot(slot_data: Dictionary, slot_index: int):
	slots[slot_index].deserialize(slot_data)


func place_serialized_card_into_slot(serialized_card: Dictionary, slot_index: int) -> BoardCard:
	return slots[slot_index].place_serialized_card(serialized_card)


func exorcise():
	for slot in slots:
		slot.exorcise()


func get_random_card() -> CardData:
	var card_datas: Array[CardData] = []
	for slot in slots:
		if slot.is_taken():
			card_datas.append(slot.get_card().get_card_data())

	return card_datas[randi() % len(card_datas)] if len(card_datas) > 0 else null
