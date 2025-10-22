class_name CardHand
extends Control

@export var hover_height: float = 20
@export var animation_length: float = 0.2
@export var animation_trans: Tween.TransitionType
@onready var card_front := $CardFront
@onready var base_position: Vector2 = card_front.position
@onready var area2d := $CardFront/Area2D
@onready var select_timer := $SelectTimer

signal card_placed(card, slot)
signal card_selected(card)
signal card_deselected()

var touched: bool = false
enum DragState {RESTING, DRAGGING, UNDRAGABLE}
var drag_state: DragState = DragState.RESTING
var selected: bool = false
@export var dragback_time : float = 0.5
@export var dragback_trans : Tween.TransitionType = Tween.TRANS_ELASTIC
@export var dragback_ease : Tween.EaseType = Tween.EASE_OUT
var overlapping_slot_areas : Array[SlotArea]
var tween: Tween

func _process(_delta: float) -> void:
	if drag_state == DragState.DRAGGING:
		card_front.global_position = get_global_mouse_position() - card_front.size/2

func _input(event: InputEvent) -> void:
	if event.is_action_released("click") and drag_state == DragState.DRAGGING:
		if not select_timer.is_stopped():
			select()
			return
		
		drag_state = DragState.UNDRAGABLE
		
		if not overlapping_slot_areas.is_empty():
			var nearest_area = find_nearest_overlapping_area()
			card_placed.emit(self, nearest_area.slot)
			return
		
		animate_to_position(base_position, dragback_trans, dragback_time, dragback_ease)
		tween.tween_callback(rest)

func rest():
	drag_state = DragState.RESTING
		
	if card_front.is_hovered():
		_on_mouse_entered()

func select():
	drag_state = DragState.UNDRAGABLE
	card_front.position = base_position - Vector2(0, hover_height)
	selected = true
	card_selected.emit(self)

func deselect():
	animate_to_position(base_position, animation_trans, animation_length)
	tween.tween_callback(rest)
	selected = false

func find_nearest_overlapping_area():
	"""Finds the closest area in overlapping_slot_areas to our own area2d and returns it"""
	if overlapping_slot_areas.is_empty():
		return null
	
	var min_area = overlapping_slot_areas[0]
	var min_distance = min_area.global_position.distance_to(area2d.global_position)
	
	for area in overlapping_slot_areas.slice(1):
		var distance = area.global_position.distance_to(area2d.global_position)
		if distance < min_distance:
			min_distance = distance
			min_area = area
	
	return min_area

func goto_slot(slot : CardSlot):
	"""
	Moves cardfront to the desired slot, and disables further dragging/selecting
	(Should be deleted and replaced with a CardBoard afterwords by the board)
	"""
	drag_state = DragState.UNDRAGABLE
	var target_position := slot.global_position
	animate_to_position(target_position, animation_trans, animation_length, Tween.EASE_IN_OUT, true)

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
	"""
	Animate the cardfront to the desired position
	pos - desired position
	length - animation length
	trans_type, ease_type - animation settings
	global - if this is true, animation will use global position instead of relative
	"""
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	if global:
		tween.tween_property(card_front, "global_position", pos, length).set_trans(trans_type).set_ease(ease_type)
	else:
		tween.tween_property(card_front, "position", pos, length).set_trans(trans_type).set_ease(ease_type)

func _on_card_front_button_down() -> void:
	if selected:
		card_deselected.emit()
	elif drag_state == DragState.RESTING:
		drag_state = DragState.DRAGGING
		$SelectTimer.start()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is not SlotArea:
		print_rich("why the [b][color=red]fuck[/color][/b] is this happening")
		return
	
	if not area.taken:
		overlapping_slot_areas.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area in overlapping_slot_areas:
		overlapping_slot_areas.erase(area)
