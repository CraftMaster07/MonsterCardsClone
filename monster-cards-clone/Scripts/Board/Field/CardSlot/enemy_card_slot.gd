class_name EnemyCardSlot
extends Control

@export var board_card_scene: PackedScene
@export var color_rect: ColorRect

@export var base_color: Color = Color(0.4, 0.4, 0.4, 0.723)
@export var error_color: Color = Color(0.816, 0.0, 0.186, 0.723)
@export var flash_duration: float = 0.25
@export var flash_trans_type: Tween.TransitionType = Tween.TRANS_CUBIC
@export var flash_ease_type: Tween.EaseType = Tween.EASE_OUT

var card: BoardCard
var tween: Tween


func _ready():
	color_rect.color = base_color


func take():
	push_error("take() not implemented")


func is_taken():
	return card != null


func place_card(new_card: BoardCard):
	card = new_card
	add_child(card)
	card.position = Vector2.ZERO


func serialize():
	return {
		"card": card.serialize() if card else {}
	}


func deserialize(serialized_slot: Dictionary):
	if serialized_slot['card'] and card:
		card.deserialize(serialized_slot['card'])
	elif serialized_slot['card']:
		place_card(board_card_scene.instantiate())


func place_serialized_card(serialized_card: Dictionary):
	if card:
		card.deserialize(serialized_card)
	else:
		var new_card := board_card_scene.instantiate()
		new_card.deserialize(serialized_card)
		place_card(new_card)


func flash_color(flashed_color: Color = error_color):
	color_rect.color = flashed_color

	tween = color_rect.create_tween()
	tween.tween_property(
		color_rect,
		"color",
		base_color,
		flash_duration
	).set_trans(flash_trans_type).set_ease(flash_ease_type)
