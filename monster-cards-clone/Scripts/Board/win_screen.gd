class_name WinScreen
extends Control


signal play_again()
signal leave_game()

@export var win_message: RichTextLabel
@export var screen_filter: ColorRect
@export var leave_game_button: Button
@export var play_again_button: Button
@export var view_board_button: Button


func set_winner(player_name: String) -> void:
	win_message.text = player_name + " Wins!"


func _on_leave_game_button_pressed() -> void:
	leave_game.emit()


func _on_view_board_button_pressed() -> void:
	screen_filter.visible = !screen_filter.visible


func _on_play_again_button_pressed() -> void:
	play_again.emit()
