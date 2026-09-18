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
        # FIX: Godot 4 appends ".remap" to exported resources. 
        # We must strip it so ResourceLoader can recognize the original path.
        var clean_name = file_name.trim_suffix(".remap")
        
        if clean_name.ends_with(".tres") or clean_name.ends_with(".res"):
            var full_path = EFFECT_PLUGINS_DIR.path_join(clean_name)
            
            # Safely check if the engine recognizes the resource
            if ResourceLoader.exists(full_path):
                var res = ResourceLoader.load(full_path) as Effect
                
                if res:
                    _effect_cache[res.id] = res


func get_effect_names() -> Array:
    return _effect_cache.keys()


func get_effects() -> Array:
    return _effect_cache.values()


func get_effect_instance(effect_id: EFFECT_ID) -> Effect:
    if _effect_cache.has(effect_id):
        return _effect_cache[effect_id].duplicate(true) as Effect
    return null


func get_effect_data(effect_id: EFFECT_ID) -> Effect:
    return _effect_cache.get(effect_id)