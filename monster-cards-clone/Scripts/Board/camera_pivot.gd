extends Control

@export var animation_length: float = 0.5
@export var animation_trans: Tween.TransitionType = Tween.TRANS_CUBIC
@export var animation_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var hand: Hand
var prev_target: float = 0

var tween: Tween

func animate_camera_rotation_to(
	target_rotation: float,
	duration: float = animation_length,
	trans_type: Tween.TransitionType = animation_trans,
	ease_type: Tween.EaseType = animation_ease
) -> void:
	"""
	Animate the camera's pivot to the desired rotation
	target_rotation - desired rotation in radians
	duration - animation length in seconds
	trans_type, ease_type - animation settings
	"""
	if tween:
		tween.kill()
		rotation = prev_target
	
	hand.set_camera_rotation(target_rotation)
	prev_target = target_rotation
	tween = create_tween()
	
	tween.tween_property(self, "rotation", target_rotation, duration).set_trans(trans_type).set_ease(ease_type)

func rotate_by(
	angle_delta: float,
	duration: float = animation_length,
	trans_type: Tween.TransitionType = animation_trans,
	ease_type: Tween.EaseType = animation_ease
) -> void:
	"""
	Rotate the node by a relative amount (in radians)
	angle_delta - amount to rotate by in radians
	duration - animation length in seconds
	trans_type, ease_type - animation settings
	"""
	
	if tween:
		tween.kill()
		rotation = prev_target
	
	animate_camera_rotation_to(rotation + angle_delta, duration, trans_type, ease_type)
