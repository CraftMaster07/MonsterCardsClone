extends ObjectPivot

@export var enemy_player_area_scene: PackedScene
@export var your_player_area_scene: PackedScene
@export var player_area_spawner: Control

var radius: float

signal new_area_spawned(field: Field)
signal spawning_finished()


func _ready() -> void:
	super._ready()
	set_revolving_object(player_area_spawner)


func spawn_area(player_area: PackedScene):
	var new_player_area: PlayerArea = spawn_at_object_position(player_area)
	new_area_spawned.emit(new_player_area)


func spawn_enemy_area():
	spawn_area(enemy_player_area_scene)


func spawn_your_area():
	spawn_area(your_player_area_scene)


func spawn_player_areas(total_player_count: int) -> void:
	spawn_your_area()

	for i in range(1, total_player_count):
		rotate_by(TAU / total_player_count, 0)
		if animated_rotation.tween:
			await animated_rotation.tween.finished
		spawn_enemy_area()

	if animated_rotation.tween:
		await animated_rotation.tween.finished

	spawning_finished.emit()


func set_radius(new_radius: float) -> void:
	radius = new_radius
	update_object_radius(new_radius)
