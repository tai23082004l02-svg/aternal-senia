extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/ryn_gallery_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func run() -> void:
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty(): output = dir
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1, 2]
	assert(game.store.commit(p))
	game._select_tab(1)
	game._inspect_character("ryn")
	await capture("ryn-character")
	game._show_ryn_portrait()
	await capture("ryn-portrait-large")
	game._close_modal()
	game._hero("ryn")
	game._select_tab(0)
	game._enter_stage(1)
	game._begin()
	game.set_physics_process(false)
	game.view.set_process(false)
	assert(game.battle is TeamBattle and game.battle.allies[0].id == "ryn")
	game.battle._schedule_ally(game.battle.allies[0], "attack", 1.0, .22, .52)
	for i in range(14):
		game.battle.advance(BattleModel.STEP)
	game._refresh_hud()
	await capture("ryn-battle-thrust")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	await RenderingServer.frame_post_draw
	await create_timer(.2).timeout
	print("PASS: adult Ryn face/portrait/large touch view and real battle thrust rendered")
	quit()
