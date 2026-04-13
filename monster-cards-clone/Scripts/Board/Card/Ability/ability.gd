class_name Ability
extends RefCounted


var trigger: Trigger
var effect: Effect
var active_in_hand: bool = false

signal activated(effect: Effect)

func _init(new_trigger: Trigger, new_effect: Effect):
	trigger = new_trigger
	effect = new_effect


func run():
	activated.emit(effect)


func get_trigger() -> Trigger:
	return trigger


func serialize() -> Dictionary:
	return {
		"trigger": trigger,
		"effect": effect.serialize()
	}


func deserialize(serialized: Dictionary):
	trigger = serialized["trigger"]
	effect.deserialize(serialized["effect"])


func check_compatibility() -> bool:
	if trigger and effect:
		return effect.check_trigger_compatibility(trigger.id)
	return false


func set_trigger(new_trigger: Trigger):
	trigger = new_trigger
