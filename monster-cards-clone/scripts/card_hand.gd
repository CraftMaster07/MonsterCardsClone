extends Control

@export var hover_height: float = 20
@export var animation_length: float = 0.2
@export var animation_trans : Tween.TransitionType
@onready var card_front := $CardFront
@onready var base_position : Vector2 = card_front.position
@onready var area2d := $CardFront/Area2D

var touched : bool = false
enum DragState {RESTING, DRAGGING, FINISHING_DRAGGING}
var drag_state : DragState = DragState.RESTING
@export var dragback_time : float = 0.5
@export var dragback_trans : Tween.TransitionType = Tween.TRANS_ELASTIC
@export var dragback_ease : Tween.EaseType = Tween.EASE_OUT
var overlapping_slot_areas : Array[Area2D]
var tween: Tween

func _process(_delta: float) -> void:
	if drag_state == DragState.DRAGGING:
		card_front.global_position = get_global_mouse_position() - card_front.size/2

func _input(event: InputEvent) -> void:
	if event.is_action_released("click") and drag_state == DragState.DRAGGING:
		drag_state = DragState.FINISHING_DRAGGING
		
		if not overlapping_slot_areas.is_empty():
			goto_nearest_overlapping_area()
			return
		
		animate_to_position(base_position, dragback_trans, dragback_time, dragback_ease)
		await tween.finished
		drag_state = DragState.RESTING
		
		if card_front.is_hovered():
			_on_mouse_entered()

func goto_nearest_overlapping_area():
	overlapping_slot_areas.sort_custom(area_distance_compare)
	var target_position := overlapping_slot_areas[0].global_position - size/2
	animate_to_position(target_position, animation_trans, animation_length, Tween.EASE_IN_OUT, true)

func area_distance_compare(area1 : Area2D, area2 : Area2D):
	if area1.global_position.distance_to(area2d.global_position) < area2.global_position.distance_to(area2d.global_position):
		return true
	return false

func update_base_position():
	"""Updates the base_position variable to the current card_front position"""
	base_position = card_front.position

func _on_mouse_entered() -> void:
	"""Animating the card when mouse is hovered over it"""
	if drag_state != DragState.RESTING:
		return
	
	if not touched:
		update_base_position()
		touched = true
	
	animate_to_position(base_position - Vector2(0, hover_height), animation_trans, animation_length)

func _on_mouse_exited() -> void:
	"""Animating the card when mouse leaves it"""
	if drag_state != DragState.RESTING:
		return
	
	animate_to_position(base_position, animation_trans, animation_length)

func animate_to_position(pos, trans_type, length, ease_type = Tween.EASE_IN_OUT, global = false):
	if tween:
		tween.kill()
	
	tween = create_tween()
	if global:
		tween.tween_property(card_front, "global_position", pos, length).set_trans(trans_type).set_ease(ease_type)
	else:
		tween.tween_property(card_front, "position", pos, length).set_trans(trans_type).set_ease(ease_type)

func _on_card_front_button_down() -> void:
	drag_state = DragState.DRAGGING

func _on_area_2d_area_entered(area: Area2D) -> void:
	overlapping_slot_areas.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area in overlapping_slot_areas:
		overlapping_slot_areas.erase(area)
