extends Node2D


signal card_selected(card)


func _on_button_up() -> void:
	card_selected.emit(self)
