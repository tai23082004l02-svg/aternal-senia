extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/environment_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func run() -> void:
	var override_dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not override_dir.is_empty():
		output = override_dir
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	game.set_physics_process(false)
	game.view._process(0)
	game.view.set_process(false)
	# Review the real battle renderer with a separate test profile, no player writes.
	for stage_id in [2, 3]:
		game.selected_stage = stage_id
		game._refresh_hud()
		game.view.selected_stage = game.catalog.data.stages[stage_id - 1]
		game.view.preview.assist = "ash"
		game.view.world_time = 1.25
		game.view.world.queue_redraw()
		await capture("environment-%d" % stage_id)
	# Verify pause and speed use the battle clock, without consuming combat RNG.
	game.selected_stage = 1
	game._enter_stage(1)
	game._begin()
	game.set_physics_process(true)
	game.view.set_process(true)
	game.battle.paused = true
	await process_frame
	await RenderingServer.frame_post_draw
	var frozen: float = game.view.world_time
	var rng_state: int = game.battle.rng.state
	var motion := EnvironmentMotion.companion(frozen, game.battle.assist_flash, true)
	await create_timer(.15).timeout
	assert(game.view.world_time == frozen)
	assert(game.battle.rng.state == rng_state)
	assert(EnvironmentMotion.companion(game.view.world_time, game.battle.assist_flash, true) == motion)
	game.battle.paused = false
	await create_timer(.15).timeout
	assert(game.view.world_time > frozen)
	assert(EnvironmentMotion.companion(game.view.world_time, 0, true) != motion)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: painted ruins/lake/Ash rendered; environment freezes on pause without RNG consumption")
	quit()
