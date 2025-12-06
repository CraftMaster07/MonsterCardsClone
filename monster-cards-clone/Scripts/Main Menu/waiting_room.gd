extends Control

signal start_game()

var rngesus := RandomNumberGenerator.new()
var colors := []
var current_bot_index := 0
@onready var player_container: VBoxContainer = $VBoxContainer/PlayersContainer


func _on_button_pressed() -> void:
    player_container.add_player("BOT" + str(current_bot_index), generate_random_color())
    current_bot_index += 1


func generate_random_color() -> Color:
    var r = rngesus.randf_range(0.0, 1.0)
    var g = rngesus.randf_range(0.0, 1.0)
    var b = rngesus.randf_range(0.0, 1.0)
    return Color(r, g, b)


func _on_start_pressed() -> void:
    start_game.emit()
