extends Node

@onready var multiplayer_manager = $MultiplayerManager
@onready var main_menu = $MainMenu
@export var board_scene: PackedScene


func init_board():
    var new_board: Board = board_scene.instantiate()
    add_child(new_board)