extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1080, 1280)
	root.content_scale_size = Vector2i(1080, 1280)
	var library := FrameLibrary.new()
	var unique := {}
	for clip in library.manifest.heroes.eira.values():
		for frame in clip.frames:
			unique[frame.file] = frame
	var all_keys: Array = unique.keys()
	all_keys.sort()
	var keys: Array = all_keys.filter(func(key): return key.begins_with("painted/")) + all_keys.filter(func(key): return key.begins_with("combat/"))
	var output := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if output.is_empty():
		output = "user://first_light_previews"
	DirAccess.make_dir_recursive_absolute(output)
	for page in range(ceili(keys.size() / 16.0)):
		var board := Board.new()
		board.library = library
		board.page = page
		for key in keys.slice(page * 16, mini(keys.size(), (page + 1) * 16)):
			board.frames.append(unique[key])
		root.add_child(board)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join("11-eira-poses-page%d.png" % (page + 1))) == OK)
		board.queue_free()
		await process_frame
	print("PASS: rendered all %d Eira poses, both source atlases and weapon sockets" % keys.size())
	quit()

class Board extends Node2D:
	var library: FrameLibrary
	var frames: Array = []
	var page := 0
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1080, 1280), Color("102430"))
		draw_string(ThemeDB.fallback_font, Vector2(30, 45), "EIRA / FRAME REVIEW / PAGE %d" % (page + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("e5cf9f"))
		var old := ["Idle A", "Idle B", "Run A", "Run B", "Run C", "Run D", "Anticipation", "Windup", "Impact", "Recovery", "Cast", "Release", "Hurt", "Brace", "Kneel", "Defeat"]
		var new := ["Run bridge A", "Run bridge B", "Run bridge C", "Run bridge D", "Raise bridge", "Windup bridge", "Lunge bridge", "Follow-through", "Guard", "Block brace", "Cast bridge", "Release bridge", "Breathe A", "Breathe B", "Recoil bridge", "Ready bridge"]
		for i in range(frames.size()):
			var frame: Dictionary = frames[i]
			var label: String
			var death := false
			if frame.file.begins_with("painted/"):
				var index := int(str(frame.file).get_file().get_slice("_", 1))
				label = old[index]
				death = index >= 14
			else:
				label = new[int(str(frame.file).get_file().get_slice("_", 2))]
			var foot := Vector2(134 + (i % 4) * 270, 306 + int(i / 4.0) * 280)
			library.draw_actor(self, frame, foot, "sword_2", Color.WHITE, not death, .60)
			draw_line(foot - Vector2(95, 0), foot + Vector2(95, 0), Color("566962"), 1)
			draw_circle(foot, 3, Color("eac994"))
			draw_string(ThemeDB.fallback_font, foot + Vector2(-92, 28), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("b8c9c0"))
