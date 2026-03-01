class_name BoardCard
extends Control

static var board_card_scene: PackedScene = preload("res://Scenes/Board/Card/board_card.tscn")
var card_data_resource = BaseCardData

var card_data
var image: Texture


func init():
	card_data = card_data_resource.new_with_init()
	update_image()


func serialize() -> Dictionary:
	return {
		"card_data": card_data.serialize(),
	}


func deserialize(data):
	card_data.deserialize(data["card_data"])
	update_image()


func update_image():
	var new_image_id = card_data.query_updated_image_id()
	if new_image_id:
		# for now, i do nothing
		pass

		# image = load("res://Assets/Sprites/BoardCards/" + str(new_image_id) + ".png")

static func instantiate_with_init():
	var new_board_card = board_card_scene.instantiate()
	new_board_card.init()
	return new_board_card
