class_name Field
extends MarginContainer

@onready var slot_container = $HBoxContainer
@onready var slots := slot_container.get_children()


func get_slots():
	return slots


func is_slot_taken(slot_index: int):
	return slots[slot_index].is_taken()


func get_slot_id(slot: EnemyCardSlot):
	return slots.find(slot)


func serialize():
	var slots_data := []

	for slot in get_slots():
		slots_data.append(slot.serialize())

	return slots_data


func deserialise(slots_data: Array):
	for i in range(len(slots_data)):
		slots[i].deserialise(slots_data[i])


func deserialise_slot(slot_data: Dictionary, slot_index: int):
	slots[slot_index].deserialise(slot_data)


func place_serialised_card_into_slot(serialised_card: Dictionary, slot_index: int):
	slots[slot_index].place_serialised_card(serialised_card)
