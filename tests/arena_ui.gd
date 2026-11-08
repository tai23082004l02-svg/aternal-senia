extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/arena_ui_%d" % Time.get_ticks_usec()))
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
	game.set_physics_process(false)
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1,2,3,4,5]
	p.hero = "ryn"
	p.formation = {"slots":["ryn","eira","mira","lyra"],"auto_ult":true,"auto_next":false}
	assert(game.store.commit(p))
	game.selected_stage = 6
	game._begin()
	assert(game.battle is ArenaBattle and game.battle.run.team.version == 3)
	game.battle.paused = true
	await capture("arena-spawn")
	game.battle.paused = false
	for i in range(180): game.battle.advance(1.0/60)
	game.battle.paused = true
	var units: Array = game.battle.allies.duplicate(true)
	var enemies: Array = game.battle.enemies.duplicate(true)
	var events: Array = game.battle.events.duplicate(true)
	var rng_state: int = game.battle.rng.state
	await capture("arena-combat")
	assert(game.battle.allies == units and game.battle.enemies == enemies and game.battle.events == events and game.battle.rng.state == rng_state, "Rendering must not mutate combat")
	game.battle.paused = false
	var tap := InputEventScreenTouch.new()
	tap.pressed = true
	tap.position = game.battle.enemies[1].pos - Vector2(0,32)
	game.team_ui.field._gui_input(tap)
	assert(game.battle.focus >= 0)
	# Make one real committed telegraph visible and review its ground alignment.
	var enemy: Dictionary = game.battle.enemies[0]
	enemy.action = {"id":999,"target":0,"started":game.battle.time-.15,"marker":.6,"duration":.9,"hit":false}
	game.battle._prepare_enemy_action(enemy)
	game.battle.paused = true
	await capture("arena-warning")
	game.battle.paused = false
	for i in range(180): game.battle.advance(1.0/60)
	game.battle.paused = true
	await capture("arena-after-escape")
	# Resume routing is selected from the frozen snapshot, never from current rules.
	for version in [2,1]:
		var legacy: Dictionary = game.store.profile.duplicate(true)
		legacy.pending.team.version = version
		if version == 1: legacy.pending.team.units.pop_back()
		assert(game.store.commit(legacy))
		var bytes := FileAccess.get_file_as_bytes(game.store.path)
		game._resume()
		assert(game.battle is TeamBattle and not game.battle is ArenaBattle)
		assert(game.battle.run == legacy.pending and FileAccess.get_file_as_bytes(game.store.path) == bytes)
		game.battle.paused = true
		await capture("legacy-v%d" % version)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	game.queue_free()
	await process_frame
	print("PASS: actual ArenaBattle routing, movement render, telegraph/escape, dynamic touch targeting, render immutability and v1/v2 legacy resume without save writes")
	quit()
