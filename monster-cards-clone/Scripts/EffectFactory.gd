extends Node


const EFFECT_PLUGINS_DIR = PathConstants.EFFECT_PLUGINS_PATH
var _effect_cache: Dictionary = {} # { "Heal": "res://effects/heal_base.tres" }

func _ready() -> void:
	_index_effects()


func _index_effects() -> void:
	if not DirAccess.dir_exists_absolute(EFFECT_PLUGINS_DIR):
		return

	for file_name in DirAccess.get_files_at(EFFECT_PLUGINS_DIR):
		# Resource files in Godot 4.x
		if file_name.ends_with(".tres"):
			var full_path = EFFECT_PLUGINS_DIR.path_join(file_name)
			var res = load(full_path) as Effect
			
			if res:
				# Use the 'display_name' from the Resource instead of the filename!
				_effect_cache[res.display_name] = full_path


func get_effect_names() -> Array:
	return _effect_cache.keys()


## Returns a duplicate of the resource so you don't overwrite the original file data
func get_effect(display_name: String) -> Effect:
	if _effect_cache.has(display_name):
		# .duplicate() is vital so each instance has its own 'amount' or 'target'
		return ResourceLoader.load(_effect_cache[display_name], "", ResourceLoader.CACHE_MODE_IGNORE) as Effect
	return null
