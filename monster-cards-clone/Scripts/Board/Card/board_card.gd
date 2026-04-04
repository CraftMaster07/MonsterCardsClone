class_name BoardCard
extends CardSerializer

var image: Texture

@export var card_front: CardFront

const BOARD_CARD_SCENE = preload("res://Scenes/Board/Card/board_card.tscn")


func _ready():
	card_front.set_initial_values(card_data)
	update_image()


func deserialize(data: Dictionary):
	super.deserialize(data)
	update_image()
	update_labels()


func update_image():
	var new_image_id = card_data.query_updated_image_id()
	if new_image_id:
		# image = load("res://Assets/Sprites/BoardCards/" + str(new_image_id) + ".png")
		# for now, i do nothing
		pass


func hit(target):
	card_data.hit(target)


func take_damage(amount: int):
	card_data.take_damage(amount)
	update_labels()


func update_labels():
	card_front.update_labels(card_data)


func is_ghost():
	return card_data.is_ghost


static func create(new_card_data: CardData) -> BoardCard:
	var card = BOARD_CARD_SCENE.instantiate() as BoardCard
	card.set_card_data(new_card_data)
	return card


func set_card_data(new_card_data: CardData):
	card_data = new_card_data


func run_ability():
	card_data.run_ability()


func get_card_data():
	return card_data