extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/progression_ui_%d" % Time.get_ticks_usec()))
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
	p.gold = 10000
	p.xp = 10000
	p.shards = 100
	p.heroes.eira.level = 10
	p.assists.lumi = 6
	p.recruitment = Recruitment.fresh()
	p.recruitment.fragments.eira = 30
	assert(game.store.commit(p))
	game._select_tab(12)
	game._batch_level()
	assert(game.store.profile.heroes.eira.level == 15)
	game._awaken()
	assert(game.store.profile.recruitment.awakening.eira == 2)
	await capture("hero-upgrade")
	game._select_tab(6)
	game._talent("focus")
	await capture("hero-skill-tree")
	game._select_tab(13)
	game._spirit_talent("flow")
	game._spirit_talent("echo")
	assert(game.store.profile.expansion.spirit_skills.lumi.advanced == "echo")
	await capture("spirit-skill-tree")
	game._select_tab(11)
	await capture("summoning")
	game._summon()
	assert(game.store.profile.recruitment.count == 1 and game.modal != null)
	await create_timer(.3).timeout
	await capture("summon-result")
	game._close_modal()
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: upgrade, awakening, two trees, rarity pools and summon result rendered")
	quit()
