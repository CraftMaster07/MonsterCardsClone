class_name CardFront
extends TextureButton

@export var health_label: RichTextLabel

func update_health(health: int) -> void:
	if str(health) != health_label.text:
		health_label.text = ColorConstants.RED_TEXT.format([str(health)])
