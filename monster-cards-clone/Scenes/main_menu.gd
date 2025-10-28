extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_idk_button_pressed() -> void:
	print("Why would you press this?")


func _on_deck_button_pressed() -> void:
	print("Deck button pressed")
	

func _on_play_button_pressed() -> void:
	print("Play button pressed")
	get_tree().change_scene_to_file("res://Scenes/board.tscn")


func _on_settings_button_pressed() -> void:
	print("Settings button pressed")


func _on_quit_button_pressed() -> void:
	print("Quit button pressed")
	get_tree().quit()
