class_name CardDetails
extends Control

@export var card_front: CardFront
@export var card_description_label: RichTextLabel

const CARD_DESCRIPTION_FORMAT = """[center][font_size=24][b]{card_name}[/b][/font_size][/center]
[center][color=#888888]Forged by: {creator_name}[/color][/center]

[center][color=#e0e0e0]{abilities}[/color][/center]



[center][font_size=16][color=#666666][i]"{creator_note}"[/i][/color][/font_size][/center]"""

const ABILITY_DESCRIPTION_FORMAT = """[color=#ffcc00][b]{trigger}: {effect} {target}[/b][/color]"""


func display_card_details(card_data: CardData):
	card_front.set_initial_values(card_data)
	var card_description: String

	var card_name = card_data.get_card_name()

	if card_data.has_ability():
		var trigger = card_data.get_trigger().get_display_name()
		var effect = card_data.get_effect().get_display_name()
		var target = card_data.get_effect().get_target_display_name()

		var ability_description = ABILITY_DESCRIPTION_FORMAT.format({"trigger": trigger, "effect": effect, "target": target})
		card_description = CARD_DESCRIPTION_FORMAT.format({
			"card_name": card_name,
			"creator_name": card_data.get_creator_name(),
			"abilities": ability_description,
			"creator_note": card_data.get_creator_note()
		})
	else:
		card_description = CARD_DESCRIPTION_FORMAT.format({
			"card_name": card_name,
			"creator_name": card_data.get_creator_name(),
			"abilities": "",
			"creator_note": card_data.get_creator_note()
		})

	card_description_label.text = card_description
