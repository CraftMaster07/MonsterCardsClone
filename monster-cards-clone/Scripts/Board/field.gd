class_name Field
extends MarginContainer

@onready var slot_container = $HBoxContainer
var slots := slot_container.get_children()


func _ready():
	pass


func get_slots():
	return slots


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
