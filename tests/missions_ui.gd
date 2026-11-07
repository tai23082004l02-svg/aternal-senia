extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/missions_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	game._select_tab(3)
	var original: Dictionary = game.store.profile.duplicate(true)
	for i in range(3):
		game._mission_tab(i)
		assert(game.panel.get_child(0) is MissionScreen)
		await capture(["missions-daily", "missions-weekly", "missions-progress"][i])
	assert(game.store.profile == original)
	var p: Dictionary = original.duplicate(true)
	for event in ["offline", "wins", "kills"]: MissionBoard.record(p, event, 100)
	assert(game.store.commit(p))
	game._mission_tab(0)
	await capture("missions-active")
	game._mission_chest("daily", 60)
	await capture("missions-chest")
	game._mission_claim_chest("daily", 60)
	assert(game.store.profile.gold == 60)
	game._mission_claim("daily", "wins")
	assert(game.store.profile.missions.vip_exp == 5)
	game._refresh_hud()
	assert("5 EXP" in game.profile_vip.text)
	game._show_player_profile()
	await capture("missions-vip-exp")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.3).timeout
	game.queue_free()
	await process_frame
	print("PASS: three mission tabs, activity/chests, atomic claims, earned VIP EXP profile")
	quit()
