class_name SaveLoad


enum DrawType {
	TYPE_LINE = 0,
	TYPE_POLYGON = 1,
}


# ── Serialize ────────────────────────────────────────────────────────────────
# Returns a small Dictionary  { "size", "d" }  that fits inside the
# card's existing JSON without any double-encoding or float-string bloat.

static func serialize(lines: Node) -> Dictionary:
	var buf := StreamPeerBuffer.new()

	var children := lines.get_children()
	buf.put_u16(children.size())

	for child in children:
		if child is Line2D:
			_write_line(buf, child)
		elif child is Polygon2D:
			_write_polygon(buf, child)

	# Compress the raw bytes, then base64-encode so they sit cleanly in JSON
	var raw: PackedByteArray = buf.data_array
	var compressed := raw.compress(FileAccess.COMPRESSION_ZSTD)

	return {
		"size": raw.size(),       # needed to decompress — ZSTD requires knowing output size
		"d":    Marshalls.raw_to_base64(compressed),
	}


static func _write_color(buf: StreamPeerBuffer, c: Color) -> void:
	buf.put_u8(int(c.r * 255))
	buf.put_u8(int(c.g * 255))
	buf.put_u8(int(c.b * 255))
	buf.put_u8(int(c.a * 255))


static func _write_points(buf: StreamPeerBuffer, pts: PackedVector2Array) -> void:
	buf.put_u16(pts.size())
	for p in pts:
		buf.put_float(p.x)   # float32 — 4 bytes vs ~12 bytes as JSON text
		buf.put_float(p.y)


static func _write_line(buf: StreamPeerBuffer, line: Line2D) -> void:
	buf.put_u8(DrawType.TYPE_LINE)
	_write_color(buf, line.default_color)
	buf.put_u16(int(line.width * 10))   # one decimal place, e.g. 5.5 → 55
	_write_points(buf, line.points)


static func _write_polygon(buf: StreamPeerBuffer, poly: Polygon2D) -> void:
	buf.put_u8(DrawType.TYPE_POLYGON)
	_write_color(buf, poly.color)
	_write_points(buf, poly.polygon)


# ── Deserialize ───────────────────────────────────────────────────────────────

static func deserialize(data: Dictionary, lines: Node) -> void:
	for child in lines.get_children():
		lines.remove_child(child)
		child.queue_free()

	if not data.has("d"):
		return

	var compressed  := Marshalls.base64_to_raw(data["d"])
	var raw         := compressed.decompress(int(data["size"]), FileAccess.COMPRESSION_ZSTD)

	var buf := StreamPeerBuffer.new()
	buf.data_array = raw

	var node_count := buf.get_u16()
	for i in range(node_count):
		var type := buf.get_u8()
		match type:
			DrawType.TYPE_LINE:    lines.add_child(_read_line(buf))
			DrawType.TYPE_POLYGON: lines.add_child(_read_polygon(buf))


static func _read_color(buf: StreamPeerBuffer) -> Color:
	return Color(
		buf.get_u8() / 255.0,
		buf.get_u8() / 255.0,
		buf.get_u8() / 255.0,
		buf.get_u8() / 255.0,
	)


static func _read_points(buf: StreamPeerBuffer) -> PackedVector2Array:
	var pts: PackedVector2Array = []
	var count := buf.get_u16()
	for i in range(count):
		pts.append(Vector2(buf.get_float(), buf.get_float()))
	return pts


static func _read_line(buf: StreamPeerBuffer) -> Line2D:
	var line           := Line2D.new()
	line.default_color  = _read_color(buf)
	line.width          = buf.get_u16() / 10.0
	line.points         = _read_points(buf)
	return line


static func _read_polygon(buf: StreamPeerBuffer) -> Polygon2D:
	var poly    := Polygon2D.new()
	poly.color   = _read_color(buf)
	poly.z_index = -1
	poly.polygon = _read_points(buf)
	return poly
