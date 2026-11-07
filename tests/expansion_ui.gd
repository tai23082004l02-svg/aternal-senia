extends SceneTree

var game
var output := "/workspace/work/expansion/previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/expansion_ui_%d" % Time.get_ticks_usec()))
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
	game._select_tab(5)
	await capture("01-locked-expeditions")
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 3000
	p.shards = 50
	p.cleared = [1, 2, 3, 4, 5]
	p.heroes.eira.level = 4
	p.assists.lumi = 6
	p.expansion.cores = 10
	assert(game.store.commit(p))
	game._talent("breaker")
	game._talent("barrier")
	game._talent("flow")
	game._select_tab(6)
	await capture("02-skill-tree")
	game._rank_assist()
	game._select_tab(7)
	await capture("03-companions")
	game._select_tab(8)
	await capture("04-collection")
	game._select_tab(5)
	await capture("05-expeditions")
	game.scroll.scroll_vertical = 820
	await capture("10-story-branches")
	game._enter_stage(6)
	await capture("11-branch-intro")
	game._close_modal()
	game._enter_stage(103)
	await capture("06-challenge-intro")
	game._begin()
	assert(game.tab == 0 and game.battle.wave_count() == 3 and game.battle.is_boss())
	for tick in range(36000):
		var b: BattleModel = game.battle
		if b.state != "battle": break
		if b.enemy_clock > 2.45: b.guard()
		if b.hp < b.stats.hp * .65: b.skill(1)
		elif not b.warning().begins_with("PHẢN"):
			b.skill(2)
			b.skill(0)
		if tick == 45: await capture("07-boss-rush")
		await physics_frame
	assert(game.battle.state == "won")
	await create_timer(.8).timeout
	assert(game.store.profile.expansion.records.has("103"))
	await capture("08-trial-reward")
	game._return_to_camp()
	game._select_tab(5)
	await capture("09-record")
	game.audio.shutdown()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: expansion screens, talent selection, evolution, real boss-rush battle, reward and persisted record")
	quit()
