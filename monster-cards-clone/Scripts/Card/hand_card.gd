class_name HandCard
extends Control

@export var hover_height: float = 20
@export var animation_length: float = 0.2
@export var animation_trans: Tween.TransitionType
@onready var card_front := $CardFront
@onready var base_position: Vector2 = card_front.position
@onready var area2d := $CardFront/Area2D
@onready var select_timer := $SelectTimer
@onready var sfx_hover: AudioStreamPlayer = $sfx_hover
@onready var drag_offset: Vector2 = card_front.size / 2

signal card_placed(card, slot)
signal card_selected(card)
signal card_deselected()

var touched: bool = false
enum DragState {RESTING, DRAGGING, UNDRAGGABLE}
var drag_state: DragState = DragState.RESTING
var selected: bool = false
var mouse_in_card: bool = false
@export var dragback_time: float = 0.5
@export var dragback_trans: Tween.TransitionType = Tween.TRANS_ELASTIC
@export var dragback_ease: Tween.EaseType = Tween.EASE_OUT
var overlapping_slot_areas: Array[SlotArea]
var tween: Tween


func _process(_delta: float) -> void:
	if drag_state == DragState.DRAGGING:
		card_front.global_position = get_global_mouse_position() - drag_offset

func _input(event: InputEvent) -> void:
	if event.is_action_released("click") and drag_state == DragState.DRAGGING:
		if not select_timer.is_stopped():
			if selected:
				deselect()
			else:
				select()
			return
		
		drag_state = DragState.UNDRAGGABLE
		
		if not overlapping_slot_areas.is_empty():
			var nearest_area = _find_nearest_overlapping_area()
			card_placed.emit(self, nearest_area.slot)
			return
		
		animate_to_position(base_position, dragback_trans, dragback_time, dragback_ease)
		tween.tween_callback(_rest)


func _rest():
	drag_state = DragState.RESTING
	
	if card_front.is_hovered():
		_on_mouse_entered()


func update_drag_offset(camera_rotation: float):
	drag_offset = (card_front.size / 2).rotated(camera_rotation)


func select():
	drag_state = DragState.RESTING
	card_front.position = base_position - Vector2(0, hover_height)
	selected = true
	card_selected.emit(self)


func deselect():
	if not selected:
		return
	animate_to_position(base_position, animation_trans, animation_length)
	tween.tween_callback(_rest)
	selected = false
	mouse_in_card = card_front.is_hovered()
	card_deselected.emit()


func _find_nearest_overlapping_area():
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


func goto_slot(slot: YourCardSlot):
	"""
	Moves cardfront to the desired slot, and disables further dragging/selecting
	(Should be deleted and replaced with a BoardCard afterwords by the board)
	"""
	drag_state = DragState.UNDRAGGABLE
	var target_position := slot.global_position
	animate_to_position(target_position, animation_trans, animation_length, Tween.EASE_IN_OUT, true)


func _update_base_position():
	"""Updates the base_position variable to the current card_front position"""
	base_position = card_front.position


func _on_mouse_entered() -> void:
	"""Animating the card when mouse is hovered over it"""
	if drag_state != DragState.RESTING:
		return
	
	if mouse_in_card: # Prevents activation immediately after deselecting
		return
	
	if not touched:
		_update_base_position()
		touched = true
	
	animate_to_position(base_position - Vector2(0, hover_height), animation_trans, animation_length)
	sfx_hover.play()


func _on_mouse_exited() -> void:
	"""Animating the card when mouse leaves it"""
	if drag_state != DragState.RESTING:
		return
	
	mouse_in_card = false
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

func scale_card(target_scale: Vector2, trans_type = animation_trans, length = animation_length, ease_type = Tween.EASE_OUT):
	"""
	Animate the card_front to the desired scale
	target_scale - desired scale (e.g., Vector2(1.2, 1.2) for 20% larger)
	length - animation length
	trans_type, ease_type - animation settings
	"""
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(card_front, "scale", target_scale, length).set_trans(trans_type).set_ease(ease_type)

func _on_card_front_button_down() -> void:
	if drag_state == DragState.RESTING:
		drag_state = DragState.DRAGGING
		select_timer.start()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is not SlotArea:
		print_rich("why the [b][color=red]fuck[/color][/b] is this happening")
		return
	
	if not area.taken:
		overlapping_slot_areas.append(area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area in overlapping_slot_areas:
		overlapping_slot_areas.erase(area)
