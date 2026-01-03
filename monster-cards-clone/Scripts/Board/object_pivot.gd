class_name ObjectPivot
extends Control

@export var animation_length: float = 0.5
@export var animation_trans: Tween.TransitionType = Tween.TRANS_CUBIC
@export var animation_ease: Tween.EaseType = Tween.EASE_OUT
var revolving_object: Node

var prev_target: float = 0

var tween: Tween


func _ready() -> void:
	pivot_offset = size / 2
	# you should also set the revolving object here


func set_revolving_object(object: Node) -> void:
	revolving_object = object


func animate_rotation_to(
	target_rotation: float,
	duration: float = animation_length,
	trans_type: Tween.TransitionType = animation_trans,
	ease_type: Tween.EaseType = animation_ease
) -> void:
	"""
	Animate an object's rotation to the desired value
	target_rotation - desired rotation in radians
	duration - animation length in seconds
	trans_type, ease_type - animation settings
	"""
	#print("rotating to: ", target_rotation)
	if tween:
		tween.kill()
		rotation = prev_target
	
	prev_target = target_rotation

	if duration == 0:
		rotation = target_rotation
	else:
		tween = create_tween()
		tween.tween_property(
			self, 
			"rotation", 
			target_rotation, 
			duration
		).set_trans(trans_type).set_ease(ease_type)


func rotate_by(
	angle_delta: float,
	duration: float = animation_length,
	trans_type: Tween.TransitionType = animation_trans,
	ease_type: Tween.EaseType = animation_ease
) -> void:
	"""
	Animate an object's rotation by a relative amount
	angle_delta - amount to rotate by in radians
	duration - animation length in seconds
	trans_type, ease_type - animation settings
	"""

	if tween:
		tween.kill()
		rotation = prev_target
	
	animate_rotation_to(rotation + angle_delta, duration, trans_type, ease_type)


func update_object_radius(new_radius: float):
	var new_position = size / 2
	new_position.y += new_radius
	set_object_position(new_position)


func set_object_position(new_position: Vector2):
	revolving_object.global_position = new_position
