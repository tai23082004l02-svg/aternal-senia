extends SceneTree

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/visual_movie_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func run() -> void:
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	await create_timer(1).timeout
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1, 2, 3, 4, 5]
	p.heroes.lyra.level = 8
	p.assists.lumi = 6
	p.expansion.ranks.lumi = 2
	assert(game.store.commit(p))
	for hero in ["ryn", "mira", "lyra"]:
		game._hero(hero)
		game._select_tab(1)
		await create_timer(1.2).timeout
	game._bag_open("equipment")
	await create_timer(1.2).timeout
	game._select_tab(21)
	await create_timer(1.2).timeout
	game._enter_stage(103)
	await create_timer(1).timeout
	game._begin()
	for tick in range(12000):
		var b: BattleModel = game.battle
		if b.state != "battle": break
		if b.enemy_clock > 2.45: b.guard()
		if b.hp < b.stats.hp * .65: b.skill(1)
		elif not b.warning().begins_with("PHẢN"):
			b.skill(2)
			b.skill(0)
		await physics_frame
	assert(game.battle.state == "won")
	await create_timer(1.6).timeout
	assert(game.store.profile.expansion.records.has("103"))
	game.audio.shutdown()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: integrated graphics showcase, four heroes, real three-boss combat and result")
	quit()
