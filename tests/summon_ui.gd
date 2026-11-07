extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/summon_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)
func screen() -> SummonScreen:
	return game.panel.get_child(0).body.get_child(0)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 5000
	assert(game.store.commit(p))
	game._select_tab(11)
	assert(screen().get_node_or_null("BannerPityCounter") == null)
	assert(not screen().draw_ten.disabled)
	await capture("summon-normal")
	for index in [1, 2]:
		game._select_summon_kind(index)
		assert(screen().get_node_or_null("BannerPityCounter") != null)
		assert(screen().draw_one.disabled and screen().draw_ten.disabled)
		await capture("summon-premium" if index == 1 else "summon-event")
	assert(game.store.profile == p)
	game._select_summon_kind(0)
	screen().draw_ten.pressed.emit()
	assert(game.modal != null and game.store.profile == p)
	game._summon_execute(10)
	assert(game.store.profile.gold == 3800 and game.store.profile.recruitment.count == 10)
	await capture("summon-results")
	game._close_modal()
	game._summon_history()
	await capture("summon-history")
	game._close_modal()
	game._summon_rates()
	await capture("summon-rates")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.3).timeout
	game.queue_free()
	await process_frame
	print("PASS: normal/premium/event layout, scoped counters, unavailable banners, confirmed x10 and history")
	quit()
