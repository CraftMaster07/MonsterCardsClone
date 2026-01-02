class_name Field
extends MarginContainer

@onready var slot_container = $HBoxContainer

func get_slots():
	return slot_container.get_children()
