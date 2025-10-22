class_name CardSlot
extends Control

@onready var slot_area = $SlotArea

signal clicked(slot)

func take():
	slot_area.taken = true


func _on_texture_button_pressed() -> void:
	clicked.emit(self)
