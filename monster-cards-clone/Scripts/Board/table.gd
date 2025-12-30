extends Control

@export var radius: float = 300.0
@export var color: Color = Color(0.256, 0.256, 0.256, 1.0)

func _draw() -> void:
	var center = size / 2
	draw_circle(center, radius, color)
	print("drawing circle")
