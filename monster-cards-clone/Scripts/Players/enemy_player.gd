class_name EnemyPlayer
extends Player


signal attacked(player_id: int)

func _on_button_pressed() -> void:
	attacked.emit(player_id)


func draw_card():
	if deck.draw_card():
		hand.add_card()
