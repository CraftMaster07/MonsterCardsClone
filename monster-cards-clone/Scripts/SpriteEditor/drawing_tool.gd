class_name DrawingTool
extends RefCounted


var canvas: Node
var color: Color


func _init(new_canvas: Node, new_color: Color) -> void:
    canvas = new_canvas
    color = new_color


func set_color(new_color: Color) -> void:
    color = new_color


func on_press(_pos: Vector2) -> void: pass
func on_drag(_pos: Vector2) -> void: pass
func on_release(_pos: Vector2) -> void: pass
