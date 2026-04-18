class_name Effect
extends Resource

enum TARGET {
	SELF,
	FACE
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


func get_id():
	return id


func get_target():
	return target


func get_property(property_name: String) -> Variant:
	print(extra_properties)
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
