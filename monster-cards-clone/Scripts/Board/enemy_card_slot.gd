class_name EnemyCardSlot
extends Control

@onready var slot_area = $SlotArea


func take():
	_set_taken(true)


func _set_taken(taken: bool):
	slot_area.taken = taken


func is_taken():
	return slot_area.taken


func serialize():
	return {
		"taken": is_taken()
	}


func deserialise(serialised_slot: Dictionary):
	_set_taken(serialised_slot['taken'])
