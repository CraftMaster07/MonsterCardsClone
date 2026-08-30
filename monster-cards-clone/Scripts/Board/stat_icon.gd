class_name StatIcon
extends Control

@export var stat_display: RichTextLabel
@export var stat_texture: TextureRect


func update_label(text: String):
	stat_display.text = text


func update_texture(texture: Texture2D):
	stat_texture.texture = texture
