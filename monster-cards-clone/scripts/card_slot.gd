class_name CardSlot
extends Control

@onready var slot_area = $SlotArea


func take():
	slot_area.taken = true
