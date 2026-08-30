class_name DrawingTool
extends RefCounted


var sprite: Node
var color: Color


func _init(new_sprite: Node, new_color: Color) -> void:
    sprite = new_sprite
    color = new_color


func set_color(new_color: Color) -> void:
    color = new_color


func on_press(_pos: Vector2) -> void: pass
func on_drag(_pos: Vector2) -> void: pass
func on_release(_pos: Vector2) -> void: pass
