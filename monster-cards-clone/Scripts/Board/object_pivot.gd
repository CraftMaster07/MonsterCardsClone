class_name ObjectPivot
extends Control

@export var animated_rotation: AnimatedRotation

var revolving_object: Node

var prev_target: float = 0


func _ready() -> void:
	pivot_offset = size / 2
	animated_rotation.set_rotating_object(self)
	# you should also set the revolving object here


func set_revolving_object(object: Node) -> void:
	revolving_object = object


func animate_rotation_to(
	target_rotation: float,
	duration: float = animated_rotation.animation_length,
	trans_type: Tween.TransitionType = animated_rotation.animation_trans,
	ease_type: Tween.EaseType = animated_rotation.animation_ease
) -> void:
	"""
	Animate an object's rotation to the desired value
	target_rotation - desired rotation in radians
	duration - animation length in seconds
	trans_type, ease_type - animation settings
	"""
	#print("rotating to: ", target_rotation)
	animated_rotation.animate_rotation_to(target_rotation, duration, trans_type, ease_type)


func rotate_by(
	angle_delta: float,
	duration: float = animated_rotation.animation_length,
	trans_type: Tween.TransitionType = animated_rotation.animation_trans,
	ease_type: Tween.EaseType = animated_rotation.animation_ease
) -> void:
	"""
	Animate an object's rotation by a relative amount
	angle_delta - amount to rotate by in radians
	duration - animation length in seconds
	trans_type, ease_type - animation settings
	"""
	animated_rotation.rotate_by(angle_delta, duration, trans_type, ease_type)


func update_object_radius(new_radius: float):
	var new_position = size / 2
	new_position.y += new_radius
	set_object_position(new_position)


func set_object_position(new_position: Vector2):
	revolving_object.position = new_position
