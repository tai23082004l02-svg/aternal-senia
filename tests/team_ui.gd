extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/team_ui_%d" % Time.get_ticks_usec()))
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
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1,2]
	p.hero = "ryn"
	p.assist = "ash"
	p.formation = {"slots":["ryn","mira","eira"],"auto_ult":false,"auto_next":false}
	assert(game.store.commit(p))
	game._select_tab(22)
	await capture("formation")
	game._formation_assign(1, "eira")
	assert(game.store.profile.formation.slots == ["ryn","eira","mira"])
	game._formation_assign(1, "mira")
	game.selected_stage = 6
	game._begin()
	assert(game.battle is TeamBattle and game.team_ui != null)
	game.battle.wave = 0
	game.battle._spawn()
	game.battle.paused = true
	await capture("team-3v3")
	assert(game.team_ui.visible and not game.view.visible and not game.scroll.visible)
	assert(game.battle.allies.size() == 3 and game.battle.enemies.size() == 3)
	assert(not Formation.assign(game.store, 0, "eira"))
	game.battle.allies[0].energy = 100
	assert(not game.battle.ultimate(0)) # Paused.
	game.battle.paused = false
	game.team_ui._ultimate(0)
	assert(not game.battle.allies[0].action.is_empty())
	game._speed()
	assert(game.battle.speed == 2)
	game._speed()
	assert(game.battle.speed == 1)
	game.team_ui._auto()
	assert(game.battle.auto_ultimate)
	game.battle.wave = game.battle.wave_count() - 1
	game.battle._spawn()
	game.battle.enemies[0].hp = game.battle.enemies[0].max_hp * .49
	game.battle.advance(.1)
	game.battle.paused = true
	await capture("team-boss-adds")
	assert(game.battle.enemies.size() == 3)
	game._select_tab(22)
	await capture("formation-locked")
	assert(game.battle.paused)
	game._select_tab(0)
	game.battle.paused = true
	# Return to preview, then resume an actual old singleton pending snapshot.
	assert(game.store.settle(game.battle.run.id, false, 0))
	game._return_to_camp()
	var legacy: Dictionary = game.store.profile.duplicate(true)
	legacy.pending = {"id":"legacy_ui", "stage":1, "seed":17, "stats":game.catalog.stats(legacy)}
	assert(game.store.commit(legacy))
	game._resume()
	assert(not game.battle is TeamBattle and game.view.visible)
	assert(game.store.settle("legacy_ui", false, 0))
	game._return_to_camp()
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.3).timeout
	game.queue_free()
	await process_frame
	print("PASS: formation/swap/lock, painted 3v3/boss adds, ultimate, x1/x2 and legacy singleton resume UI")
	quit()
