extends Node


var sprite_hashes: Dictionary[String, Dictionary] = {}


func add_sprite(serialized_sprite: Dictionary) -> String:
    var sprite_hash = JSON.stringify(serialized_sprite).md5_text()

    if not has_sprite(sprite_hash):
        sprite_hashes[sprite_hash] = serialized_sprite

    return sprite_hash


func get_serialized_sprites() -> Dictionary:
    return sprite_hashes


func has_sprite(sprite_hash: String) -> bool:
    return sprite_hash in sprite_hashes


func get_serialized_sprite(sprite_hash: String) -> Dictionary:
    if not has_sprite(sprite_hash):
        return {}

    return sprite_hashes[sprite_hash]


func get_sprite(sprite_hash: String, size: Vector2i = Vector2i(60, 90)) -> ImageTexture:
    var baked_sprite_image: Image = get_cached_baked_sprite(sprite_hash)

    if baked_sprite_image == null:
        if sprite_hash not in sprite_hashes:
            return null

        print("Baking sprite: ", sprite_hash)
        baked_sprite_image = await _bake(sprite_hashes[sprite_hash], size)
        save_baked_sprite(sprite_hash, baked_sprite_image)
    
    var baked_sprite := ImageTexture.create_from_image(baked_sprite_image)
    return baked_sprite


func get_cached_baked_sprite(sprite_hash: String) -> Image:
    var err: int

    if sprite_hash.is_empty():
        push_error("Sprite hash is empty.")
        return null

    if not DirAccess.dir_exists_absolute(PathConstants.BAKED_SPRITES_PATH):
        err = DirAccess.make_dir_absolute(PathConstants.BAKED_SPRITES_PATH)

        if err != OK:
            push_error("Failed to create baked sprites directory. Error code: ", err)

        return null

    var file_path = PathConstants.BAKED_SPRITES_PATH.path_join(sprite_hash + ".png")

    if not FileAccess.file_exists(file_path):
        return null

    var image = Image.new()
    err = image.load(file_path)
    
    if err != OK:
        push_error("Failed to load image at: ", file_path, " Error code: ", err)
        return null
    
    return image


static func save_baked_sprite(sprite_hash: String, image: Image):
    var file_path = PathConstants.BAKED_SPRITES_PATH.path_join(sprite_hash + ".png")
    var err = image.save_png(file_path)
    if err != OK:
        push_error("Failed to save image at: ", file_path, " Error code: ", err)


static func _bake(data: Dictionary, size: Vector2i) -> Image:
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
 
    # 7. Clean up
    viewport.queue_free()
    
    return image


func clear_cache():
    var err: int
    var undeleted_files: Array[String]
    var dir = DirAccess.open(PathConstants.BAKED_SPRITES_PATH)
    dir.list_dir_begin()
    var file_name = dir.get_next()

    while file_name != "":
        if file_name.ends_with(".png"):
            err = dir.remove(file_name)

            if err != OK:
                undeleted_files.append(file_name)

        file_name = dir.get_next()
    
    dir.list_dir_end()

    if undeleted_files.size() > 0:
        push_error("Failed to delete these files: ", undeleted_files)

    return undeleted_files.size() == 0
