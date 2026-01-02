extends Control

@export var radius: float = 300.0
@export var color: Color = Color(0.256, 0.256, 0.256, 1.0)


func _draw(table_radius: float = radius) -> void:
	var center = size / 2
	draw_circle(center, table_radius, color)
	print("drawing circle")


func set_radius(new_radius: float):
	radius = new_radius
	queue_redraw()
