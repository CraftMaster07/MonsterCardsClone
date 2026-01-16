class_name Field
extends MarginContainer

@onready var slot_container = $HBoxContainer


func get_slots():
	print(slot_container)
	return slot_container.get_children()


func get_data():
	var slots_data := []

	for slot in get_slots():
		slots_data.append(slot.get_data())

	return slots_data


func set_data(slots_data: Array):
	for slot in get_slots():
		slot.set_data(slots_data.pop_front())
