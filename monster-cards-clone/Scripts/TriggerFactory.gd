extends Node

const TRIGGER_PLUGINS_DIR = PathConstants.TRIGGER_PLUGINS_PATH

# Now stores { "Display Name": TriggerResourceObject }
var _trigger_cache: Dictionary = {} 


func _ready() -> void:
	_index_triggers()


func _index_triggers() -> void:
	if not DirAccess.dir_exists_absolute(TRIGGER_PLUGINS_DIR):
		push_warning("Trigger directory not found: ", TRIGGER_PLUGINS_DIR)
		return

	for file_name in DirAccess.get_files_at(TRIGGER_PLUGINS_DIR):
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var full_path = TRIGGER_PLUGINS_DIR.path_join(file_name)
			var res = load(full_path) as Trigger
			
			if res:
				# Store the actual object, not the path
				_trigger_cache[res.display_name] = res


func get_trigger_names() -> Array:
	return _trigger_cache.keys()


func get_triggers() -> Array:
	return _trigger_cache.values()


## Returns a unique copy for game logic use
func get_trigger_instance(display_name: String) -> Trigger:
	if _trigger_cache.has(display_name):
		# We duplicate the cached version to get a unique instance
		return _trigger_cache[display_name].duplicate() as Trigger
	return null


## Returns the shared 'read-only' version (useful for UI/tooltips)
func get_trigger_data(display_name: String) -> Trigger:
	return _trigger_cache.get(display_name)
