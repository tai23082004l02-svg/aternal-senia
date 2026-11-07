extends SceneTree

const Library = preload("res://game/core/frame_library.gd")
var frames
var board

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1080, 960)
	root.content_scale_size = Vector2i(1080, 960)
	frames = Library.new()
	board = Gallery.new()
	board.library = frames
	root.add_child(board)
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if dir.is_empty():
		dir = "user://first_light_previews"
	DirAccess.make_dir_recursive_absolute(dir)
	root.get_texture().get_image().save_png(dir.path_join("08-animation-gallery.png"))
	board.queue_free()
	await process_frame
	print("PASS: four heroes × six states, weapon sockets and foot anchors rendered")
	quit()

class Gallery extends Node2D:
	var library
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1080, 960), Color("101b2a"))
		draw_string(ThemeDB.fallback_font, Vector2(30, 45), "FIRST LIGHT / ORIGINAL FRAME REVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 25, Color("ebd7ac"))
		var states := ["idle", "run", "attack", "skill", "hurt", "death"]
		for row in range(3):
			var hero: String = ["eira", "ryn", "mira"][row]
			for col in range(6):
				var foot := Vector2(90 + col * 180, 300 + row * 290)
				var state: String = states[col]
				var frame: Dictionary = library.frame_at(hero, state, .18 if state == "run" else (.55 if state == "skill" else .5))
				library.draw_actor(self, frame, foot, ["sword_1", "spear_1", "staff_1"][row], Color.WHITE, state != "death", .52 if hero == "eira" else (.5 if hero == "ryn" else .8))
				draw_line(foot - Vector2(55, 0), foot + Vector2(55, 0), Color("64716d"), 1)
				draw_circle(foot, 3, Color("e2b785"))
				draw_string(ThemeDB.fallback_font, foot + Vector2(-65, 28), hero + " / " + state, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("b0c6c1"))
