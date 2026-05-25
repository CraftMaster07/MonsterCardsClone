class_name SaveLoad


const VERSION := 1
const SAVE_PATH := "user://sprite.json"


# ── Save ─────────────────────────────────────────────────────────────────────

static func serialize(lines: Node) -> Dictionary:
	var nodes: Array = []

	for child in lines.get_children():
		if child is Line2D:
			nodes.append(_serialize_line(child))
		elif child is Polygon2D:
			nodes.append(_serialize_polygon(child))

	return {"nodes": JSON.stringify(nodes, "\t")}


static func _serialize_line(line: Line2D) -> Dictionary:
	var pts: Array = []
	for p in line.points:
		pts.append([p.x, p.y])

	return {
		"type": "line",
		"points": pts,
		"color": _color_to_array(line.default_color),
		"width": line.width,
	}


static func _serialize_polygon(poly: Polygon2D) -> Dictionary:
	var pts: Array = []
	for p in poly.polygon:
		pts.append([p.x, p.y])

	return {
		"type": "polygon",
		"polygon": pts,
		"color": _color_to_array(poly.color),
	}


static func _color_to_array(c: Color) -> Array:
	return [c.r, c.g, c.b, c.a]


# ── Load ─────────────────────────────────────────────────────────────────────

static func deserialize(data: Dictionary, lines: Node) -> void:

	var nodes = JSON.parse_string(data["nodes"])
	if not nodes is Dictionary:
		push_error("SaveLoad: invalid JSON in %s" % SAVE_PATH)
		return

	# Clear existing canvas (including the undo stack in the caller if needed)
	for child in lines.get_children():
		lines.remove_child(child)
		child.queue_free()

	for entry in nodes.get("nodes", []):
		match entry.get("type", ""):
			"line":    lines.add_child(_deserialize_line(entry))
			"polygon": lines.add_child(_deserialize_polygon(entry))


static func _deserialize_line(d: Dictionary) -> Line2D:
	var line := Line2D.new()
	line.default_color = _array_to_color(d["color"])
	line.width = float(d["width"])
	for p in d["points"]:
		line.add_point(Vector2(float(p[0]), float(p[1])))
	return line


static func _deserialize_polygon(d: Dictionary) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = _array_to_color(d["color"])
	poly.z_index = -1  # fills always render behind strokes
	var pts: PackedVector2Array = []
	for p in d["polygon"]:
		pts.append(Vector2(float(p[0]), float(p[1])))
	poly.polygon = pts
	return poly


static func _array_to_color(a: Array) -> Color:
	return Color(float(a[0]), float(a[1]), float(a[2]), float(a[3]))
