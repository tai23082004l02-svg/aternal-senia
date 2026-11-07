extends SceneTree

var game
var output := "user://first_light_previews"
var serial := 0

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/combat_scenarios_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func fixture(stage: int = 1) -> void:
	serial += 1
	var model := BattleModel.new(game.catalog)
	model.start({"id": "scenario_%d" % serial, "stage": stage, "seed": 7, "stats": game.catalog.stats(game.store.profile)})
	model.wave = 2
	model._spawn()
	model.auto_attack = false
	game.battle = model
	game.selected_stage = stage
	game.view.battle = model
	game.audio.begin_run(model.run.id)
	game._refresh_panel()
	game.view._process(0)

func sim(seconds: float) -> void:
	for i in range(ceili(seconds / BattleModel.STEP)):
		game.battle.advance(BattleModel.STEP)
		game.view._process(BattleModel.STEP)
	game._refresh_hud()

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func run() -> void:
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		output = dir
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	game.set_physics_process(false)
	fixture()
	game.battle.attack_clock = .9
	assert(game.battle.attack())
	sim(.25)
	await capture("12-sword-impact")
	fixture()
	assert(game.battle.skill(2))
	sim(.55)
	await capture("13-dawn-burst")
	fixture()
	game.battle.hp = 80
	assert(game.battle.skill(1))
	sim(.55)
	await capture("14-healing")
	fixture()
	sim(2.78)
	await capture("15-boss-telegraph")
	fixture()
	sim(2.45)
	assert(game.battle.guard())
	sim(.6)
	await capture("16-guard-and-slam")
	fixture(2)
	sim(.04)
	assert(game.battle.shield)
	await capture("17-enemy-shield")
	assert(game.battle.skill(2))
	sim(.55)
	assert(game.battle.shield_broken)
	await capture("18-shield-shatter")
	fixture(3)
	sim(2.05)
	assert(game.battle.skill(0))
	sim(.30)
	await capture("19-counter")
	fixture()
	game.battle._take_damage(9999)
	sim(.4)
	await capture("20-defeat-pose")
	game.audio.shutdown()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: rendered slash/burst/heal/telegraph/guard/slam/shield/shatter/counter/defeat scenarios")
	quit()
