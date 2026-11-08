extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/journey_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)
func screen() -> JourneyScreen:
	return game.panel.get_child(0)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	game._select_tab(0)
	assert(screen().progress_text.text == "Chapter progress · 0/3 stages")
	assert(not screen().auto_play.disabled and not screen().challenge.disabled)
	var original: Dictionary = game.store.profile.duplicate(true)
	await capture("journey-top")
	assert(screen().challenge.get_global_rect().end.y <= 864, "Primary action fits above navigation")
	assert(screen().auto_play.get_global_rect().end.y <= 864, "Auto settings fit above navigation")
	for control in screen().find_children("*", "Button", true, false):
		assert(control.get_global_rect().end.x <= 516, "Journey actions fit portrait width")
		assert(control.get_global_rect().end.y <= 864, "Default journey actions are visible without scrolling")
	game.scroll.scroll_vertical = 500
	await capture("journey-actions")
	game._journey_afk()
	await capture("journey-afk")
	game._close_modal()
	assert(game.store.profile == original)
	var p: Dictionary = original.duplicate(true)
	p.cleared = [1, 6, 7]
	p.last_offline = int(Time.get_unix_time_from_system()) - 120
	assert(game.store.commit(p))
	game._refresh_panel()
	assert(not screen().auto_play.disabled)
	assert(screen().progress_text.text == "Chapter progress · 3/3 stages")
	game._journey_afk()
	game._journey_claim_afk()
	assert(game.store.profile.gold >= 8)
	assert(game.store.profile.missions.daily.counts.offline == 1)
	game._choose_stage(6)
	assert(JourneyScreen.stage_code(game.catalog, game.catalog.find_row("stages", 6)) == "1-2")
	game._journey_auto()
	assert(game.modal != null)
	game._begin()
	assert(game.battle != null and game.battle.auto_attack)
	assert(game.team_ui.visible and game.store.profile.pending.stage == 6)
	await capture("journey-battle")
	assert(game.store.settle(game.store.profile.pending.id, false, 0))
	game._return_to_camp()
	assert(screen() is JourneyScreen)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.3).timeout
	game.queue_free()
	await process_frame
	print("PASS: real chapter progress/rewards, story codes, auto unlock, AFK transaction and battle/home layouts")
	quit()
