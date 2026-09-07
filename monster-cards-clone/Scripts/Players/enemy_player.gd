class_name EnemyPlayer
extends Player


signal attacked(player_id: int)


func draw_card():
	if super.draw_card():
		hand.add_card()


func set_attack_button(new_attack_button: Button):
	attack_button = new_attack_button
	attack_button.pressed.connect(_on_attack_button_pressed)


func show_attack_button():
	attack_button.show()


func hide_attack_button():
	attack_button.hide()


func _on_attack_button_pressed() -> void:
	attacked.emit(player_id)
