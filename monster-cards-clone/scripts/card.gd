extends TextureButton
class_name Card

signal card_selected(card)

func _on_button_up() -> void:
	print("hi")
	card_selected.emit(self)
