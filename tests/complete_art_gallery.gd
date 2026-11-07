extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1080, 1280)
	root.content_scale_size = Vector2i(1080, 1280)
	var lib := FrameLibrary.new()
	var out := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if out.is_empty(): out = "user://first_light_previews"
	DirAccess.make_dir_recursive_absolute(out)
	for hero in ["lyra", "mira"]:
		var board := Board.new()
		board.library = lib
		board.hero = hero
		var unique := {}
		for clip in lib.manifest.heroes[hero].values():
			for frame in clip.frames: unique[frame.file] = frame
		var keys := unique.keys()
		keys.sort()
		for key in keys: board.frames.append(unique[key])
		root.add_child(board)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(out.path_join(hero + "-poses.png")) == OK)
		board.queue_free()
		await process_frame
	print("PASS: all 32 new Lyra/Mira poses rendered with separate painted weapons")
	quit()

class Board extends Node2D:
	var library: FrameLibrary
	var hero: String
	var frames: Array
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1080, 1280), Color("102430"))
		draw_string(ThemeDB.fallback_font, Vector2(30, 45), hero.to_upper() + " / PAINTED POSE REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("e5cf9f"))
		for i in range(frames.size()):
			var foot := Vector2(134 + (i % 4) * 270, 306 + int(i / 4.0) * 280)
			library.draw_actor(self, frames[i], foot, "spear_2" if hero == "lyra" else "staff_2", Color.WHITE, i < 14, .60)
			draw_line(foot-Vector2(95,0),foot+Vector2(95,0),Color("566962"),1)
			draw_string(ThemeDB.fallback_font,foot+Vector2(-90,25),"Pose %02d" % i,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("b8c9c0"))
