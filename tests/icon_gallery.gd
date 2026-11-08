extends SceneTree

var output := "user://first_light_previews/icons"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if not OS.get_environment("FIRST_LIGHT_CAPTURE_DIR").is_empty(): output = OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(540, 960)
	var icons := UIIcons.new()
	var frames := FrameLibrary.new()
	assert(icons.manifest.regions.size() == 98)
	var catalog := GameCatalog.new()
	for item in catalog.data.items:
		assert(icons.textures.has(item.id))
		assert(frames.textures["icon_" + item.id].region == icons.textures[item.id].region)
	for key in icons.manifest.regions:
		var texture: AtlasTexture = icons.textures[key]
		assert(texture.region.position.x >= 0 and texture.region.position.y >= 0)
		assert(texture.region.end.x <= texture.atlas.get_width() and texture.region.end.y <= texture.atlas.get_height())
		assert(texture.filter_clip)
		assert(not texture.get_image().is_invisible())
	for sheet in ["navigation", "systems", "equipment", "resources", "gear", "grove", "storm", "moon"]:
		var canvas := Control.new()
		root.add_child(canvas)
		var title := Label.new()
		title.text = "FIRST LIGHT · " + sheet.to_upper()
		title.position = Vector2(18, 18)
		title.add_theme_font_size_override("font_size", 24)
		canvas.add_child(title)
		for key in icons.manifest.regions:
			var spec: Dictionary = icons.manifest.regions[key]
			if spec.sheet != sheet: continue
			var cell := Panel.new()
			cell.position = Vector2(14 + (int(spec.cell) % 4) * 130, 64 + (int(spec.cell) / 4) * 218)
			cell.size = Vector2(122, 208)
			canvas.add_child(cell)
			for size in [104, 28]:
				var picture := TextureRect.new()
				picture.texture = icons.textures[key]
				picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				picture.position = Vector2(9 if size == 104 else 47, 8 if size == 104 else 124)
				picture.size = Vector2.ONE * size
				cell.add_child(picture)
			var label := Label.new()
			label.text = key
			label.position = Vector2(0, 168)
			label.size.x = 122
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 13)
			cell.add_child(label)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join("icons-" + sheet + ".png")) == OK)
		canvas.queue_free()
		await process_frame
	print("PASS: 98 visible bounded icon cells, all catalog items covered, shared UI/item regions and 28px/104px galleries")
	quit()
