class_name EnemyCardSlot
extends Control

@onready var slot_area = $SlotArea


func take():
	slot_area.taken = true


func is_taken():
	return slot_area.taken


func get_data():
	return {
		"taken": slot_area.taken
	}


func set_data(data: Dictionary):
	slot_area.taken = data['taken']
