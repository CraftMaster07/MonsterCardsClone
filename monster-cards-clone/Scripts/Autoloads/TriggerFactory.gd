extends Node

const TRIGGER_PLUGINS_DIR = PathConstants.TRIGGER_PLUGINS_PATH
const TRIGGER_ID = Trigger.TriggerID

# Now stores { TRIGGER_ID.ROUND_START : TriggerResourceObject }
var _trigger_cache: Dictionary[TRIGGER_ID, Trigger] = {} 


func _ready() -> void:
    _index_triggers()


func _index_triggers() -> void:
    if not DirAccess.dir_exists_absolute(TRIGGER_PLUGINS_DIR):
        push_warning("Trigger directory not found: ", TRIGGER_PLUGINS_DIR)
        return

    for file_name in DirAccess.get_files_at(TRIGGER_PLUGINS_DIR):
        # Strip the ".remap" suffix added during export
        var clean_name = file_name.trim_suffix(".remap")
        
        if clean_name.ends_with(".tres") or clean_name.ends_with(".res"):
            var full_path = TRIGGER_PLUGINS_DIR.path_join(clean_name)
            
            # Use ResourceLoader to safely check and load the mapped file
            if ResourceLoader.exists(full_path):
                var res = ResourceLoader.load(full_path) as Trigger
                
                if res:
                    # Store the actual object, not the path
                    _trigger_cache[res.id] = res


func get_trigger_names() -> Array:
    return _trigger_cache.keys()


func get_triggers() -> Array:
    return _trigger_cache.values()


## Returns a unique copy for game logic use
func get_trigger_instance(trigger_id: TRIGGER_ID) -> Trigger:
    if _trigger_cache.has(trigger_id):
        # We duplicate the cached version to get a unique instance
        return _trigger_cache[trigger_id].duplicate(true) as Trigger
    return null


## Returns the shared 'read-only' version (useful for UI/tooltips)
func get_trigger_data(trigger_id: TRIGGER_ID) -> Trigger:
    return _trigger_cache.get(trigger_id)