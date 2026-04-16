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
		"trigger_id" : trigger.get_id(),
		"trigger": trigger.serialize(),
		"effect_id": effect.get_id(),
		"effect": effect.serialize()
	}


func deserialize(serialized: Dictionary):
	if not trigger or serialized["trigger_id"] != trigger.get_id():
		# free the old trigger?
		trigger = TriggerFactory.get_trigger_instance(serialized["trigger_id"])

	trigger.deserialize(serialized["trigger"])

	if not effect or serialized["effect_id"] != effect.get_id():
		effect = EffectFactory.get_effect_instance(serialized["effect_id"])

	effect.deserialize(serialized["effect"])


func check_compatibility() -> bool:
	if trigger and effect:
		return effect.check_trigger_compatibility(trigger.get_id())
	return false


func set_trigger(new_trigger: Trigger):
	trigger = new_trigger
