extends VBoxContainer

@export var player_scene: PackedScene


func add_player(player_name: String, color: Color):
    var player = player_scene.instantiate()
    add_child(player)
    player.set_player_name(player_name)
    player.set_color(color)
