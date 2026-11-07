extends SceneTree

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/portrait_touch_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func run() -> void:
	var frames := FrameLibrary.new()
	var portrait := HeroPortrait.new()
	portrait.library = frames
	portrait.interactive = true
	portrait.size = Vector2(270, 205)
	root.add_child(portrait)
	portrait.begin_touch(Vector2(100, 100), 0)
	portrait.move_touch(Vector2(1000, -1000))
	assert(portrait.dragging and portrait.motion.length() <= 11.01)
	portrait.begin_touch(Vector2.ZERO, 1)
	assert(portrait.pointer == 0, "Secondary pointer cannot steal grab")
	portrait.end_touch()
	var previous := portrait.motion
	for i in range(30): portrait.advance_motion(1.0 / 60)
	assert(portrait.motion != previous and portrait.motion.length() <= 14.01)
	for i in range(240): portrait.advance_motion(1.0 / 60)
	assert(portrait.motion == Vector2.ZERO and portrait.velocity == Vector2.ZERO)
	portrait.begin_touch(Vector2(100, 100), 0)
	portrait.end_touch()
	portrait.advance_motion(1.0 / 60)
	assert(portrait.motion.y < 0, "Tap causes bounded rebound")
	portrait._notification(Control.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
	assert(not portrait.dragging)
	for i in range(100): portrait.advance_motion(10)
	assert(is_finite(portrait.motion.x) and portrait.motion.length() <= 14.01)
	portrait.queue_free()
	await process_frame
	print("PASS: portrait tap/drag, bounded rebound, settle, multitouch ownership, focus reset and long-frame stability")
	quit()
