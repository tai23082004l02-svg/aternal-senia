extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/visual_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func run() -> void:
	if not OS.get_environment("FIRST_LIGHT_CAPTURE_DIR").is_empty(): output = OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	await capture("home")
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 1800
	p.shards = 40
	p.cleared = [1, 2, 3, 4, 5]
	p.seen_story = ["1_before", "1_after", "2_before", "2_after"]
	p.heroes.eira.level = 4
	p.assists.lumi = 6
	p.expansion.cores = 7
	assert(game.store.commit(p))
	for page in [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 13, 15, 20, 21]:
		game._select_tab(page)
		await capture("menu-%d" % page)
	game._bag_open("equipment")
	await capture("equipment-grid")
	game._item_detail("starter_eira")
	await capture("equipment-detail")
	game._select_tab(5)
	game.scroll.scroll_vertical = 1000
	await capture("chapters")
	game._select_tab(6)
	game._talent("breaker")
	await capture("talent-selected")
	game._select_tab(0)
	for hero in ["ryn", "mira", "lyra"]:
		game._hero(hero)
		game._select_tab(1)
		await capture(hero + "-profile")
		game._select_tab(0)
		await capture(hero + "-home")
	game._assist("ash")
	for id in range(1, 6):
		game._choose_stage(id)
		game._enter_stage(id)
		await capture("story-%d" % id)
		game._begin()
		game.set_physics_process(false)
		game.battle.wave = 2
		game.battle._spawn()
		game.battle.auto_attack = false
		for tick in range(132): game.battle.advance(1.0 / 60)
		game._refresh_hud()
		await capture("world-%d" % id)
		assert(game.store.settle(game.battle.run.id, false, 0, game.battle.time))
		game._return_to_camp()
	game._audio_settings()
	await capture("sound-settings")
	game._cancel_audio_settings()
	game.audio.shutdown()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: home, all feature menus, equipment, four hero profiles, five worlds/bosses, story and sound settings rendered")
	quit()
