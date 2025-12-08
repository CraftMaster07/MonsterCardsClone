class_name WaitingRoom
extends Control


signal start_game()

var rngesus := RandomNumberGenerator.new()
var current_bot_index := 0
@onready var player_name_input: LineEdit = $LineEdit
@onready var player_container: VBoxContainer = $VBoxContainer/PlayersContainer


func add_player(player_name: String, color = null) -> void:
	if color == null:
		color = hash_to_color(player_name)

	player_container.add_player(player_name, color)


func _on_button_pressed() -> void:
	add_player(player_name_input.text, hash_to_color(player_name_input.text))
	current_bot_index += 1


func generate_random_color() -> Color:
	var r = rngesus.randf_range(0.0, 1.0)
	var g = rngesus.randf_range(0.0, 1.0)
	var b = rngesus.randf_range(0.0, 1.0)
	return Color(r, g, b)


func hash_to_color(player_name: String) -> Color:
	# 1. Get the deterministic integer hash of the player's name
	var seed_value = hash(player_name)

	# 2. Use the hash as a seed for a temporary RandomNumberGenerator
	# This ensures the "random" values derived are always the same for this name.
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value

	# 3. Generate HSV components deterministically

	# HUE (0.0 to 1.0): This is the main color tone.
	# We want it to be as diverse as possible, so we map the hash directly
	# (0 to 1, wrapping around).
	var h = fmod(rng.randf(), 1.0)

	# SATURATION (0.0 to 1.0): How vibrant the color is.
	# We want colors to be easily visible, so we keep saturation high.
	var s = rng.randf_range(0.7, 1.0)

	# VALUE/BRIGHTNESS (0.0 to 1.0): How bright the color is.
	# Keep it bright enough to see easily.
	var v = rng.randf_range(0.8, 1.0)

	# 4. Create the Color from HSV and return it
	# The last argument (alpha) is set to 1.0 (fully opaque).
	return Color.from_hsv(h, s, v, 1.0)


func _on_start_pressed() -> void:
	start_game.emit()
