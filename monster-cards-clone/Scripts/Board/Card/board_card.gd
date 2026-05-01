class_name BoardCard
extends CardObject

var image: Texture

const BOARD_CARD_SCENE = preload("res://Scenes/Board/Card/board_card.tscn")

signal card_selected(card: BoardCard)

func _ready():
	card_front.set_initial_values(card_data)
	update_image()


func deserialize(data: Dictionary):
	super.deserialize(data)
	update_image()


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


func _on_card_front_pressed() -> void:
	card_selected.emit(self )
