class_name StatIcon
extends Control

@export var stat_display: RichTextLabel
@export var stat_texture: TextureRect
@export var default_texture: Texture2D


func _ready() -> void:
	update_texture(default_texture)


func update_label(text: String):
	if text != null:
		stat_display.text = text
	else:
		stat_display.text = "E/E"


func update_texture(texture: Texture2D):
	if texture != null:
		stat_texture.texture = texture
	else:
		stat_texture.texture = default_texture
