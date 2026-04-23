extends Node

const EFFECT_PLUGINS_DIR = PathConstants.EFFECT_PLUGINS_PATH
const EFFECT_ID = Effect.EffectID

# Now stores { EFFECT_ID.HEAL : EffectResourceObject }
var _effect_cache: Dictionary[EFFECT_ID, Effect] = {} 


func _ready() -> void:
	_index_effects()


func _index_effects() -> void:
	if not DirAccess.dir_exists_absolute(EFFECT_PLUGINS_DIR):
		push_warning("Effect directory not found: ", EFFECT_PLUGINS_DIR)
		return

	for file_name in DirAccess.get_files_at(EFFECT_PLUGINS_DIR):
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var full_path = EFFECT_PLUGINS_DIR.path_join(file_name)
			var res = load(full_path) as Effect
			
			if res:
				# Cache the object directly
				_effect_cache[res.id] = res


func get_effect_names() -> Array:
	return _effect_cache.keys()


func get_effects() -> Array:
	return _effect_cache.values()


## Returns a unique instance for gameplay (modifying stats, timers, etc.)
func get_effect_instance(effect_id: EFFECT_ID) -> Effect:
	if _effect_cache.has(effect_id):
		# Use duplicate(true) if your Effect contains other sub-resources 
		# that need to be unique (like a custom Behavior script/resource)
		return _effect_cache[effect_id].duplicate(true) as Effect
	return null


## Returns a shared reference for read-only data (UI, Tooltips, Inspectors)
func get_effect_data(effect_id: EFFECT_ID) -> Effect:
	return _effect_cache.get(effect_id)
