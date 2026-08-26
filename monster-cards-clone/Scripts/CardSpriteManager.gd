extends Node


var sprite_hashes: Dictionary[String, Dictionary] = {}
var baked_sprites: Dictionary[String, ImageTexture] = {}


func add_sprite(serialized_sprite: Dictionary):
	var sprite_hash = JSON.stringify(serialized_sprite).md5_text()

	if not has_sprite(sprite_hash):
		sprite_hashes[sprite_hash] = serialized_sprite

	return sprite_hash


func get_serialized_sprites():
	return sprite_hashes


func has_sprite(sprite_hash: String):
	return sprite_hash in sprite_hashes


func get_serialized_sprite(sprite_hash: String):
	return sprite_hashes[sprite_hash]


func get_sprite(sprite_hash: String, size: Vector2i = Vector2i(90, 60)):
	if sprite_hash not in sprite_hashes:
		return null

	if sprite_hash in baked_sprites:
		return baked_sprites[sprite_hash]

	var baked_sprite = await _bake(sprite_hashes[sprite_hash], size)
	baked_sprites[sprite_hash] = baked_sprite

	return baked_sprite



static func _bake(data: Dictionary, size: Vector2i) -> ImageTexture:
	"""
	Usage:
	var texture = await CardSpriteManager.bake(card_file.card_image, Vector2i(300, 420))
	$Sprite2D.texture = texture
	"""
	# 1. SubViewport to render into
	var viewport := SubViewport.new()
	viewport.size = size
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
 
	# 2. Node2D root for the deserialized strokes
	var lines_root := Node2D.new()
	viewport.add_child(lines_root)
 
	# 3. Deserialize straight into it — SaveLoad stores raw pixel coords so
	#    no coordinate scaling is needed; the strokes land exactly as drawn
	SaveLoad.deserialize(data, lines_root)
 
	# 4. Must be in the scene tree before the renderer can see it
	Engine.get_main_loop().root.add_child(viewport)
 
	# 5. Wait one frame for the SubViewport to render
	await RenderingServer.frame_post_draw
 
	# 6. Grab the image and wrap it
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("CardBaker: viewport rendered an empty image")
		viewport.queue_free()
		return null
 
	var texture := ImageTexture.create_from_image(image)
 
	# 7. Clean up
	viewport.queue_free()
	
	return texture
