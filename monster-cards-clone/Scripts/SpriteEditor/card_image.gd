class_name CardImage
extends Sprite2D


@export var _lines: Node


func add_line(line: Node) -> void:
	_lines.add_child(line)


func has_lines() -> bool:
	return _lines.get_child_count() > 0


func pop_line() -> Node:
	if not has_lines(): return
	var child = _lines.get_child(_lines.get_child_count() - 1)
	_lines.remove_child(child)
	return child


# ── Save / Load ───────────────────────────────────────────────────────────────

func save() -> void:
	SaveLoad.save(_lines)


func load() -> void:
	SaveLoad.load_into(_lines)