extends Button

@export var more_options_label: Label


func _on_pressed() -> void:
	if CardSpriteManager.clear_cache():
		more_options_label.text = "Successfully deleted sprite cache"
	else:
		more_options_label.text = "Failed to delete sprite cache"
