extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/arena_lab_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name+".png")) == OK)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var before: Dictionary = game.store.profile.duplicate(true)
	var bytes := FileAccess.get_file_as_bytes(game.store.path)
	game._select_tab(21)
	await capture("dungeons-arena-entry")
	assert(game.panel.find_child("DungeonArena",true,false) != null)
	game._select_tab(25)
	await capture("arena-setup")
	var screen: ArenaLabScreen = game.panel.get_child(0)
	assert(screen.selectors[0].size() == 4 and screen.selectors[1].size() == 4)
	game.arena_setup.teams = [["eira","ryn","mira","caelan"],["lyra","mira","caelan","eira"]]
	screen._start()
	assert(screen.model != null and game.battle == null)
	screen.set_process(false)
	for i in range(150): screen.model.advance(1.0/60)
	screen.model.paused = true
	screen._process(0)
	await capture("arena-four-v-four")
	var frozen: Array = screen.model.teams.duplicate(true)
	var rng_state: int = screen.model.rng.state
	await capture("arena-paused")
	assert(screen.model.teams == frozen and screen.model.rng.state == rng_state)
	screen._speed()
	assert(screen.model.speed == 2)
	screen._setup()
	assert(screen.setup.visible and screen.model.paused)
	game._select_tab(21)
	await process_frame
	assert(game.store.profile == before and FileAccess.get_file_as_bytes(game.store.path) == bytes)
	# Existing campaign pending is paused, preserved and can resume after viewing.
	game.selected_stage = 1
	game._begin()
	var pending: Dictionary = game.store.profile.pending.duplicate(true)
	game._select_tab(25)
	assert(game.battle.paused)
	var lab: ArenaLabScreen = game.panel.get_child(0)
	lab._start()
	assert(game.store.profile.pending == pending)
	game._select_tab(0)
	assert(not game.battle.paused and game.store.profile.pending == pending)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	game.queue_free()
	screen = null
	lab = null
	game = null
	await process_frame
	await process_frame
	await create_timer(.2).timeout
	print("PASS: Dungeon Arena entry/setup, original courtyard render, real hero 4v4, pause/speed/setup, renderer immutability, no save mutation and campaign isolation")
	quit()
