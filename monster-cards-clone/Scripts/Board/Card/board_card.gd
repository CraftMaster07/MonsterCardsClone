class_name BoardCard
extends CardObject

var image: Texture

const BOARD_CARD_SCENE = preload("res://Scenes/Board/Card/board_card.tscn")


func deserialize(data: Dictionary):
	super.deserialize(data)


func hit(target):
	card_data.hit(target)


func take_damage(amount: int):
	card_data.take_damage(amount)


func is_ghost():
	return card_data.is_ghost


static func create(new_card_data: CardData) -> BoardCard:
	var card = BOARD_CARD_SCENE.instantiate() as BoardCard
	card.set_card_data(new_card_data)
	return card


func run_ability():
	card_data.run_ability()


func _on_card_front_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print(card_data.serialize())
