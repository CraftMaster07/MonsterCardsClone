class_name YourCardSlot
extends EnemyCardSlot

signal clicked(slot)


func take():
	_set_taken(true)


func _set_taken(taken: bool):
	slot_area.taken = taken


func is_taken():
	return slot_area.taken


func _deserialise(_serialised_slot: Dictionary):
	if card and not is_taken():
		_set_taken(true)


func _on_texture_button_pressed() -> void:
	print("slot clicked")
	clicked.emit(self)
