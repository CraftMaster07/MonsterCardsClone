class_name AnimatedRotation
extends Resource

var prev_target: float = 0
var tween: Tween
var rotating_object: Control

const DEFAULT_DURATION: float = 1
const DEFAULT_TRANS: Tween.TransitionType = Tween.TRANS_LINEAR
const DEFAULT_EASE: Tween.EaseType = Tween.EASE_IN


func set_rotating_object(object: Control) -> void:
	rotating_object = object


func animate_rotation_to(
	target_rotation: float,
	duration: float = DEFAULT_DURATION,
	trans_type: Tween.TransitionType = DEFAULT_TRANS,
	ease_type: Tween.EaseType = DEFAULT_EASE) -> void:
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
	duration: float = DEFAULT_DURATION,
	trans_type: Tween.TransitionType = DEFAULT_TRANS,
	ease_type: Tween.EaseType = DEFAULT_EASE
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
