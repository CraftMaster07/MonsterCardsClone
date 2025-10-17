extends Control

@export var hover_height: float = 20
@export var animation_length: float = 0.2
@export var animation_trans : Tween.TransitionType
@onready var card_button := $CardButton
@onready var base_position : Vector2 = card_button.position
var tween: Tween

func update_base_position():
	base_position = position

func _on_mouse_entered() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(card_button, "position", base_position - Vector2(0, hover_height), animation_length).set_trans(animation_trans)

func _on_mouse_exited() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(card_button, "position", base_position, animation_length).set_trans(animation_trans)
