class_name Effect
extends Resource

enum TARGET {
	INVALID = -1,
	SELF,
	FACE,
	RANDOM_FRIENDLY_CARD,
	RANDOM_ENEMY_CARD,
	RANDOM_ENEMY_FACE,
}

enum EffectID {
	INVALID = -1,
	HEAL,
	ATTACK_BUFF,
	DRAW_CARD
}

enum Null{
	NULL,
}

@export var id: EffectID = EffectID.INVALID
@export var display_name: String
# we are using Dictionary as a Set here
@export var target_whitelist: Dictionary[TARGET, Null]
@export var trigger_blacklist: Dictionary[Trigger.TriggerID, Null]

@export var cost_multiplier: float = 1
@export var extra_properties: Dictionary[String, Variant] = {}

var target: TARGET

const TARGET_MULTIPLIERS = {
	TARGET.SELF: 1,
	TARGET.FACE: 1,
	TARGET.RANDOM_FRIENDLY_CARD: 1,
	TARGET.RANDOM_ENEMY_CARD: 1,
	TARGET.RANDOM_ENEMY_FACE: 1,
}


func get_id():
	return id


func get_target():
	return target


func get_property(property_name: String) -> Variant:
	return extra_properties[property_name]


func get_properties():
	return extra_properties


func get_display_name():
	return display_name


func serialize():
	return {
		"extra_properties": extra_properties,
		"target": target
	}


func deserialize(data):
	for key in data["extra_properties"]:
		extra_properties[key] = data["extra_properties"][key]

	target = data["target"]


static func get_target_name(target_value: TARGET):
	return TARGET.keys()[target_value]


func check_trigger_compatibility(trigger_id: Trigger.TriggerID):
	return not trigger_blacklist.has(trigger_id)


func get_multiplier(_trigger_id: Trigger.TriggerID):
	return cost_multiplier


func get_target_multiplier():
	# can add some overrides here using 'self' as the effect.
	return TARGET_MULTIPLIERS[target]
