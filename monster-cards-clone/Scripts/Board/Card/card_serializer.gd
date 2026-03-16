class_name CardSerializer
extends Control
# The reason this exists is because both hand card and board card share the same serialize and deserialize methods


var card_data: CardData


func serialize() -> Dictionary:
	# If we ever need to change that, mind the shadow_deserialize too.
	return card_data.serialize()


func deserialize(data: Dictionary):
	card_data.deserialize(data)
