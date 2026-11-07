extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(800, 680)
	root.content_scale_size = Vector2i(800, 680)
	var board := Board.new()
	root.add_child(board)
	await process_frame
	await RenderingServer.frame_post_draw
	var output := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if output.is_empty(): output = "user://first_light_previews"
	DirAccess.make_dir_recursive_absolute(output)
	assert(root.get_texture().get_image().save_png(output.path_join("icon-gallery.png")) == OK)
	board.queue_free()
	await process_frame
	print("PASS: 16 icons rendered at 32px and 64px on dark background")
	quit()

class Board extends Node2D:
	var icons := UIIcons.new()
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 800, 680), Color("0c1421"))
		draw_string(ThemeDB.fallback_font, Vector2(24, 34), "FIRST LIGHT / UI ICONS / 64 + 32 px", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("e5cd9e"))
		for i in range(16):
			var origin := Vector2((i % 4) * 200, (i / 4) * 155 + 50)
			draw_texture_rect(icons.textures[UIIcons.NAMES[i]], Rect2(origin + Vector2(35, 12), Vector2(64, 64)), false)
			draw_texture_rect(icons.textures[UIIcons.NAMES[i]], Rect2(origin + Vector2(121, 32), Vector2(32, 32)), false)
			draw_string(ThemeDB.fallback_font, origin + Vector2(28, 108), UIIcons.NAMES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("c0d0cb"))
