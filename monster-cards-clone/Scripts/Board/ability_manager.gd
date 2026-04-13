class_name AbilityManager
extends Node


const TRIGGER_ID = Trigger.TriggerID


var triggers_to_signals: Dictionary = {
	TRIGGER_ID.ROUND_START: round_start,
}


@export var board: Board

signal round_start
signal activate(effect: Effect, card: CardData, player: Player)

func subscribe_card(card: CardData, player: Player):
	var trigger_id: Trigger.TriggerID = card.get_trigger_id()

	if is_between(-1, trigger_id, Trigger.PLAYER_TRIGGER_THRESHOLD):
		triggers_to_signals[trigger_id].connect(card.run_ability)
	elif Trigger.PLAYER_TRIGGER_THRESHOLD <= trigger_id:
		player.triggers_to_signals[trigger_id].connect(card.run_ability)

	card.get_ability_signal().connect(activate_effect.bind(card, player))


func board_trigger(trigger_id):
	print("triggering board trigger: ", trigger_id)
	triggers_to_signals[trigger_id].emit()


static func is_between(minimum, n, maximum):
	return minimum < n and n < maximum


func activate_effect(effect: Effect, card: CardData, player: Player):
	activate.emit(effect, card, player)
