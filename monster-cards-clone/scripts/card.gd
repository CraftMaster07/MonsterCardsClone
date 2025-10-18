extends Control

@export var hover_height: float = 20
@export var animation_length: float = 0.2
@export var animation_trans : Tween.TransitionType
@onready var card_button := $CardButton
@onready var base_position : Vector2 = card_button.position
var touched: bool = false
enum DragState {RESTING, DRAGGING, FINISHING_DRAGGING}
var drag_state: DragState = DragState.RESTING
var tween: Tween

func _process(_delta: float) -> void:
	if drag_state == DragState.DRAGGING:
		card_button.global_position = get_global_mouse_position() - card_button.size/2

func _input(event: InputEvent) -> void:
	if event.is_action_released("click") and drag_state == DragState.DRAGGING:
		drag_state = DragState.FINISHING_DRAGGING
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(card_button, "position", base_position, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		await tween.finished
		drag_state = DragState.RESTING
		if card_button.is_hovered():
			_on_mouse_entered()

func update_base_position():
	"""Updates the base_position variable to the current card_button position"""
	base_position = card_button.position

func _on_mouse_entered() -> void:
	"""Animating the card when mouse is hovered over it"""
	if drag_state != DragState.RESTING:
		return
	if not touched:
		update_base_position()
		touched = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(card_button, "position", base_position - Vector2(0, hover_height), animation_length).set_trans(animation_trans)

func _on_mouse_exited() -> void:
	"""Animating the card when mouse leaves it"""
	if drag_state != DragState.RESTING:
		return
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(card_button, "position", base_position, animation_length).set_trans(animation_trans)


func _on_card_button_button_down() -> void:
	drag_state = DragState.DRAGGING
