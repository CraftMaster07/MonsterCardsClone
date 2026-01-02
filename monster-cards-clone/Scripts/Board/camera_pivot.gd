extends ObjectPivot


@export var camera: Camera2D
@export var hand: Hand


func _ready() -> void:
	super._ready()
	set_revolving_object(camera)


func update_camera_radius(new_radius: float):
	update_object_radius(new_radius)
