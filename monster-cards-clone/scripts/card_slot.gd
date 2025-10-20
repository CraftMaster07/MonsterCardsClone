extends Control


func _on_mouse_entered() -> void:
	print_rich("The mouse just [color=red][shake]entered[/shake][/color] me uwu")




func _on_area_2d_area_entered(area: Area2D) -> void:
	print("an area has entered me ", area)
