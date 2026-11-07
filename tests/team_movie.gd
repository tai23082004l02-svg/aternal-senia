extends SceneTree
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/team_movie_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func run() -> void:
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	game.set_physics_process(false)
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1,2]
	p.hero = "ryn"
	p.assist = "ash"
	p.formation = {"slots":["ryn","mira","eira"],"auto_ult":true,"auto_next":false}
	assert(game.store.commit(p))
	game.selected_stage = 6
	assert(game.store.begin_run(6))
	p = game.store.profile.duplicate(true)
	p.pending.seed = 17
	assert(game.store.commit(p))
	game._resume()
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	assert(not dir.is_empty())
	DirAccess.make_dir_recursive_absolute(dir)
	for i in range(180):
		game.battle.advance(1.0 / 30)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(dir.path_join("frame-%03d.png" % i)) == OK)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: 180 frames of real 3vN model and painted renderer")
	quit()
