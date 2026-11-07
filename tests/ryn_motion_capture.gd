extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(420, 640)
	root.content_scale_size = Vector2i(420, 640)
	var background := ColorRect.new()
	background.size = Vector2(420, 640)
	background.color = Color("101e2a")
	root.add_child(background)
	var label := Label.new()
	label.text = "RYN / TAP + DRAG"
	label.position = Vector2(24, 20)
	label.add_theme_font_size_override("font_size", 20)
	label.modulate = Color("e5cd9e")
	root.add_child(label)
	var view := HeroPortrait.new()
	view.library = FrameLibrary.new()
	view.hero = "ryn"
	view.interactive = true
	view.position = Vector2(10, 62)
	view.size = Vector2(400, 540)
	root.add_child(view)
	view.set_process(false)
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if dir.is_empty(): dir = "user://first_light_previews/ryn-motion"
	DirAccess.make_dir_recursive_absolute(dir)
	for i in range(90):
		if i == 12: view.begin_touch(Vector2(200, 250), 0)
		if i == 13: view.end_touch()
		if i == 35: view.begin_touch(Vector2(200, 250), 0)
		if i >= 36 and i <= 50:
			view.move_touch(Vector2(200, 250) + Vector2((i - 35) * 5, -(i - 35) * 2))
		if i == 51: view.end_touch()
		view.advance_motion(1.0 / 30)
		view.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(dir.path_join("frame-%03d.png" % i)) == OK)
	view.queue_free()
	background.queue_free()
	label.queue_free()
	await process_frame
	await RenderingServer.frame_post_draw
	print("PASS: recorded 90 real rendered Ryn tap/drag frames")
	quit()
