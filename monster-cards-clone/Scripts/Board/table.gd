class_name Table
extends Control

@export var animated_rotation: AnimatedRotation

@export var radius: float = 100.0
@export var color: Color = Color(0.256, 0.256, 0.256, 1.0)


func _ready() -> void:
	animated_rotation.set_rotating_object(self)


func _draw(table_radius: float = radius) -> void:
	var center = size / 2
	draw_circle(center, table_radius, color)


func set_radius(new_radius: float):
	size = Vector2(new_radius * 2, new_radius * 2)
	global_position -= size / 2
	pivot_offset = size / 2
	radius = new_radius
	queue_redraw()


func rotate_by(angle_delta: float):
	animated_rotation.rotate_by(angle_delta)
