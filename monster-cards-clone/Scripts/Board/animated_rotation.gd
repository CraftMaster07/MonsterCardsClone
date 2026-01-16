class_name AnimatedRotation
extends Resource

@export var animation_length: float = 0.5
@export var animation_trans: Tween.TransitionType = Tween.TRANS_CUBIC
@export var animation_ease: Tween.EaseType = Tween.EASE_OUT

var prev_target: float = 0
var tween: Tween
var rotating_object: Control

func set_rotating_object(object: Control) -> void:
	rotating_object = object

func animate_rotation_to(
	target_rotation: float,
	duration: float = animation_length,
	trans_type: Tween.TransitionType = animation_trans,
	ease_type: Tween.EaseType = animation_ease) -> void:
	"""
	Animate an object's rotation to the desired value
	target_rotation - desired rotation in radians
	duration - animation length in seconds
	trans_type, ease_type - animation settings
	"""
	#print("rotating to: ", target_rotation)
	if tween:
		tween.kill()
		rotating_object.rotation = prev_target

	prev_target = target_rotation

	if duration == 0:
		rotating_object.rotation = target_rotation
	else:
		tween = rotating_object.create_tween()
		tween.tween_property(
			rotating_object,
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
		rotating_object.rotation = prev_target

	animate_rotation_to(rotating_object.rotation + angle_delta, duration, trans_type, ease_type)