extends Node


const TRIGGER_PLUGINS_DIR = PathConstants.TRIGGER_PLUGINS_PATH
var _trigger_cache: Dictionary = {} # { "On Round Start": "res://triggers/round_start.tres" }

func _ready() -> void:
	_index_triggers()


func _index_triggers() -> void:
	if not DirAccess.dir_exists_absolute(TRIGGER_PLUGINS_DIR):
		return

	for file_name in DirAccess.get_files_at(TRIGGER_PLUGINS_DIR):
		# Resource files in Godot 4.x
		if file_name.ends_with(".tres"):
			var full_path = TRIGGER_PLUGINS_DIR.path_join(file_name)
			var res = load(full_path) as Trigger
			
			if res:
				# Use the 'display_name' from the Resource instead of the filename!
				_trigger_cache[res.display_name] = full_path


func get_trigger_names() -> Array:
	return _trigger_cache.keys()


## Returns a duplicate of the resource so you don't overwrite the original file data
func get_trigger(display_name: String) -> Trigger:
	if _trigger_cache.has(display_name):
		# .duplicate() is vital so each instance has its own 'amount' or 'target'
		return ResourceLoader.load(_trigger_cache[display_name], "", ResourceLoader.CACHE_MODE_IGNORE) as Trigger
	return null
