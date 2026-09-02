class_name CardDetails
extends Control

@export var card_front: CardFront
@export var card_description_label: RichTextLabel

const CARD_DESCRIPTION_FORMAT = """[b]{}[/b]

Ability: """

const ABILITY_DESCRIPTION_FORMAT = """{}: {}"""


func display_card_details(card_data: CardData):
	card_front.set_initial_values(card_data)
	var card_description: String

	var card_name = card_data.get_card_name()

	if card_data.has_ability():
		var trigger = card_data.get_trigger().get_display_name()
		var effect = card_data.get_effect().get_display_name()

		card_description = CARD_DESCRIPTION_FORMAT.format([card_name], "{}")
		card_description += ABILITY_DESCRIPTION_FORMAT.format([trigger, effect], "{}")
	else:
		card_description = CARD_DESCRIPTION_FORMAT.format([card_name], "{}")
		card_description += "None"

	card_description_label.text = card_description
