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


func spawn_field(field: PackedScene) -> Field:
	var new_field := field.instantiate()
	set_new_field_position(new_field)
	new_field_spawned.emit(new_field)
	return new_field


func spawn_enemy_field() -> Field:
	return spawn_field(enemy_field_scene)


func spawn_your_field() -> YourField:
	return spawn_field(your_field_scene)


func set_new_field_position(new_field: Field) -> void:
	new_field.pivot_offset = new_field.size / 2
	"""
	Explanation of the new field's position:
	we cannot set its global position yet since its not in the scene tree yet
	(doing so will just set the local position instead)
	we want to set the local position to the local positon of the field spawner, however
	since we dont actually move the field spawner(we only do so by rotating the pivot)
	its local position never changes so we need to use its global position offseted by the global
	position of the pivot
	(This seems really stupid, should probably change this system later)
	And then we add the local position of the pivot cause it in the middle of the table
	since we want the new position to be relative to the table's center
	(should probably also have a more reliable way to do this too)
	and finally offset by size/2 so the field is centered

	some ideas to change this:
	add the field to the board before setting position
	actually move the field spawner instead of rotating the pivot
	have a variable here to hold the table's center
	"""
	new_field.position = field_spawner.global_position - global_position + position - new_field.size / 2
	new_field.rotation = rotation


func spawn_fields(total_player_count: int) -> void:
	spawn_your_field()
	for i in range(1, total_player_count):
		rotate_by(TAU / total_player_count)
		if animated_rotation.tween:
			await animated_rotation.tween.finished
		spawn_enemy_field()

	if animated_rotation.tween:
		await animated_rotation.tween.finished

	spawning_finished.emit()


func set_radius(new_radius: float) -> void:
	radius = new_radius
	update_object_radius(new_radius)
