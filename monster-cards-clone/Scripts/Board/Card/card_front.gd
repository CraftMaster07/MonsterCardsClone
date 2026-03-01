class_name CardFront
extends TextureButton

@export var health_label: RichTextLabel
const RED_TEXT: String = "[color=red]{0}[/color]"

func update_health(health: int) -> void:
	if str(health) != health_label.text:
		health_label.text = RED_TEXT.format([str(health)])
