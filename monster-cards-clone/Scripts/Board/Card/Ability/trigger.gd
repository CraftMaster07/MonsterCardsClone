class_name Trigger
extends Resource

const PLAYER_TRIGGER_THRESHOLD = 50
const SINGLE_TIME_TRIGGER_THRESHOLD = 100

enum TriggerID {
	INVALID = -1,
	ROUND_START,
	DRAW_CARD = PLAYER_TRIGGER_THRESHOLD,
	ON_FACE_DAMAGED,
	WHEN_PLAYED = SINGLE_TIME_TRIGGER_THRESHOLD,
	WHEN_DESTROYED,
}


@export var id: TriggerID = TriggerID.INVALID
@export var display_name: String

@export var cost_multiplier: float = 1


func get_id() -> TriggerID:
	return id


func get_display_name() -> String:
	return display_name


func serialize() -> Dictionary:
	return {
	}


func deserialize(_data: Dictionary):
	pass


func get_multiplier(_effect_id: Effect.EffectID) -> float:
	return cost_multiplier