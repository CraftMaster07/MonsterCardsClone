class_name Fill
extends DrawingTool


func _init(new_canvas: Node, new_color: Color) -> void:
	canvas = new_canvas
	color = new_color


func on_press(pos: Vector2) -> void:
	# Determine the raster image bounds from existing strokes + click position
	var region := _get_region(pos)
	var w := region.size.x
	var h := region.size.y
	if w <= 0 or h <= 0:
		return

	# 1. Software-rasterize all Line2D strokes into a binary (R8) image.
	#    This is a temporary scratch buffer — not stored anywhere.
	var img := Image.create(w, h, false, Image.FORMAT_R8)
	for child in canvas.get_children():
		if child is Line2D:
			_rasterize_line2d(img, child, region.position, w, h)

	# 2. Map click position into image space and bail if it lands on a stroke
	var sx := clampi(int(pos.x) - region.position.x, 0, w - 1)
	var sy := clampi(int(pos.y) - region.position.y, 0, h - 1)
	var raw := img.get_data()  # raw bytes: 0 = empty, 255 = stroke
	if raw[sy * w + sx] != 0:
		return

	# 3. BFS/DFS flood-fill the empty region from the click point
	var fill_pixels := _flood_fill(raw, Vector2i(sx, sy), w, h)
	if fill_pixels.is_empty():
		return

	# 4. Build a scanline polygon from the filled pixel set (image space)
	var contour := _scanline_polygon(fill_pixels)
	if contour.size() < 3:
		return

	# 5. Translate polygon back to world space
	var offset := Vector2(region.position)
	for i in range(contour.size()):
		contour[i] += offset

	# 6. Simplify with Ramer-Douglas-Peucker — turns the per-row polygon
	#    into a clean minimal polygon with just the meaningful corners.
	contour = _rdp(contour, 1.5)

	# 7. Store as a Polygon2D — a real vector primitive.
	#    Insert at index 0 so it sits behind all strokes.
	#    Undo/redo works exactly the same as with Line2D nodes.
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array(contour)
	poly.color = color
	poly.z_index = -1
	canvas.add_child(poly)


# ── Raster bounds ─────────────────────────────────────────────────────────────
# The image only needs to cover the area where strokes actually exist plus the
# click point. Any fill that escapes this box is an "open" region.

func _get_region(click_pos: Vector2) -> Rect2i:
	var min_x := click_pos.x
	var min_y := click_pos.y
	var max_x := click_pos.x
	var max_y := click_pos.y
	var max_radius := 1

	for child in canvas.get_children():
		if child is Line2D:
			var r := maxi(1, int(ceil(child.width * 0.5)))
			if r > max_radius:
				max_radius = r
			for pt in child.points:
				if pt.x < min_x: min_x = pt.x
				if pt.y < min_y: min_y = pt.y
				if pt.x > max_x: max_x = pt.x
				if pt.y > max_y: max_y = pt.y

	# Expand by stroke radius so thick strokes don't get clipped at the edge
	var margin := max_radius + 4
	var ox := int(floor(min_x)) - margin
	var oy := int(floor(min_y)) - margin
	var sw := int(ceil(max_x)) - ox + margin + 1
	var sh := int(ceil(max_y)) - oy + margin + 1
	return Rect2i(ox, oy, sw, sh)


# ── Software rasterizer ───────────────────────────────────────────────────────
# Draws each Line2D into the scratch image using thick-segment stamping.
# Uses set_pixel for clarity — fast enough since this runs once per click.

func _rasterize_line2d(img: Image, line: Line2D, offset: Vector2i, w: int, h: int) -> void:
	var pts := line.points
	if pts.size() < 2:
		return
	var radius := maxi(1, int(ceil(line.width * 0.5)))
	for i in range(pts.size() - 1):
		var a := Vector2i(pts[i]) - offset
		var b := Vector2i(pts[i + 1]) - offset
		_draw_thick_segment(img, a, b, radius, w, h)


