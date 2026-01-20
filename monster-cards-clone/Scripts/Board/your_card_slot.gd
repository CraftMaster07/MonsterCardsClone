class_name YourCardSlot
extends EnemyCardSlot

signal clicked(slot)


func _on_texture_button_pressed() -> void:
	print("slot clicked")
	clicked.emit(self)
