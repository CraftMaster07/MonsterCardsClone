class_name Field
extends MarginContainer

@onready var slot_container = $HBoxContainer


func get_slots():
	print(slot_container)
	return slot_container.get_children()


func serialize():
	var slots_data := []

	for slot in get_slots():
		slots_data.append(slot.serialize())

	return slots_data


func deserialise(slots_data: Array):
	var slots = get_slots()

	for i in range(len(slots_data)):
		slots[i].deserialise(slots_data[i])