func _draw_thick_segment(img: Image, a: Vector2i, b: Vector2i, radius: int, w: int, h: int) -> void:
	var dx := b.x - a.x
	var dy := b.y - a.y
	var steps := maxi(abs(dx), abs(dy))
	if steps == 0:
		_stamp_circle(img, a, radius, w, h)
		return
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var p := Vector2i(int(round(a.x + dx * t)), int(round(a.y + dy * t)))
		_stamp_circle(img, p, radius, w, h)


func _stamp_circle(img: Image, center: Vector2i, radius: int, w: int, h: int) -> void:
	var white := Color(1, 1, 1)
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius:
				var px := center.x + dx
				var py := center.y + dy
				if px >= 0 and px < w and py >= 0 and py < h:
					img.set_pixel(px, py, white)


# ── Flood fill ────────────────────────────────────────────────────────────────
# DFS stack-based fill on raw bytes (avoids per-pixel get_pixel overhead).
# Fills all connected non-stroke (value == 0) pixels reachable from start.

func _flood_fill(raw: PackedByteArray, start: Vector2i, w: int, h: int) -> Array[Vector2i]:
	var visited := PackedByteArray()
	visited.resize(w * h)
	var result: Array[Vector2i] = []
	var stack: Array[Vector2i] = [start]
	visited[start.y * w + start.x] = 1

	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		result.append(p)
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n = p + d
			if n.x < 0 or n.x >= w or n.y < 0 or n.y >= h:
				continue
			var idx = n.y * w + n.x
			if visited[idx] or raw[idx] != 0:
				continue
			visited[idx] = 1
			stack.append(n)

	return result


# ── Scanline polygon ──────────────────────────────────────────────────────────
# For each filled row, record the leftmost and rightmost pixel.
# Walk the left edge top→bottom and the right edge bottom→top to close the ring.
# This produces a correct, non-self-intersecting polygon for any simply-connected
# region (which is exactly what a stroke-bounded fill area is).

func _scanline_polygon(pixels: Array[Vector2i]) -> Array[Vector2]:
	var row_min: Dictionary = {}
	var row_max: Dictionary = {}
	for p in pixels:
		if not row_min.has(p.y) or p.x < row_min[p.y]:
			row_min[p.y] = p.x
		if not row_max.has(p.y) or p.x > row_max[p.y]:
			row_max[p.y] = p.x

	var rows: Array = row_min.keys()
	rows.sort()

	var left: Array[Vector2] = []
	var right: Array[Vector2] = []
	for y in rows:
		left.append(Vector2(row_min[y], y))
		right.append(Vector2(row_max[y], y))

	right.reverse()  # walk right edge bottom→top to close the ring
	left.append_array(right)
	return left


# ── Ramer-Douglas-Peucker polygon simplification ──────────────────────────────
# Reduces the dense per-row polygon to just the geometrically significant
# vertices. Epsilon = 1.5 px is a good default for pixel-art scale.

func _rdp(pts: Array[Vector2], eps: float) -> Array[Vector2]:
	if pts.size() <= 2:
		return pts
	return _rdp_seg(pts, 0, pts.size() - 1, eps)


func _rdp_seg(pts: Array[Vector2], lo: int, hi: int, eps: float) -> Array[Vector2]:
	if hi <= lo + 1:
		return [pts[lo], pts[hi]]
	var a := pts[lo]
	var b := pts[hi]
	var max_d := 0.0
	var max_i := lo
	for i in range(lo + 1, hi):
		var d := _seg_dist(pts[i], a, b)
		if d > max_d:
			max_d = d
			max_i = i
	if max_d <= eps:
		return [a, b]
	var left := _rdp_seg(pts, lo, max_i, eps)
	var right := _rdp_seg(pts, max_i, hi, eps)
	left.pop_back()  # drop the duplicated midpoint
	left.append_array(right)
	return left


func _seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var len_sq := ab.dot(ab)
	if len_sq == 0.0:
		return p.distance_to(a)
	var t := clampf((p - a).dot(ab) / len_sq, 0.0, 1.0)
	return p.distance_to(a + ab * t)