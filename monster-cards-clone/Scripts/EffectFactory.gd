extends Node


const EFFECT_PLUGINS_DIR = PathConstants.EFFECT_PLUGINS_PATH

# This stays empty; the script fills it automatically
var _effect_paths: Dictionary = {}


func _ready() -> void:
	_auto_scan_directory()


func _auto_scan_directory() -> void:
	if not DirAccess.dir_exists_absolute(EFFECT_PLUGINS_DIR):
		push_error("Directory not found: " + EFFECT_PLUGINS_DIR)
		return

	# get_files_at is a Godot 4+ shortcut that returns an array of strings
	for file_name in DirAccess.get_files_at(EFFECT_PLUGINS_DIR):
		# The 'Export Trap': in build, .gd files become .gd.remap or .gdc
		if file_name.ends_with(".gd") or file_name.ends_with(".gdc") or file_name.ends_with(".remap"):
			# Clean the path so Godot's load() can understand it
			var clean_name = file_name.replace(".remap", "").replace(".gdc", "").replace(".gd", "")
			var full_path = EFFECT_PLUGINS_DIR.path_join(clean_name + ".gd")
			
			# Map "Fireball" -> "res://effects/Fireball.gd"
			_effect_paths[clean_name] = full_path


func get_effect_names() -> Array:
	return _effect_paths.keys()


## Logic calls this to get the actual script/object
func load_effect(effect_name: String) -> Effect:
	if _effect_paths.has(effect_name):
		var script = load(_effect_paths[effect_name])
		return script.new()
	return null
