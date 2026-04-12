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
}

enum Null{
	NULL,
}

@export var id: EffectID
@export var display_name: String
# we are using Dictionary as a Set here
@export var target_whitelist: Dictionary[TARGET, Null]

@export var cost_multiplier: float = 1

var amount: int
var target: TARGET


func _init(new_amount: int = 1):
	amount = new_amount


func get_target():
	return target


func get_amount():
	return amount


func serialize():
	return {
		"amount": amount,
		"target": target
	}


static func get_target_name(target_value: TARGET):
	return TARGET.keys()[target_value]