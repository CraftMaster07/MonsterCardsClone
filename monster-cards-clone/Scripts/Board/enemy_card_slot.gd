class_name EnemyCardSlot
extends Control

@onready var slot_area = $SlotArea

func take():
	slot_area.taken = true

func is_taken():
	return slot_area.taken