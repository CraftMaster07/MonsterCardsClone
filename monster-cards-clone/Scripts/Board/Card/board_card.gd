class_name BoardCard
extends Control

var card_data: CardData
var image: Texture

@export var card_front: CardFront


func _init():
	card_data = CardData.new()
	update_image()


func serialize() -> Dictionary:
	return {
		"card_data": card_data.serialize(),
	}


func deserialize(data):
	card_data.deserialize(data["card_data"])
	update_image()
	update_health_label()


func update_image():
	var new_image_id = card_data.query_updated_image_id()
	if new_image_id:
		# for now, i do nothing
		pass

		# image = load("res://Assets/Sprites/BoardCards/" + str(new_image_id) + ".png")


func hit(target):
	card_data.hit(target)


func take_damage(amount: int):
	card_data.take_damage(amount)
	update_health_label()


func update_health_label():
	card_front.update_health(card_data.health)


func is_ghost():
	return card_data.is_ghost
