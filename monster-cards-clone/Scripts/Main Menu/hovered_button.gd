extends TextureButton

@export_group("Hover Settings")
@export var scale_factor: Vector2 = Vector2(1.05, 1.05)
@export var brightness_factor: float = 1.1
@export var duration: float = 0.1


func _ready():
	pivot_offset = size / 2
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)


func _on_mouse_entered():
	# Create a color that is brighter than "White"
	var bright_color = Color(brightness_factor, brightness_factor, brightness_factor)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", scale_factor, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "self_modulate", bright_color, duration).set_trans(Tween.TRANS_SINE)


func _on_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "self_modulate", Color.WHITE, duration).set_trans(Tween.TRANS_SINE)


func _on_button_down():
	scale = Vector2(0.97, 0.97)
	self_modulate = Color(0.9, 0.9, 0.9)