class_name Ability
extends RefCounted


var trigger: Trigger
var effect: Effect
var active_in_hand: bool = false

const TRIGGER_ID = Trigger.TriggerID
const EFFECT_ID = Effect.EffectID

signal activated(effect: Effect)


static func create_from_serialized(serialized: Dictionary):
	var ability = Ability.new(null, null)
	ability.deserialize(serialized)
	return ability


func _init(new_trigger: Trigger, new_effect: Effect):
	trigger = new_trigger
	effect = new_effect


func run():
	print("running ability: ", effect.get_id())
	activated.emit(effect)


func get_trigger() -> Trigger:
	return trigger


func serialize() -> Dictionary:
	var data = {}

	if trigger:
		data["trigger_id"] = trigger.get_id()
		data["trigger"] = trigger.serialize()
	
	if effect:
		data["effect_id"] = effect.get_id()
		data["effect"] = effect.serialize()
	
	return data


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


func get_trigger_multiplier() -> float:
	if not trigger: return 0
	return trigger.get_multiplier(effect.get_id() if effect else EFFECT_ID.INVALID)


func get_effect_multiplier() -> float:
	if not effect: return 0
	return effect.get_multiplier(trigger.get_id() if trigger else TRIGGER_ID.INVALID)


func get_target_multiplier() -> float:
	if not effect: return 0
	print("target multiplier: ", effect.get_target_multiplier())
	return effect.get_target_multiplier()
