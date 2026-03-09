extends ObjectPivot

@export var enemy_field_scene: PackedScene
@export var your_field_scene: PackedScene
@export var field_spawner: Control

var radius: float

signal new_field_spawned(field: Field)
signal spawning_finished()


func _ready() -> void:
	super._ready()
	set_revolving_object(field_spawner)


func spawn_field(field: PackedScene):
	var new_field: Field = spawn_at_object_position(field)
	new_field_spawned.emit(new_field)


func spawn_enemy_field():
	spawn_field(enemy_field_scene)


func spawn_your_field():
	spawn_field(your_field_scene)


func spawn_fields(total_player_count: int) -> void:
	spawn_your_field()

	for i in range(1, total_player_count):
		rotate_by(TAU / total_player_count, 0)
		if animated_rotation.tween:
			await animated_rotation.tween.finished
		spawn_enemy_field()

	if animated_rotation.tween:
		await animated_rotation.tween.finished

	spawning_finished.emit()


func set_radius(new_radius: float) -> void:
	radius = new_radius
	update_object_radius(new_radius)
