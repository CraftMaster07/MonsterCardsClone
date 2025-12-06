extends Control

@onready var color_rect: ColorRect = $Color
@onready var name_label: Label = $Name


func set_player_name(new_name: String):
	name_label.text = new_name


func set_color(new_color: Color):
	color_rect.set_color(new_color)
