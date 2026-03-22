class_name ObjectPivot
extends Control

@export var animated_rotation: AnimatedRotation

var revolving_object: Node


func _ready() -> void:
	pivot_offset = size / 2
	animated_rotation.set_rotating_object(self)
	# you should also set the revolving object here


func set_revolving_object(object: Node) -> void:
	revolving_object = object


func animate_rotation_to(
	target_rotation: float,
	duration: float = animated_rotation.default_duration,
	trans_type: Tween.TransitionType = animated_rotation.default_trans_type,
	ease_type: Tween.EaseType = animated_rotation.default_ease_type
) -> void:
	"""
	Animate an object's rotation to the desired value
	target_rotation - desired rotation in radians
	duration - animation length in seconds
	trans_type, ease_type - animation settings
	"""
	animated_rotation.animate_rotation_to(target_rotation, duration, trans_type, ease_type)


func rotate_by(
	angle_delta: float,
	duration: float = animated_rotation.default_duration,
	trans_type: Tween.TransitionType = animated_rotation.default_trans_type,
	ease_type: Tween.EaseType = animated_rotation.default_ease_type
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


func spawn_at_object_position(scene: PackedScene, position_offset: Vector2 = Vector2.ZERO) -> Node:
	var new_instance = scene.instantiate()
	new_instance.pivot_offset = new_instance.size / 2
	"""
	Explanation of the new field's position:
	we cannot set its global position yet since its not in the scene tree yet
	(doing so will just set the local position instead)
	we want to set the local position to the local positon of the field spawner, however
	since we dont actually move the field spawner(we only do so by rotating the pivot)
	its local position never changes so we need to use its global position offseted by the global
	position of the pivot
	(This seems really stupid, should probably change this system later)
	And then we add the local position of the pivot cause it in the middle of the table
	since we want the new position to be relative to the table's center
	(should probably also have a more reliable way to do this too)
	and finally offset by size/2 so the field is centered

	some ideas to change this:
	add the field to the board before setting position
	actually move the field spawner instead of rotating the pivot
	have a variable here to hold the table's center
	"""
	new_instance.position = revolving_object.global_position - global_position + position - new_instance.size / 2
	new_instance.rotation = rotation
	new_instance.position += position_offset.rotated(rotation)
	return new_instance
