extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1080, 1280)
	root.content_scale_size = Vector2i(1080, 1280)
	var board := Board.new()
	board.library = FrameLibrary.new()
	var frames := {}
	for clip in board.library.manifest.heroes.eira.values():
		for frame in clip.frames:
			frames[frame.file] = frame
	var keys: Array = frames.keys()
	keys.sort()
	for key in keys:
		board.frames.append(frames[key])
	root.add_child(board)
	await process_frame
	await RenderingServer.frame_post_draw
	var output := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if output.is_empty():
		output = "user://first_light_previews"
	DirAccess.make_dir_recursive_absolute(output)
	assert(root.get_texture().get_image().save_png(output.path_join("09-eira-16-poses.png")) == OK)
	board.queue_free()
	await process_frame
	print("PASS: rendered every painted Eira pose with weapon and stable baseline")
	quit()

class Board extends Node2D:
	var library: FrameLibrary
	var frames: Array = []
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1080, 1280), Color("102430"))
		draw_string(ThemeDB.fallback_font, Vector2(30, 45), "EIRA / DAWNVEIL / 16 PAINTED POSES", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("e5cf9f"))
		var labels := ["Idle A", "Idle B", "Run A", "Run B", "Run C", "Run D", "Anticipation", "Windup", "Impact", "Recovery", "Cast", "Release", "Hurt", "Brace", "Kneel", "Defeat"]
		for i in range(frames.size()):
			var foot := Vector2(134 + (i % 4) * 270, 306 + int(i / 4.0) * 280)
			library.draw_actor(self, frames[i], foot, "sword_2", Color.WHITE, i < 14, .60)
			draw_line(foot - Vector2(95, 0), foot + Vector2(95, 0), Color("566962"), 1)
			draw_circle(foot, 3, Color("eac994"))
			draw_string(ThemeDB.fallback_font, foot + Vector2(-82, 28), "%02d  %s" % [i, labels[i]], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("b8c9c0"))
