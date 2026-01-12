extends ObjectPivot

@export var enemy_field_scene: PackedScene
@export var your_field_scene: PackedScene
@export var board: Control
@export var field_spawner: Control

var radius: float

signal spawning_finished()


func _ready() -> void:
	super._ready()
	set_revolving_object(field_spawner)


func spawn_field(field: PackedScene) -> Field:
	var new_field := field.instantiate()
	set_new_field_position(new_field)
	board.add_child(new_field)
	return new_field


func spawn_enemy_field() -> Field:
	return spawn_field(enemy_field_scene)


func spawn_your_field() -> YourField:
	return spawn_field(your_field_scene)


func set_new_field_position(new_field: Field) -> void:
	new_field.pivot_offset = new_field.size / 2
	new_field.global_position = field_spawner.global_position - new_field.size / 2
	new_field.rotation = rotation


func set_radius_and_spawn_fields(table_radius: float, total_player_count: int) -> void:
	update_object_radius(table_radius)
	spawn_fields(total_player_count)
	spawning_finished.emit()



func spawn_fields(total_player_count: int) -> void:
	board.set_your_field(spawn_your_field())

	for i in range(1, total_player_count):
		rotate_by(TAU / total_player_count)
		if tween:
			await tween.finished
		spawn_enemy_field()

	if tween:
		await tween.finished



func set_radius(new_radius: float) -> void:
	radius = new_radius
