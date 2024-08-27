extends Node2D

const CARD = preload("res://scenes/card.tscn")

var hand_ratio: float
@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve
@export var HAND_WIDTH: float = 30.0
@export var HAND_HEIGHT: float = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_cards(5)
	order_cards()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_cards(amount: int) -> void:
	for _x in range(amount):
		var card = CARD.instantiate()
		add_child(card)
	
func order_cards() -> void:
	for card in get_children():
		if get_child_count() > 1:
			hand_ratio = float(card.get_index()) / float(get_child_count()-1)
		else:
			hand_ratio = 0.5
		
		card.position.x += spread_curve.sample(hand_ratio) * HAND_WIDTH
		card.position += height_curve.sample(hand_ratio) * Vector2.UP * HAND_HEIGHT
		print(rotation_curve.sample(hand_ratio) * 0.3)
		card.rotation = rotation_curve.sample(hand_ratio) * 0.3
